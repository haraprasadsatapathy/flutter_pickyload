import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'offer_loads_list_event.dart';
import 'offer_loads_list_state.dart';

class OfferLoadsListBloc
    extends Bloc<OfferLoadsListEvent, OfferLoadsListState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  OfferLoadsListBloc(this.context, this.driverRepository)
      : super(OfferLoadsListInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch Offer Loads
    on<FetchOfferLoads>((event, emit) async {
      emit(OfferLoadsListLoading(
        offerLoads: state.offerLoads,
        count: state.count,
      ));

      try {
        // Call API to fetch offered loads
        final result = await driverRepository.getAllOfferLoads(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          emit(OfferLoadsListSuccess(
            message: result.data!.message,
            offerLoads: result.data!.offerLoads,
            count: result.data!.count,
          ));
        } else {
          emit(OfferLoadsListError(
            error: result.message ?? 'Failed to load offered loads.',
            offerLoads: state.offerLoads,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(OfferLoadsListError(
          error: 'Failed to load offered loads: ${e.toString()}',
          offerLoads: state.offerLoads,
          count: state.count,
        ));
      }
    });

    // Refresh Offer Loads
    on<RefreshOfferLoads>((event, emit) async {
      try {
        // Call API to refresh offered loads
        final result = await driverRepository.getAllOfferLoads(
          driverId: event.driverId,
        );

        if (result.status == true && result.data != null) {
          emit(OfferLoadsListSuccess(
            message: 'Offered loads refreshed',
            offerLoads: result.data!.offerLoads,
            count: result.data!.count,
          ));
        } else {
          emit(OfferLoadsListError(
            error: result.message ?? 'Failed to refresh offered loads.',
            offerLoads: state.offerLoads,
            count: state.count,
          ));
        }
      } catch (e) {
        emit(OfferLoadsListError(
          error: 'Failed to refresh offered loads: ${e.toString()}',
          offerLoads: state.offerLoads,
          count: state.count,
        ));
      }
    });
  }
}
