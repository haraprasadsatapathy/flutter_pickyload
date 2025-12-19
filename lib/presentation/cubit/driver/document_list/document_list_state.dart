import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';
import '../../../../domain/models/document_list_response.dart';

// Base state class for Document List feature
class DocumentListState extends BaseEventState {
  final List<DocumentInfo> documents;
  final int totalCount;

  DocumentListState({
    this.documents = const [],
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [documents, totalCount];
}

/// Initial state
class DocumentListInitial extends DocumentListState {
  DocumentListInitial() : super();
}

/// Loading state - retains existing documents while loading
class DocumentListLoading extends DocumentListState {
  DocumentListLoading({
    super.documents,
    super.totalCount,
  });
}

/// Success state - documents fetched successfully
class DocumentListSuccess extends DocumentListState {
  final String message;

  DocumentListSuccess({
    required this.message,
    required super.documents,
    required super.totalCount,
  });

  @override
  List<Object?> get props => [message, documents, totalCount];
}

/// Error state - error occurred while fetching documents
class DocumentListError extends DocumentListState {
  final String error;

  DocumentListError({
    required this.error,
    super.documents,
    super.totalCount,
  });

  @override
  List<Object?> get props => [error, documents, totalCount];
}
