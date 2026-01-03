import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

class UploadDocumentsEvent extends BaseEventState {}

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
