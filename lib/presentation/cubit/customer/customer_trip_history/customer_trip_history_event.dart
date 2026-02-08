import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

/// Base event class for Customer Trip History feature
class CustomerTripHistoryEvent extends BaseEventState {}

/// Fetch all trip history for a customer
class FetchCustomerTripHistory extends CustomerTripHistoryEvent {
  final String userId;

  FetchCustomerTripHistory({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Refresh trip history list
class RefreshCustomerTripHistory extends CustomerTripHistoryEvent {
  final String userId;

  RefreshCustomerTripHistory({required this.userId});

  @override
  List<Object?> get props => [userId];
}
