import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/repository/trip_repository.dart';
import '../../../services/local/storage_service.dart';
import '../../cubit/trip/trip_request_bloc.dart';
import '../../cubit/trip/trip_request_event.dart';
import '../../cubit/trip/trip_request_state.dart';
import '../driver/map_location_picker_screen.dart';

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
  final _loadNameController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedLoadCapacity;
  String? _selectedBodyCoverType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  double? _pickupLatitude;
  double? _pickupLongitude;
  double? _dropLatitude;
  double? _dropLongitude;

  final List<Map<String, String>> _capacityOptions = [
    {'value': 'upto_half_tonne', 'label': 'Up to 0.5 Tonne'},
    {'value': 'upto_01_tonne', 'label': 'Up to 1 Tonne'},
    {'value': 'upto_05_tonne', 'label': 'Up to 5 Tonne'},
    {'value': 'upto_15_tonne', 'label': 'Up to 15 Tonne'},
    {'value': 'upto_25_tonne', 'label': 'Up to 25 Tonne'},
    {'value': 'upto_35_tonne', 'label': 'Up to 35 Tonne'},
    {'value': 'upto_45_tonne', 'label': 'Up to 45 Tonne'},
    {'value': 'upto_55_tonne', 'label': 'Up to 55 Tonne'},
  ];

  final List<Map<String, String>> _bodyCoverTypeOptions = [
    {'value': 'Open', 'label': 'Open'},
    {'value': 'Closed', 'label': 'Closed'},
    {'value': 'SemiClosed', 'label': 'Semi-Closed'},
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _loadNameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectPickupLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          title: 'Select Pickup Location',
          initialLocation: _pickupLatitude != null && _pickupLongitude != null
              ? LatLng(_pickupLatitude!, _pickupLongitude!)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _pickupController.text = result['address'] as String;
        _pickupLatitude = result['latitude'] as double;
        _pickupLongitude = result['longitude'] as double;
      });
    }
  }

  Future<void> _selectDropLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          title: 'Select Drop Location',
          initialLocation: _dropLatitude != null && _dropLongitude != null
              ? LatLng(_dropLatitude!, _dropLongitude!)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _dropController.text = result['address'] as String;
        _dropLatitude = result['latitude'] as double;
        _dropLongitude = result['longitude'] as double;
      });
    }
  }

  DateTime? _getPickupDateTime() {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_pickupLatitude == null || _pickupLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select pickup location from map'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_dropLatitude == null || _dropLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select drop location from map'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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

      final length = double.tryParse(_lengthController.text) ?? 0.0;
      final width = double.tryParse(_widthController.text) ?? 0.0;
      final height = double.tryParse(_heightController.text) ?? 0.0;

      // Calculate distance between pickup and drop locations
      final distance = _calculateDistance(
        _pickupLatitude!,
        _pickupLongitude!,
        _dropLatitude!,
        _dropLongitude!,
      );

      context.read<TripRequestBloc>().add(
        SubmitTripRequest(
          userId: userIdFromStorage,
          pickupLocation: _pickupController.text,
          dropLocation: _dropController.text,
          loadCapacity: _selectedLoadCapacity ?? '',
          bodyCoverType: _selectedBodyCoverType ?? '',
          loadName: _loadNameController.text,
          length: length,
          width: width,
          height: height,
          pickupTime: _getPickupDateTime(),
          pickupLat: _pickupLatitude!,
          pickupLng: _pickupLongitude!,
          dropLat: _dropLatitude!,
          dropLng: _dropLongitude!,
          distance: distance,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripRequestBloc, TripRequestStates>(
      listener: (context, state) {
        if (state is OnTripRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }

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

                  // Pickup Location
                  TextFormField(
                    controller: _pickupController,
                    readOnly: true,
                    onTap: _selectPickupLocation,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Location',
                      hintText: 'Tap to select pickup location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      suffixIcon: Icon(Icons.map),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select pickup location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Drop Location
                  TextFormField(
                    controller: _dropController,
                    readOnly: true,
                    onTap: _selectDropLocation,
                    decoration: const InputDecoration(
                      labelText: 'Drop Location',
                      hintText: 'Tap to select drop location',
                      prefixIcon: Icon(Icons.place_outlined),
                      suffixIcon: Icon(Icons.map),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select drop location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Load Capacity
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Load Capacity',
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                    initialValue: _selectedLoadCapacity,
                    items: _capacityOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Text(option['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLoadCapacity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select load capacity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Body Cover Type
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Body Cover Type',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    initialValue: _selectedBodyCoverType,
                    items: _bodyCoverTypeOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Text(option['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBodyCoverType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select body cover type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Load Name
                  TextFormField(
                    controller: _loadNameController,
                    decoration: const InputDecoration(
                      labelText: 'Load Name',
                      hintText: 'Enter load name (e.g., Furniture, Electronics)',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter load name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Dimensions Section
                  Text(
                    'Vehicle Dimensions (in meters)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Length
                  TextFormField(
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Length (m)',
                      hintText: 'Enter length',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter length';
                      }
                      final length = double.tryParse(value);
                      if (length == null || length <= 0) {
                        return 'Please enter a valid length';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Width
                  TextFormField(
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Width (m)',
                      hintText: 'Enter width',
                      prefixIcon: Icon(Icons.height),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter width';
                      }
                      final width = double.tryParse(value);
                      if (width == null || width <= 0) {
                        return 'Please enter a valid width';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Height
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (m)',
                      hintText: 'Enter height',
                      prefixIcon: Icon(Icons.height_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter height';
                      }
                      final height = double.tryParse(value);
                      if (height == null || height <= 0) {
                        return 'Please enter a valid height';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Pickup Time Section
                  Text(
                    'Pickup Schedule',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pickup Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Picker
                  InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pickup Time',
                        prefixIcon: Icon(Icons.access_time_outlined),
                      ),
                      child: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select time',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
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
