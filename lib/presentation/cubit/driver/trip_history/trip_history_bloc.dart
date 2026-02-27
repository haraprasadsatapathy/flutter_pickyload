import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'trip_history_event.dart';
import 'trip_history_state.dart';

class TripHistoryBloc extends Bloc<TripHistoryEvent, TripHistoryState> {
  final BuildContext context;
  final DriverRepository driverRepository;

  TripHistoryBloc(this.context, this.driverRepository) : super(TripHistoryInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch Trip History
    on<FetchTripHistory>((event, emit) async {
      emit(TripHistoryLoading(
        trips: state.trips,
        count: state.count,
      ));

      try {
        final result = await driverRepository.getTripHistoryByDriverId(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          emit(TripHistorySuccess(
            message: result.data!.message,
            trips: result.data!.trips,
            count: result.data!.trips.length,
          ));
        } else {
          emit(TripHistoryError(
            error: result.message ?? 'Failed to load trip history.',
            trips: state.trips,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(TripHistoryError(
          error: 'Failed to load trip history: ${e.toString()}',
          trips: state.trips,
          count: state.count,
        ));
      }
    });

    // Refresh Trip History
    on<RefreshTripHistory>((event, emit) async {
      try {
        final result = await driverRepository.getTripHistoryByDriverId(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          emit(TripHistorySuccess(
            message: 'Trip history refreshed',
            trips: result.data!.trips,
            count: result.data!.trips.length,
          ));
        } else {
          emit(TripHistoryError(
            error: result.message ?? 'Failed to refresh trip history.',
            trips: state.trips,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(TripHistoryError(
          error: 'Failed to refresh trip history: ${e.toString()}',
          trips: state.trips,
          count: state.count,
        ));
      }
    });
  }
}
