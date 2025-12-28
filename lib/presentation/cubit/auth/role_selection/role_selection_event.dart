import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Role Selection feature
class RoleSelectionEvent extends BaseEventState {}

// Select Customer role
class SelectCustomerRole extends RoleSelectionEvent {
  SelectCustomerRole();

  @override
  List<Object?> get props => [];
}

// Select Driver role
class SelectDriverRole extends RoleSelectionEvent {
  SelectDriverRole();

  @override
  List<Object?> get props => [];
}
