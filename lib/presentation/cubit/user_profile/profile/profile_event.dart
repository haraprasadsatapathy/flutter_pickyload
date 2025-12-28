import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Profile feature
abstract class ProfileEvent extends BaseEventState {}

// Event to fetch user profile
class FetchProfile extends ProfileEvent {
  final String userId;

  FetchProfile({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Event to update profile
class UpdateProfile extends ProfileEvent {
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? profileImageUrl;

  UpdateProfile({
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [userId, userName, userEmail, userPhone, profileImageUrl];
}
