import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base state class for Update Offer Price feature
class UpdateOfferPriceState extends BaseEventState {
  @override
  List<Object?> get props => [];
}

// Initial state
class UpdateOfferPriceInitial extends UpdateOfferPriceState {}

// Loading state
class UpdateOfferPriceLoading extends UpdateOfferPriceState {}

// Offer price updated successfully
class OfferPriceUpdated extends UpdateOfferPriceState {
  final String message;
  final String offerId;
  final double price;

  OfferPriceUpdated({
    required this.message,
    required this.offerId,
    required this.price,
  });

  @override
  List<Object?> get props => [message, offerId, price];
}

// Error state
class UpdateOfferPriceError extends UpdateOfferPriceState {
  final String error;

  UpdateOfferPriceError({required this.error});

  @override
  List<Object?> get props => [error];
}
