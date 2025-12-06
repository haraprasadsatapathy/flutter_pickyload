import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Login feature
class LoginEvent extends BaseEventState {}

// Login with phone number (triggers OTP)
class LoginWithPhone extends LoginEvent {
  final String phoneNumber;

  LoginWithPhone({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

// Navigate to register screen
class NavigateToRegister extends LoginEvent {}
