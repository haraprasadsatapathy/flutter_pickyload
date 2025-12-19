import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'update_offer_price_event.dart';
import 'update_offer_price_state.dart';

class UpdateOfferPriceBloc
    extends Bloc<UpdateOfferPriceEvent, UpdateOfferPriceState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  UpdateOfferPriceBloc(this.context, this.driverRepository)
      : super(UpdateOfferPriceInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Update Offer Price
    on<UpdateOfferPrice>((event, emit) async {
      emit(UpdateOfferPriceLoading());

      try {
        // Call API to update offer price
        final result = await driverRepository.updateOfferPrice(
          offerId: event.offerId,
          driverId: event.driverId,
          vehicleId: event.vehicleId,
          price: event.price,
        );

        if (result.status == true && result.data != null) {
          emit(OfferPriceUpdated(
            message: result.data!.message,
            offerId: result.data!.data?.offerId ?? event.offerId,
            price: result.data!.data?.price ?? event.price,
          ));
        } else {
          emit(UpdateOfferPriceError(
            error: result.message ?? 'Failed to update offer price',
          ));
        }
      } catch (e) {
        emit(UpdateOfferPriceError(
          error: 'Failed to update offer price: ${e.toString()}',
        ));
      }
    });

    // Reset Form
    on<ResetUpdateOfferPriceForm>((event, emit) {
      emit(UpdateOfferPriceInitial());
    });
  }
}
