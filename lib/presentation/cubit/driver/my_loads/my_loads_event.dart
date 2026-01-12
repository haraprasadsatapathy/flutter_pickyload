import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for My Loads feature
class MyLoadsEvent extends BaseEventState {}

// Fetch all loads for a driver
class FetchMyLoads extends MyLoadsEvent {
  final String driverId;

  FetchMyLoads({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

// Refresh loads list
class RefreshMyLoads extends MyLoadsEvent {
  final String driverId;

  RefreshMyLoads({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}
