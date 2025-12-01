import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../../../domain/repository/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginStates> {
  // Dependencies
  final BuildContext context;
  final UserRepository userRepository;

  // Constructor
  LoginBloc(this.context, this.userRepository) : super(LoginInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Login with phone number (triggers OTP)
    on<LoginWithPhone>((event, emit) async {
      emit(OnLoading());

      // ============================================
      // BUSINESS LOGIC: Phone Number Validation
      // ============================================

      // Validation Rule 1: Check if phone number is empty
      if (event.phoneNumber.isEmpty) {
        emit(OnOtpSendError('Please enter your mobile number'));
        return;
      }

      // Validation Rule 2: Check if phone number length is exactly 10 digits
      if (event.phoneNumber.length != 10) {
        emit(OnOtpSendError('Please enter a valid 10 digit mobile number'));
        return;
      }

      // Validation Rule 3: Check if phone number contains only numeric digits
      final phoneRegex = RegExp(r'^[0-9]+$');
      if (!phoneRegex.hasMatch(event.phoneNumber)) {
        emit(OnOtpSendError('Mobile number should contain only digits'));
        return;
      }

      // ============================================
      // BUSINESS LOGIC: Send OTP to Phone Number
      // ============================================

      try {
        // Call API to send OTP to phone number
        final result = await userRepository.loginUser(event.phoneNumber);

        if (result.status == true && result.data != null) {
          // OTP sent successfully
          final otpData = result.data!.data;

          // Emit success state - this will trigger navigation to OTP screen
          emit(OnOtpSentSuccess(event.phoneNumber, otpData.message, otpData.otp));
        } else {
          // OTP send failed
          emit(OnOtpSendError(result.message ?? 'Failed to send OTP'));
        }
      } catch (e) {
        emit(OnOtpSendError('Failed to send OTP. Please try again.'));
      }
    });

    // Navigate to register
    on<NavigateToRegister>((event, emit) {
      emit(OnNavigateToRegister());
    });
  }
}
