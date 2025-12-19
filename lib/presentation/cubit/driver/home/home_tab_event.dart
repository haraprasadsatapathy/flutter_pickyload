import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Home Tab feature
class HomeTabEvent extends BaseEventState {}

// Toggle online/offline status
class ToggleOnlineStatus extends HomeTabEvent {
  final bool isOnline;

  ToggleOnlineStatus({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}

// Fetch today's stats
class FetchTodayStats extends HomeTabEvent {
  final String driverId;

  FetchTodayStats({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

// Fetch available load requests
class FetchLoadRequests extends HomeTabEvent {
  final String driverId;

  FetchLoadRequests({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

// Accept a load request
class AcceptLoadRequest extends HomeTabEvent {
  final String loadRequestId;

  AcceptLoadRequest({required this.loadRequestId});

  @override
  List<Object?> get props => [loadRequestId];
}

// Decline a load request
class DeclineLoadRequest extends HomeTabEvent {
  final String loadRequestId;

  DeclineLoadRequest({required this.loadRequestId});

  @override
  List<Object?> get props => [loadRequestId];
}

// Refresh home tab data (stats and load requests)
class RefreshHomeTab extends HomeTabEvent {
  final String driverId;

  RefreshHomeTab({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}