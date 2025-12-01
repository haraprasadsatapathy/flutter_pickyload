import 'package:equatable/equatable.dart';

/// Base class for all events and states in the application
/// All BLoC events and states must extend this class for consistency
/// and Equatable comparison
class BaseEventState extends Equatable {
  @override
  List<Object?> get props => [];
}
