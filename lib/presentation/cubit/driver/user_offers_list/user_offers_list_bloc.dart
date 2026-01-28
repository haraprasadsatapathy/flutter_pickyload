import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'user_offers_list_event.dart';
import 'user_offers_list_state.dart';

class UserOffersListBloc extends Bloc<UserOffersListEvent, UserOffersListState> {
  final BuildContext context;
  final DriverRepository driverRepository;

  UserOffersListBloc(this.context, this.driverRepository) : super(UserOffersListInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Initialize with trip detail data
    on<InitializeUserOffersList>((event, emit) async {
      emit(UserOffersListLoading(
        tripDetail: event.tripDetail,
        userOffers: event.tripDetail.userOffers,
      ));

      try {
        emit(UserOffersListSuccess(
          message: 'User offers loaded successfully',
          tripDetail: event.tripDetail,
          userOffers: event.tripDetail.userOffers,
        ));
      } catch (e) {
        debugPrint('UserOffersListBloc: Error initializing: $e');
        emit(UserOffersListError(
          error: 'Failed to load user offers: ${e.toString()}',
          tripDetail: event.tripDetail,
          userOffers: event.tripDetail.userOffers,
        ));
      }
    });

    // Update offer price for a specific user offer
    on<UpdateUserOfferPrice>((event, emit) async {
      emit(UserOfferPriceUpdating(
        updatingBookingId: event.bookingId,
        tripDetail: state.tripDetail,
        userOffers: state.userOffers,
      ));

      try {
        // Get user details for driver ID
        final user = await driverRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(UserOffersListError(
            error: 'Driver ID not found. Please login again.',
            tripDetail: state.tripDetail,
            userOffers: state.userOffers,
          ));
          return;
        }

        final driverId = user.id;

        debugPrint('UserOffersListBloc: Updating price - quotationId: ${event.quotationId}, offerId: ${event.offerId}, bookingId: ${event.bookingId}, price: ${event.price}');

        final response = await driverRepository.updateOfferPrice(
          quotationId: event.quotationId,
          offerId: event.offerId,
          driverId: driverId,
          bookingId: event.bookingId,
          price: event.price,
        );

        if (response.status == true && response.data != null) {
          emit(UserOfferPriceUpdated(
            message: response.data!.message,
            bookingId: event.bookingId,
            newPrice: event.price,
            tripDetail: state.tripDetail,
            userOffers: state.userOffers,
          ));
        } else {
          emit(UserOffersListError(
            error: response.message ?? 'Failed to update offer price',
            tripDetail: state.tripDetail,
            userOffers: state.userOffers,
          ));
        }
      } catch (e) {
        debugPrint('UserOffersListBloc: Error updating price: $e');
        emit(UserOffersListError(
          error: 'Failed to update offer price: ${e.toString()}',
          tripDetail: state.tripDetail,
          userOffers: state.userOffers,
        ));
      }
    });

    // Refresh user offers list
    on<RefreshUserOffersList>((event, emit) async {
      if (state.tripDetail == null) return;

      emit(UserOffersListLoading(
        tripDetail: state.tripDetail,
        userOffers: state.userOffers,
      ));

      try {
        // Get user details
        final user = await driverRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(UserOffersListError(
            error: 'Driver ID not found. Please login again.',
            tripDetail: state.tripDetail,
            userOffers: state.userOffers,
          ));
          return;
        }

        final driverId = user.id;

        // Fetch updated home page data
        final response = await driverRepository.getHomePage(driverId: driverId);

        if (response.status == true && response.data != null) {
          // Find the matching trip detail by offerId
          final updatedTripDetail = response.data!.data.tripDetails.firstWhere(
            (trip) => trip.offerId == state.tripDetail!.offerId,
            orElse: () => state.tripDetail!,
          );

          emit(UserOffersListSuccess(
            message: 'User offers refreshed successfully',
            tripDetail: updatedTripDetail,
            userOffers: updatedTripDetail.userOffers,
          ));
        } else {
          emit(UserOffersListError(
            error: response.message ?? 'Failed to refresh user offers',
            tripDetail: state.tripDetail,
            userOffers: state.userOffers,
          ));
        }
      } catch (e) {
        debugPrint('UserOffersListBloc: Error refreshing: $e');
        emit(UserOffersListError(
          error: 'Failed to refresh user offers: ${e.toString()}',
          tripDetail: state.tripDetail,
          userOffers: state.userOffers,
        ));
      }
    });

    // Reset state
    on<ResetUserOffersListState>((event, emit) {
      emit(UserOffersListInitial());
    });
  }
}
