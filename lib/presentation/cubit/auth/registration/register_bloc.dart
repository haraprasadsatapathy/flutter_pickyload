import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../../../../domain/repository/user_repository.dart';
import '../../../../models/user_model.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterStates> {
  // Dependencies
  final BuildContext context;
  final UserRepository userRepository;

  // State management fields
  UserRole selectedRole = UserRole.customer;
  bool isLoading = false;

  // Constructor
  RegisterBloc(this.context, this.userRepository)
    : super(RegisterInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Select user role event
    on<SelectUserRole>((event, emit) {
      selectedRole = event.role;
      emit(OnRoleSelected(selectedRole));
    });

    // Register user event
    on<RegisterUser>((event, emit) async {
      emit(OnLoading());

      // ============================================
      // BUSINESS LOGIC: Input Validation
      // ============================================

      // Validation Rule 1: Check if all fields are filled
      if (event.name.isEmpty || event.email.isEmpty || event.phone.isEmpty) {
        emit(OnRegisterError('Please fill all fields'));
        return;
      }

      // Validation Rule 2: Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(event.email)) {
        emit(OnRegisterError('Please enter a valid email'));
        return;
      }

      // Validation Rule 3: Validate phone format (must be 10 digits)
      if (event.phone.length != 10) {
        emit(OnRegisterError('Please enter a valid 10 digit mobile number'));
        return;
      }

      // Validation Rule 4: Phone must contain only digits
      final phoneRegex = RegExp(r'^[0-9]+$');
      if (!phoneRegex.hasMatch(event.phone)) {
        emit(OnRegisterError('Mobile number should contain only digits'));
        return;
      }

      // ============================================
      // BUSINESS LOGIC: User Registration
      // ============================================

      try {
        // Step 1: Register user
        final registerResult = await userRepository.registerUser(
          userName: event.name,
          userEmail: event.email,
          userPhone: event.phone,
          pictureUrl: event.pictureUrl,
        );

        if (registerResult.status == true && registerResult.data != null) {
          // Registration successful, now generate OTP

          // Step 2: Generate OTP for the registered phone number
          final otpResult = await userRepository.generateOtp(event.phone);

          if (otpResult.status == true && otpResult.data != null) {
            // Both registration and OTP generation successful
            final otpData = otpResult.data!.data;

            emit(
              OnRegisterSuccess(
                phoneNumber: event.phone,
                otp: otpData.otp,
                message: registerResult.data!.message,
              ),
            );
          } else {
            // OTP generation failed
            emit(
              OnRegisterError(
                otpResult.message ??
                    'Registration successful but failed to send OTP',
              ),
            );
          }
        } else {
          // Registration failed
          emit(
            OnRegisterError(registerResult.message ?? 'Registration failed'),
          );
        }
      } catch (e) {
        emit(OnRegisterError('An error occurred: ${e.toString()}'));
      }
    });

    // Navigate to login
    on<NavigateToLogin>((event, emit) {
      emit(OnNavigateToLogin());
    });
  }
}
