import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Vehicle Model for dropdown selection
class VehicleOptionModel {
  final String vehicleId;
  final String vehicleNumber;
  final String makeModel;
  final String capacity;
  final String rcNumber;

  VehicleOptionModel({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.makeModel,
    required this.capacity,
    required this.rcNumber,
  });

  factory VehicleOptionModel.fromJson(Map<String, dynamic> json) {
    return VehicleOptionModel(
      vehicleId: json['vehicleId'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      makeModel: json['makeModel'] ?? '',
      capacity: json['capacity'] ?? '',
      rcNumber: json['rcNumber'] ?? '',
    );
  }

  String get displayName => '$vehicleNumber - $makeModel (RC: $rcNumber)';
}

// Load Offer Request Model
class LoadOfferRequest {
  final String offerId;
  final String driverId;
  final String vehicleId;
  final String origin;
  final String destination;
  final DateTime availableTimeStart;
  final DateTime availableTimeEnd;
  final String status;

  LoadOfferRequest({
    required this.offerId,
    required this.driverId,
    required this.vehicleId,
    required this.origin,
    required this.destination,
    required this.availableTimeStart,
    required this.availableTimeEnd,
    this.status = 'DriverOffered',
  });

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'origin': origin,
      'destination': destination,
      'availableTimeStart': availableTimeStart.toIso8601String(),
      'availableTimeEnd': availableTimeEnd.toIso8601String(),
      'status': status,
    };
  }
}

// Base state class for Add Load feature
class AddLoadState extends BaseEventState {
  final List<VehicleOptionModel> vehicles;
  final String? selectedVehicleId;

  AddLoadState({
    this.vehicles = const [],
    this.selectedVehicleId,
  });

  @override
  List<Object?> get props => [vehicles, selectedVehicleId];
}

// Initial state
class AddLoadInitial extends AddLoadState {}

// Loading state
class AddLoadLoading extends AddLoadState {
  AddLoadLoading({
    super.vehicles,
    super.selectedVehicleId,
  });
}

// Vehicles fetched successfully
class VehiclesFetched extends AddLoadState {
  final String message;

  VehiclesFetched({
    required this.message,
    required super.vehicles,
    super.selectedVehicleId,
  });

  @override
  List<Object?> get props => [message, vehicles, selectedVehicleId];
}

// Load offer submitted successfully
class LoadOfferSubmitted extends AddLoadState {
  final String message;
  final String offerId;

  LoadOfferSubmitted({
    required this.message,
    required this.offerId,
    super.vehicles,
    super.selectedVehicleId,
  });

  @override
  List<Object?> get props => [message, offerId, vehicles, selectedVehicleId];
}

// Error state
class AddLoadError extends AddLoadState {
  final String error;

  AddLoadError({
    required this.error,
    super.vehicles,
    super.selectedVehicleId,
  });

  @override
  List<Object?> get props => [error, vehicles, selectedVehicleId];
}

// Form reset state
class AddLoadFormReset extends AddLoadState {
  AddLoadFormReset({super.vehicles});

  @override
  List<Object?> get props => [vehicles];
}
