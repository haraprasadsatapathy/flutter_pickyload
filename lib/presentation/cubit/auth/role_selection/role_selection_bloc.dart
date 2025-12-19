import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'role_selection_event.dart';
import 'role_selection_state.dart';
import '../../../../domain/repository/driver_repository.dart';
import '../../../../domain/repository/user_repository.dart';

class RoleSelectionBloc
    extends Bloc<RoleSelectionEvent, RoleSelectionState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;
  final UserRepository userRepository;

  // Constructor
  RoleSelectionBloc({
    required this.context,
    required this.driverRepository,
    required this.userRepository,
  }) : super(RoleSelectionInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Select Customer role
    on<SelectCustomerRole>((event, emit) async {
      emit(RoleSelectionLoading());

      try {
        // ============================================
        // BUSINESS LOGIC: Customer Role Selection
        // ============================================

        // Here you can add any business logic needed when customer role is selected
        // For example:
        // - Update user profile with selected role
        // - Store role preference locally
        // - Track analytics event

        // Emit success state
        emit(CustomerRoleSelected(message: 'Customer role selected'));
      } catch (e) {
        emit(RoleSelectionError('Failed to select customer role: ${e.toString()}'));
      }
    });

    // Select Driver role
    on<SelectDriverRole>((event, emit) async {
      emit(RoleSelectionLoading());

      try {
        // ============================================
        // BUSINESS LOGIC: Driver Role Selection
        // ============================================

        // Step 1: Get the current user ID
        final user = await userRepository.getUserDetailsSp();

        if (user == null || user.id == null) {
          emit(RoleSelectionError('User not found. Please login again.'));
          return;
        }

        // Step 2: Check if driver has uploaded documents
        final documentsResponse = await driverRepository.getAllDocuments(
          userId: user.id!,
        );

        if (documentsResponse.status == false) {
          emit(RoleSelectionError(
            documentsResponse.message ?? 'Failed to fetch documents',
          ));
          return;
        }

        // Step 3: Determine navigation based on document count
        final documentCount = documentsResponse.data?.count ?? 0;

        if (documentCount == 0) {
          // No documents - navigate to document upload screen
          emit(DriverRoleSelectedWithoutDocuments(
            message: 'Please upload your documents to continue',
          ));
        } else {
          // Documents exist - navigate to driver dashboard
          emit(DriverRoleSelectedWithDocuments(
            documentCount: documentCount,
            message: 'Welcome back! You have $documentCount document(s) on file.',
          ));
        }
      } catch (e) {
        emit(RoleSelectionError('Failed to select driver role: ${e.toString()}'));
      }
    });
  }
}
