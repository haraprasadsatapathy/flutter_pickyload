import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

class UploadDocumentsState extends BaseEventState {
  final String? dlNumber;
  final String? rcNumber;

  UploadDocumentsState({
    this.dlNumber,
    this.rcNumber,
  });

  UploadDocumentsState copyWith({
    String? dlNumber,
    String? rcNumber,
  }) {
    return UploadDocumentsState(
      dlNumber: dlNumber ?? this.dlNumber,
      rcNumber: rcNumber ?? this.rcNumber,
    );
  }

  @override
  List<Object?> get props => [dlNumber, rcNumber];
}

class UploadDocumentsInitial extends UploadDocumentsState {}

class UploadDocumentsLoading extends UploadDocumentsState {
  UploadDocumentsLoading({
    super.dlNumber,
    super.rcNumber,
  });
}

class DocumentsSubmittedSuccess extends UploadDocumentsState {
  final String message;
  final String? documentId;
  final String? responseUserId;

  DocumentsSubmittedSuccess({
    required this.message,
    this.documentId,
    this.responseUserId,
  });

  @override
  List<Object?> get props => [message, documentId, responseUserId];
}

class DocumentsSubmissionError extends UploadDocumentsState {
  final String error;

  DocumentsSubmissionError({required this.error});

  @override
  List<Object?> get props => [error];
}
