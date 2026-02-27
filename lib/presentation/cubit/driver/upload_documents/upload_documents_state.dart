import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

class UploadDocumentsState extends BaseEventState {
  final String? dlNumber;
  final String? rcNumber;
  final bool hasDrivingLicense;
  final bool hasRegistrationCertificate;
  final bool isLoadingDocuments;

  UploadDocumentsState({
    this.dlNumber,
    this.rcNumber,
    this.hasDrivingLicense = false,
    this.hasRegistrationCertificate = false,
    this.isLoadingDocuments = false,
  });

  UploadDocumentsState copyWith({
    String? dlNumber,
    String? rcNumber,
    bool? hasDrivingLicense,
    bool? hasRegistrationCertificate,
    bool? isLoadingDocuments,
  }) {
    return UploadDocumentsState(
      dlNumber: dlNumber ?? this.dlNumber,
      rcNumber: rcNumber ?? this.rcNumber,
      hasDrivingLicense: hasDrivingLicense ?? this.hasDrivingLicense,
      hasRegistrationCertificate: hasRegistrationCertificate ?? this.hasRegistrationCertificate,
      isLoadingDocuments: isLoadingDocuments ?? this.isLoadingDocuments,
    );
  }

  @override
  List<Object?> get props => [dlNumber, rcNumber, hasDrivingLicense, hasRegistrationCertificate, isLoadingDocuments];
}

class UploadDocumentsInitial extends UploadDocumentsState {}

class UploadDocumentsLoading extends UploadDocumentsState {
  UploadDocumentsLoading({
    super.dlNumber,
    super.rcNumber,
    super.hasDrivingLicense,
    super.hasRegistrationCertificate,
    super.isLoadingDocuments,
  });
}

class DocumentsFetched extends UploadDocumentsState {
  DocumentsFetched({
    super.dlNumber,
    super.rcNumber,
    super.hasDrivingLicense,
    super.hasRegistrationCertificate,
  });

  @override
  List<Object?> get props => [hasDrivingLicense, hasRegistrationCertificate];
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
