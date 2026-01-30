import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/dependency_injection.dart';
import '../../../domain/repository/driver_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../cubit/driver/vehicle_list/vehicle_list_bloc.dart';
import '../../cubit/driver/vehicle_list/vehicle_list_event.dart';
import '../../cubit/driver/vehicle_list/vehicle_list_state.dart';

class ShowVehicleScreen extends StatelessWidget {
  const ShowVehicleScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    String vehicleId,
    String vehicleNumber,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text(
            'Are you sure you want to delete vehicle $vehicleNumber?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<VehicleListBloc>().add(
                      DeleteVehicle(vehicleId: vehicleId),
                    );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final driverId = authProvider.currentUser?.id ?? '';

    return BlocProvider(
      create: (context) {
        final bloc = VehicleListBloc(context, getIt<DriverRepository>());
        // Fetch vehicles on initialization
        if (driverId.isNotEmpty) {
          bloc.add(FetchVehicles(driverId: driverId));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Vehicles'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Vehicle',
              onPressed: () {
                context.push('/add-vehicle');
              },
            ),
          ],
        ),
        body: BlocConsumer<VehicleListBloc, VehicleListState>(
          listener: (context, state) {
            if (state is VehicleDeletedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is VehicleDeletionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is VehicleListError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is VehicleListLoading && state.vehicles.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.vehicles.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (driverId.isNotEmpty) {
                  context.read<VehicleListBloc>().add(
                        RefreshVehicles(driverId: driverId),
                      );
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = state.vehicles[index];
                  return _buildVehicleCard(context, vehicle);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Vehicles Added',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first vehicle to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/add-vehicle');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleModel vehicle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Vehicle Number Plate and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vehicle.vehicleNumber.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (vehicle.status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: vehicle.isVerified
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vehicle.status!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: vehicle.isVerified ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(
                      context,
                      vehicle.vehicleId,
                      vehicle.vehicleNumber,
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 24),

            // Vehicle Details
            _buildDetailRow(
              context,
              Icons.scale_outlined,
              'Capacity',
              vehicle.getCapacityLabel(),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.tire_repair_outlined,
              'Number of Wheels',
              vehicle.numberOfWheels.toString(),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.pin_outlined,
              'Chassis Number',
              vehicle.chassisNumber,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.local_shipping_outlined,
              'Body Cover Type',
              vehicle.bodyCoverTypeLabel,
            ),
            const SizedBox(height: 12),

            // Dimensions Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dimensions (ft)',
                    style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDimensionChip(context, 'L', vehicle.length),
                      _buildDimensionChip(context, 'W', vehicle.width),
                      _buildDimensionChip(context, 'H', vehicle.height),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionChip(BuildContext context, String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }
}
