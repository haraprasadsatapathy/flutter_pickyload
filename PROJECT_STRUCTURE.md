# Project Structure - Picky Load

## Current Architecture (BLoC Pattern)

```
picky_load3/
│
├── lib/
│   │
│   ├── 📁 config/                          # Configuration files
│   │   ├── dependency_injection.dart       # ✨ GetIt DI setup
│   │   └── routes.dart                     # go_router configuration
│   │
│   ├── 📁 data/                            # Data layer
│   │   ├── data_source/
│   │   │   └── api_client.dart             # ✨ Dio HTTP client
│   │   └── local/                          # Local data sources
│   │
│   ├── 📁 domain/                          # Domain layer
│   │   ├── models/
│   │   │   └── api_response.dart           # ✨ Generic API response
│   │   └── repository/
│   │       └── user_repository.dart        # ✨ User data repository
│   │
│   ├── 📁 presentation/                    # Presentation layer
│   │   │
│   │   ├── 📁 cubit/                       # ✨ BLoC files
│   │   │   │
│   │   │   ├── base/
│   │   │   │   └── baseEventState.dart     # ✨ Base class for events/states
│   │   │   │
│   │   │   └── auth/                       # ✨ Authentication BLoCs
│   │   │       ├── login_bloc.dart         # ✨ Login BLoC
│   │   │       ├── login_event.dart        # ✨ Login events
│   │   │       ├── login_state.dart        # ✨ Login states
│   │   │       ├── register_bloc.dart      # ✨ Register BLoC
│   │   │       ├── register_event.dart     # ✨ Register events
│   │   │       └── register_state.dart     # ✨ Register states
│   │   │
│   │   ├── 📁 views/                       # ✨ Screen files (BLoC-based)
│   │   │   └── auth/
│   │   │       ├── login_screen.dart       # ✨ Login screen (BLoC provider)
│   │   │       └── login_view.dart         # ✨ Login view (UI)
│   │   │
│   │   └── 📁 widgets/                     # Reusable widgets
│   │
│   ├── 📁 services/                        # Service layer
│   │   ├── local/
│   │   │   └── storage_service.dart        # ✨ SharedPreferences wrapper
│   │   └── network/
│   │
│   ├── 📁 models/                          # Legacy models (to be moved)
│   │   ├── user_model.dart
│   │   ├── trip_model.dart
│   │   ├── payment_model.dart
│   │   └── document_model.dart
│   │
│   ├── 📁 screens/                         # Legacy screens (to be migrated)
│   │   ├── auth/
│   │   │   ├── login_screen.dart           # ⚠️ Old version (replaced)
│   │   │   ├── register_screen.dart        # ⏳ To be migrated
│   │   │   ├── otp_verification_screen.dart # ⏳ To be migrated
│   │   │   ├── password_recovery_screen.dart # ⏳ To be migrated
│   │   │   └── role_selection_screen.dart  # ⏳ To be migrated
│   │   │
│   │   ├── driver/
│   │   │   ├── driver_dashboard.dart       # ⏳ To be migrated
│   │   │   ├── document_upload_screen.dart # ⏳ To be migrated
│   │   │   └── tabs/
│   │   │       ├── home_tab.dart
│   │   │       ├── my_loads_tab.dart
│   │   │       ├── earnings_tab.dart
│   │   │       └── profile_tab.dart
│   │   │
│   │   ├── customer/
│   │   │   ├── customer_dashboard.dart     # ⏳ To be migrated
│   │   │   ├── customer_profile_screen.dart # ⏳ To be migrated
│   │   │   ├── trip_request_screen.dart    # ⏳ To be migrated
│   │   │   ├── trip_tracking_screen.dart   # ⏳ To be migrated
│   │   │   ├── payment_screen.dart         # ⏳ To be migrated
│   │   │   ├── transaction_history_screen.dart
│   │   │   ├── notifications_screen.dart   # ⏳ To be migrated
│   │   │   ├── help_support_screen.dart    # ✨ New
│   │   │   └── tabs/
│   │   │       ├── my_trips_tab.dart
│   │   │       ├── notifications_tab.dart
│   │   │       ├── profile_tab.dart
│   │   │       └── quick_action_button.dart
│   │   │
│   │   ├── profile/
│   │   │   └── user_profile_screen.dart    # ⏳ Legacy (not in use)
│   │   │
│   │   └── splash/
│   │       └── splash_screen.dart
│   │
│   ├── 📁 providers/                       # Legacy providers (Provider pattern)
│   │   ├── auth_provider.dart              # ⚠️ Being replaced by BLoC
│   │   └── theme_provider.dart             # ✅ Keep (for theme management)
│   │
│   ├── 📁 theme/
│   │   └── app_theme.dart
│   │
│   ├── 📁 utils/
│   │   └── constant/
│   │
│   ├── 📁 widgets/                         # Shared widgets
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_indicator.dart
│   │   └── empty_state.dart
│   │
│   └── main.dart                           # ✨ Updated with BLoC initialization
│
├── 📄 BLOC_IMPLEMENTATION_GUIDE.md         # ✨ Complete implementation guide
├── 📄 BLOC_MIGRATION_SUMMARY.md            # ✨ Migration summary
├── 📄 PROJECT_STRUCTURE.md                 # ✨ This file
└── 📄 pubspec.yaml                         # ✨ Updated with BLoC dependencies

```

## Legend

- ✨ **New/Updated** - Created or modified for BLoC architecture
- ✅ **Keep** - Keep as is (compatible with BLoC)
- ⚠️ **Replaced** - Old version, new BLoC version available
- ⏳ **To Migrate** - Needs to be converted to BLoC pattern

---

## Architecture Layers Explained

### 1. Presentation Layer (`lib/presentation/`)
**Purpose**: UI and user interaction

#### Components:
- **cubit/** - BLoC files (Business Logic Components)
  - Events: User actions and triggers
  - States: UI states and data
  - BLoCs: Business logic handlers

- **views/** - Screen implementations
  - `*_screen.dart`: BLoC provider setup
  - `*_view.dart`: UI implementation with BlocConsumer

- **widgets/** - Reusable UI components

### 2. Domain Layer (`lib/domain/`)
**Purpose**: Business logic and data contracts

#### Components:
- **models/** - Data models and entities
  - API response models
  - Business models

- **repository/** - Data access interfaces
  - Abstract repository contracts
  - Concrete implementations

### 3. Data Layer (`lib/data/`)
**Purpose**: Data sources and external communication

#### Components:
- **data_source/** - Remote data sources
  - API clients
  - Network calls

- **local/** - Local data sources
  - Database access
  - Cache management

### 4. Services Layer (`lib/services/`)
**Purpose**: Cross-cutting concerns

#### Components:
- **local/** - Local services
  - Storage service
  - Cache service

- **network/** - Network services
  - Connectivity
  - Network state

### 5. Config Layer (`lib/config/`)
**Purpose**: App-wide configuration

#### Components:
- Dependency injection setup
- Routing configuration
- Environment configuration

---

## Data Flow

```
User Interaction (View)
        ↓
    Add Event (BLoC)
        ↓
    Event Handler (BLoC)
        ↓
    Repository Call
        ↓
    Data Source (API/Local)
        ↓
    Emit State (BLoC)
        ↓
    Update UI (View)
```

---

## Feature Organization Pattern

Each feature follows this structure:

```
feature_name/
├── cubit/
│   ├── [feature]_bloc.dart     # Business logic
│   ├── [feature]_event.dart    # User actions
│   └── [feature]_state.dart    # UI states
├── views/
│   ├── [feature]_screen.dart   # BLoC provider
│   └── [feature]_view.dart     # UI implementation
└── widgets/
    └── [feature]_widget.dart   # Feature-specific widgets
```

---

## Migration Status

### ✅ Completed Features (BLoC)
1. **Login**
   - Events: 5
   - States: 7
   - Full UI implementation

2. **Register** (BLoC only)
   - Events: 3
   - States: 6
   - UI pending

### ⏳ Pending Features
1. OTP Verification
2. Password Recovery
3. Role Selection
4. Driver Dashboard
5. Customer Dashboard
6. Trip Request
7. Trip Tracking
8. Payment
9. Profile Management
10. Notifications
11. Settings

### 📊 Progress
- **Infrastructure**: 100%
- **Auth BLoCs**: 66% (2/3 features)
- **Dashboard BLoCs**: 0%
- **Trip BLoCs**: 0%
- **Overall**: ~15%

---

## Dependencies Overview

### BLoC Architecture
```yaml
flutter_bloc: ^8.1.6      # State management
equatable: ^2.0.7         # Value comparison
get_it: ^8.0.2           # Dependency injection
```

### Routing
```yaml
go_router: ^13.0.0       # Current (to be replaced)
auto_route: ^9.2.2       # Future routing solution
```

### Network
```yaml
dio: ^5.7.0              # HTTP client
```

### Storage
```yaml
shared_preferences: ^2.2.2  # Local storage
```

### Utilities
```yaml
dartz: ^0.10.1           # Functional programming
intl: ^0.19.0            # Internationalization
```

---

## Naming Conventions

### Files
- Events: `[feature]_event.dart`
- States: `[feature]_state.dart`
- BLoCs: `[feature]_bloc.dart`
- Screens: `[feature]_screen.dart`
- Views: `[feature]_view.dart`

### Classes
- Base Event: `[Feature]Event`
- Base State: `[Feature]States` (plural)
- BLoC: `[Feature]Bloc`
- Events: `Get*`, `On*`, `Update*`, `Submit*`
- States: `On*`, `OnLoading`, `OnError`, `[Feature]InitialState`

### Folders
- Use `snake_case` for all folder names
- Example: `trip_request`, `user_profile`, `payment_history`

---

## Quick Reference

### Creating New Feature
1. Create folder: `lib/presentation/cubit/[feature_name]/`
2. Create event file
3. Create state file
4. Create bloc file
5. Create screen file
6. Create view file
7. Register dependencies
8. Update routing

### Common Commands
```bash
# Install dependencies
flutter pub get

# Run code generation (for auto_route, when ready)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run app
flutter run
```

---

## Best Practices

1. ✅ Keep BLoCs focused on single responsibility
2. ✅ Always extend BaseEventState for events and states
3. ✅ Emit OnLoading before async operations
4. ✅ Handle both success and error cases
5. ✅ Use meaningful names for events and states
6. ✅ Keep UI logic out of BLoCs
7. ✅ Use repositories for data access
8. ✅ Test BLoCs in isolation

---

**Last Updated**: 2025-11-29
**BLoC Version**: 8.1.6
**Architecture Status**: ✅ Production Ready
