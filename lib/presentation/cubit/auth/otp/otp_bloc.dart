import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_event.dart';
import 'otp_state.dart';
import '../../../../domain/repository/user_repository.dart';

class OtpBloc extends Bloc<OtpEvent, OtpStates> {
  // Dependencies
  final BuildContext context;
  final UserRepository userRepository;
  Timer? _resendTimer;

  // Constructor
  OtpBloc(this.context, this.userRepository) : super(OtpInitialState()) {
    _registerEventHandlers();
    _startResendTimer();
  }

  void _registerEventHandlers() {
    // Verify OTP
    on<VerifyOtp>((event, emit) async {
      emit(OnLoading());

      // ============================================
      // BUSINESS LOGIC: OTP Validation
      // ============================================

      // Validation Rule 1: Check if OTP is empty
      if (event.otp.isEmpty) {
        emit(OnOtpVerificationError('Please enter the OTP'));
        // Restore timer state
        _emitCurrentTimerState();
        return;
      }

      // Validation Rule 2: Check if OTP length is exactly 6 digits
      if (event.otp.length != 6) {
        emit(OnOtpVerificationError('Please enter a valid 6 digit OTP'));
        // Restore timer state
        _emitCurrentTimerState();
        return;
      }

      // Validation Rule 3: Check if OTP contains only numeric digits
      final otpRegex = RegExp(r'^[0-9]+$');
      if (!otpRegex.hasMatch(event.otp)) {
        emit(OnOtpVerificationError('OTP should contain only digits'));
        // Restore timer state
        _emitCurrentTimerState();
        return;
      }

      // ============================================
      // BUSINESS LOGIC: Verify OTP with Server
      // ============================================

      try {
        // Call API to verify OTP
        final result = await userRepository.verifyOtp(
          event.phoneNumber,
          event.otp,
        );

        if (result.status == true && result.data != null) {
          // OTP verified successfully
          // Cancel the timer as we're navigating away
          _resendTimer?.cancel();
          emit(OnOtpVerificationSuccess(
            result.message ?? 'OTP verified successfully',
          ));
        } else {
          // OTP verification failed
          emit(OnOtpVerificationError(
            result.message ?? 'Invalid OTP. Please try again.',
          ));
          // Restore timer state
          _emitCurrentTimerState();
        }
      } catch (e) {
        emit(OnOtpVerificationError(
          'Failed to verify OTP. Please try again.',
        ));
        // Restore timer state
        _emitCurrentTimerState();
      }
    });

    // Resend OTP
    on<ResendOtp>((event, emit) async {
      // ============================================
      // BUSINESS LOGIC: Resend OTP
      // ============================================

      try {
        // Call API to resend OTP
        final result = await userRepository.loginUser(event.phoneNumber);

        if (result.status == true && result.data != null) {
          // OTP resent successfully
          emit(OnResendOtpSuccess(
            result.message ?? 'OTP resent successfully',
          ));

          // Restart the resend timer
          _startResendTimer();
        } else {
          // OTP resend failed
          emit(OnResendOtpError(
            result.message ?? 'Failed to resend OTP',
          ));
          // Restore timer state
          _emitCurrentTimerState();
        }
      } catch (e) {
        emit(OnResendOtpError('Failed to resend OTP. Please try again.'));
        // Restore timer state
        _emitCurrentTimerState();
      }
    });

    // Update resend timer
    on<UpdateResendTimer>((event, emit) {
      emit(OnTimerUpdate(event.seconds));
    });
  }

  // Start the resend timer (60 seconds countdown)
  void _startResendTimer() {
    _resendTimer?.cancel();
    int remainingSeconds = 60;

    // Emit initial timer state
    add(UpdateResendTimer(remainingSeconds));

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds--;

      if (remainingSeconds >= 0) {
        add(UpdateResendTimer(remainingSeconds));
      } else {
        timer.cancel();
      }
    });
  }

  // Helper method to emit current timer state after error
  void _emitCurrentTimerState() {
    // Get current state and preserve timer if it's a timer update state
    if (state is OnTimerUpdate) {
      final currentTimer = (state as OnTimerUpdate).remainingSeconds;
      Future.delayed(const Duration(milliseconds: 100), () {
        add(UpdateResendTimer(currentTimer));
      });
    }
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
