import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base state class for Upload Documents feature
class UploadDocumentsState extends BaseEventState {
  final String? dlFrontPath;
  final String? dlBackPath;
  final String? rcFrontPath;
  final String? rcBackPath;
  final String? dlNumber;
  final String? rcNumber;
  final String? userId;

  UploadDocumentsState({
    this.dlFrontPath,
    this.dlBackPath,
    this.rcFrontPath,
    this.rcBackPath,
    this.dlNumber,
    this.rcNumber,
    this.userId,
  });

  UploadDocumentsState copyWith({
    String? dlFrontPath,
    String? dlBackPath,
    String? rcFrontPath,
    String? rcBackPath,
    String? dlNumber,
    String? rcNumber,
    String? userId,
  }) {
    return UploadDocumentsState(
      dlFrontPath: dlFrontPath ?? this.dlFrontPath,
      dlBackPath: dlBackPath ?? this.dlBackPath,
      rcFrontPath: rcFrontPath ?? this.rcFrontPath,
      rcBackPath: rcBackPath ?? this.rcBackPath,
      dlNumber: dlNumber ?? this.dlNumber,
      rcNumber: rcNumber ?? this.rcNumber,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        dlFrontPath,
        dlBackPath,
        rcFrontPath,
        rcBackPath,
        dlNumber,
        rcNumber,
        userId,
      ];
}

// Initial state
class UploadDocumentsInitial extends UploadDocumentsState {}

// Loading state
class UploadDocumentsLoading extends UploadDocumentsState {
  UploadDocumentsLoading({
    super.dlFrontPath,
    super.dlBackPath,
    super.rcFrontPath,
    super.rcBackPath,
    super.dlNumber,
    super.rcNumber,
    super.userId,
  });
}

// Document uploaded successfully
class DocumentUploaded extends UploadDocumentsState {
  final String message;

  DocumentUploaded({
    required this.message,
    super.dlFrontPath,
    super.dlBackPath,
    super.rcFrontPath,
    super.rcBackPath,
    super.dlNumber,
    super.rcNumber,
    super.userId,
  });

  @override
  List<Object?> get props => [
        message,
        dlFrontPath,
        dlBackPath,
        rcFrontPath,
        rcBackPath,
        dlNumber,
        rcNumber,
        userId,
      ];
}

// Document upload failed
class DocumentUploadError extends UploadDocumentsState {
  final String error;

  DocumentUploadError({
    required this.error,
    super.dlFrontPath,
    super.dlBackPath,
    super.rcFrontPath,
    super.rcBackPath,
    super.dlNumber,
    super.rcNumber,
    super.userId,
  });

  @override
  List<Object?> get props => [
        error,
        dlFrontPath,
        dlBackPath,
        rcFrontPath,
        rcBackPath,
        dlNumber,
        rcNumber,
        userId,
      ];
}

// All documents submitted successfully
class DocumentsSubmittedSuccess extends UploadDocumentsState {
  final String message;

  DocumentsSubmittedSuccess({
    required this.message,
    super.dlFrontPath,
    super.dlBackPath,
    super.rcFrontPath,
    super.rcBackPath,
    super.dlNumber,
    super.rcNumber,
    super.userId,
  });

  @override
  List<Object?> get props => [
        message,
        dlFrontPath,
        dlBackPath,
        rcFrontPath,
        rcBackPath,
        dlNumber,
        rcNumber,
        userId,
      ];
}

// Document submission failed
class DocumentsSubmissionError extends UploadDocumentsState {
  final String error;

  DocumentsSubmissionError({
    required this.error,
    super.dlFrontPath,
    super.dlBackPath,
    super.rcFrontPath,
    super.rcBackPath,
    super.dlNumber,
    super.rcNumber,
    super.userId,
  });

  @override
  List<Object?> get props => [
        error,
        dlFrontPath,
        dlBackPath,
        rcFrontPath,
        rcBackPath,
        dlNumber,
        rcNumber,
        userId,
      ];
}

// User data loaded successfully
class UserDataLoaded extends UploadDocumentsState {
  UserDataLoaded({
    required String userId,
    super.dlFrontPath,
    super.dlBackPath,
    super.rcFrontPath,
    super.rcBackPath,
    super.dlNumber,
    super.rcNumber,
  }) : super(userId: userId);

  @override
  List<Object?> get props => [
        userId,
        dlFrontPath,
        dlBackPath,
        rcFrontPath,
        rcBackPath,
        dlNumber,
        rcNumber,
      ];
}

// User data load failed
class UserDataLoadError extends UploadDocumentsState {
  final String error;

  UserDataLoadError({required this.error});

  @override
  List<Object?> get props => [error];
}
