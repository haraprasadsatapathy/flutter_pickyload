import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picky_load/presentation/cubit/user_profile/profile/profile_state.dart';
import 'profile_event.dart';
import '../../../../domain/repository/user_repository.dart';
import '../../../../models/user_model.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // Dependencies
  final BuildContext context;
  final UserRepository userRepository;

  // Constructor
  ProfileBloc(this.context, this.userRepository)
    : super(ProfileInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fetch Profile
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());

      // ============================================
      // BUSINESS LOGIC: Fetch User Profile
      // ============================================

      try {
        // Call API to fetch profile
        final result = await userRepository.fetchUserProfile(event.userId);

        if (result.status == true && result.data != null) {
          // Profile fetched successfully
          final profileData = result.data!;

          // Get existing user data to preserve userId and role
          final existingUser = await userRepository.getUserDetailsSp();

          if (existingUser != null) {
            // Create updated User object with fetched profile data
            final updatedUser = User(
              id: existingUser.id,
              name: profileData.userName,
              email: profileData.userEmail,
              phone: profileData.userPhone,
              role: existingUser.role,
              profileImage: profileData.uProfileImageUrl,
              isVerified: existingUser.isVerified,
              createdAt: existingUser.createdAt,
            );

            // Save updated user details to SharedPreferences
            await userRepository.saveUserDetailsSp(updatedUser);
          }

          emit(ProfileFetchSuccess(profileData));
        } else {
          // Profile fetch failed
          emit(
            ProfileFetchError(
              result.message ?? 'Failed to fetch profile. Please try again.',
            ),
          );
        }
      } catch (e) {
        emit(ProfileFetchError('Failed to fetch profile. Please try again.'));
      }
    });

    // Update Profile
    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());

      // ============================================
      // BUSINESS LOGIC: Update User Profile
      // ============================================

      try {
        // Call API to update profile
        final result = await userRepository.updateProfile(
          userId: event.userId,
          name: event.userName,
          email: event.userEmail,
          phone: event.userPhone,
          profileImage: event.profileImageUrl,
        );

        if (result.status == true && result.data != null) {
          // Profile updated successfully
          // Fetch the updated profile data
          final fetchResult = await userRepository.fetchUserProfile(
            event.userId,
          );

          if (fetchResult.status == true && fetchResult.data != null) {
            final profileData = fetchResult.data!;

            // Get existing user data to preserve userId and role
            final existingUser = await userRepository.getUserDetailsSp();

            if (existingUser != null) {
              // Create updated User object with fetched profile data
              final updatedUser = User(
                id: existingUser.id,
                name: profileData.userName,
                email: profileData.userEmail,
                phone: profileData.userPhone,
                role: existingUser.role,
                profileImage: profileData.uProfileImageUrl,
                isVerified: existingUser.isVerified,
                createdAt: existingUser.createdAt,
              );

              // Save updated user details to SharedPreferences
              await userRepository.saveUserDetailsSp(updatedUser);
            }

            emit(
              ProfileUpdateSuccess(
                result.message ?? 'Profile updated successfully',
                profileData,
              ),
            );
          } else {
            emit(
              ProfileUpdateError(
                'Profile updated but failed to fetch updated data',
              ),
            );
          }
        } else {
          // Profile update failed
          emit(
            ProfileUpdateError(
              result.message ?? 'Failed to update profile. Please try again.',
            ),
          );
        }
      } catch (e) {
        emit(ProfileUpdateError('Failed to update profile. Please try again.'));
      }
    });
  }
}
