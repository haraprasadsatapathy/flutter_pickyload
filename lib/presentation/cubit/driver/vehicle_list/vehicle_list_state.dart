import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Vehicle Model
class VehicleModel {
  final String vehicleId;
  final String driverId;
  final String capacity;
  final int numberOfWheels;
  final double length;
  final double width;
  final double height;
  final String vehicleNumber;
  final String chassisNumber;
  final String bodyCoverType;
  final String? status;
  final DateTime? verifiedOn;
  final DateTime? updatedOn;

  VehicleModel({
    required this.vehicleId,
    required this.driverId,
    required this.capacity,
    required this.numberOfWheels,
    required this.length,
    required this.width,
    required this.height,
    required this.vehicleNumber,
    required this.chassisNumber,
    required this.bodyCoverType,
    this.status,
    this.verifiedOn,
    this.updatedOn,
  });

  String getCapacityLabel() {
    switch (capacity) {
      case 'upto_half_tonne':
        return 'Up to 0.5 Tonne';
      case 'upto_01_tonne':
        return 'Up to 1 Tonne';
      case 'upto_05_tonne':
        return 'Up to 5 Tonne';
      case 'upto_15_tonne':
        return 'Up to 15 Tonne';
      case 'upto_25_tonne':
        return 'Up to 25 Tonne';
      case 'upto_35_tonne':
        return 'Up to 35 Tonne';
      case 'upto_45_tonne':
        return 'Up to 45 Tonne';
      case 'upto_55_tonne':
        return 'Up to 55 Tonne';
      default:
        return capacity;
    }
  }

  String get bodyCoverTypeLabel {
    switch (bodyCoverType) {
      case 'Open':
        return 'Open';
      case 'Closed':
        return 'Closed';
      case 'SemiClosed':
        return 'Semi-Closed';
      default:
        return bodyCoverType;
    }
  }

  bool get isVerified => status?.toLowerCase() == 'verified';
}

// Base state class for Vehicle List feature
class VehicleListState extends BaseEventState {
  final List<VehicleModel> vehicles;

  VehicleListState({this.vehicles = const []});

  @override
  List<Object?> get props => [vehicles];
}

// Initial state
class VehicleListInitial extends VehicleListState {}

// Loading state
class VehicleListLoading extends VehicleListState {
  VehicleListLoading({super.vehicles});
}

// Vehicles fetched successfully
class VehicleListSuccess extends VehicleListState {
  final String message;

  VehicleListSuccess({
    required this.message,
    required super.vehicles,
  });

  @override
  List<Object?> get props => [message, vehicles];
}

// Vehicle list fetch failed
class VehicleListError extends VehicleListState {
  final String error;

  VehicleListError({
    required this.error,
    super.vehicles = const [],
  });

  @override
  List<Object?> get props => [error, vehicles];
}

// Vehicle deleted successfully
class VehicleDeletedSuccess extends VehicleListState {
  final String message;

  VehicleDeletedSuccess({
    required this.message,
    required super.vehicles,
  });

  @override
  List<Object?> get props => [message, vehicles];
}

// Vehicle deletion failed
class VehicleDeletionError extends VehicleListState {
  final String error;

  VehicleDeletionError({
    required this.error,
    required super.vehicles,
  });

  @override
  List<Object?> get props => [error, vehicles];
}
