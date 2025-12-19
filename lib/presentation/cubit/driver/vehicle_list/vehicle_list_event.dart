import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Vehicle List feature
class VehicleListEvent extends BaseEventState {}

// Fetch all vehicles for a driver
class FetchVehicles extends VehicleListEvent {
  final String driverId;

  FetchVehicles({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

// Refresh vehicle list
class RefreshVehicles extends VehicleListEvent {
  final String driverId;

  RefreshVehicles({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

// Delete a vehicle
class DeleteVehicle extends VehicleListEvent {
  final String vehicleId;

  DeleteVehicle({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
