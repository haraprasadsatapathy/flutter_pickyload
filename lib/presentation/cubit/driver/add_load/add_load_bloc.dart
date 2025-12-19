import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'add_load_event.dart';
import 'add_load_state.dart';

class AddLoadBloc extends Bloc<AddLoadEvent, AddLoadState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  AddLoadBloc(this.context, this.driverRepository) : super(AddLoadInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch Driver Vehicles
    on<FetchDriverVehicles>((event, emit) async {
      emit(AddLoadLoading(
        vehicles: state.vehicles,
        selectedVehicleId: state.selectedVehicleId,
      ));

      try {
        // Call API to fetch vehicles
        final result = await driverRepository.getDriverVehicles(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          // Convert Vehicle objects to VehicleOptionModel objects
          final vehicles = result.data!.data?.vehicles
                  .map((vehicle) => VehicleOptionModel(
                        vehicleId: vehicle.vehicleId,
                        vehicleNumber: vehicle.vehicleNumber,
                        makeModel: vehicle.makeModel,
                        capacity: vehicle.capacity,
                      ))
                  .toList() ??
              [];

          emit(VehiclesFetched(
            message: 'Vehicles loaded successfully',
            vehicles: vehicles,
          ));
        } else {
          emit(AddLoadError(
            error: result.message ?? 'Failed to load vehicles.',
            vehicles: state.vehicles,
            selectedVehicleId: state.selectedVehicleId,
          ));
        }
      } catch (e) {
        emit(AddLoadError(
          error: 'Failed to load vehicles: ${e.toString()}',
          vehicles: state.vehicles,
          selectedVehicleId: state.selectedVehicleId,
        ));
      }
    });

    // Submit Load Offer
    on<SubmitLoadOffer>((event, emit) async {
      emit(AddLoadLoading(
        vehicles: state.vehicles,
        selectedVehicleId: state.selectedVehicleId,
      ));

      try {
        // Generate a unique offer ID
        final offerId = const Uuid().v4();

        // Call API to submit load offer
        final result = await driverRepository.offerLoadsUpsert(
          offerId: offerId,
          driverId: event.driverId,
          vehicleId: event.vehicleId,
          origin: event.origin,
          destination: event.destination,
          availableTimeStart: event.availableTimeStart,
          availableTimeEnd: event.availableTimeEnd,
        );

        if (result.status == true && result.data != null) {
          emit(LoadOfferSubmitted(
            message: result.data!.message,
            offerId: result.data!.data?.offerId ?? offerId,
            vehicles: state.vehicles,
          ));
        } else {
          emit(AddLoadError(
            error: result.message ?? 'Failed to submit load offer',
            vehicles: state.vehicles,
            selectedVehicleId: state.selectedVehicleId,
          ));
        }
      } catch (e) {
        emit(AddLoadError(
          error: 'Failed to submit load offer: ${e.toString()}',
          vehicles: state.vehicles,
          selectedVehicleId: state.selectedVehicleId,
        ));
      }
    });

    // Reset Form
    on<ResetAddLoadForm>((event, emit) {
      emit(AddLoadFormReset(vehicles: state.vehicles));
    });
  }
}
