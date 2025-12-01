import 'package:go_router/go_router.dart';
import 'package:picky_load3/presentation/screens/auth/login_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/common/language_selection_screen.dart';
// Old login screen
// import '../presentation/screens/auth/login_screen.dart';
// New BLoC-based login screen
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/otp_verification_screen.dart';
import '../presentation/screens/auth/password_recovery_screen.dart';
import '../presentation/screens/auth/role_selection_screen.dart';
import '../presentation/screens/customer/customer_dashboard.dart';
import '../presentation/screens/driver/driver_dashboard.dart';
import '../presentation/screens/driver/document_upload_screen.dart';
import '../presentation/screens/trip/trip_request_screen.dart';
import '../presentation/screens/trip/trip_tracking_screen.dart';
import '../presentation/screens/payment/payment_screen.dart';
import '../presentation/screens/payment/transaction_history_screen.dart';
import '../presentation/screens/insurance/insurance_screen.dart';
import '../presentation/screens/profile/customer_profile_screen.dart';
import '../presentation/screens/profile/driver_profile_screen.dart';
import '../presentation/screens/profile/change_password_screen.dart';
import '../presentation/screens/profile/rating_review_screen.dart';
import '../presentation/screens/profile/saved_addresses_screen.dart';
import '../presentation/screens/profile/add_address_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OtpVerificationScreen(
          phoneNumber: extra?['phoneNumber'] as String? ?? '',
          otp: extra?['otp'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/password-recovery',
      builder: (context, state) => const PasswordRecoveryScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/customer-dashboard',
      builder: (context, state) => const CustomerDashboard(),
    ),
    GoRoute(
      path: '/driver-dashboard',
      builder: (context, state) => const DriverDashboard(),
    ),
    GoRoute(
      path: '/document-upload',
      builder: (context, state) => const DocumentUploadScreen(),
    ),
    GoRoute(
      path: '/trip-request',
      builder: (context, state) => const TripRequestScreen(),
    ),
    GoRoute(
      path: '/trip-tracking',
      builder: (context, state) =>
          TripTrackingScreen(tripId: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) =>
          PaymentScreen(tripId: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/transaction-history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/insurance',
      builder: (context, state) =>
          InsuranceScreen(tripId: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/customer-profile',
      builder: (context, state) => const CustomerProfileScreen(),
    ),
    GoRoute(
      path: '/driver-profile',
      builder: (context, state) => const DriverProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/rating-review',
      builder: (context, state) => const RatingReviewScreen(),
    ),
    GoRoute(
      path: '/saved-addresses',
      builder: (context, state) => const SavedAddressesScreen(),
    ),
    GoRoute(
      path: '/add-address',
      builder: (context, state) => AddAddressScreen(
        existingAddress: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
  ],
);
