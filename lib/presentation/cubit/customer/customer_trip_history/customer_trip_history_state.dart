import 'package:picky_load/domain/models/customer_trip_history_response.dart';
import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

/// Base state class for Customer Trip History feature
class CustomerTripHistoryState extends BaseEventState {
  final List<CustomerTripHistoryModel> trips;
  final int count;

  CustomerTripHistoryState({
    this.trips = const [],
    this.count = 0,
  });

  @override
  List<Object?> get props => [trips, count];
}

/// Initial state
class CustomerTripHistoryInitial extends CustomerTripHistoryState {}

/// Loading state
class CustomerTripHistoryLoading extends CustomerTripHistoryState {
  CustomerTripHistoryLoading({
    super.trips,
    super.count,
  });
}

/// Trips fetched successfully
class CustomerTripHistorySuccess extends CustomerTripHistoryState {
  final String message;

  CustomerTripHistorySuccess({
    required this.message,
    required super.trips,
    required super.count,
  });

  @override
  List<Object?> get props => [message, trips, count];
}

/// Error state
class CustomerTripHistoryError extends CustomerTripHistoryState {
  final String error;

  CustomerTripHistoryError({
    required this.error,
    super.trips,
    super.count,
  });

  @override
  List<Object?> get props => [error, trips, count];
}
