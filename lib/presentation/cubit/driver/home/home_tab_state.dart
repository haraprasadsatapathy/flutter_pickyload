import 'package:picky_load/presentation/cubit/base/base_event_state.dart';
import 'package:picky_load/domain/models/home_page_response.dart';

// Re-export TripDetail for convenience
export 'package:picky_load/domain/models/home_page_response.dart' show TripDetail, UserOffer;

// Base state class for Home Tab feature
class HomeTabState extends BaseEventState {
  final String loadStatus;
  final List<TripDetail> tripDetails;

  HomeTabState({
    this.loadStatus = '',
    this.tripDetails = const [],
  });

  @override
  List<Object?> get props => [loadStatus, tripDetails];
}

// Initial state
class HomeTabInitial extends HomeTabState {}

// Loading state
class HomeTabLoading extends HomeTabState {
  HomeTabLoading({
    super.loadStatus,
    super.tripDetails,
  });
}

// Home page data loaded successfully
class HomeTabSuccess extends HomeTabState {
  final String message;

  HomeTabSuccess({
    required this.message,
    required super.loadStatus,
    required super.tripDetails,
  });

  @override
  List<Object?> get props => [message, loadStatus, tripDetails];
}

// Error state
class HomeTabError extends HomeTabState {
  final String error;

  HomeTabError({
    required this.error,
    super.loadStatus,
    super.tripDetails,
  });

  @override
  List<Object?> get props => [error, loadStatus, tripDetails];
}
