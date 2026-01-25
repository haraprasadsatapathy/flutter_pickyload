import 'package:picky_load/domain/models/customer_home_page_response.dart';
import 'package:picky_load/models/user_model.dart';
import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Re-export BookingDetail and VehicleMatch for convenience
export 'package:picky_load/domain/models/customer_home_page_response.dart' show BookingDetail, VehicleMatch;

/// Base state class for Customer Home Tab feature
class CustomerHomeTabState extends BaseEventState {
  final User? user;
  final bool isLoading;
  final String bookingStatus;
  final List<BookingDetail> bookingDetails;
  final List<BookingDetail> ongoingTrips;

  CustomerHomeTabState({
    this.user,
    this.isLoading = false,
    this.bookingStatus = '',
    this.bookingDetails = const [],
    this.ongoingTrips = const [],
  });

  @override
  List<Object?> get props => [user, isLoading, bookingStatus, bookingDetails, ongoingTrips];
}

/// Initial state
class CustomerHomeTabInitial extends CustomerHomeTabState {}

/// Loading state - when fetching user data
class CustomerHomeTabLoading extends CustomerHomeTabState {
  CustomerHomeTabLoading({
    super.user,
    super.bookingStatus,
    super.bookingDetails,
    super.ongoingTrips,
  }) : super(isLoading: true);
}

/// User data loaded successfully
class CustomerHomeTabLoaded extends CustomerHomeTabState {
  final String? message;

  CustomerHomeTabLoaded({
    required User user,
    this.message,
    super.bookingStatus,
    super.bookingDetails,
    super.ongoingTrips,
  }) : super(user: user, isLoading: false);

  @override
  List<Object?> get props => [user, message, isLoading, bookingStatus, bookingDetails, ongoingTrips];
}

/// Home page data fetched successfully
class CustomerHomeTabSuccess extends CustomerHomeTabState {
  final String message;

  CustomerHomeTabSuccess({
    required this.message,
    required super.user,
    required super.bookingStatus,
    required super.bookingDetails,
    required super.ongoingTrips,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [message, user, bookingStatus, bookingDetails, ongoingTrips, isLoading];
}

/// Error state
class CustomerHomeTabError extends CustomerHomeTabState {
  final String error;

  CustomerHomeTabError({
    required this.error,
    super.user,
    super.bookingStatus,
    super.bookingDetails,
    super.ongoingTrips,
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [error, user, bookingStatus, bookingDetails, ongoingTrips, isLoading];
}

/// Logout success state
class CustomerHomeTabLoggedOut extends CustomerHomeTabState {
  CustomerHomeTabLoggedOut() : super(user: null, isLoading: false);

  @override
  List<Object?> get props => [user, isLoading];
}
