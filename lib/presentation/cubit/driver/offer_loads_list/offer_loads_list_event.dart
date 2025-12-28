import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Offer Loads List feature
class OfferLoadsListEvent extends BaseEventState {}

// Fetch all offered loads for a driver
class FetchOfferLoads extends OfferLoadsListEvent {
  final String driverId;

  FetchOfferLoads({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

// Refresh offered loads list
class RefreshOfferLoads extends OfferLoadsListEvent {
  final String driverId;

  RefreshOfferLoads({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}
