import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

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
  final String origin;
  final String destination;
  final DateTime availableTimeStart;
  final DateTime availableTimeEnd;

  SubmitLoadOffer({
    required this.driverId,
    required this.vehicleId,
    required this.origin,
    required this.destination,
    required this.availableTimeStart,
    required this.availableTimeEnd,
  });

  @override
  List<Object?> get props => [
        driverId,
        vehicleId,
        origin,
        destination,
        availableTimeStart,
        availableTimeEnd,
      ];
}

// Reset form
class ResetAddLoadForm extends AddLoadEvent {
  @override
  List<Object?> get props => [];
}
