import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/repository/trip_repository.dart';
import '../../../services/local/storage_service.dart';
import '../../cubit/trip/trip_request_bloc.dart';
import '../../cubit/trip/trip_request_event.dart';
import '../../cubit/trip/trip_request_state.dart';

class TripRequestScreen extends StatelessWidget {
  const TripRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TripRequestBloc(context, context.read<TripRepository>()),
      child: const _TripRequestScreenContent(),
    );
  }
}

class _TripRequestScreenContent extends StatefulWidget {
  const _TripRequestScreenContent();

  @override
  State<_TripRequestScreenContent> createState() =>
      _TripRequestScreenContentState();
}

class _TripRequestScreenContentState extends State<_TripRequestScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _loadCapacityController = TextEditingController();

  String _selectedVehicleType = 'Mini Truck';
  DateTime? _scheduledDate;
  bool _needsInsurance = false;

  final List<String> _vehicleTypes = [
    'Mini Truck',
    'Pickup',
    'Small Truck',
    'Medium Truck',
    'Large Truck',
    'Container',
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _loadCapacityController.dispose();
    super.dispose();
  }

  Future<void> _selectScheduledDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Validate scheduled date
      if (_scheduledDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a scheduled date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get user ID from storage
      final userIdFromStorage = StorageService.getString('userId');
      if (userIdFromStorage == null || userIdFromStorage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Trigger the SubmitTripRequest event
      context.read<TripRequestBloc>().add(
        SubmitTripRequest(
          userId: userIdFromStorage,
          pickupLocation: _pickupController.text,
          dropLocation: _dropController.text,
          vehicleType: _selectedVehicleType,
          loadCapacity: _loadCapacityController.text,
          scheduledDate: _scheduledDate,
          needsInsurance: _needsInsurance,
          pickupLat: 0.0,
          pickupLng: 0.0,
          dropLat: 0.0,
          dropLng: 0.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripRequestBloc, TripRequestStates>(
      listener: (context, state) {
        // Handle trip request success
        if (state is OnTripRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate based on insurance option
          if (state.needsInsurance) {
            context.push('/insurance', extra: state.tripId);
          } else {
            context.go('/customer-dashboard');
          }
        }

        // Handle trip request error
        if (state is OnTripRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Request Load'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _pickupController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dropController,
                    decoration: const InputDecoration(
                      labelText: 'Drop Location',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter drop location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedVehicleType,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type',
                      prefixIcon: Icon(Icons.local_shipping_outlined),
                    ),
                    items: _vehicleTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _loadCapacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Load Capacity (in Tons)',
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter load capacity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectScheduledDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Scheduled Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _scheduledDate != null
                            ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    value: _needsInsurance,
                    onChanged: (value) {
                      setState(() {
                        _needsInsurance = value ?? false;
                      });
                    },
                    title: const Text('Add Insurance for this load'),
                    subtitle: const Text('Protect your goods during transit'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Cost',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹12,500',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  BlocBuilder<TripRequestBloc, TripRequestStates>(
                    builder: (context, state) {
                      final isLoading = state is OnLoading;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitRequest,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Submit Request'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
