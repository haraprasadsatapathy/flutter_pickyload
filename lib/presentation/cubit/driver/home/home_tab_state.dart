import 'package:picky_load/presentation/cubit/base/base_event_state.dart';
import 'package:picky_load/domain/models/home_page_response.dart';
import 'package:picky_load/domain/models/document_list_response.dart';

// Re-export TripDetail for convenience
export 'package:picky_load/domain/models/home_page_response.dart' show TripDetail, UserOffer;
export 'package:picky_load/domain/models/document_list_response.dart' show DocumentInfo;

// Base state class for Home Tab feature
class HomeTabState extends BaseEventState {
  final String loadStatus;
  final List<TripDetail> tripDetails;
  final List<DocumentInfo> documents;
  final bool isDocumentsLoading;

  HomeTabState({
    this.loadStatus = '',
    this.tripDetails = const [],
    this.documents = const [],
    this.isDocumentsLoading = false,
  });

  @override
  List<Object?> get props => [loadStatus, tripDetails, documents, isDocumentsLoading];
}

// Initial state
class HomeTabInitial extends HomeTabState {}

// Loading state
class HomeTabLoading extends HomeTabState {
  HomeTabLoading({
    super.loadStatus,
    super.tripDetails,
    super.documents,
    super.isDocumentsLoading,
  });
}

// Home page data loaded successfully
class HomeTabSuccess extends HomeTabState {
  final String message;

  HomeTabSuccess({
    required this.message,
    required super.loadStatus,
    required super.tripDetails,
    super.documents,
    super.isDocumentsLoading,
  });

  @override
  List<Object?> get props => [message, loadStatus, tripDetails, documents, isDocumentsLoading];
}

// Error state
class HomeTabError extends HomeTabState {
  final String error;

  HomeTabError({
    required this.error,
    super.loadStatus,
    super.tripDetails,
    super.documents,
    super.isDocumentsLoading,
  });

  @override
  List<Object?> get props => [error, loadStatus, tripDetails, documents, isDocumentsLoading];
}

// Documents loaded state
class DocumentsFetched extends HomeTabState {
  final String message;

  DocumentsFetched({
    required this.message,
    required super.documents,
    super.loadStatus,
    super.tripDetails,
  });

  @override
  List<Object?> get props => [message, loadStatus, tripDetails, documents];
}
