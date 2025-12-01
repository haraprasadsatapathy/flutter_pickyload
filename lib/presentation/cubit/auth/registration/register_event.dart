import 'package:picky_load3/presentation/cubit/base/baseEventState.dart';
import '../../../../models/user_model.dart';

// Base event class for Register feature
class RegisterEvent extends BaseEventState {}

// Register new user
class RegisterUser extends RegisterEvent {
  final String name;
  final String email;
  final String phone;
  final String? pictureUrl;

  RegisterUser({
    required this.name,
    required this.email,
    required this.phone,
    this.pictureUrl,
  });

  @override
  List<Object?> get props => [name, email, phone, pictureUrl];
}

// Navigate to login screen
class NavigateToLogin extends RegisterEvent {}

// Select user role
class SelectUserRole extends RegisterEvent {
  final UserRole role;

  SelectUserRole(this.role);

  @override
  List<Object?> get props => [role];
}
