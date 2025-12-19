import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Update Offer Price feature
class UpdateOfferPriceEvent extends BaseEventState {}

// Update offer price
class UpdateOfferPrice extends UpdateOfferPriceEvent {
  final String offerId;
  final String driverId;
  final String vehicleId;
  final double price;

  UpdateOfferPrice({
    required this.offerId,
    required this.driverId,
    required this.vehicleId,
    required this.price,
  });

  @override
  List<Object?> get props => [offerId, driverId, vehicleId, price];
}

// Reset form
class ResetUpdateOfferPriceForm extends UpdateOfferPriceEvent {
  @override
  List<Object?> get props => [];
}
