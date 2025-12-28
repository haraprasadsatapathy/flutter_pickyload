import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../domain/repository/user_repository.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final UserRepository userRepository;
  final ImagePicker imagePicker;

  EditProfileBloc({
    required this.userRepository,
    ImagePicker? imagePicker,
  })  : imagePicker = imagePicker ?? ImagePicker(),
        super(const EditProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<ToggleEditModeEvent>(_onToggleEditMode);
    on<PickImageEvent>(_onPickImage);
    on<SaveProfileEvent>(_onSaveProfile);
    on<CancelEditEvent>(_onCancelEdit);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileLoading());
    try {
      // Load user profile from local storage first
      final user = await userRepository.getUserDetailsSp();

      if (user != null) {
        // Fetch profile from API to get the profile image URL
        final profileResponse = await userRepository.fetchUserProfile(user.id);

        if (profileResponse.status == true && profileResponse.data != null) {
          emit(EditProfileLoaded(
            name: profileResponse.data!.userName,
            email: profileResponse.data!.userEmail,
            phone: profileResponse.data!.userPhone,
            profileImageUrl: profileResponse.data!.uProfileImageUrl,
            isEditing: false,
          ));
        } else {
          // Fallback to local user data if API fails
          emit(EditProfileLoaded(
            name: user.name,
            email: user.email,
            phone: user.phone,
            isEditing: false,
          ));
        }
      } else {
        emit(const EditProfileError('Failed to load user profile'));
      }
    } catch (e) {
      emit(EditProfileError('Error loading profile: ${e.toString()}'));
    }
  }

  void _onToggleEditMode(
    ToggleEditModeEvent event,
    Emitter<EditProfileState> emit,
  ) {
    if (state is EditProfileLoaded) {
      final currentState = state as EditProfileLoaded;
      emit(currentState.copyWith(isEditing: event.isEditing));
    }
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: event.source,
      );

      if (image != null) {
        if (state is EditProfileLoaded) {
          final currentState = state as EditProfileLoaded;
          // Create new state with local image path and clear network URL
          emit(EditProfileLoaded(
            name: currentState.name,
            email: currentState.email,
            phone: currentState.phone,
            vehicleType: currentState.vehicleType,
            vehicleNumber: currentState.vehicleNumber,
            profileImagePath: image.path,
            profileImageUrl: null, // Clear network URL when new image is picked
            isEditing: true,
          ));
        } else {
          emit(EditProfileImagePicked(image.path, isEditing: true));
        }
      }
    } catch (e) {
      emit(EditProfileError('Failed to pick image: ${e.toString()}'));
    }
  }

  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileSaving());
    try {
      // Get current user to preserve other fields
      final currentUser = await userRepository.getUserDetailsSp();

      if (currentUser != null) {
        // Get the profile image path from current state if available
        String? profileImagePath;
        if (state is EditProfileLoaded) {
          profileImagePath = (state as EditProfileLoaded).profileImagePath;
        }

        // Use the new update-profile API with multipart/form-data
        final response = await userRepository.updateProfileWithImage(
          userId: currentUser.id,
          userName: event.name,
          userPhone: event.phone,
          userEmail: event.email,
          profileImagePath: profileImagePath,
        );

        if (response.status == true) {
          // Fetch updated profile from API to get new image URL
          final profileResponse = await userRepository.fetchUserProfile(currentUser.id);
          String? newProfileImageUrl;

          if (profileResponse.status == true && profileResponse.data != null) {
            newProfileImageUrl = profileResponse.data!.uProfileImageUrl;
          }

          emit(EditProfileLoaded(
            name: event.name,
            email: event.email,
            phone: event.phone,
            vehicleType: event.vehicleType,
            vehicleNumber: event.vehicleNumber,
            profileImagePath: null, // Clear local path after successful upload
            profileImageUrl: newProfileImageUrl, // Use new URL from server
            isEditing: false,
          ));

          emit(EditProfileSaved(response.message ?? 'Profile updated successfully'));
        } else {
          emit(EditProfileError(response.message ?? 'Failed to update profile'));
        }
      } else {
        emit(const EditProfileError('User not found'));
      }
    } catch (e) {
      emit(EditProfileError('Failed to save profile: ${e.toString()}'));
    }
  }

  void _onCancelEdit(
    CancelEditEvent event,
    Emitter<EditProfileState> emit,
  ) {
    if (state is EditProfileLoaded) {
      final currentState = state as EditProfileLoaded;
      emit(currentState.copyWith(isEditing: false));
    } else {
      emit(const EditProfileInitial());
    }
  }
}
