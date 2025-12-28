import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base state class for OTP verification feature
class OtpStates extends BaseEventState {}

// Initial state
class OtpInitialState extends OtpStates {
  final int resendTimer;

  OtpInitialState({this.resendTimer = 60});

  @override
  List<Object?> get props => [resendTimer];
}

// Loading state during OTP verification
class OnLoading extends OtpStates {}

// Timer update state
class OnTimerUpdate extends OtpStates {
  final int remainingSeconds;

  OnTimerUpdate(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

// OTP verification successful
class OnOtpVerificationSuccess extends OtpStates {
  final String message;

  OnOtpVerificationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// OTP verification failed
class OnOtpVerificationError extends OtpStates {
  final String message;

  OnOtpVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// OTP resend successful
class OnResendOtpSuccess extends OtpStates {
  final String message;

  OnResendOtpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// OTP resend failed
class OnResendOtpError extends OtpStates {
  final String message;

  OnResendOtpError(this.message);

  @override
  List<Object?> get props => [message];
}
