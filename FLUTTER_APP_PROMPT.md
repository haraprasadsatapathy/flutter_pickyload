# Flutter App Generation Prompt

Use the following instructions to create a new Flutter app with the same architecture, folder structure, and BLoC pattern.

---

## Prompt

Create a new Flutter application named **[APP_NAME]** with the following architecture, folder structure, and coding conventions. Follow every rule strictly.

---

## 1. Folder Structure

```
lib/
├── main.dart
├── config/
│   ├── dependency_injection.dart
│   └── routes.dart
├── data/
│   └── data_source/
│       ├── api_client.dart
│       └── pretty_dio_logger.dart
├── domain/
│   ├── models/
│   │   ├── api_response.dart
│   │   └── [feature]_response.dart / [feature]_request.dart
│   └── repository/
│       └── [feature]_repository.dart
├── models/
│   └── [shared_model].dart
├── presentation/
│   ├── cubit/
│   │   ├── base/
│   │   │   └── base_event_state.dart
│   │   ├── auth/
│   │   │   ├── login/
│   │   │   │   ├── login_bloc.dart
│   │   │   │   ├── login_event.dart
│   │   │   │   └── login_state.dart
│   │   │   └── [other_auth_feature]/
│   │   │       ├── [feature]_bloc.dart
│   │   │       ├── [feature]_event.dart
│   │   │       └── [feature]_state.dart
│   │   └── [feature_group]/
│   │       └── [feature]/
│   │           ├── [feature]_bloc.dart
│   │           ├── [feature]_event.dart
│   │           └── [feature]_state.dart
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── otp_verification_screen.dart
│   │   └── [feature]/
│   │       └── [feature]_screen.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── empty_state.dart
│       └── loading_indicator.dart
├── providers/
│   ├── auth_provider.dart
│   └── theme_provider.dart
├── services/
│   ├── local/
│   │   ├── storage_service.dart
│   │   └── saved_service.dart
│   └── notification/
│       └── notification_service.dart
├── theme/
│   └── app_theme.dart
└── utils/
    └── constant/
        └── app_constants.dart
```

---

## 2. pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # BLoC Architecture
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7
  get_it: ^8.0.2

  # Navigation
  go_router: ^13.0.0

  # Networking
  dio: ^5.7.0
  http_parser: ^4.0.2

  # UI
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_spinkit: ^5.2.0
  pin_code_fields: ^8.0.1

  # State / DI
  provider: ^6.1.1

  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.2.2

  # Utilities
  intl: ^0.19.0
  uuid: ^4.5.1
  flutter_dotenv: ^5.2.1
  fluttertoast: ^8.2.4
  url_launcher: ^6.2.4
  permission_handler: ^11.2.0
  image_picker: ^1.0.7

  # Firebase
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.6

  # Fonts (add custom fonts in flutter section)
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.13
  icons_launcher: ^3.0.0
  package_rename_plus: ^1.5.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - .env
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

---

## 3. Architecture Rules

### 3.1 BLoC Pattern

Every feature's state management must follow this exact pattern:

**base_event_state.dart** — shared base class for all events and states:
```dart
import 'package:equatable/equatable.dart';

class BaseEventState extends Equatable {
  @override
  List<Object?> get props => [];
}
```

**[feature]_event.dart** — all events extend `BaseEventState`:
```dart
import '../../../base/base_event_state.dart';

abstract class LoginEvent extends BaseEventState {}

class LoginWithPhone extends LoginEvent {
  final String phoneNumber;
  LoginWithPhone(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class NavigateToRegister extends LoginEvent {}
```

**[feature]_state.dart** — all states extend `BaseEventState`:
```dart
import '../../../base/base_event_state.dart';

abstract class LoginStates extends BaseEventState {}

class LoginInitialState extends LoginStates {}
class OnLoading extends LoginStates {}

class OnOtpSentSuccess extends LoginStates {
  final String phoneNumber;
  final String message;
  final String otp;
  OnOtpSentSuccess(this.phoneNumber, this.message, this.otp);

  @override
  List<Object?> get props => [phoneNumber, message, otp];
}

class OnOtpSendError extends LoginStates {
  final String message;
  OnOtpSendError(this.message);

  @override
  List<Object?> get props => [message];
}

class OnNavigateToRegister extends LoginStates {}
```

**[feature]_bloc.dart** — BLoC class pattern:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '[feature]_event.dart';
import '[feature]_state.dart';
import '../../../../domain/repository/[feature]_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginStates> {
  final BuildContext context;
  final UserRepository userRepository;

  LoginBloc(this.context, this.userRepository) : super(LoginInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<LoginWithPhone>((event, emit) async {
      emit(OnLoading());
      // validation + business logic
      try {
        final result = await userRepository.loginUser(event.phoneNumber);
        if (result.status == true && result.data != null) {
          emit(OnOtpSentSuccess(...));
        } else {
          emit(OnOtpSendError(result.message ?? 'Failed'));
        }
      } catch (e) {
        emit(OnOtpSendError('Something went wrong'));
      }
    });

    on<NavigateToRegister>((event, emit) {
      emit(OnNavigateToRegister());
    });
  }
}
```

### 3.2 ApiResponse Model

`lib/domain/models/api_response.dart` — generic wrapper for all API responses:
```dart
class ApiResponse<T> {
  final bool? status;
  final String? message;
  final T? data;

  ApiResponse({this.status, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
```

### 3.3 ApiClient (Dio Wrapper)

`lib/data/data_source/api_client.dart`:
- Wraps Dio with a base URL from `AppConstants.baseUrl` (loaded from `.env`)
- Exposes typed methods: `get<T>`, `getRaw<T>`, `post<T>`, `put<T>`, `delete<T>`, `postMultipart<T>`
- All methods return `ApiResponse<T>`
- Handles `DioException` and maps errors to human-readable messages:
  - connectionTimeout/sendTimeout/receiveTimeout → `'Connection timeout'`
  - badResponse → response body message or `'Server error'`
  - connectionError → `'No internet connection'`
  - default → `'Something went wrong'`
- `setToken(String token)` sets `Authorization: Bearer <token>` header
- `clearToken()` removes the Authorization header
- Adds `PrettyDioLoggerInterceptor` for formatted JSON logging

### 3.4 Repository Pattern

`lib/domain/repository/[feature]_repository.dart`:
- Takes `ApiClient` (and optionally `SavedService`) as constructor arguments
- All methods return `Future<ApiResponse<T>>`
- Wraps API calls in try/catch — never throws, always returns `ApiResponse`
- Local data methods (save/get/clear) delegate to `SavedService`

```dart
class UserRepository {
  final ApiClient _apiClient;
  final SavedService _savedService;

  UserRepository(this._apiClient, this._savedService);

  Future<ApiResponse<SomeModel>> fetchData() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/endpoint',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      if (response.data != null) {
        return ApiResponse(
          status: true,
          message: response.message,
          data: SomeModel.fromJson(response.data!),
        );
      }
      return ApiResponse(status: false, message: response.message, data: null);
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: $e', data: null);
    }
  }
}
```

### 3.5 Dependency Injection

`lib/config/dependency_injection.dart` — uses `GetIt`:
```dart
import 'package:get_it/get_it.dart';
import '../data/data_source/api_client.dart';
import '../domain/repository/user_repository.dart';
// ... other repositories

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<SavedService>(() => SavedService());

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<ApiClient>(), getIt<SavedService>()),
  );
  // Register all other repositories...
}
```

### 3.6 Routing

`lib/config/routes.dart` — uses `go_router`:
- `GoRouter` with `initialLocation: '/'`
- Each route is a `GoRoute` with a path string and builder
- BLoCs that a screen needs are injected via `BlocProvider` directly in the route builder
- Repositories are accessed via `Provider.of<XRepository>(context, listen: false)` inside the builder
- Pass complex objects via `state.extra`

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/feature-screen',
      builder: (context, state) => BlocProvider(
        create: (context) => FeatureBloc(
          context,
          Provider.of<FeatureRepository>(context, listen: false),
        ),
        child: const FeatureScreen(),
      ),
    ),
  ],
);
```

### 3.7 main.dart Structure

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await StorageService.init();
  await setupDependencyInjection();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget { ... }

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<UserRepository>(create: (_) => getIt<UserRepository>()),
        // All other repositories...
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: '[APP_NAME]',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
```

### 3.8 Local Storage

- `StorageService` — wraps `SharedPreferences` for simple key-value storage. Initialize with `StorageService.init()` before `runApp`.
- `SavedService` — higher-level service that uses `StorageService` + `FlutterSecureStorage` for saving/reading user objects, auth tokens, and other structured data.

### 3.9 Theme

`lib/theme/app_theme.dart` — defines both `lightTheme` and `darkTheme` as `ThemeData`. Use `Poppins` as the default font family throughout.

### 3.10 Environment Variables

- Use `flutter_dotenv` to load a `.env` file at app root.
- `AppConstants.baseUrl` reads `dotenv.env['BASE_URL']`.
- Add `.env` to `pubspec.yaml` assets.
- Add `.env` to `.gitignore`.

---

## 4. Coding Conventions

- **Naming**: `snake_case` for files, `PascalCase` for classes, `camelCase` for variables/methods.
- **BLoC file triplet**: every feature must have `_bloc.dart`, `_event.dart`, `_state.dart` in its own sub-folder.
- **No business logic in UI**: screens only dispatch events and listen to states.
- **Screens use `BlocBuilder` / `BlocListener` / `BlocConsumer`** — never call repository methods directly from screens.
- **Repository methods never throw** — always catch and return `ApiResponse` with `status: false`.
- **Equatable on all events and states** via `BaseEventState`.
- **GetIt for DI, Provider for propagation** — register singletons in `setupDependencyInjection()`, expose via `MultiProvider` in `MyApp`.
- **go_router for navigation** — always navigate with `context.go('/route')` or `context.push('/route')`.
- **Dio for networking** — never use `http` package directly.

---

## 5. How to Add a New Feature

Follow these steps every time a new feature is added:

1. **Domain model**: create `lib/domain/models/[feature]_response.dart` (and `_request.dart` if needed).
2. **Repository**: add methods to an existing repository or create `lib/domain/repository/[feature]_repository.dart`.
3. **DI**: register the new repository in `setupDependencyInjection()` and add it to `MultiProvider` in `main.dart`.
4. **BLoC**: create folder `lib/presentation/cubit/[group]/[feature]/` with `_bloc.dart`, `_event.dart`, `_state.dart`.
5. **Screen**: create `lib/presentation/screens/[group]/[feature]_screen.dart`. Use `BlocConsumer` or `BlocBuilder`.
6. **Route**: add a `GoRoute` entry in `lib/config/routes.dart`, wrapping with `BlocProvider` if the screen needs a BLoC.

---

## 6. App-Specific Customization Placeholders

Replace these before generating:

| Placeholder | Description | 
|---|---|
| `[APP_NAME]` | App display name (e.g., `My App`) |
| `[PACKAGE_NAME]` | Bundle/package ID (e.g., `com.example.myapp`) |
| `[BASE_URL]` | Backend API base URL (stored in `.env`) |
| `[FEATURE_LIST]` | List of features/screens to generate |
| `[ROLES]` | User roles if the app has role-based navigation (e.g., `admin`, `user`) |
