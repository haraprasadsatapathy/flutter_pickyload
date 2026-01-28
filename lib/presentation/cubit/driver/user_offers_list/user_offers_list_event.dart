import 'package:picky_load/presentation/cubit/base/base_event_state.dart';
import '../../../../domain/models/home_page_response.dart';

// Base event class for User Offers List feature
class UserOffersListEvent extends BaseEventState {}

// Initialize with trip detail data
class InitializeUserOffersList extends UserOffersListEvent {
  final TripDetail tripDetail;

  InitializeUserOffersList({required this.tripDetail});

  @override
  List<Object?> get props => [tripDetail];
}

// Update offer price for a specific user offer
class UpdateUserOfferPrice extends UserOffersListEvent {
  final String quotationId;
  final String offerId;
  final String bookingId;
  final double price;

  UpdateUserOfferPrice({
    required this.quotationId,
    required this.offerId,
    required this.bookingId,
    required this.price,
  });

  @override
  List<Object?> get props => [quotationId, offerId, bookingId, price];
}

// Refresh user offers list
class RefreshUserOffersList extends UserOffersListEvent {
  @override
  List<Object?> get props => [];
}

// Reset state
class ResetUserOffersListState extends UserOffersListEvent {
  @override
  List<Object?> get props => [];
}
