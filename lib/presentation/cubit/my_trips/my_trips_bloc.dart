import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_trips_event.dart';
import 'my_trips_state.dart';
import '../../../domain/repository/trip_repository.dart';
import '../../../domain/models/booking_history_response.dart';

class MyTripsBloc extends Bloc<MyTripsEvent, MyTripsStates> {
  // Dependencies
  final BuildContext context;
  final TripRepository tripRepository;

  // State management fields
  List<BookingHistory> allTrips = [];
  String currentFilter = 'all';

  // Constructor
  MyTripsBloc(this.context, this.tripRepository)
      : super(MyTripsInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Load all trips for the current user
    on<LoadMyTrips>((event, emit) async {
      emit(OnMyTripsLoading());

      // ============================================
      // BUSINESS LOGIC: Load User Trips
      // ============================================

      try {
        // Call API to fetch user booking history
        final result = await tripRepository.getUserBookings(userId: event.userId);

        if (result.status == true && result.data != null) {
          // Successfully fetched booking history
          allTrips = result.data!.data;

          if (allTrips.isEmpty) {
            emit(OnMyTripsEmpty());
            return;
          }

          // Apply current filter
          final filteredTrips = _applyFilter(allTrips, currentFilter);

          emit(OnMyTripsLoaded(
            trips: filteredTrips,
            currentFilter: currentFilter,
          ));
        } else {
          // Failed to fetch booking history
          emit(OnMyTripsError(result.message ?? 'Failed to load trips'));
        }
      } catch (e) {
        emit(OnMyTripsError('Failed to load trips: ${e.toString()}'));
      }
    });

    // Refresh trips list
    on<RefreshMyTrips>((event, emit) async {
      // ============================================
      // BUSINESS LOGIC: Refresh Trips
      // ============================================

      try {
        // Call API to fetch user booking history
        final result = await tripRepository.getUserBookings(userId: event.userId);

        if (result.status == true && result.data != null) {
          // Successfully fetched booking history
          allTrips = result.data!.data;

          if (allTrips.isEmpty) {
            emit(OnMyTripsEmpty());
            return;
          }

          // Apply current filter
          final filteredTrips = _applyFilter(allTrips, currentFilter);

          emit(OnMyTripsLoaded(
            trips: filteredTrips,
            currentFilter: currentFilter,
          ));
        } else {
          // Failed to fetch booking history
          emit(OnMyTripsError(result.message ?? 'Failed to refresh trips'));
        }
      } catch (e) {
        emit(OnMyTripsError('Failed to refresh trips: ${e.toString()}'));
      }
    });

    // Filter trips by status
    on<FilterTripsByStatus>((event, emit) {
      // ============================================
      // BUSINESS LOGIC: Filter Trips by Status
      // ============================================

      currentFilter = event.status;

      if (allTrips.isEmpty) {
        emit(OnMyTripsEmpty());
        return;
      }

      final filteredTrips = _applyFilter(allTrips, currentFilter);

      if (filteredTrips.isEmpty) {
        emit(OnMyTripsEmpty(
          message: 'No ${event.status} trips found',
        ));
        return;
      }

      emit(OnMyTripsLoaded(
        trips: filteredTrips,
        currentFilter: currentFilter,
      ));
    });

    // Navigate to trip details
    on<NavigateToTripDetails>((event, emit) {
      emit(OnNavigateToTripDetails(event.tripId));
    });
  }

  // Helper method to apply filter
  List<BookingHistory> _applyFilter(List<BookingHistory> trips, String filter) {
    if (filter == 'all') {
      return trips;
    }
    // Filter based on booking status (case-insensitive)
    return trips.where((trip) => trip.bookingStatus.toLowerCase() == filter.toLowerCase()).toList();
  }
}
