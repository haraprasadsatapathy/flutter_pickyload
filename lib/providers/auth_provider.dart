import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/local/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userName = prefs.getString('userName');
    final userEmail = prefs.getString('userEmail');
    final userPhone = prefs.getString('userPhone');
    final userRole = prefs.getString('userRole');
    final userProfileImage = prefs.getString('userProfileImage');
    final isVerified = prefs.getBool('isVerified') ?? false;

    if (userId != null && userName != null && userEmail != null) {
      _currentUser = User(
        id: userId,
        name: userName,
        email: userEmail,
        phone: userPhone ?? '',
        role: userRole == 'driver' ? UserRole.driver : UserRole.customer,
        profileImage: userProfileImage,
        isVerified: isVerified,
      );
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> login(User user) async {
    _currentUser = user;
    _isAuthenticated = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userPhone', user.phone);
    await prefs.setString('userRole', user.role == UserRole.driver ? 'driver' : 'customer');

    // Set login flag for auto-login feature
    await StorageService.setBool('isLoggedIn', true);
    await StorageService.setString('loginTimestamp', DateTime.now().toIso8601String());

    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;

    // Clear all user data from storage
    await StorageService.clear();

    notifyListeners();
  }

  Future<void> updateProfile(User user) async {
    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userPhone', user.phone);
    if (user.profileImage != null) {
      await prefs.setString('userProfileImage', user.profileImage!);
    }
    await prefs.setBool('isVerified', user.isVerified);

    notifyListeners();
  }

  /// Public method to reload user data from SharedPreferences
  Future<void> loadUser() async {
    await _loadUserData();
  }
}
