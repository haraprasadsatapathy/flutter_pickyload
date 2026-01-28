import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Update Offer Price feature
class UpdateOfferPriceEvent extends BaseEventState {}

// Update offer price
class UpdateOfferPrice extends UpdateOfferPriceEvent {
  final String quotationId;
  final String offerId;
  final String driverId;
  final String bookingId;
  final double price;

  UpdateOfferPrice({
    required this.quotationId,
    required this.offerId,
    required this.driverId,
    required this.bookingId,
    required this.price,
  });

  @override
  List<Object?> get props => [quotationId, offerId, driverId, bookingId, price];
}

// Reset form
class ResetUpdateOfferPriceForm extends UpdateOfferPriceEvent {
  @override
  List<Object?> get props => [];
}
