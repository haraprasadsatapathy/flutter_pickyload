import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/vehicle_list_response.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'vehicle_list_event.dart';
import 'vehicle_list_state.dart';

class VehicleListBloc extends Bloc<VehicleListEvent, VehicleListState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  VehicleListBloc(this.context, this.driverRepository) : super(VehicleListInitial()) {
    _registerEventHandlers();
  }

  List<VehicleModel> _mapVehicles(List<Vehicle> vehicles) {
    return vehicles
        .map((v) => VehicleModel(
              vehicleId: v.vehicleId,
              driverId: v.driverId,
              capacity: v.capacity,
              numberOfWheels: v.numberOfWheels,
              length: v.length,
              width: v.width,
              height: v.height,
              vehicleNumber: v.vehicleNumber,
              chassisNumber: v.chassisNumber,
              bodyCoverType: v.bodyCoverType,
              status: v.status,
              verifiedOn: v.verifiedOn,
              updatedOn: v.updatedOn,
            ))
        .toList();
  }

  void _registerEventHandlers() {
    // Fetch Vehicles
    on<FetchVehicles>((event, emit) async {
      emit(VehicleListLoading(vehicles: state.vehicles));

      try {
        // Call API to fetch vehicles
        final result = await driverRepository.getDriverVehicles(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          // Convert Vehicle objects to VehicleModel objects
          final vehicles = _mapVehicles(result.data!.vehicles);

          emit(VehicleListSuccess(
            message: result.data!.message,
            vehicles: vehicles,
          ));
        } else {
          emit(VehicleListError(
            error: result.message ?? 'Failed to load vehicles.',
            vehicles: state.vehicles,
          ));
        }
      } catch (e) {
        emit(VehicleListError(
          error: 'Failed to load vehicles: ${e.toString()}',
          vehicles: state.vehicles,
        ));
      }
    });

    // Refresh Vehicles
    on<RefreshVehicles>((event, emit) async {
      try {
        // Call API to refresh vehicles
        final result = await driverRepository.getDriverVehicles(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          final vehicles = _mapVehicles(result.data!.vehicles);

          emit(VehicleListSuccess(
            message: 'Vehicles refreshed',
            vehicles: vehicles,
          ));
        } else {
          emit(VehicleListError(
            error: result.message ?? 'Failed to refresh vehicles.',
            vehicles: state.vehicles,
          ));
        }
      } catch (e) {
        emit(VehicleListError(
          error: 'Failed to refresh vehicles: ${e.toString()}',
          vehicles: state.vehicles,
        ));
      }
    });

    // Delete Vehicle (placeholder)
    on<DeleteVehicle>((event, emit) async {
      emit(VehicleListLoading(vehicles: state.vehicles));

      try {
        // TODO: Call API to delete vehicle
        // final result = await vehicleRepository.deleteVehicle(vehicleId: event.vehicleId);

        // For now, simulate deletion
        await Future.delayed(const Duration(seconds: 1));

        // Remove the vehicle from the list
        final updatedVehicles = state.vehicles
            .where((vehicle) => vehicle.vehicleId != event.vehicleId)
            .toList();

        emit(VehicleDeletedSuccess(
          message: 'Vehicle deleted successfully',
          vehicles: updatedVehicles,
        ));
      } catch (e) {
        emit(VehicleDeletionError(
          error: 'Failed to delete vehicle. Please try again.',
          vehicles: state.vehicles,
        ));
      }
    });
  }
}
