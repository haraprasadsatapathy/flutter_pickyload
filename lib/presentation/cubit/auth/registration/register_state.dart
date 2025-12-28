import 'package:picky_load/presentation/cubit/base/base_event_state.dart';
import '../../../../models/user_model.dart';

// Base state class for Register feature
class RegisterStates extends BaseEventState {}

// Initial state
class RegisterInitialState extends RegisterStates {}

// Loading state
class OnLoading extends RegisterStates {}

// Registration successful - navigate to OTP screen
class OnRegisterSuccess extends RegisterStates {
  final String phoneNumber;
  final String otp;
  final String message;

  OnRegisterSuccess({
    required this.phoneNumber,
    required this.otp,
    required this.message,
  });

  @override
  List<Object?> get props => [phoneNumber, otp, message];
}

// Registration failed
class OnRegisterError extends RegisterStates {
  final String message;

  OnRegisterError(this.message);

  @override
  List<Object?> get props => [message];
}

// Navigate to login
class OnNavigateToLogin extends RegisterStates {}

// Role selected
class OnRoleSelected extends RegisterStates {
  final UserRole selectedRole;

  OnRoleSelected(this.selectedRole);

  @override
  List<Object?> get props => [selectedRole];
}

// Error state
class OnError extends RegisterStates {
  final String message;

  OnError(this.message);

  @override
  List<Object?> get props => [message];
}
