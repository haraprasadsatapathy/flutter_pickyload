import 'package:picky_load3/services/local/saved_service.dart';

import '../../models/user_model.dart';
import '../../data/data_source/api_client.dart';
import '../models/api_response.dart';
import '../models/otp_response.dart';
import '../models/verify_otp_response.dart';
import '../models/register_response.dart';

/// Repository for user-related operations
class UserRepository {
  final ApiClient _apiClient;
  final SavedService _savedService;

  UserRepository(this._apiClient, this._savedService);

  /// Get user details from SharedPreferences
  Future<User?> getUserDetailsSp() async {
    return await _savedService.getUserDetailsSp();
  }

  /// Save user details to SharedPreferences
  Future<void> saveUserDetailsSp(User user) async {
    await _savedService.saveUserDetailsSp(user);
  }

  /// Save auth token
  Future<void> saveAuthToken(String token) async {
    await _savedService.saveAuthToken(token);
    _apiClient.setToken(token);
  }

  /// Get auth token
  String? getAuthToken() {
    return _savedService.getAuthToken();
  }

  /// Clear user data (logout)
  Future<void> clearUserData() async {
    _savedService.clearUserData();
    _apiClient.clearToken();
  }

  /// Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final user = await getUserDetailsSp();
    return user != null;
  }

  // API Methods (to be implemented with actual backend)

  /// Login user
  // Future<ApiResponse<User>> login(String email, String password) async {
  //   try {
  //     final response = await _apiClient.post<Map<String, dynamic>>(
  //       '/auth/login',
  //       data: {'email': email, 'password': password},
  //       fromJsonT: (json) => json as Map<String, dynamic>,
  //     );

  //     if (response.status == true && response.data != null) {
  //       final user = User.fromJson(response.data!['user']);
  //       final token = response.data!['token'] as String;

  //       await saveUserDetailsSp(user);
  //       await saveAuthToken(token);

  //       return ApiResponse(
  //         status: true,
  //         message: response.message ?? 'Login successful',
  //         data: user,
  //       );
  //     }

  //     return ApiResponse(
  //       status: false,
  //       message: response.message ?? 'Login failed',
  //       data: null,
  //     );
  //   } catch (e) {
  //     return ApiResponse(
  //       status: false,
  //       message: 'An error occurred: ${e.toString()}',
  //       data: null,
  //     );
  //   }
  // }

  /// Register user
  Future<ApiResponse<RegisterResponse>> registerUser({
    required String userName,
    required String userEmail,
    required String userPhone,
    String? pictureUrl,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/Register',
        data: {
          'userName': userName,
          'userEmail': userEmail,
          'userPhone': userPhone,
          if (pictureUrl != null) 'pictureUrl': pictureUrl,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.data != null) {
        // Parse the register response directly from response.data
        final registerResponse = RegisterResponse.fromJson(response.data!);

        return ApiResponse(
          status: true,
          message: response.message ?? 'User registered successfully',
          data: registerResponse,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Registration failed',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Generate OTP for phone number
  Future<ApiResponse<OtpResponse>> generateOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/Generate-Otp',
        data: {'phoneNumber': phoneNumber},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.data != null) {
        // Parse the OTP data from response.data
        final otpData = OtpData.fromJson(response.data!);

        // Create OtpResponse with the message from response.message
        final otpResponse = OtpResponse(
          message: response.message ?? 'OTP sent successfully',
          data: otpData,
        );

        // Check if OTP was sent successfully
        if (otpData.isOtpSent) {
          return ApiResponse(
            status: true,
            message: otpResponse.message,
            data: otpResponse,
          );
        } else {
          return ApiResponse(
            status: false,
            message: otpData.message,
            data: null,
          );
        }
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to generate OTP',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Verify OTP
  Future<ApiResponse<User>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/verify-otp',
        data: {'phoneNumber': phoneNumber, 'otp': otp},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.data != null) {
        // Parse the verify OTP data from response.data
        final verifyOtpData = VerifyOtpData.fromJson(response.data!);

        // Check if OTP was verified successfully
        if (verifyOtpData.isVerified) {
          // Convert VerifyOtpUser to User model
          final user = User(
            id: verifyOtpData.user.userID,
            name: verifyOtpData.user.userName,
            email: verifyOtpData.user.userEmail,
            phone: verifyOtpData.user.userMobile,
            role: verifyOtpData.user.roleName.toLowerCase() == 'driver'
                ? UserRole.driver
                : UserRole.customer,
            isVerified: true,
            createdAt: DateTime.now(),
          );

          // Save user details and access token to SharedPreferences
          await saveUserDetailsSp(user);
          await saveAuthToken(verifyOtpData.accessToken);

          return ApiResponse(
            status: true,
            message: response.message ?? 'OTP verified successfully',
            data: user,
          );
        } else {
          return ApiResponse(
            status: false,
            message: verifyOtpData.message,
            data: null,
          );
        }
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'OTP verification failed',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/user/profile/$userId',
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (profileImage != null) 'profileImage': profileImage,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true && response.data != null) {
        final user = User.fromJson(response.data!);
        await saveUserDetailsSp(user);

        return ApiResponse(
          status: true,
          message: response.message ?? 'Profile updated successfully',
          data: user,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Profile update failed',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get user profile from server
  Future<ApiResponse<User>> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/user/profile/$userId',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true && response.data != null) {
        final user = User.fromJson(response.data!);

        return ApiResponse(
          status: true,
          message: response.message ?? 'Profile fetched successfully',
          data: user,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to fetch profile',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Send OTP to phone number for login
  Future<ApiResponse<OtpResponse>> loginUser(String phoneNumber) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/Login-User',
        data: {'phoneNumber': phoneNumber},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      // Check if we have data in the response
      if (response.data != null) {
        // The API response structure after ApiClient processing is:
        // response.message contains the top-level message
        // response.data contains the nested data object {isOtpSent, message, otp}

        // Parse the OTP data from response.data
        final otpData = OtpData.fromJson(response.data!);

        // Create OtpResponse with the message from response.message
        final otpResponse = OtpResponse(
          message: response.message ?? 'OTP sent successfully',
          data: otpData,
        );

        // Check if OTP was sent successfully
        if (otpData.isOtpSent) {
          return ApiResponse(
            status: true,
            message: otpResponse.message,
            data: otpResponse,
          );
        } else {
          return ApiResponse(
            status: false,
            message: otpData.message,
            data: null,
          );
        }
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to send OTP',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}
