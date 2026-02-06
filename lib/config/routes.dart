import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picky_load/presentation/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/otp_verification_screen.dart';
import '../presentation/screens/auth/password_recovery_screen.dart';
import '../presentation/screens/auth/role_selection_screen.dart';
import '../presentation/screens/customer/customer_dashboard.dart';
import '../presentation/screens/driver/driver_dashboard.dart';
import '../presentation/screens/driver/document_upload_screen.dart';
import '../presentation/screens/driver/add_vehicle_screen.dart';
import '../presentation/screens/driver/show_vehicle_screen.dart';
import '../presentation/screens/driver/show_documents_screen.dart';
import '../presentation/screens/driver/add_load_screen.dart';
import '../presentation/screens/driver/offer_loads_list_screen.dart';
import '../presentation/screens/customer/trip_request_screen.dart';
import '../presentation/screens/customer/trip_details_screen.dart';
import '../presentation/screens/customer/cancel_booking_screen.dart';
import '../presentation/screens/customer/payment_screen.dart';
import '../presentation/screens/customer/advance_payment_screen.dart';
import '../presentation/screens/customer/transaction_history_screen.dart';
import '../presentation/screens/customer/customer_profile_screen.dart';
import '../presentation/screens/customer/notifications_screen.dart';
import '../presentation/screens/customer/help_support_screen.dart';
import '../presentation/screens/customer/matched_vehicles_screen.dart';
import '../presentation/screens/driver/user_offers_list_screen.dart';
import '../presentation/screens/driver/confirmed_trip_detail_screen.dart';
import '../domain/models/payment_request_response.dart';
import '../domain/models/customer_home_page_response.dart';
import '../domain/models/home_page_response.dart' show TripDetail, ConfirmedTrip;
import '../domain/repository/user_repository.dart';
import '../domain/repository/driver_repository.dart';
import '../domain/repository/customer_repository.dart';
import '../presentation/cubit/user_profile/edit_profile/edit_profile_bloc.dart';
import '../presentation/cubit/driver/home/home_tab_bloc.dart';
import '../presentation/cubit/customer/home/customer_home_tab_bloc.dart';
import '../presentation/cubit/customer/home/customer_home_tab_event.dart';
import '../presentation/cubit/driver/add_load/add_load_bloc.dart';
import '../presentation/cubit/driver/offer_loads_list/offer_loads_list_bloc.dart';
import '../presentation/cubit/driver/user_offers_list/user_offers_list_bloc.dart';
import '../presentation/cubit/driver/user_offers_list/user_offers_list_event.dart';

/// Global route observer for detecting navigation changes
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

final router = GoRouter(
  initialLocation: '/',
  observers: [routeObserver],
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
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
      builder: (context, state) => BlocProvider(
        create: (context) => CustomerHomeTabBloc(
          Provider.of<CustomerRepository>(context, listen: false),
        )..add(LoadUserData()),
        child: const CustomerDashboard(),
      ),
    ),
    GoRoute(
      path: '/driver-dashboard',
      builder: (context, state) => BlocProvider(
        create: (context) => HomeTabBloc(
          context,
          Provider.of<DriverRepository>(context, listen: false),
        ),
        child: const DriverDashboard(),
      ),
    ),
    GoRoute(
      path: '/document-upload',
      builder: (context, state) => const DocumentUploadScreen(),
    ),
    GoRoute(
      path: '/add-vehicle',
      builder: (context, state) => const AddVehicleScreen(),
    ),
    GoRoute(
      path: '/show-vehicles',
      builder: (context, state) => const ShowVehicleScreen(),
    ),
    GoRoute(
      path: '/show-documents',
      builder: (context, state) => const ShowDocumentsScreen(),
    ),
    GoRoute(
      path: '/add-load',
      builder: (context, state) => BlocProvider(
        create: (context) => AddLoadBloc(
          context,
          Provider.of<DriverRepository>(context, listen: false),
        ),
        child: const AddLoadScreen(),
      ),
    ),
    GoRoute(
      path: '/offer-loads-list',
      builder: (context, state) => BlocProvider(
        create: (context) => OfferLoadsListBloc(
          context,
          Provider.of<DriverRepository>(context, listen: false),
        ),
        child: const OfferLoadsListScreen(),
      ),
    ),
    GoRoute(
      path: '/trip-request',
      builder: (context, state) => const TripRequestScreen(),
    ),
    GoRoute(
      path: '/trip-tracking',
      builder: (context, state) =>
          TripDetailsScreen(trip: state.extra as OngoingTrip),
    ),
    GoRoute(
      path: '/cancel-booking',
      builder: (context, state) => const CancelBookingScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) =>
          PaymentScreen(tripId: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/advance-payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return AdvancePaymentScreen(
          vehicle: extra['vehicle'] as VehicleMatch,
          booking: extra['booking'] as BookingDetail,
          paymentData: extra['paymentData'] as PaymentRequestResponse,
          onPaymentSuccess: extra['onPaymentSuccess'] as Function()?,
        );
      },
    ),
    GoRoute(
      path: '/transaction-history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/customer-profile',
      builder: (context, state) => BlocProvider(
        create: (context) => EditProfileBloc(
          userRepository: Provider.of<UserRepository>(context, listen: false),
        ),
        child: const CustomerProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/user-profile',
      builder: (context, state) => BlocProvider(
        create: (context) => EditProfileBloc(
          userRepository: Provider.of<UserRepository>(context, listen: false),
        ),
        child: const CustomerProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/matched-vehicles',
      builder: (context, state) {
        final booking = state.extra as BookingDetail;
        return MatchedVehiclesScreen(booking: booking);
      },
    ),
    GoRoute(
      path: '/user-offers-list',
      builder: (context, state) {
        final tripDetail = state.extra as TripDetail;
        return BlocProvider(
          create: (context) => UserOffersListBloc(
            context,
            Provider.of<DriverRepository>(context, listen: false),
          )..add(InitializeUserOffersList(tripDetail: tripDetail)),
          child: UserOffersListScreen(tripDetail: tripDetail),
        );
      },
    ),
    GoRoute(
      path: '/confirmed-trip-detail',
      builder: (context, state) {
        final confirmedTrip = state.extra as ConfirmedTrip;
        return ConfirmedTripDetailScreen(trip: confirmedTrip);
      },
    ),
  ],
);
