import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'home_tab_event.dart';
import 'home_tab_state.dart';

class HomeTabBloc extends Bloc<HomeTabEvent, HomeTabState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  HomeTabBloc(this.context, this.driverRepository) : super(HomeTabInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Toggle Online Status
    on<ToggleOnlineStatus>((event, emit) async {
      emit(HomeTabLoading(
        isOnline: state.isOnline,
        todayStats: state.todayStats,
        loadRequests: state.loadRequests,
      ));

      try {
        // TODO: Call API to update online status
        // final result = await driverRepository.updateOnlineStatus(
        //   isOnline: event.isOnline,
        // );

        // For now, simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        emit(OnlineStatusUpdated(
          message: event.isOnline
              ? 'You are now online'
              : 'You are now offline',
          isOnline: event.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      } catch (e) {
        emit(HomeTabError(
          error: 'Failed to update online status: ${e.toString()}',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      }
    });

    // Fetch Today's Stats
    on<FetchTodayStats>((event, emit) async {
      emit(HomeTabLoading(
        isOnline: state.isOnline,
        todayStats: state.todayStats,
        loadRequests: state.loadRequests,
      ));

      try {
        // TODO: Call API to fetch today's stats
        // final result = await driverRepository.getTodayStats(
        //   driverId: event.driverId,
        // );

        // For now, use mock data
        await Future.delayed(const Duration(milliseconds: 500));
        final stats = TodayStatsModel(
          completedTrips: 3,
          earnedAmount: 35000.0,
          traveledDistance: 250.0,
        );

        emit(TodayStatsFetched(
          message: 'Stats fetched successfully',
          isOnline: state.isOnline,
          todayStats: stats,
          loadRequests: state.loadRequests,
        ));
      } catch (e) {
        emit(HomeTabError(
          error: 'Failed to fetch today\'s stats: ${e.toString()}',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      }
    });

    // Fetch Load Requests
    on<FetchLoadRequests>((event, emit) async {
      emit(HomeTabLoading(
        isOnline: state.isOnline,
        todayStats: state.todayStats,
        loadRequests: state.loadRequests,
      ));

      try {
        // TODO: Call API to fetch available load requests
        // final result = await driverRepository.getAvailableLoadRequests(
        //   driverId: event.driverId,
        // );

        // For now, use mock data
        await Future.delayed(const Duration(milliseconds: 500));
        final loadRequests = [
          LoadRequestModel(
            loadRequestId: '1',
            route: 'Mumbai to Delhi',
            fromLocation: 'Mumbai',
            toLocation: 'Delhi',
            capacity: '10 Ton',
            price: 15000.0,
          ),
          LoadRequestModel(
            loadRequestId: '2',
            route: 'Pune to Bangalore',
            fromLocation: 'Pune',
            toLocation: 'Bangalore',
            capacity: '5 Ton',
            price: 12500.0,
          ),
          LoadRequestModel(
            loadRequestId: '3',
            route: 'Chennai to Hyderabad',
            fromLocation: 'Chennai',
            toLocation: 'Hyderabad',
            capacity: '8 Ton',
            price: 10000.0,
          ),
        ];

        emit(LoadRequestsFetched(
          message: 'Load requests fetched successfully',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: loadRequests,
        ));
      } catch (e) {
        emit(HomeTabError(
          error: 'Failed to fetch load requests: ${e.toString()}',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      }
    });

    // Accept Load Request
    on<AcceptLoadRequest>((event, emit) async {
      emit(HomeTabLoading(
        isOnline: state.isOnline,
        todayStats: state.todayStats,
        loadRequests: state.loadRequests,
      ));

      try {
        // TODO: Call API to accept load request
        // final result = await driverRepository.acceptLoadRequest(
        //   loadRequestId: event.loadRequestId,
        // );

        // For now, simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        // Remove accepted load from the list
        final updatedLoadRequests = state.loadRequests
            .where((load) => load.loadRequestId != event.loadRequestId)
            .toList();

        emit(LoadRequestAccepted(
          message: 'Load request accepted successfully',
          loadRequestId: event.loadRequestId,
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: updatedLoadRequests,
        ));
      } catch (e) {
        emit(HomeTabError(
          error: 'Failed to accept load request: ${e.toString()}',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      }
    });

    // Decline Load Request
    on<DeclineLoadRequest>((event, emit) async {
      emit(HomeTabLoading(
        isOnline: state.isOnline,
        todayStats: state.todayStats,
        loadRequests: state.loadRequests,
      ));

      try {
        // TODO: Call API to decline load request
        // final result = await driverRepository.declineLoadRequest(
        //   loadRequestId: event.loadRequestId,
        // );

        // For now, simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        // Remove declined load from the list
        final updatedLoadRequests = state.loadRequests
            .where((load) => load.loadRequestId != event.loadRequestId)
            .toList();

        emit(LoadRequestDeclined(
          message: 'Load request declined',
          loadRequestId: event.loadRequestId,
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: updatedLoadRequests,
        ));
      } catch (e) {
        emit(HomeTabError(
          error: 'Failed to decline load request: ${e.toString()}',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      }
    });

    // Submit Quote
    on<SubmitQuote>((event, emit) async {
      emit(HomeTabLoading(
        isOnline: state.isOnline,
        todayStats: state.todayStats,
        loadRequests: state.loadRequests,
      ));

      try {
        // TODO: Call API to submit quote
        // final result = await driverRepository.submitQuote(
        //   loadRequestId: event.loadRequestId,
        //   driverId: event.driverId,
        //   quotePrice: event.quotePrice,
        // );

        // For now, simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        // Update the load request with the new quote price
        final updatedLoadRequests = state.loadRequests.map((load) {
          if (load.loadRequestId == event.loadRequestId) {
            return LoadRequestModel(
              loadRequestId: load.loadRequestId,
              route: load.route,
              fromLocation: load.fromLocation,
              toLocation: load.toLocation,
              capacity: load.capacity,
              price: event.quotePrice,
              description: load.description,
              pickupDateTime: load.pickupDateTime,
              startDate: load.startDate,
              endDate: load.endDate,
            );
          }
          return load;
        }).toList();

        emit(QuoteSubmitted(
          message: 'Quote submitted successfully for ₹${event.quotePrice.toStringAsFixed(0)}',
          loadRequestId: event.loadRequestId,
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: updatedLoadRequests,
        ));
      } catch (e) {
        emit(HomeTabError(
          error: 'Failed to submit quote: ${e.toString()}',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      }
    });

    // Refresh Home Tab (Fetch both stats and load requests)
    on<RefreshHomeTab>((event, emit) async {
      try {
        // TODO: Call APIs to fetch both stats and load requests
        // final statsResult = await driverRepository.getTodayStats(
        //   driverId: event.driverId,
        // );
        // final loadsResult = await driverRepository.getAvailableLoadRequests(
        //   driverId: event.driverId,
        // );

        // For now, use mock data
        await Future.delayed(const Duration(milliseconds: 500));

        final stats = TodayStatsModel(
          completedTrips: 3,
          earnedAmount: 35000.0,
          traveledDistance: 250.0,
        );

        final loadRequests = [
          LoadRequestModel(
            loadRequestId: '1',
            route: 'Mumbai to Delhi',
            fromLocation: 'Mumbai',
            toLocation: 'Delhi',
            capacity: '10 Ton',
            price: 15000.0,
          ),
          LoadRequestModel(
            loadRequestId: '2',
            route: 'Pune to Bangalore',
            fromLocation: 'Pune',
            toLocation: 'Bangalore',
            capacity: '5 Ton',
            price: 12500.0,
          ),
          LoadRequestModel(
            loadRequestId: '3',
            route: 'Chennai to Hyderabad',
            fromLocation: 'Chennai',
            toLocation: 'Hyderabad',
            capacity: '8 Ton',
            price: 10000.0,
          ),
        ];

        emit(HomeTabSuccess(
          message: 'Data refreshed successfully',
          isOnline: state.isOnline,
          todayStats: stats,
          loadRequests: loadRequests,
        ));
      } catch (e) {
        emit(HomeTabError(
          error: 'Failed to refresh data: ${e.toString()}',
          isOnline: state.isOnline,
          todayStats: state.todayStats,
          loadRequests: state.loadRequests,
        ));
      }
    });
  }
}