import '../../models/user_model.dart';
import '../../services/local/storage_service.dart';

/// Repository for user-related operations
class SavedService {
  // Storage keys
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserPhone = 'userPhone';
  static const String _keyUserRole = 'userRole';
  static const String _keyUserProfileImage = 'userProfileImage';
  static const String _keyIsVerified = 'isVerified';
  static const String _keyAuthToken = 'authToken';

  /// Get user details from SharedPreferences
  Future<User?> getUserDetailsSp() async {
    final userId = StorageService.getString(_keyUserId);
    final userName = StorageService.getString(_keyUserName);
    final userEmail = StorageService.getString(_keyUserEmail);
    final userPhone = StorageService.getString(_keyUserPhone);
    final userRole = StorageService.getString(_keyUserRole);
    final userProfileImage = StorageService.getString(_keyUserProfileImage);
    final isVerified = StorageService.getBool(_keyIsVerified) ?? false;

    if (userId != null && userName != null && userEmail != null) {
      return User(
        id: userId,
        name: userName,
        email: userEmail,
        phone: userPhone ?? '',
        role: userRole == 'driver' ? UserRole.driver : UserRole.customer,
        profileImage: userProfileImage,
        isVerified: isVerified,
      );
    }
    return null;
  }

  /// Save user details to SharedPreferences
  Future<void> saveUserDetailsSp(User user) async {
    await StorageService.setString(_keyUserId, user.id);
    await StorageService.setString(_keyUserName, user.name);
    await StorageService.setString(_keyUserEmail, user.email);
    await StorageService.setString(_keyUserPhone, user.phone);
    await StorageService.setString(
      _keyUserRole,
      user.role == UserRole.driver ? 'driver' : 'customer',
    );
    if (user.profileImage != null) {
      await StorageService.setString(_keyUserProfileImage, user.profileImage!);
    }
    await StorageService.setBool(_keyIsVerified, user.isVerified);
  }

  /// Clear user data (logout)
  Future<void> clearUserData() async {
    await StorageService.remove(_keyUserId);
    await StorageService.remove(_keyUserName);
    await StorageService.remove(_keyUserEmail);
    await StorageService.remove(_keyUserPhone);
    await StorageService.remove(_keyUserRole);
    await StorageService.remove(_keyUserProfileImage);
    await StorageService.remove(_keyIsVerified);
    await StorageService.remove(_keyAuthToken);
    // _apiClient.clearToken();
  }

  /// Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final user = await getUserDetailsSp();
    return user != null;
  }

  Future<void> saveAuthToken(String token) async {
    await StorageService.setString(_keyAuthToken, token);
  }

  String? getAuthToken() {
    return StorageService.getString(_keyAuthToken);
  }
}
