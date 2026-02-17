import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'home_tab_event.dart';
import 'home_tab_state.dart';

class HomeTabBloc extends Bloc<HomeTabEvent, HomeTabState> {
  final BuildContext context;
  final DriverRepository driverRepository;

  HomeTabBloc(this.context, this.driverRepository) : super(HomeTabInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch Home Page Data
    on<FetchHomePage>((event, emit) async {
      emit(HomeTabLoading(
        isAvailableForLoad: state.isAvailableForLoad,
        hasActiveSubscription: state.hasActiveSubscription,
        tripDetails: state.tripDetails,
        confirmedTrips: state.confirmedTrips,
      ));

      try {
        // Get user details from SharedPreferences
        final user = await driverRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(HomeTabError(
            error: 'Driver ID not found. Please login again.',
            isAvailableForLoad: state.isAvailableForLoad,
            hasActiveSubscription: state.hasActiveSubscription,
            tripDetails: state.tripDetails,
            confirmedTrips: state.confirmedTrips,
          ));
          return;
        }

        final driverId = user.id;
        debugPrint('HomeTabBloc: Fetching home page for driverId: $driverId');

        final response = await driverRepository.getHomePage(
          driverId: driverId,
        );

        debugPrint('HomeTabBloc: Response status: ${response.status}, message: ${response.message}');

        if (response.status == true && response.data != null) {
          debugPrint('HomeTabBloc: Fetched ${response.data!.data.tripDetails.length} trips');
          debugPrint('HomeTabBloc: Fetched ${response.data!.data.confirmedTrips.length} confirmed trips');
          debugPrint('HomeTabBloc: hasActiveSubscription: ${response.data!.data.hasActiveSubscription}');
          emit(HomeTabSuccess(
            message: response.data!.message,
            isAvailableForLoad: response.data!.data.isAvailableForLoad,
            hasActiveSubscription: response.data!.data.hasActiveSubscription,
            tripDetails: response.data!.data.tripDetails,
            confirmedTrips: response.data!.data.confirmedTrips,
            documents: state.documents,
          ));

          // If no trips and no confirmed trips, fetch documents
          if (response.data!.data.tripDetails.isEmpty && response.data!.data.confirmedTrips.isEmpty) {
            add(FetchDocuments());
          }
        } else {
          emit(HomeTabError(
            error: response.message ?? 'Failed to fetch home page data',
            isAvailableForLoad: state.isAvailableForLoad,
            hasActiveSubscription: state.hasActiveSubscription,
            tripDetails: state.tripDetails,
            confirmedTrips: state.confirmedTrips,
          ));
        }
      } catch (e) {
        debugPrint('HomeTabBloc: Error fetching home page: $e');
        emit(HomeTabError(
          error: 'Failed to fetch home page data: ${e.toString()}',
          isAvailableForLoad: state.isAvailableForLoad,
          hasActiveSubscription: state.hasActiveSubscription,
          tripDetails: state.tripDetails,
          confirmedTrips: state.confirmedTrips,
        ));
      }
    });

    // Fetch Documents
    on<FetchDocuments>((event, emit) async {
      emit(HomeTabLoading(
        isAvailableForLoad: state.isAvailableForLoad,
        hasActiveSubscription: state.hasActiveSubscription,
        tripDetails: state.tripDetails,
        confirmedTrips: state.confirmedTrips,
        documents: state.documents,
        isDocumentsLoading: true,
      ));

      try {
        final user = await driverRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(HomeTabError(
            error: 'Driver ID not found. Please login again.',
            isAvailableForLoad: state.isAvailableForLoad,
            hasActiveSubscription: state.hasActiveSubscription,
            tripDetails: state.tripDetails,
            confirmedTrips: state.confirmedTrips,
            documents: state.documents,
          ));
          return;
        }

        final response = await driverRepository.getAllDocuments(userId: user.id);

        if (response.status == true && response.data != null) {
          emit(DocumentsFetched(
            message: 'Documents loaded successfully',
            documents: response.data!.documents,
            isAvailableForLoad: state.isAvailableForLoad,
            hasActiveSubscription: state.hasActiveSubscription,
            tripDetails: state.tripDetails,
            confirmedTrips: state.confirmedTrips,
          ));
        } else {
          emit(HomeTabError(
            error: response.message ?? 'Failed to fetch documents',
            isAvailableForLoad: state.isAvailableForLoad,
            hasActiveSubscription: state.hasActiveSubscription,
            tripDetails: state.tripDetails,
            confirmedTrips: state.confirmedTrips,
            documents: state.documents,
          ));
        }
      } catch (e) {
        debugPrint('HomeTabBloc: Error fetching documents: $e');
        emit(HomeTabError(
          error: 'Failed to fetch documents: ${e.toString()}',
          isAvailableForLoad: state.isAvailableForLoad,
          hasActiveSubscription: state.hasActiveSubscription,
          tripDetails: state.tripDetails,
          confirmedTrips: state.confirmedTrips,
          documents: state.documents,
        ));
      }
    });

    // Refresh Home Page Data
    on<RefreshHomePage>((event, emit) async {
      try {
        // Get user details from SharedPreferences
        final user = await driverRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(HomeTabError(
            error: 'Driver ID not found. Please login again.',
            isAvailableForLoad: state.isAvailableForLoad,
            hasActiveSubscription: state.hasActiveSubscription,
            tripDetails: state.tripDetails,
            confirmedTrips: state.confirmedTrips,
          ));
          return;
        }

        final driverId = user.id;
        debugPrint('HomeTabBloc: Refreshing home page for driverId: $driverId');

        final response = await driverRepository.getHomePage(
          driverId: driverId,
        );

        if (response.status == true && response.data != null) {
          emit(HomeTabSuccess(
            message: 'Data refreshed successfully',
            isAvailableForLoad: response.data!.data.isAvailableForLoad,
            hasActiveSubscription: response.data!.data.hasActiveSubscription,
            tripDetails: response.data!.data.tripDetails,
            confirmedTrips: response.data!.data.confirmedTrips,
            documents: state.documents,
          ));

          // If no trips and no confirmed trips, fetch documents
          if (response.data!.data.tripDetails.isEmpty && response.data!.data.confirmedTrips.isEmpty) {
            add(FetchDocuments());
          }
        } else {
          emit(HomeTabError(
            error: response.message ?? 'Failed to refresh data',
            isAvailableForLoad: state.isAvailableForLoad,
            hasActiveSubscription: state.hasActiveSubscription,
            tripDetails: state.tripDetails,
            confirmedTrips: state.confirmedTrips,
            documents: state.documents,
          ));
        }
      } catch (e) {
        debugPrint('HomeTabBloc: Error refreshing home page: $e');
        emit(HomeTabError(
          error: 'Failed to refresh data: ${e.toString()}',
          isAvailableForLoad: state.isAvailableForLoad,
          hasActiveSubscription: state.hasActiveSubscription,
          tripDetails: state.tripDetails,
          confirmedTrips: state.confirmedTrips,
        ));
      }
    });
  }
}
