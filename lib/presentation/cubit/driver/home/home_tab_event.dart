import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Home Tab feature
class HomeTabEvent extends BaseEventState {}

// Fetch home page data
class FetchHomePage extends HomeTabEvent {
  @override
  List<Object?> get props => [];
}

// Refresh home page data
class RefreshHomePage extends HomeTabEvent {
  @override
  List<Object?> get props => [];
}

// Fetch documents for user
class FetchDocuments extends HomeTabEvent {
  @override
  List<Object?> get props => [];
}
