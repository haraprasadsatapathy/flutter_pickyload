import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Vehicle Model
class VehicleModel {
  final String vehicleId;
  final String driverId;
  final bool isVehicleBodyCovered;
  final String capacity;
  final double length;
  final double width;
  final double height;
  final String vehicleNumber;
  final String rcNumber;
  final String makeModel;

  VehicleModel({
    required this.vehicleId,
    required this.driverId,
    required this.isVehicleBodyCovered,
    required this.capacity,
    required this.length,
    required this.width,
    required this.height,
    required this.vehicleNumber,
    required this.rcNumber,
    required this.makeModel,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vehicleId: json['vehicleId'] ?? '',
      driverId: json['driverId'] ?? '',
      isVehicleBodyCovered: json['isVehicleBodyCovered'] ?? false,
      capacity: json['capacity'] ?? '',
      length: (json['length'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      vehicleNumber: json['vehicleNumber'] ?? '',
      rcNumber: json['rcNumber'] ?? '',
      makeModel: json['makeModel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'driverId': driverId,
      'isVehicleBodyCovered': isVehicleBodyCovered,
      'capacity': capacity,
      'length': length,
      'width': width,
      'height': height,
      'vehicleNumber': vehicleNumber,
      'rcNumber': rcNumber,
      'makeModel': makeModel,
    };
  }

  String getCapacityLabel() {
    switch (capacity) {
      case 'upto_half_tonne':
        return 'Up to Half Tonne';
      case 'half_to_one_tonne':
        return 'Half to One Tonne';
      case 'one_to_two_tonne':
        return 'One to Two Tonne';
      case 'two_to_three_tonne':
        return 'Two to Three Tonne';
      case 'above_three_tonne':
        return 'Above Three Tonne';
      default:
        return capacity;
    }
  }
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
