import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

/// Base event class for Trip History feature
class TripHistoryEvent extends BaseEventState {}

/// Fetch all trip history for a driver
class FetchTripHistory extends TripHistoryEvent {
  final String driverId;

  FetchTripHistory({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

/// Refresh trip history list
class RefreshTripHistory extends TripHistoryEvent {
  final String driverId;

  RefreshTripHistory({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}
