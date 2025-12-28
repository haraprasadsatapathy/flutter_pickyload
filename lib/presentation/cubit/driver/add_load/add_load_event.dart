import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Add Load feature
class AddLoadEvent extends BaseEventState {}

// Fetch driver's vehicles for selection
class FetchDriverVehicles extends AddLoadEvent {
  final String driverId;

  FetchDriverVehicles({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

// Submit load offer
class SubmitLoadOffer extends AddLoadEvent {
  final String driverId;
  final String vehicleId;
  final DateTime availableTimeStart;
  final DateTime availableTimeEnd;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String pickupAddress;
  final String dropAddress;
  final double price;
  final List<Map<String, double>>? routePolylinePoints;

  SubmitLoadOffer({
    required this.driverId,
    required this.vehicleId,
    required this.availableTimeStart,
    required this.availableTimeEnd,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.pickupAddress,
    required this.dropAddress,
    required this.price,
    this.routePolylinePoints,
  });

  @override
  List<Object?> get props => [
        driverId,
        vehicleId,
        availableTimeStart,
        availableTimeEnd,
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
        pickupAddress,
        dropAddress,
        price,
        routePolylinePoints,
      ];
}

// Reset form
class ResetAddLoadForm extends AddLoadEvent {
  @override
  List<Object?> get props => [];
}
