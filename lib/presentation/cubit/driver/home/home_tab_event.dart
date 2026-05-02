import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Home Tab feature
class HomeTabEvent extends BaseEventState {}

// Fetch home page data
class FetchHomePage extends HomeTabEvent {
  @override
  List<Object?> get props => [];
}

// Refresh home page data
class RefreshHomePage extends HomeTabEvent {
  @override
  List<Object?> get props => [];
}

// Cancel a driver's trip offer
class CancelTripOffer extends HomeTabEvent {
  final String offerId;

  CancelTripOffer({required this.offerId});

  @override
  List<Object?> get props => [offerId];
}

// Fetch documents for user
class FetchDocuments extends HomeTabEvent {
  @override
  List<Object?> get props => [];
}
