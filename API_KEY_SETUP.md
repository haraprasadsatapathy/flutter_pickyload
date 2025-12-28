# Google Maps API Key Setup Guide

This guide explains how to properly configure your Google Maps API key for the Picky Load application, following Google's security best practices.

## Why This Setup?

API keys should **NEVER** be hardcoded in source code or committed to version control. This setup ensures:
- ✅ API keys are stored securely outside of source code
- ✅ Keys are not committed to Git (protected by .gitignore)
- ✅ Different developers can use their own API keys
- ✅ Production and development keys can be separated
- ✅ Compliance with Google's API key security policies

## Getting Your Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Directions API
   - Geocoding API (if needed)
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Restrict your API key:
   - **Application restrictions**: Set to Android/iOS apps
   - **API restrictions**: Limit to only the APIs you need
6. Copy your API key

## Setup Instructions

### 1. Flutter Environment Variables (.env)

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your API key:
   ```env
   GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here
   ```

3. The `.env` file is already in `.gitignore` and will not be committed.

### 2. Android Configuration

1. Copy the example file:
   ```bash
   cp android/local.properties.example android/local.properties
   ```

   **Note**: If `android/local.properties` already exists (created by Android Studio), just add the API key line to it.

2. Edit `android/local.properties` and add your API key:
   ```properties
   GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here
   ```

3. The `local.properties` file is already in `.gitignore` and will not be committed.

### 3. iOS Configuration

1. Copy the example file:
   ```bash
   cp ios/Flutter/Keys.xcconfig.example ios/Flutter/Keys.xcconfig
   ```

2. Edit `ios/Flutter/Keys.xcconfig` and add your API key:
   ```
   GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here
   ```

3. The `Keys.xcconfig` file is already in `.gitignore` and will not be committed.

## How It Works

### Flutter/Dart Code
- Environment variables are loaded from `.env` using the `flutter_dotenv` package
- Access the API key via `AppConstants.googleApiKey`
- Used for Google Directions API calls in `route_map_screen.dart`

### Android
- API key is read from `android/local.properties`
- `android/app/build.gradle.kts` reads the key and passes it to the manifest
- `AndroidManifest.xml` uses the placeholder `${GOOGLE_MAPS_API_KEY}`
- Google Maps SDK reads the key from the manifest metadata

### iOS
- API key is defined in `ios/Flutter/Keys.xcconfig`
- Included in `Debug.xcconfig` and `Release.xcconfig`
- `Info.plist` uses the variable `$(GOOGLE_MAPS_API_KEY)`
- Google Maps SDK reads the key from Info.plist

## Installation Steps

After setting up all the configuration files:

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. For Android:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   ```

3. For iOS:
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Security Checklist

Before committing your code, verify:

- [ ] `.env` file is listed in `.gitignore`
- [ ] `android/local.properties` is listed in `.gitignore`
- [ ] `ios/Flutter/Keys.xcconfig` is listed in `.gitignore`
- [ ] No hardcoded API keys in source code
- [ ] Example files (`.env.example`, `local.properties.example`, `Keys.xcconfig.example`) are committed
- [ ] Your actual API keys are NOT in any committed files

## Troubleshooting

### "API key not found" error
- Ensure you've created the `.env`, `local.properties`, and `Keys.xcconfig` files
- Verify the API key format is correct (no quotes, spaces, or extra characters)
- Run `flutter clean` and `flutter pub get`

### Android: "REQUEST_DENIED" error
- Check that the API key in `android/local.properties` is correct
- Verify the API key is enabled for "Maps SDK for Android" in Google Cloud Console
- Add your app's SHA-1 fingerprint to the API key restrictions

### iOS: Maps not loading
- Ensure `ios/Flutter/Keys.xcconfig` exists and has the correct key
- Run `pod install` in the `ios` directory
- Clean and rebuild the project

### Directions API not working
- Verify the API key in `.env` is correct
- Enable "Directions API" in Google Cloud Console
- Check that the API key has no IP/domain restrictions blocking your requests

## Team Development

When working in a team:

1. **Never share API keys via Git** - Each developer should use their own API key
2. **Share setup instructions** - Point team members to this README
3. **Document any API changes** - Update this file if you modify the API key configuration
4. **Use separate keys for prod/dev** - Consider different keys for development and production builds

## Production Deployment

For production builds:

1. Use environment-specific API keys (production keys)
2. Set up API key restrictions properly:
   - Android: Add release keystore SHA-1 fingerprint
   - iOS: Add bundle identifier restriction
3. Enable only the necessary Google Maps APIs
4. Set up billing alerts in Google Cloud Console
5. Consider using CI/CD secrets management for production keys

## Additional Resources

- [Google Maps Platform Security Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [flutter_dotenv Documentation](https://pub.dev/packages/flutter_dotenv)
- [Securing API Keys in Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#provider)

## Support

If you encounter issues with API key setup:
1. Check this documentation first
2. Verify your Google Cloud Console configuration
3. Review the troubleshooting section
4. Check the Flutter and Google Maps documentation
