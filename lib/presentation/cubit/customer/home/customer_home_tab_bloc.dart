import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/customer_repository.dart';
import 'customer_home_tab_event.dart';
import 'customer_home_tab_state.dart';

class CustomerHomeTabBloc extends Bloc<CustomerHomeTabEvent, CustomerHomeTabState> {
  final CustomerRepository customerRepository;

  CustomerHomeTabBloc(this.customerRepository) : super(CustomerHomeTabInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Load user data from SharedPreferences
    on<LoadUserData>((event, emit) async {
      emit(CustomerHomeTabLoading(
        user: state.user,
        bookingStatus: state.bookingStatus,
        bookingDetails: state.bookingDetails,
        ongoingTrips: state.ongoingTrips,
      ));

      try {
        final user = await customerRepository.getUserDetailsSp();

        if (user == null) {
          emit(CustomerHomeTabError(
            error: 'User not found. Please login again.',
            user: null,
            bookingStatus: state.bookingStatus,
            bookingDetails: state.bookingDetails,
            ongoingTrips: state.ongoingTrips,
          ));
          return;
        }

        debugPrint('CustomerHomeTabBloc: User loaded - ${user.name}');

        emit(CustomerHomeTabLoaded(
          user: user,
          message: 'User data loaded successfully',
          bookingStatus: state.bookingStatus,
          bookingDetails: state.bookingDetails,
          ongoingTrips: state.ongoingTrips,
        ));

        // Automatically fetch home page data after loading user
        add(FetchHomePage());
      } catch (e) {
        debugPrint('CustomerHomeTabBloc: Error loading user data: $e');
        emit(CustomerHomeTabError(
          error: 'Failed to load user data: ${e.toString()}',
          user: state.user,
          bookingStatus: state.bookingStatus,
          bookingDetails: state.bookingDetails,
          ongoingTrips: state.ongoingTrips,
        ));
      }
    });

    // Fetch home page data from API
    on<FetchHomePage>((event, emit) async {
      emit(CustomerHomeTabLoading(
        user: state.user,
        bookingStatus: state.bookingStatus,
        bookingDetails: state.bookingDetails,
        ongoingTrips: state.ongoingTrips,
      ));

      try {
        // Get user details from SharedPreferences
        final user = state.user ?? await customerRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(CustomerHomeTabError(
            error: 'User ID not found. Please login again.',
            user: state.user,
            bookingStatus: state.bookingStatus,
            bookingDetails: state.bookingDetails,
            ongoingTrips: state.ongoingTrips,
          ));
          return;
        }

        final userId = user.id;
        debugPrint('CustomerHomeTabBloc: Fetching home page for userId: $userId');

        final response = await customerRepository.getHomePage(userId: userId);

        debugPrint('CustomerHomeTabBloc: Response status: ${response.status}, message: ${response.message}');

        if (response.status == true && response.data != null) {
          debugPrint('CustomerHomeTabBloc: Fetched ${response.data!.data.bookingDetails.length} bookings and ${response.data!.data.ongoingTrips.length} ongoing trips');
          emit(CustomerHomeTabSuccess(
            message: response.data!.message,
            user: user,
            bookingStatus: response.data!.data.bookingStatus,
            bookingDetails: response.data!.data.bookingDetails,
            ongoingTrips: response.data!.data.ongoingTrips,
          ));
        } else {
          emit(CustomerHomeTabError(
            error: response.message ?? 'Failed to fetch home page data',
            user: user,
            bookingStatus: state.bookingStatus,
            bookingDetails: state.bookingDetails,
            ongoingTrips: state.ongoingTrips,
          ));
        }
      } catch (e) {
        debugPrint('CustomerHomeTabBloc: Error fetching home page: $e');
        emit(CustomerHomeTabError(
          error: 'Failed to fetch home page data: ${e.toString()}',
          user: state.user,
          bookingStatus: state.bookingStatus,
          bookingDetails: state.bookingDetails,
          ongoingTrips: state.ongoingTrips,
        ));
      }
    });

    // Refresh home page data
    on<RefreshHomePage>((event, emit) async {
      try {
        // Get user details from SharedPreferences
        final user = state.user ?? await customerRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(CustomerHomeTabError(
            error: 'User ID not found. Please login again.',
            user: state.user,
            bookingStatus: state.bookingStatus,
            bookingDetails: state.bookingDetails,
            ongoingTrips: state.ongoingTrips,
          ));
          return;
        }

        final userId = user.id;
        debugPrint('CustomerHomeTabBloc: Refreshing home page for userId: $userId');

        final response = await customerRepository.getHomePage(userId: userId);

        if (response.status == true && response.data != null) {
          emit(CustomerHomeTabSuccess(
            message: 'Data refreshed successfully',
            user: user,
            bookingStatus: response.data!.data.bookingStatus,
            bookingDetails: response.data!.data.bookingDetails,
            ongoingTrips: response.data!.data.ongoingTrips,
          ));
        } else {
          emit(CustomerHomeTabError(
            error: response.message ?? 'Failed to refresh data',
            user: user,
            bookingStatus: state.bookingStatus,
            bookingDetails: state.bookingDetails,
            ongoingTrips: state.ongoingTrips,
          ));
        }
      } catch (e) {
        debugPrint('CustomerHomeTabBloc: Error refreshing home page: $e');
        emit(CustomerHomeTabError(
          error: 'Failed to refresh data: ${e.toString()}',
          user: state.user,
          bookingStatus: state.bookingStatus,
          bookingDetails: state.bookingDetails,
          ongoingTrips: state.ongoingTrips,
        ));
      }
    });

    // Logout user
    on<LogoutUser>((event, emit) async {
      emit(CustomerHomeTabLoading(user: state.user));

      try {
        await customerRepository.logout();

        debugPrint('CustomerHomeTabBloc: User logged out successfully');

        emit(CustomerHomeTabLoggedOut());
      } catch (e) {
        debugPrint('CustomerHomeTabBloc: Error during logout: $e');
        emit(CustomerHomeTabError(
          error: 'Failed to logout: ${e.toString()}',
          user: state.user,
          bookingStatus: state.bookingStatus,
          bookingDetails: state.bookingDetails,
          ongoingTrips: state.ongoingTrips,
        ));
      }
    });
  }
}
