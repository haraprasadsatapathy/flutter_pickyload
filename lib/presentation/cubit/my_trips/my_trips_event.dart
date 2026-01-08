import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for MyTrips feature
class MyTripsEvent extends BaseEventState {}

// Load all trips for the current user
class LoadMyTrips extends MyTripsEvent {
  final String userId;

  LoadMyTrips({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

// Refresh trips list
class RefreshMyTrips extends MyTripsEvent {
  final String userId;

  RefreshMyTrips({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

// Filter trips by status
class FilterTripsByStatus extends MyTripsEvent {
  final String status; // 'all', 'in_progress', 'completed', 'cancelled'

  FilterTripsByStatus({
    required this.status,
  });

  @override
  List<Object?> get props => [status];
}

// Navigate to trip details
class NavigateToTripDetails extends MyTripsEvent {
  final String tripId;

  NavigateToTripDetails({
    required this.tripId,
  });

  @override
  List<Object?> get props => [tripId];
}

// Cancel a booking
class CancelBooking extends MyTripsEvent {
  final String userId;
  final String bookingId;

  CancelBooking({
    required this.userId,
    required this.bookingId,
  });

  @override
  List<Object?> get props => [userId, bookingId];
}
