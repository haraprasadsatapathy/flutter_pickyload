import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Document List feature
class DocumentListEvent extends BaseEventState {}

/// Event to fetch all documents for a user
class FetchDocuments extends DocumentListEvent {
  final String userId;

  FetchDocuments({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to refresh documents list
class RefreshDocuments extends DocumentListEvent {
  final String userId;

  RefreshDocuments({required this.userId});

  @override
  List<Object?> get props => [userId];
}
