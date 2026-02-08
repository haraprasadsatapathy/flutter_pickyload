import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/customer_repository.dart';
import 'customer_trip_history_event.dart';
import 'customer_trip_history_state.dart';

class CustomerTripHistoryBloc extends Bloc<CustomerTripHistoryEvent, CustomerTripHistoryState> {
  final BuildContext context;
  final CustomerRepository customerRepository;

  CustomerTripHistoryBloc(this.context, this.customerRepository) : super(CustomerTripHistoryInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch Customer Trip History
    on<FetchCustomerTripHistory>((event, emit) async {
      emit(CustomerTripHistoryLoading(
        trips: state.trips,
        count: state.count,
      ));

      try {
        final result = await customerRepository.getTripHistoryByUserId(
          userId: event.userId,
        );

        if (result.status == true && result.data != null) {
          emit(CustomerTripHistorySuccess(
            message: result.data!.message,
            trips: result.data!.trips,
            count: result.data!.trips.length,
          ));
        } else {
          emit(CustomerTripHistoryError(
            error: result.message ?? 'Failed to load trip history.',
            trips: state.trips,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(CustomerTripHistoryError(
          error: 'Failed to load trip history: ${e.toString()}',
          trips: state.trips,
          count: state.count,
        ));
      }
    });

    // Refresh Customer Trip History
    on<RefreshCustomerTripHistory>((event, emit) async {
      try {
        final result = await customerRepository.getTripHistoryByUserId(
          userId: event.userId,
        );

        if (result.status == true && result.data != null) {
          emit(CustomerTripHistorySuccess(
            message: 'Trip history refreshed',
            trips: result.data!.trips,
            count: result.data!.trips.length,
          ));
        } else {
          emit(CustomerTripHistoryError(
            error: result.message ?? 'Failed to refresh trip history.',
            trips: state.trips,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(CustomerTripHistoryError(
          error: 'Failed to refresh trip history: ${e.toString()}',
          trips: state.trips,
          count: state.count,
        ));
      }
    });
  }
}
