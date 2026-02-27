import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// API Base URL
  // static const String baseUrl = 'https://pickyload.in/api';
  static const String baseUrl = 'https://pickyload.com/api';

  /// Google Maps API Key
  /// IMPORTANT: API key is now loaded from environment variables for security
  /// Load from .env file using flutter_dotenv package
  /// For native platforms (Android/iOS), keys are configured in:
  /// - Android: android/local.properties -> AndroidManifest.xml
  /// - iOS: ios/Flutter/Keys.xcconfig -> Info.plist
  static String get googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}
