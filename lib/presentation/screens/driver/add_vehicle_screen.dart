import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/dependency_injection.dart';
import '../../../domain/repository/driver_repository.dart';
import '../../cubit/driver/add_vehicle/add_vehicle_bloc.dart';
import '../../cubit/driver/add_vehicle/add_vehicle_event.dart';
import '../../cubit/driver/add_vehicle/add_vehicle_state.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberPlateController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _numberOfWheelsController = TextEditingController();

  // Capacity options
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

  // Body cover type options
  final List<Map<String, String>> _bodyCoverTypeOptions = [
    {'value': 'Open', 'label': 'Open'},
    {'value': 'Closed', 'label': 'Closed'},
    {'value': 'SemiClosed', 'label': 'Semi-Closed'},
  ];

  @override
  void dispose() {
    _vehicleNumberPlateController.dispose();
    _chassisNumberController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _numberOfWheelsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = AddVehicleBloc(context, getIt<DriverRepository>());
        // Load documents when screen initializes
        bloc.add(LoadDocuments());
        return bloc;
      },
      child: BlocConsumer<AddVehicleBloc, AddVehicleState>(
        listener: (context, state) {
          if (state is VehicleAddedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to previous screen or vehicle list
            context.pop();
          } else if (state is VehicleAdditionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Add Vehicle'),
              elevation: 0,
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
                        'Vehicle Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please enter your vehicle details',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                      const SizedBox(height: 30),

                      // Vehicle Number Plate
                      TextFormField(
                        controller: _vehicleNumberPlateController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Number Plate',
                          hintText: 'e.g., KA01AB1234',
                          prefixIcon: Icon(Icons.local_shipping_outlined),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateVehicleNumberPlate(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // RC Number Dropdown
                      state.isLoadingDocuments
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : (state.rcDocuments == null || state.rcDocuments!.isEmpty)
                              ? Card(
                                  color: Colors.orange.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'No RC documents found. Please upload your RC document first.',
                                            style: TextStyle(color: Colors.orange.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'RC Number',
                                    hintText: 'Select Registration Certificate',
                                    prefixIcon: Icon(Icons.description_outlined),
                                  ),
                                  value: state.rcNumber,
                                  items: state.rcDocuments!.map((doc) {
                                    return DropdownMenuItem<String>(
                                      value: doc.documentNumber,
                                      child: Text(doc.documentNumber),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<AddVehicleBloc>().add(UpdateRcNumber(value));
                                    }
                                  },
                                ),
                      const SizedBox(height: 20),

                      // Chassis Number
                      TextFormField(
                        controller: _chassisNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Chassis Number',
                          hintText: 'Vehicle Chassis Number',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateChassisNumber(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // Body Cover Type Dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Body Cover Type',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        value: state.bodyCoverType,
                        items: _bodyCoverTypeOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<AddVehicleBloc>().add(UpdateBodyCoverType(value));
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Capacity Dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Capacity',
                          prefixIcon: Icon(Icons.scale_outlined),
                        ),
                        value: state.capacity,
                        items: _capacityOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<AddVehicleBloc>().add(UpdateCapacity(value));
                          }
                        },
                      ),
                      const SizedBox(height: 30),

                      // Vehicle Dimensions Section
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
                        decoration: const InputDecoration(
                          labelText: 'Length (meters)',
                          hintText: 'Max 18.75m (e.g., 6.1)',
                          helperText: 'Maximum: 18.75 meters',
                          prefixIcon: Icon(Icons.straighten_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateLength(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // Width
                      TextFormField(
                        controller: _widthController,
                        decoration: const InputDecoration(
                          labelText: 'Width (meters)',
                          hintText: 'Max 2.6m (e.g., 2.5)',
                          helperText: 'Maximum: 2.6 meters',
                          prefixIcon: Icon(Icons.width_normal_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateWidth(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // Height
                      TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height (meters)',
                          hintText: 'Max 4.75m (e.g., 4.0)',
                          helperText: 'Maximum: 4.75 meters',
                          prefixIcon: Icon(Icons.height_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateHeight(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // Number of Wheels
                      TextFormField(
                        controller: _numberOfWheelsController,
                        decoration: const InputDecoration(
                          labelText: 'Number of Wheels',
                          hintText: 'e.g., 4, 6, 10, 12',
                          helperText: 'Common: 4 (car), 6 (small truck), 10-12 (large truck)',
                          prefixIcon: Icon(Icons.settings_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateNumberOfWheels(value));
                        },
                      ),
                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AddVehicleLoading
                              ? null
                              : () {
                                  context.read<AddVehicleBloc>().add(SubmitVehicle());
                                },
                          child: state is AddVehicleLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Add Vehicle'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
