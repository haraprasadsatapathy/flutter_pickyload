import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'my_loads_event.dart';
import 'my_loads_state.dart';

class MyLoadsBloc extends Bloc<MyLoadsEvent, MyLoadsState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  MyLoadsBloc(this.context, this.driverRepository) : super(MyLoadsInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch My Loads
    on<FetchMyLoads>((event, emit) async {
      emit(MyLoadsLoading(
        loads: state.loads,
        count: state.count,
      ));

      try {
        // Call API to fetch offered loads
        final result = await driverRepository.getAllOfferLoads(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          // Convert OfferLoadModel to MyLoadModel
          final myLoads = result.data!.offerLoads.map((offerLoad) {
            return MyLoadModel(
              offerId: offerLoad.offerId,
              driverId: offerLoad.driverId,
              vehicleId: offerLoad.vehicleId,
              price: offerLoad.price,
              availableTimeStart: offerLoad.availableTimeStart,
              availableTimeEnd: offerLoad.availableTimeEnd,
              status: offerLoad.status,
              pickupLocation: [offerLoad.pickupLng, offerLoad.pickupLat],
              dropLocation: [offerLoad.dropLng, offerLoad.dropLat],
              pickupAddress: offerLoad.pickupAddress,
              dropAddress: offerLoad.dropAddress,
            );
          }).toList();

          emit(MyLoadsSuccess(
            message: result.data!.message,
            loads: myLoads,
            count: myLoads.length,
          ));
        } else {
          emit(MyLoadsError(
            error: result.message ?? 'Failed to load my loads.',
            loads: state.loads,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(MyLoadsError(
          error: 'Failed to load my loads: ${e.toString()}',
          loads: state.loads,
          count: state.count,
        ));
      }
    });

    // Refresh My Loads
    on<RefreshMyLoads>((event, emit) async {
      try {
        // Call API to refresh loads
        final result = await driverRepository.getAllOfferLoads(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          // Convert OfferLoadModel to MyLoadModel
          final myLoads = result.data!.offerLoads.map((offerLoad) {
            return MyLoadModel(
              offerId: offerLoad.offerId,
              driverId: offerLoad.driverId,
              vehicleId: offerLoad.vehicleId,
              price: offerLoad.price,
              availableTimeStart: offerLoad.availableTimeStart,
              availableTimeEnd: offerLoad.availableTimeEnd,
              status: offerLoad.status,
              pickupLocation: [offerLoad.pickupLng, offerLoad.pickupLat],
              dropLocation: [offerLoad.dropLng, offerLoad.dropLat],
              pickupAddress: offerLoad.pickupAddress,
              dropAddress: offerLoad.dropAddress,
            );
          }).toList();

          emit(MyLoadsSuccess(
            message: 'My loads refreshed',
            loads: myLoads,
            count: myLoads.length,
          ));
        } else {
          emit(MyLoadsError(
            error: result.message ?? 'Failed to refresh my loads.',
            loads: state.loads,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(MyLoadsError(
          error: 'Failed to refresh my loads: ${e.toString()}',
          loads: state.loads,
          count: state.count,
        ));
      }
    });
  }
}
