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
      print('🔄 LoadMyTrips: Starting to load trips for userId: ${event.userId}');

      // Check if userId is empty
      if (event.userId.isEmpty) {
        print('❌ LoadMyTrips: userId is empty');
        emit(OnMyTripsError('User not logged in. Please login to view your trips.'));
        return;
      }

      emit(OnMyTripsLoading());

      // ============================================
      // BUSINESS LOGIC: Load User Trips
      // ============================================

      try {
        // Call API to fetch user booking history
        print('📞 LoadMyTrips: Calling API...');
        final result = await tripRepository.getUserBookings(userId: event.userId);
        print('📦 LoadMyTrips: API Response - status: ${result.status}, message: ${result.message}');

        if (result.status == true && result.data != null) {
          // Successfully fetched booking history
          allTrips = result.data!.data;
          print('✅ LoadMyTrips: Fetched ${allTrips.length} trips');

          if (allTrips.isEmpty) {
            print('⚠️ LoadMyTrips: No trips found');
            emit(OnMyTripsEmpty());
            return;
          }

          // Apply current filter
          final filteredTrips = _applyFilter(allTrips, currentFilter);
          print('🔍 LoadMyTrips: Filtered to ${filteredTrips.length} trips with filter: $currentFilter');

          emit(OnMyTripsLoaded(
            trips: filteredTrips,
            currentFilter: currentFilter,
          ));
        } else {
          // Failed to fetch booking history
          print('❌ LoadMyTrips: Failed - ${result.message}');
          emit(OnMyTripsError(result.message ?? 'Failed to load trips'));
        }
      } catch (e) {
        print('💥 LoadMyTrips: Exception - ${e.toString()}');
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

    // Cancel a booking
    on<CancelBooking>((event, emit) async {
      print('🗑️ CancelBooking: Starting to cancel booking ${event.bookingId}');

      // ============================================
      // BUSINESS LOGIC: Cancel Booking
      // ============================================

      try {
        // Call API to cancel booking
        print('📞 CancelBooking: Calling API...');
        final result = await tripRepository.cancelBooking(
          userId: event.userId,
          bookingId: event.bookingId,
        );
        print('📦 CancelBooking: API Response - status: ${result.status}, message: ${result.message}');

        if (result.status == true && result.data != null) {
          // Successfully canceled booking
          print('✅ CancelBooking: Booking canceled successfully');

          // Remove the canceled booking from the list
          allTrips.removeWhere((trip) => trip.bookingId == event.bookingId);

          emit(OnBookingCanceled(
            message: result.data!.message,
            bookingId: event.bookingId,
          ));

          // Reload trips to show updated list
          if (allTrips.isEmpty) {
            emit(OnMyTripsEmpty());
          } else {
            final filteredTrips = _applyFilter(allTrips, currentFilter);
            emit(OnMyTripsLoaded(
              trips: filteredTrips,
              currentFilter: currentFilter,
            ));
          }
        } else {
          // Failed to cancel booking
          print('❌ CancelBooking: Failed - ${result.message}');
          emit(OnBookingCancelFailed(result.message ?? 'Failed to cancel booking'));
        }
      } catch (e) {
        print('💥 CancelBooking: Exception - ${e.toString()}');
        emit(OnBookingCancelFailed('Failed to cancel booking: ${e.toString()}'));
      }
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
