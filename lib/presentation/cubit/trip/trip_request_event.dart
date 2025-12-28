import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for TripRequest feature
class TripRequestEvent extends BaseEventState {}

// Submit trip request
class SubmitTripRequest extends TripRequestEvent {
  final String userId;
  final String pickupLocation;
  final String dropLocation;
  final String vehicleType;
  final String loadCapacity;
  final DateTime? scheduledDate;
  final bool needsInsurance;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;

  SubmitTripRequest({
    required this.userId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleType,
    required this.loadCapacity,
    this.scheduledDate,
    required this.needsInsurance,
    this.pickupLat = 0.0,
    this.pickupLng = 0.0,
    this.dropLat = 0.0,
    this.dropLng = 0.0,
  });

  @override
  List<Object?> get props => [
        userId,
        pickupLocation,
        dropLocation,
        vehicleType,
        loadCapacity,
        scheduledDate,
        needsInsurance,
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
      ];
}

// Select vehicle type
class SelectVehicleType extends TripRequestEvent {
  final String vehicleType;

  SelectVehicleType(this.vehicleType);

  @override
  List<Object?> get props => [vehicleType];
}

// Select scheduled date
class SelectScheduledDate extends TripRequestEvent {
  final DateTime scheduledDate;

  SelectScheduledDate(this.scheduledDate);

  @override
  List<Object?> get props => [scheduledDate];
}

// Toggle insurance option
class ToggleInsurance extends TripRequestEvent {
  final bool needsInsurance;

  ToggleInsurance(this.needsInsurance);

  @override
  List<Object?> get props => [needsInsurance];
}
