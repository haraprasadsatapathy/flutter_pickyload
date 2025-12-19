import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'document_list_event.dart';
import 'document_list_state.dart';

class DocumentListBloc extends Bloc<DocumentListEvent, DocumentListState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  DocumentListBloc({
    required this.context,
    required this.driverRepository,
  }) : super(DocumentListInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch Documents
    on<FetchDocuments>((event, emit) async {
      // Emit loading state with existing documents (if any)
      emit(DocumentListLoading(
        documents: state.documents,
        totalCount: state.totalCount,
      ));

      // ============================================
      // BUSINESS LOGIC: Fetch Documents from API
      // ============================================

      try {
        final response = await driverRepository.getAllDocuments(
          userId: event.userId,
        );

        if (response.status == true && response.data != null) {
          // Success - documents fetched
          emit(DocumentListSuccess(
            message: response.message ?? 'Documents loaded successfully',
            documents: response.data!.documents,
            totalCount: response.data!.count,
          ));
        } else {
          // API returned error
          emit(DocumentListError(
            error: response.message ?? 'Failed to load documents',
            documents: state.documents,
            totalCount: state.totalCount,
          ));
        }
      } catch (e) {
        // Exception occurred
        emit(DocumentListError(
          error: 'An error occurred while fetching documents: ${e.toString()}',
          documents: state.documents,
          totalCount: state.totalCount,
        ));
      }
    });

    // Refresh Documents
    on<RefreshDocuments>((event, emit) async {
      // ============================================
      // BUSINESS LOGIC: Refresh Documents List
      // ============================================

      try {
        final response = await driverRepository.getAllDocuments(
          userId: event.userId,
        );

        if (response.status == true && response.data != null) {
          // Success - documents refreshed
          emit(DocumentListSuccess(
            message: 'Documents refreshed',
            documents: response.data!.documents,
            totalCount: response.data!.count,
          ));
        } else {
          // API returned error
          emit(DocumentListError(
            error: response.message ?? 'Failed to refresh documents',
            documents: state.documents,
            totalCount: state.totalCount,
          ));
        }
      } catch (e) {
        // Exception occurred
        emit(DocumentListError(
          error: 'An error occurred while refreshing documents: ${e.toString()}',
          documents: state.documents,
          totalCount: state.totalCount,
        ));
      }
    });
  }
}
