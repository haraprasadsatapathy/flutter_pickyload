import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base state class for Role Selection feature
class RoleSelectionState extends BaseEventState {}

// Initial state
class RoleSelectionInitial extends RoleSelectionState {}

// Loading state
class RoleSelectionLoading extends RoleSelectionState {}

// Customer role selected
class CustomerRoleSelected extends RoleSelectionState {
  final String message;

  CustomerRoleSelected({
    this.message = 'Customer role selected',
  });

  @override
  List<Object?> get props => [message];
}

// Driver role selected - navigate to driver dashboard (documents exist)
class DriverRoleSelectedWithDocuments extends RoleSelectionState {
  final String message;
  final int documentCount;

  DriverRoleSelectedWithDocuments({
    required this.documentCount,
    this.message = 'Driver role selected',
  });

  @override
  List<Object?> get props => [message, documentCount];
}

// Driver role selected - navigate to document upload (no documents)
class DriverRoleSelectedWithoutDocuments extends RoleSelectionState {
  final String message;

  DriverRoleSelectedWithoutDocuments({
    this.message = 'Driver role selected - please upload documents',
  });

  @override
  List<Object?> get props => [message];
}

// Role selection error
class RoleSelectionError extends RoleSelectionState {
  final String message;

  RoleSelectionError(this.message);

  @override
  List<Object?> get props => [message];
}
