import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';
import '../../../../domain/models/profile_response.dart';

// Base state class for Profile feature
class ProfileState extends BaseEventState {}

// Initial state
class ProfileInitialState extends ProfileState {}

// Loading state
class ProfileLoading extends ProfileState {}

// Profile fetch successful
class ProfileFetchSuccess extends ProfileState {
  final ProfileData profileData;

  ProfileFetchSuccess(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

// Profile fetch failed
class ProfileFetchError extends ProfileState {
  final String message;

  ProfileFetchError(this.message);

  @override
  List<Object?> get props => [message];
}

// Profile update successful
class ProfileUpdateSuccess extends ProfileState {
  final String message;
  final ProfileData profileData;

  ProfileUpdateSuccess(this.message, this.profileData);

  @override
  List<Object?> get props => [message, profileData];
}

// Profile update failed
class ProfileUpdateError extends ProfileState {
  final String message;

  ProfileUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}
