import 'package:picky_load/domain/models/trip_history_response.dart';
import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

/// Base state class for Trip History feature
class TripHistoryState extends BaseEventState {
  final List<TripHistoryModel> trips;
  final int count;

  TripHistoryState({
    this.trips = const [],
    this.count = 0,
  });

  @override
  List<Object?> get props => [trips, count];
}

/// Initial state
class TripHistoryInitial extends TripHistoryState {}

/// Loading state
class TripHistoryLoading extends TripHistoryState {
  TripHistoryLoading({
    super.trips,
    super.count,
  });
}

/// Trips fetched successfully
class TripHistorySuccess extends TripHistoryState {
  final String message;

  TripHistorySuccess({
    required this.message,
    required super.trips,
    required super.count,
  });

  @override
  List<Object?> get props => [message, trips, count];
}

/// Error state
class TripHistoryError extends TripHistoryState {
  final String error;

  TripHistoryError({
    required this.error,
    super.trips,
    super.count,
  });

  @override
  List<Object?> get props => [error, trips, count];
}
