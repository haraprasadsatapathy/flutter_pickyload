import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base state class for Login feature
class LoginStates extends BaseEventState {}

// Initial state
class LoginInitialState extends LoginStates {}

// Loading state
class OnLoading extends LoginStates {}

// OTP sent successfully
class OnOtpSentSuccess extends LoginStates {
  final String phoneNumber;
  final String message;
  final String otp;

  OnOtpSentSuccess(this.phoneNumber, this.message, this.otp);

  @override
  List<Object?> get props => [phoneNumber, message, otp];
}

// OTP sending failed
class OnOtpSendError extends LoginStates {
  final String message;

  OnOtpSendError(this.message);

  @override
  List<Object?> get props => [message];
}

// Navigate to register
class OnNavigateToRegister extends LoginStates {}
