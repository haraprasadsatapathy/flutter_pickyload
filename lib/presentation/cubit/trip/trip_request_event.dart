import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

class TripRequestEvent extends BaseEventState {}

class SubmitTripRequest extends TripRequestEvent {
  final String userId;
  final String pickupLocation;
  final String dropLocation;
  final String loadCapacity;
  final String bodyCoverType;
  final String loadName;
  final double length;
  final double width;
  final double height;
  final DateTime? pickupTime;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final double distance;

  SubmitTripRequest({
    required this.userId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.loadCapacity,
    required this.bodyCoverType,
    required this.loadName,
    required this.length,
    required this.width,
    required this.height,
    this.pickupTime,
    this.pickupLat = 0.0,
    this.pickupLng = 0.0,
    this.dropLat = 0.0,
    this.dropLng = 0.0,
    this.distance = 0.0,
  });

  @override
  List<Object?> get props => [
        userId,
        pickupLocation,
        dropLocation,
        loadCapacity,
        bodyCoverType,
        loadName,
        length,
        width,
        height,
        pickupTime,
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
        distance,
      ];
}

class SelectScheduledDate extends TripRequestEvent {
  final DateTime scheduledDate;

  SelectScheduledDate(this.scheduledDate);

  @override
  List<Object?> get props => [scheduledDate];
}
