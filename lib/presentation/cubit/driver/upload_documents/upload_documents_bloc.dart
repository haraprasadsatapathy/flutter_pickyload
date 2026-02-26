import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'upload_documents_event.dart';
import 'upload_documents_state.dart';

class UploadDocumentsBloc extends Bloc<UploadDocumentsEvent, UploadDocumentsState> {
  final BuildContext context;
  final DriverRepository driverRepository;

  UploadDocumentsBloc({
    required this.context,
    required this.driverRepository,
  }) : super(UploadDocumentsInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<FetchExistingDocuments>((event, emit) async {
      try {
        emit(state.copyWith(isLoadingDocuments: true));

        final currentUser = await driverRepository.getUserDetailsSp();
        if (currentUser == null) {
          emit(state.copyWith(isLoadingDocuments: false));
          return;
        }

        final response = await driverRepository.getAllDocuments(userId: currentUser.id);

        if (response.status == true && response.data != null) {
          final documents = response.data!.documents;

          final hasDL = documents.any((doc) => doc.documentType == 'DrivingLicense');
          final hasRC = documents.any((doc) => doc.documentType == 'RegistrationCertificate');

          emit(DocumentsFetched(
            hasDrivingLicense: hasDL,
            hasRegistrationCertificate: hasRC,
          ));
        } else {
          emit(DocumentsFetched(
            hasDrivingLicense: false,
            hasRegistrationCertificate: false,
          ));
        }
      } catch (e) {
        emit(DocumentsFetched(
          hasDrivingLicense: false,
          hasRegistrationCertificate: false,
        ));
      }
    });

    on<UpdateDlNumber>((event, emit) async {
      emit(state.copyWith(dlNumber: event.dlNumber));
    });

    on<UpdateRcNumber>((event, emit) async {
      emit(state.copyWith(rcNumber: event.rcNumber));
    });

    on<SubmitSingleDocument>((event, emit) async {
      try {
        // Preserve existing document state while loading
        emit(UploadDocumentsLoading(
          hasDrivingLicense: state.hasDrivingLicense,
          hasRegistrationCertificate: state.hasRegistrationCertificate,
        ));

        final currentUser = await driverRepository.getUserDetailsSp();

        if (currentUser == null) {
          emit(DocumentsSubmissionError(error: 'User not found. Please login again.'));
          return;
        }

        String apiDocumentType;
        switch (event.documentType) {
          case 'Driving License (DL)':
            apiDocumentType = 'DrivingLicense';
            break;
          case 'Registration Certificate (RC)':
            apiDocumentType = 'RegistrationCertificate';
            break;
          default:
            apiDocumentType = 'DrivingLicense';
        }

        final response = await driverRepository.uploadDocument(
          userId: currentUser.id,
          documentType: apiDocumentType,
          documentNumber: event.documentNumber,
          dateOfBirth: event.dateOfBirth,
          documentImagePath: null,
          validTill: DateTime.now().add(const Duration(days: 365 * 5)),
          verifiedOn: DateTime.now(),
        );

        if (response.status == true) {
          final documentId = response.data?.data?.documentId;
          final responseUserId = response.data?.data?.userId;

          emit(
            DocumentsSubmittedSuccess(
              message: response.message ?? 'Document uploaded successfully',
              documentId: documentId,
              responseUserId: responseUserId,
            ),
          );
        } else {
          emit(DocumentsSubmissionError(error: response.message ?? 'Failed to upload document'));
        }
      } catch (e) {
        emit(DocumentsSubmissionError(error: 'Failed to submit document: ${e.toString()}'));
      }
    });
  }
}
