import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Upload Documents feature
class UploadDocumentsEvent extends BaseEventState {}

// Load user data from shared preferences
class LoadUserData extends UploadDocumentsEvent {
  @override
  List<Object?> get props => [];
}

// Document upload events
class UploadDlFront extends UploadDocumentsEvent {
  final String imagePath;

  UploadDlFront(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class UploadDlBack extends UploadDocumentsEvent {
  final String imagePath;

  UploadDlBack(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class UploadRcFront extends UploadDocumentsEvent {
  final String imagePath;

  UploadRcFront(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class UploadRcBack extends UploadDocumentsEvent {
  final String imagePath;

  UploadRcBack(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// Document number update events
class UpdateDlNumber extends UploadDocumentsEvent {
  final String dlNumber;

  UpdateDlNumber(this.dlNumber);

  @override
  List<Object?> get props => [dlNumber];
}

class UpdateRcNumber extends UploadDocumentsEvent {
  final String rcNumber;

  UpdateRcNumber(this.rcNumber);

  @override
  List<Object?> get props => [rcNumber];
}

// Submit all documents for verification
class SubmitDocuments extends UploadDocumentsEvent {
  @override
  List<Object?> get props => [];
}

// Submit single document (for new UI)
class SubmitSingleDocument extends UploadDocumentsEvent {
  final String documentType;
  final String documentNumber;
  final DateTime? dateOfBirth;

  SubmitSingleDocument({
    required this.documentType,
    required this.documentNumber,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [documentType, documentNumber, dateOfBirth];
}
