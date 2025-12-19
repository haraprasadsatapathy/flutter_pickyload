import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../cubit/driver/add_load/add_load_bloc.dart';
import '../../cubit/driver/add_load/add_load_event.dart';
import '../../cubit/driver/add_load/add_load_state.dart';

class AddLoadScreen extends StatefulWidget {
  const AddLoadScreen({super.key});

  @override
  State<AddLoadScreen> createState() => _AddLoadScreenState();
}

class _AddLoadScreenState extends State<AddLoadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  String? _selectedVehicleId;
  DateTime? _availableTimeStart;
  DateTime? _availableTimeEnd;

  @override
  void initState() {
    super.initState();
    // Fetch driver's vehicles when screen loads
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverId = authProvider.currentUser?.id ?? '';
    context.read<AddLoadBloc>().add(FetchDriverVehicles(driverId: driverId));
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            _availableTimeStart = selectedDateTime;
          } else {
            _availableTimeEnd = selectedDateTime;
          }
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a vehicle')),
        );
        return;
      }

      if (_availableTimeStart == null || _availableTimeEnd == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select availability times')),
        );
        return;
      }

      if (_availableTimeEnd!.isBefore(_availableTimeStart!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final driverId = authProvider.currentUser?.id ?? '';

      context.read<AddLoadBloc>().add(
            SubmitLoadOffer(
              driverId: driverId,
              vehicleId: _selectedVehicleId!,
              origin: _originController.text.trim(),
              destination: _destinationController.text.trim(),
              availableTimeStart: _availableTimeStart!,
              availableTimeEnd: _availableTimeEnd!,
            ),
          );
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not selected';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Load Offer'),
      ),
      body: BlocListener<AddLoadBloc, AddLoadState>(
        listener: (context, state) {
          if (state is LoadOfferSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Navigate to home screen after successful submission
            Future.delayed(const Duration(milliseconds: 500), () {
              context.go('/driver-dashboard');
            });
          } else if (state is AddLoadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AddLoadBloc, AddLoadState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vehicle Selection Dropdown
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Vehicle',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            if (state is AddLoadLoading && state.vehicles.isEmpty)
                              const Center(child: CircularProgressIndicator())
                            else if (state.vehicles.isEmpty)
                              const Text('No vehicles available. Please add a vehicle first.')
                            else
                              DropdownButtonFormField<String>(
                                value: _selectedVehicleId,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle',
                                  border: OutlineInputBorder(),
                                ),
                                items: state.vehicles.map((vehicle) {
                                  return DropdownMenuItem<String>(
                                    value: vehicle.vehicleId,
                                    child: Text(vehicle.displayName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVehicleId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a vehicle';
                                  }
                                  return null;
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Origin
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller: _originController,
                          decoration: const InputDecoration(
                            labelText: 'Origin',
                            hintText: 'Enter pickup location',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter origin location';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Destination
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            labelText: 'Destination',
                            hintText: 'Enter drop-off location',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.flag),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter destination location';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Available Time Start
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available From',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.calendar_today),
                              title: Text(_formatDateTime(_availableTimeStart)),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _selectDateTime(context, true),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Available Time End
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Until',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.calendar_today),
                              title: Text(_formatDateTime(_availableTimeEnd)),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _selectDateTime(context, false),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: state is AddLoadLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state is AddLoadLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Load Offer',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
