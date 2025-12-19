import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'upload_documents_event.dart';
import 'upload_documents_state.dart';

class UploadDocumentsBloc
    extends Bloc<UploadDocumentsEvent, UploadDocumentsState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;
  final String userId;

  // Constructor
  UploadDocumentsBloc({
    required this.context,
    required this.driverRepository,
    required this.userId,
  }) : super(UploadDocumentsInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Upload DL Front
    on<UploadDlFront>((event, emit) async {
      emit(DocumentUploaded(
        message: 'DL front uploaded',
        dlFrontPath: event.imagePath,
        dlBackPath: state.dlBackPath,
        rcFrontPath: state.rcFrontPath,
        rcBackPath: state.rcBackPath,
        dlNumber: state.dlNumber,
        rcNumber: state.rcNumber,
      ));
    });

    // Upload DL Back
    on<UploadDlBack>((event, emit) async {
      emit(DocumentUploaded(
        message: 'DL back uploaded',
        dlFrontPath: state.dlFrontPath,
        dlBackPath: event.imagePath,
        rcFrontPath: state.rcFrontPath,
        rcBackPath: state.rcBackPath,
        dlNumber: state.dlNumber,
        rcNumber: state.rcNumber,
      ));
    });

    // Upload RC Front
    on<UploadRcFront>((event, emit) async {
      emit(DocumentUploaded(
        message: 'RC front uploaded',
        dlFrontPath: state.dlFrontPath,
        dlBackPath: state.dlBackPath,
        rcFrontPath: event.imagePath,
        rcBackPath: state.rcBackPath,
        dlNumber: state.dlNumber,
        rcNumber: state.rcNumber,
      ));
    });

    // Upload RC Back
    on<UploadRcBack>((event, emit) async {
      emit(DocumentUploaded(
        message: 'RC back uploaded',
        dlFrontPath: state.dlFrontPath,
        dlBackPath: state.dlBackPath,
        rcFrontPath: state.rcFrontPath,
        rcBackPath: event.imagePath,
        dlNumber: state.dlNumber,
        rcNumber: state.rcNumber,
      ));
    });

    // Update DL Number
    on<UpdateDlNumber>((event, emit) async {
      emit(state.copyWith(dlNumber: event.dlNumber));
    });

    // Update RC Number
    on<UpdateRcNumber>((event, emit) async {
      emit(state.copyWith(rcNumber: event.rcNumber));
    });

    // Submit single document (for new UI)
    on<SubmitSingleDocument>((event, emit) async {
      emit(UploadDocumentsLoading(
        dlFrontPath: state.dlFrontPath,
        dlBackPath: state.dlBackPath,
        rcFrontPath: state.rcFrontPath,
        rcBackPath: state.rcBackPath,
        dlNumber: state.dlNumber,
        rcNumber: state.rcNumber,
      ));

      try {
        // Map UI document types to API document types
        String apiDocumentType;
        switch (event.documentType) {
          case 'Driving License (DL)':
            apiDocumentType = 'DrivingLicense';
            break;
          case 'Registration Certificate (RC)':
            apiDocumentType = 'RegistrationCertificate';
            break;
          case 'Aadhaar Card':
            apiDocumentType = 'AadhaarCard';
            break;
          case 'Passport':
            apiDocumentType = 'Passport';
            break;
          case 'PAN Card':
            apiDocumentType = 'PANCard';
            break;
          case 'Voter ID':
            apiDocumentType = 'VoterID';
            break;
          default:
            // This should never happen due to UI validation
            apiDocumentType = 'DrivingLicense';
        }

        // Call the generic uploadDocument API without image
        final response = await driverRepository.uploadDocument(
          userId: userId,
          documentType: apiDocumentType,
          documentNumber: event.documentNumber,
          documentImagePath: null, // No image upload
          validTill: DateTime.now().add(const Duration(days: 365 * 5)), // 5 years validity
          verifiedOn: DateTime.now(),
        );

        if (response.status == true) {
          emit(DocumentsSubmittedSuccess(
            message: response.message ?? 'Document uploaded successfully',
            dlFrontPath: state.dlFrontPath,
            dlBackPath: state.dlBackPath,
            rcFrontPath: state.rcFrontPath,
            rcBackPath: state.rcBackPath,
            dlNumber: state.dlNumber,
            rcNumber: state.rcNumber,
          ));
        } else {
          emit(DocumentsSubmissionError(
            error: response.message ?? 'Failed to upload document',
            dlFrontPath: state.dlFrontPath,
            dlBackPath: state.dlBackPath,
            rcFrontPath: state.rcFrontPath,
            rcBackPath: state.rcBackPath,
            dlNumber: state.dlNumber,
            rcNumber: state.rcNumber,
          ));
        }
      } catch (e) {
        emit(DocumentsSubmissionError(
          error: 'Failed to submit document: ${e.toString()}',
          dlFrontPath: state.dlFrontPath,
          dlBackPath: state.dlBackPath,
          rcFrontPath: state.rcFrontPath,
          rcBackPath: state.rcBackPath,
          dlNumber: state.dlNumber,
          rcNumber: state.rcNumber,
        ));
      }
    });

    // Submit all documents
    on<SubmitDocuments>((event, emit) async {
      emit(UploadDocumentsLoading(
        dlFrontPath: state.dlFrontPath,
        dlBackPath: state.dlBackPath,
        rcFrontPath: state.rcFrontPath,
        rcBackPath: state.rcBackPath,
        dlNumber: state.dlNumber,
        rcNumber: state.rcNumber,
      ));

      // ============================================
      // BUSINESS LOGIC: Document Validation
      // ============================================

      // Validation Rule 1: Check if all documents are uploaded
      if (state.dlFrontPath == null ||
          state.dlBackPath == null ||
          state.rcFrontPath == null ||
          state.rcBackPath == null) {
        emit(DocumentsSubmissionError(
          error: 'Please upload all documents',
          dlFrontPath: state.dlFrontPath,
          dlBackPath: state.dlBackPath,
          rcFrontPath: state.rcFrontPath,
          rcBackPath: state.rcBackPath,
          dlNumber: state.dlNumber,
          rcNumber: state.rcNumber,
        ));
        return;
      }

      // Validation Rule 2: Check if all document numbers are provided
      if (state.dlNumber == null ||
          state.dlNumber!.isEmpty ||
          state.rcNumber == null ||
          state.rcNumber!.isEmpty) {
        emit(DocumentsSubmissionError(
          error: 'Please enter all document numbers',
          dlFrontPath: state.dlFrontPath,
          dlBackPath: state.dlBackPath,
          rcFrontPath: state.rcFrontPath,
          rcBackPath: state.rcBackPath,
          dlNumber: state.dlNumber,
          rcNumber: state.rcNumber,
        ));
        return;
      }

      // ============================================
      // BUSINESS LOGIC: Submit Documents to Server
      // ============================================

      try {
        // Upload Driving License
        final dlResponse = await driverRepository.uploadDrivingLicense(
          userId: userId,
          dlNumber: state.dlNumber!,
          dlImagePath: state.dlFrontPath, // Using front image for DL
          validTill: DateTime.now().add(const Duration(days: 365 * 5)), // 5 years validity
        );

        if (dlResponse.status != true) {
          emit(DocumentsSubmissionError(
            error: dlResponse.message ?? 'Failed to upload Driving License',
            dlFrontPath: state.dlFrontPath,
            dlBackPath: state.dlBackPath,
            rcFrontPath: state.rcFrontPath,
            rcBackPath: state.rcBackPath,
            dlNumber: state.dlNumber,
            rcNumber: state.rcNumber,
          ));
          return;
        }

        // Upload Registration Certificate
        final rcResponse = await driverRepository.uploadRegistrationCertificate(
          userId: userId,
          rcNumber: state.rcNumber!,
          rcImagePath: state.rcFrontPath, // Using front image for RC
          validTill: DateTime.now().add(const Duration(days: 365 * 10)), // 10 years validity
        );

        if (rcResponse.status != true) {
          emit(DocumentsSubmissionError(
            error: rcResponse.message ?? 'Failed to upload Registration Certificate',
            dlFrontPath: state.dlFrontPath,
            dlBackPath: state.dlBackPath,
            rcFrontPath: state.rcFrontPath,
            rcBackPath: state.rcBackPath,
            dlNumber: state.dlNumber,
            rcNumber: state.rcNumber,
          ));
          return;
        }

        // Both documents uploaded successfully
        emit(DocumentsSubmittedSuccess(
          message: 'All documents submitted successfully',
          dlFrontPath: state.dlFrontPath,
          dlBackPath: state.dlBackPath,
          rcFrontPath: state.rcFrontPath,
          rcBackPath: state.rcBackPath,
          dlNumber: state.dlNumber,
          rcNumber: state.rcNumber,
        ));
      } catch (e) {
        emit(DocumentsSubmissionError(
          error: 'Failed to submit documents: ${e.toString()}',
          dlFrontPath: state.dlFrontPath,
          dlBackPath: state.dlBackPath,
          rcFrontPath: state.rcFrontPath,
          rcBackPath: state.rcBackPath,
          dlNumber: state.dlNumber,
          rcNumber: state.rcNumber,
        ));
      }
    });
  }
}
