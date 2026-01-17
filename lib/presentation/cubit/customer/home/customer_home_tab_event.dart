import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

/// Base event class for Customer Home Tab feature
class CustomerHomeTabEvent extends BaseEventState {}

/// Load user data from SharedPreferences
class LoadUserData extends CustomerHomeTabEvent {
  @override
  List<Object?> get props => [];
}

/// Fetch home page data from API
class FetchHomePage extends CustomerHomeTabEvent {
  @override
  List<Object?> get props => [];
}

/// Refresh home page data
class RefreshHomePage extends CustomerHomeTabEvent {
  @override
  List<Object?> get props => [];
}

/// Logout user
class LogoutUser extends CustomerHomeTabEvent {
  @override
  List<Object?> get props => [];
}
