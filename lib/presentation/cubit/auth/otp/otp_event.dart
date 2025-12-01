import 'package:picky_load3/presentation/cubit/base/baseEventState.dart';

// Base event class for OTP verification feature
abstract class OtpEvent extends BaseEventState {}

// Event to verify OTP
class VerifyOtp extends OtpEvent {
  final String phoneNumber;
  final String otp;

  VerifyOtp({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

// Event to resend OTP
class ResendOtp extends OtpEvent {
  final String phoneNumber;

  ResendOtp({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

// Event to update resend timer
class UpdateResendTimer extends OtpEvent {
  final int seconds;

  UpdateResendTimer(this.seconds);

  @override
  List<Object?> get props => [seconds];
}
