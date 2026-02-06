import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/auth_provider.dart';
import '../../cubit/driver/add_load/add_load_bloc.dart';
import '../../cubit/driver/add_load/add_load_event.dart';
import '../../cubit/driver/add_load/add_load_state.dart';
import 'map_location_picker_screen.dart';
import 'route_map_screen.dart';

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

  double? _originLatitude;
  double? _originLongitude;
  double? _destinationLatitude;
  double? _destinationLongitude;
  List<Map<String, double>>? _routePolylinePoints;

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

  Future<void> _selectOriginLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          title: 'Select Origin Location',
          initialLocation: _originLatitude != null && _originLongitude != null
              ? LatLng(_originLatitude!, _originLongitude!)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _originController.text = result['address'] as String;
        _originLatitude = result['latitude'] as double;
        _originLongitude = result['longitude'] as double;
      });
    }
  }

  Future<void> _selectDestinationLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          title: 'Select Destination Location',
          initialLocation:
              _destinationLatitude != null && _destinationLongitude != null
                  ? LatLng(_destinationLatitude!, _destinationLongitude!)
                  : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _destinationController.text = result['address'] as String;
        _destinationLatitude = result['latitude'] as double;
        _destinationLongitude = result['longitude'] as double;
      });
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

      if (_originLatitude == null || _originLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select origin location from map')),
        );
        return;
      }

      if (_destinationLatitude == null || _destinationLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select destination location from map')),
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
              availableTimeStart: _availableTimeStart!,
              availableTimeEnd: _availableTimeEnd!,
              pickupLat: _originLatitude!,
              pickupLng: _originLongitude!,
              dropLat: _destinationLatitude!,
              dropLng: _destinationLongitude!,
              pickupAddress: _originController.text.trim(),
              dropAddress: _destinationController.text.trim(),
              price: 0,
              routePolylinePoints: _routePolylinePoints,
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
            // Show toast message with green background
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            // Navigate to driver dashboard
            context.go('/driver-dashboard');
          } else if (state is AddLoadError) {
            Fluttertoast.showToast(
              msg: state.error,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
        child: BlocBuilder<AddLoadBloc, AddLoadState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                                          child: Text(vehicle.vehicleNumber),
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
                                readOnly: true,
                                onTap: _selectOriginLocation,
                                decoration: const InputDecoration(
                                  labelText: 'Origin',
                                  hintText: 'Tap to select pickup location',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_on),
                                  suffixIcon: Icon(Icons.map),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please select origin location';
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
                                readOnly: true,
                                onTap: _selectDestinationLocation,
                                decoration: const InputDecoration(
                                  labelText: 'Destination',
                                  hintText: 'Tap to select drop-off location',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.flag),
                                  suffixIcon: Icon(Icons.map),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please select destination location';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Check Distance Button
                          if (_originLatitude != null &&
                              _originLongitude != null &&
                              _destinationLatitude != null &&
                              _destinationLongitude != null)
                            Card(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RouteMapScreen(
                                        originLat: _originLatitude!,
                                        originLng: _originLongitude!,
                                        destinationLat: _destinationLatitude!,
                                        destinationLng: _destinationLongitude!,
                                        originAddress: _originController.text,
                                        destinationAddress: _destinationController.text,
                                      ),
                                    ),
                                  );

                                  // Store the polyline points from the selected route
                                  if (result != null && result['polyline_points'] != null) {
                                    setState(() {
                                      _routePolylinePoints = List<Map<String, double>>.from(
                                        (result['polyline_points'] as List).map((point) => {
                                          'latitude': (point['latitude'] as num).toDouble(),
                                          'longitude': (point['longitude'] as num).toDouble(),
                                        }),
                                      );
                                    });

                                    // Show confirmation to user
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Route selected: ${result['distance_text']} in ${result['duration_text']}',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.route,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Check Distance & Route',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_originLatitude != null &&
                              _originLongitude != null &&
                              _destinationLatitude != null &&
                              _destinationLongitude != null)
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
                        ],
                      ),
                    ),
                  ),
                ),
                // Fixed Submit Button at bottom
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state is AddLoadLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
