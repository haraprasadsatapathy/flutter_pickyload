import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../domain/repository/user_repository.dart';
import '../../cubit/auth/otp/otp_bloc.dart';
import '../../cubit/auth/otp/otp_event.dart';
import '../../cubit/auth/otp/otp_state.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final String otp;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.otp = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(context, context.read<UserRepository>()),
      child: _OtpVerificationScreenContent(phoneNumber: phoneNumber, otp: otp),
    );
  }
}

class _OtpVerificationScreenContent extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const _OtpVerificationScreenContent({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<_OtpVerificationScreenContent> createState() =>
      _OtpVerificationScreenContentState();
}

class _OtpVerificationScreenContentState
    extends State<_OtpVerificationScreenContent> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-fill OTP if provided from login screen
    if (widget.otp.isNotEmpty) {
      _otpController.text = widget.otp;
    }
  }

  // @override
  // void dispose() {
  //   _otpController.dispose();
  //   super.dispose();
  // }

  void _handleVerifyOtp() {
    if (_otpController.text.length == 6) {
      // Trigger the VerifyOtp event
      context.read<OtpBloc>().add(
        VerifyOtp(phoneNumber: widget.phoneNumber, otp: _otpController.text),
      );
    }
  }

  void _handleResendOtp() {
    // Trigger the ResendOtp event
    context.read<OtpBloc>().add(ResendOtp(phoneNumber: widget.phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpStates>(
      listener: (context, state) {
        // Handle OTP verification success - navigate to role selection
        if (state is OnOtpVerificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to role selection screen
          context.go('/role-selection');
        }

        // Handle OTP verification error
        if (state is OnOtpVerificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        // Handle OTP resend success
        if (state is OnResendOtpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Handle OTP resend error
        if (state is OnResendOtpError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Verify OTP',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 50),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor: Theme.of(context).colorScheme.surface,
                    inactiveFillColor: Theme.of(context).colorScheme.surface,
                    selectedFillColor: Theme.of(context).colorScheme.surface,
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Colors.grey,
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                  enableActiveFill: true,
                  onCompleted: (value) => _handleVerifyOtp(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 30),
                BlocBuilder<OtpBloc, OtpStates>(
                  builder: (context, state) {
                    // Get timer value from state
                    int resendTimer = 60;
                    if (state is OnTimerUpdate) {
                      resendTimer = state.remainingSeconds;
                    } else if (state is OtpInitialState) {
                      resendTimer = state.resendTimer;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive code? "),
                        TextButton(
                          onPressed: resendTimer == 0 ? _handleResendOtp : null,
                          child: Text(
                            resendTimer > 0
                                ? 'Resend in ${resendTimer}s'
                                : 'Resend',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                BlocBuilder<OtpBloc, OtpStates>(
                  builder: (context, state) {
                    final isLoading = state is OnLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleVerifyOtp,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Verify'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
