# BLoC Architecture Implementation Guide

This guide provides comprehensive instructions for implementing and extending the BLoC architecture in this Flutter project.

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Folder Structure](#folder-structure)
3. [Completed Features](#completed-features)
4. [Creating a New Feature](#creating-a-new-feature)
5. [Step-by-Step Example](#step-by-step-example)
6. [Templates](#templates)
7. [Best Practices](#best-practices)

---

## Architecture Overview

This project follows a clean BLoC (Business Logic Component) architecture with the following layers:

```
├── Presentation Layer (UI + BLoC)
│   ├── Views (Screens & Widgets)
│   └── Cubit (BLoCs, Events, States)
├── Domain Layer (Business Logic)
│   ├── Models
│   └── Repositories (Interfaces)
├── Data Layer (Data Sources)
│   ├── API Client
│   └── Local Storage
└── Services Layer
    ├── Network
    └── Local Storage
```

### Key Principles:
1. **Separation of Concerns**: Events, States, and BLoCs are in separate files
2. **Manual Dependency Injection**: Using GetIt for global services
3. **Immutable States**: States don't mutate; new instances are emitted
4. **Repository Pattern**: Data access abstracted through repositories
5. **Equatable**: All events and states extend `BaseEventState` for comparison

---

## Folder Structure

```
lib/
├── config/
│   ├── dependency_injection.dart
│   └── router/
│       └── app_router.dart (to be migrated to auto_route)
├── data/
│   ├── data_source/
│   │   └── api_client.dart
│   └── local/
├── domain/
│   ├── models/
│   │   └── api_response.dart
│   └── repository/
│       └── user_repository.dart
├── presentation/
│   ├── cubit/
│   │   ├── base/
│   │   │   └── baseEventState.dart
│   │   └── auth/
│   │       ├── login_bloc.dart
│   │       ├── login_event.dart
│   │       ├── login_state.dart
│   │       ├── register_bloc.dart
│   │       ├── register_event.dart
│   │       └── register_state.dart
│   ├── views/
│   │   └── auth/
│   │       ├── login_screen.dart
│   │       └── login_view.dart
│   └── widgets/
├── services/
│   ├── local/
│   │   └── storage_service.dart
│   └── network/
├── models/ (existing models)
│   └── user_model.dart
└── main.dart
```

---

## Completed Features

### 1. Base Infrastructure
- ✅ Base class (`baseEventState.dart`)
- ✅ API Client with Dio
- ✅ Storage Service with SharedPreferences
- ✅ Dependency Injection with GetIt
- ✅ User Repository
- ✅ API Response model

### 2. Auth Feature (Login)
- ✅ Login BLoC (event, state, bloc)
- ✅ Login Screen & View
- ✅ Integration with routing

### 3. Auth Feature (Register)
- ✅ Register BLoC (event, state, bloc)
- ⏳ Register Screen & View (template available below)

---

## Creating a New Feature

Follow these steps to create a new feature using BLoC:

### Step 1: Create Feature Folder
```bash
mkdir -p lib/presentation/cubit/[feature_name]
mkdir -p lib/presentation/views/[feature_name]
```

### Step 2: Create Event File
File: `lib/presentation/cubit/[feature_name]/[feature]_event.dart`

### Step 3: Create State File
File: `lib/presentation/cubit/[feature_name]/[feature]_state.dart`

### Step 4: Create BLoC File
File: `lib/presentation/cubit/[feature_name]/[feature]_bloc.dart`

### Step 5: Create Screen File
File: `lib/presentation/views/[feature_name]/[feature]_screen.dart`

### Step 6: Create View File
File: `lib/presentation/views/[feature_name]/[feature]_view.dart`

### Step 7: Create Repository (if needed)
File: `lib/domain/repository/[feature]_repository.dart`

### Step 8: Register in Dependency Injection
Update `lib/config/dependency_injection.dart`

---

## Step-by-Step Example

Let's create a **Trip Request** feature as an example:

### 1. Create Event File
```dart
// lib/presentation/cubit/trip/trip_request_event.dart
import 'package:picky_load3/presentation/cubit/base/baseEventState.dart';

// Base event class
class TripRequestEvent extends BaseEventState {}

// Get user details
class GetUserDetails extends TripRequestEvent {}

// Load trip data
class LoadTripData extends TripRequestEvent {}

// Submit trip request
class SubmitTripRequest extends TripRequestEvent {
  final String pickupLocation;
  final String dropLocation;
  final String loadType;
  final double weight;

  SubmitTripRequest({
    required this.pickupLocation,
    required this.dropLocation,
    required this.loadType,
    required this.weight,
  });

  @override
  List<Object?> get props => [pickupLocation, dropLocation, loadType, weight];
}
```

### 2. Create State File
```dart
// lib/presentation/cubit/trip/trip_request_state.dart
import 'package:picky_load3/presentation/cubit/base/baseEventState.dart';
import '../../../models/user_model.dart';

// Base state class
class TripRequestStates extends BaseEventState {}

// Initial state
class TripRequestInitialState extends TripRequestStates {}

// Loading state
class OnLoading extends TripRequestStates {}

// User details loaded
class OnGotUserDetails extends TripRequestStates {
  final User user;

  OnGotUserDetails(this.user);

  @override
  List<Object?> get props => [user];
}

// Trip data loaded
class OnTripDataLoaded extends TripRequestStates {}

// Trip request submitted successfully
class OnTripRequestSuccess extends TripRequestStates {
  final String tripId;

  OnTripRequestSuccess(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

// Error state
class OnError extends TripRequestStates {
  final String message;

  OnError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 3. Create BLoC File
```dart
// lib/presentation/cubit/trip/trip_request_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_request_event.dart';
import 'trip_request_state.dart';
import '../../../domain/repository/user_repository.dart';
// import '../../../domain/repository/trip_repository.dart';
import '../../../models/user_model.dart';

class TripRequestBloc extends Bloc<TripRequestEvent, TripRequestStates> {
  // Dependencies
  final BuildContext context;
  final UserRepository userRepository;
  // final TripRepository tripRepository;

  // State management fields
  User? userDetails;
  bool isLoading = false;

  // Constructor
  TripRequestBloc(
    this.context,
    this.userRepository,
    // this.tripRepository,
  ) : super(TripRequestInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Get user details
    on<GetUserDetails>((event, emit) async {
      emit(OnLoading());

      userDetails = await userRepository.getUserDetailsSp();

      if (userDetails != null) {
        emit(OnGotUserDetails(userDetails!));
      } else {
        emit(OnError('User not found'));
      }
    });

    // Load trip data
    on<LoadTripData>((event, emit) async {
      emit(OnLoading());

      // Load necessary data for trip request
      // Example: load vehicle types, pricing, etc.

      emit(OnTripDataLoaded());
    });

    // Submit trip request
    on<SubmitTripRequest>((event, emit) async {
      emit(OnLoading());

      // Validate inputs
      if (event.pickupLocation.isEmpty || event.dropLocation.isEmpty) {
        emit(OnError('Please fill all fields'));
        return;
      }

      if (event.weight <= 0) {
        emit(OnError('Please enter valid weight'));
        return;
      }

      // Call repository to submit trip request
      // final result = await tripRepository.createTripRequest(
      //   userId: userDetails!.id,
      //   pickupLocation: event.pickupLocation,
      //   dropLocation: event.dropLocation,
      //   loadType: event.loadType,
      //   weight: event.weight,
      // );

      // if (result.status == true && result.data != null) {
      //   emit(OnTripRequestSuccess(result.data!['tripId']));
      // } else {
      //   emit(OnError(result.message ?? 'Failed to create trip request'));
      // }

      // For now, simulate success
      await Future.delayed(const Duration(seconds: 2));
      emit(OnTripRequestSuccess('trip_123'));
    });
  }
}
```

### 4. Create Screen File
```dart
// lib/presentation/views/trip/trip_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/trip/trip_request_bloc.dart';
import '../../../domain/repository/user_repository.dart';
import '../../../config/dependency_injection.dart';
import 'trip_request_view.dart';

class TripRequestScreen extends StatelessWidget {
  const TripRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get repositories from GetIt
    final userRepository = getIt<UserRepository>();
    // final tripRepository = getIt<TripRepository>();

    // Provide BLoC to widget tree
    return BlocProvider(
      create: (context) => TripRequestBloc(
        context,
        userRepository,
        // tripRepository,
      ),
      child: const TripRequestView(),
    );
  }
}
```

### 5. Create View File
```dart
// lib/presentation/views/trip/trip_request_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubit/trip/trip_request_bloc.dart';
import '../../cubit/trip/trip_request_event.dart';
import '../../cubit/trip/trip_request_state.dart';

class TripRequestView extends StatefulWidget {
  const TripRequestView({super.key});

  @override
  State<TripRequestView> createState() => _TripRequestViewState();
}

class _TripRequestViewState extends State<TripRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedLoadType = 'Furniture';

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripRequestBloc, TripRequestStates>(
      builder: (context, state) {
        // Handle initial state
        if (state is TripRequestInitialState) {
          BlocProvider.of<TripRequestBloc>(context).add(GetUserDetails());
        }

        final isLoading = state is OnLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Request a Trip'),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Main content
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Trip Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _pickupController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Pickup Location',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter pickup location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _dropController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Drop Location',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter drop location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedLoadType,
                          decoration: const InputDecoration(
                            labelText: 'Load Type',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: ['Furniture', 'Electronics', 'Documents', 'Others']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedLoadType = value!;
                                  });
                                },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: Icon(Icons.scale),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter weight';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      BlocProvider.of<TripRequestBloc>(context).add(
                                        SubmitTripRequest(
                                          pickupLocation: _pickupController.text.trim(),
                                          dropLocation: _dropController.text.trim(),
                                          loadType: _selectedLoadType,
                                          weight: double.parse(_weightController.text),
                                        ),
                                      );
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Submit Request'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
              ],
            ),
          ),
        );
      },

      listener: (context, state) {
        // React to state changes
        if (state is OnGotUserDetails) {
          // User details loaded, load trip data
          BlocProvider.of<TripRequestBloc>(context).add(LoadTripData());
        }

        if (state is OnTripRequestSuccess) {
          // Trip request successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to trip tracking or back
          context.go('/trip-tracking');
        }

        if (state is OnError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
```

---

## Templates

### Quick Template for New Feature

Use this as a starting point for any new feature:

#### Event Template
```dart
import 'package:picky_load3/presentation/cubit/base/baseEventState.dart';

class [Feature]Event extends BaseEventState {}

class GetUserDetails extends [Feature]Event {}

class Get[Feature]Data extends [Feature]Event {}

class Submit[Action] extends [Feature]Event {
  final String data;

  Submit[Action](this.data);

  @override
  List<Object?> get props => [data];
}
```

#### State Template
```dart
import 'package:picky_load3/presentation/cubit/base/baseEventState.dart';

class [Feature]States extends BaseEventState {}

class [Feature]InitialState extends [Feature]States {}

class OnLoading extends [Feature]States {}

class OnGotUserDetails extends [Feature]States {}

class OnGot[Feature]Data extends [Feature]States {}

class OnSuccess[Action] extends [Feature]States {}

class OnError extends [Feature]States {
  final String message;

  OnError(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### BLoC Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '[feature]_event.dart';
import '[feature]_state.dart';
import '../../../domain/repository/user_repository.dart';

class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]States> {
  final BuildContext context;
  final UserRepository userRepository;

  [Feature]Bloc(this.context, this.userRepository)
      : super([Feature]InitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<GetUserDetails>((event, emit) async {
      emit(OnLoading());
      final user = await userRepository.getUserDetailsSp();
      emit(OnGotUserDetails());
    });
  }
}
```

---

## Best Practices

### 1. Naming Conventions
- **Events**: Use action verbs (Get, Update, Submit, Delete)
- **States**: Use "On" prefix (OnLoading, OnSuccess, OnError)
- **BLoCs**: End with "Bloc" (LoginBloc, TripRequestBloc)
- **Folders**: Use snake_case (trip_request, user_profile)

### 2. Error Handling
- Always emit `OnLoading()` before async operations
- Always handle both success and error cases
- Use meaningful error messages
- Emit `OnError(message)` for errors

### 3. State Management
- Keep states immutable
- Store intermediate data in BLoC instance variables
- Pass data through state constructor parameters

### 4. Event Chaining
- Chain events through listeners, not within handlers
- Example:
  ```dart
  if (state is OnGotUserDetails) {
    BlocProvider.of<Bloc>(context).add(NextEvent());
  }
  ```

### 5. Repository Pattern
- All API calls should go through repositories
- Repositories handle data transformation
- BLoCs should not directly call API clients

### 6. Testing
- Test BLoCs in isolation
- Mock repositories for testing
- Use `blocTest` package for BLoC testing

---

## Next Steps

### Features to Migrate:
1. ✅ Login (Completed)
2. ✅ Register (BLoC completed, Views pending)
3. ⏳ OTP Verification
4. ⏳ Driver Dashboard
5. ⏳ Customer Dashboard
6. ⏳ Trip Request
7. ⏳ Trip Tracking
8. ⏳ Payment
9. ⏳ Profile Management
10. ⏳ Notifications

### Repository Creation Needed:
- TripRepository
- PaymentRepository
- InsuranceRepository
- DocumentRepository
- NotificationRepository

### Additional Tasks:
1. Migrate from go_router to auto_route
2. Implement auto_route code generation
3. Add comprehensive error handling
4. Implement proper API integration
5. Add loading states for better UX
6. Implement proper navigation guards

---

## Support & Resources

- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Equatable Package](https://pub.dev/packages/equatable)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Auto Route Documentation](https://pub.dev/packages/auto_route)

---

## File Reference

Key files created:
- `lib/presentation/cubit/base/baseEventState.dart` - Base class
- `lib/config/dependency_injection.dart` - DI setup
- `lib/services/local/storage_service.dart` - Local storage
- `lib/data/data_source/api_client.dart` - API client
- `lib/domain/repository/user_repository.dart` - User repository
- `lib/domain/models/api_response.dart` - API response model

Auth feature files:
- `lib/presentation/cubit/auth/login_*.dart` - Login BLoC
- `lib/presentation/cubit/auth/register_*.dart` - Register BLoC
- `lib/presentation/views/auth/login_*.dart` - Login UI

---

Happy coding! 🚀
