import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base state class for TripRequest feature
class TripRequestStates extends BaseEventState {}

// Initial state
class TripRequestInitialState extends TripRequestStates {}

// Loading state
class OnLoading extends TripRequestStates {}

// Trip request submitted successfully
class OnTripRequestSuccess extends TripRequestStates {
  final String tripId;
  final String message;
  final bool needsInsurance;

  OnTripRequestSuccess({
    required this.tripId,
    required this.message,
    required this.needsInsurance,
  });

  @override
  List<Object?> get props => [tripId, message, needsInsurance];
}

// Trip request failed
class OnTripRequestError extends TripRequestStates {
  final String message;

  OnTripRequestError(this.message);

  @override
  List<Object?> get props => [message];
}

// Vehicle type selected
class OnVehicleTypeSelected extends TripRequestStates {
  final String vehicleType;

  OnVehicleTypeSelected(this.vehicleType);

  @override
  List<Object?> get props => [vehicleType];
}

// Scheduled date selected
class OnScheduledDateSelected extends TripRequestStates {
  final DateTime scheduledDate;

  OnScheduledDateSelected(this.scheduledDate);

  @override
  List<Object?> get props => [scheduledDate];
}

// Insurance toggled
class OnInsuranceToggled extends TripRequestStates {
  final bool needsInsurance;

  OnInsuranceToggled(this.needsInsurance);

  @override
  List<Object?> get props => [needsInsurance];
}

// Error state
class OnError extends TripRequestStates {
  final String message;

  OnError(this.message);

  @override
  List<Object?> get props => [message];
}
