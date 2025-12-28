import 'package:picky_load/presentation/cubit/base/base_event_state.dart';
import '../../../domain/models/booking_history_response.dart';

// Base state class for MyTrips feature
class MyTripsStates extends BaseEventState {}

// Initial state
class MyTripsInitialState extends MyTripsStates {}

// Loading state
class OnMyTripsLoading extends MyTripsStates {}

// Trips loaded successfully
class OnMyTripsLoaded extends MyTripsStates {
  final List<BookingHistory> trips;
  final String currentFilter; // 'all', 'requested', 'accepted', 'in_progress', 'completed', 'cancelled'

  OnMyTripsLoaded({
    required this.trips,
    this.currentFilter = 'all',
  });

  @override
  List<Object?> get props => [trips, currentFilter];
}

// Trips loading failed
class OnMyTripsError extends MyTripsStates {
  final String message;

  OnMyTripsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Empty state - no trips found
class OnMyTripsEmpty extends MyTripsStates {
  final String message;

  OnMyTripsEmpty({
    this.message = 'No trips found',
  });

  @override
  List<Object?> get props => [message];
}

// Navigate to trip details
class OnNavigateToTripDetails extends MyTripsStates {
  final String tripId;

  OnNavigateToTripDetails(this.tripId);

  @override
  List<Object?> get props => [tripId];
}
