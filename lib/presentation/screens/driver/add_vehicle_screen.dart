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
  final _vehicleNumberController = TextEditingController();
  final _rcNumberController = TextEditingController();
  final _makeModelController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  // Capacity options
  final List<Map<String, String>> _capacityOptions = [
    {'value': 'upto_half_tonne', 'label': 'Up to Half Tonne'},
    {'value': 'half_to_one_tonne', 'label': 'Half to One Tonne'},
    {'value': 'one_to_two_tonne', 'label': 'One to Two Tonne'},
    {'value': 'two_to_three_tonne', 'label': 'Two to Three Tonne'},
    {'value': 'above_three_tonne', 'label': 'Above Three Tonne'},
  ];

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _rcNumberController.dispose();
    _makeModelController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddVehicleBloc(context, getIt<DriverRepository>()),
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

                      // Vehicle Number
                      TextFormField(
                        controller: _vehicleNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Number',
                          hintText: 'e.g., KA01AB1234',
                          prefixIcon: Icon(Icons.local_shipping_outlined),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateVehicleNumber(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // RC Number
                      TextFormField(
                        controller: _rcNumberController,
                        decoration: const InputDecoration(
                          labelText: 'RC Number',
                          hintText: 'Registration Certificate Number',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateRcNumber(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // Make/Model
                      TextFormField(
                        controller: _makeModelController,
                        decoration: const InputDecoration(
                          labelText: 'Make/Model',
                          hintText: 'e.g., Tata Ace, Mahindra Bolero',
                          prefixIcon: Icon(Icons.directions_car_outlined),
                        ),
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateMakeModel(value));
                        },
                      ),
                      const SizedBox(height: 20),

                      // Capacity Dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Capacity',
                          prefixIcon: Icon(Icons.scale_outlined),
                        ),
                        initialValue: state.capacity,
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
                      const SizedBox(height: 20),

                      // Vehicle Body Covered Switch
                      Card(
                        child: SwitchListTile(
                          title: const Text('Vehicle Body Covered'),
                          subtitle: const Text('Does your vehicle have a covered body?'),
                          value: state.isVehicleBodyCovered,
                          onChanged: (value) {
                            context.read<AddVehicleBloc>().add(UpdateVehicleBodyCovered(value));
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Vehicle Dimensions Section
                      Text(
                        'Vehicle Dimensions (in cm)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Length
                      TextFormField(
                        controller: _lengthController,
                        decoration: const InputDecoration(
                          labelText: 'Length (cm)',
                          hintText: 'e.g., 100',
                          prefixIcon: Icon(Icons.straighten_outlined),
                        ),
                        keyboardType: TextInputType.number,
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
                          labelText: 'Width (cm)',
                          hintText: 'e.g., 100',
                          prefixIcon: Icon(Icons.width_normal_outlined),
                        ),
                        keyboardType: TextInputType.number,
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
                          labelText: 'Height (cm)',
                          hintText: 'e.g., 100',
                          prefixIcon: Icon(Icons.height_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (value) {
                          context.read<AddVehicleBloc>().add(UpdateHeight(value));
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
