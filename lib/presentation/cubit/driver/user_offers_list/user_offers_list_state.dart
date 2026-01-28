import 'package:picky_load/presentation/cubit/base/base_event_state.dart';
import '../../../../domain/models/home_page_response.dart';

// Re-export models for convenience
export 'package:picky_load/domain/models/home_page_response.dart' show TripDetail, UserOffer;

// Base state class for User Offers List feature
class UserOffersListState extends BaseEventState {
  final TripDetail? tripDetail;
  final List<UserOffer> userOffers;

  UserOffersListState({
    this.tripDetail,
    this.userOffers = const [],
  });

  @override
  List<Object?> get props => [tripDetail, userOffers];
}

// Initial state
class UserOffersListInitial extends UserOffersListState {}

// Loading state
class UserOffersListLoading extends UserOffersListState {
  UserOffersListLoading({
    super.tripDetail,
    super.userOffers,
  });
}

// Data loaded successfully
class UserOffersListSuccess extends UserOffersListState {
  final String message;

  UserOffersListSuccess({
    required this.message,
    required super.tripDetail,
    required super.userOffers,
  });

  @override
  List<Object?> get props => [message, tripDetail, userOffers];
}

// Offer price update loading
class UserOfferPriceUpdating extends UserOffersListState {
  final String updatingBookingId;

  UserOfferPriceUpdating({
    required this.updatingBookingId,
    super.tripDetail,
    super.userOffers,
  });

  @override
  List<Object?> get props => [updatingBookingId, tripDetail, userOffers];
}

// Offer price updated successfully
class UserOfferPriceUpdated extends UserOffersListState {
  final String message;
  final String bookingId;
  final double newPrice;

  UserOfferPriceUpdated({
    required this.message,
    required this.bookingId,
    required this.newPrice,
    super.tripDetail,
    super.userOffers,
  });

  @override
  List<Object?> get props => [message, bookingId, newPrice, tripDetail, userOffers];
}

// Error state
class UserOffersListError extends UserOffersListState {
  final String error;

  UserOffersListError({
    required this.error,
    super.tripDetail,
    super.userOffers,
  });

  @override
  List<Object?> get props => [error, tripDetail, userOffers];
}
