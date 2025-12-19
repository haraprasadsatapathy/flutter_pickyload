import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base state class for Add Vehicle feature
class AddVehicleState extends BaseEventState {
  final String? vehicleNumber;
  final String? rcNumber;
  final String? makeModel;
  final bool isVehicleBodyCovered;
  final String? capacity;
  final String? length;
  final String? width;
  final String? height;

  AddVehicleState({
    this.vehicleNumber,
    this.rcNumber,
    this.makeModel,
    this.isVehicleBodyCovered = false,
    this.capacity,
    this.length,
    this.width,
    this.height,
  });

  AddVehicleState copyWith({
    String? vehicleNumber,
    String? rcNumber,
    String? makeModel,
    bool? isVehicleBodyCovered,
    String? capacity,
    String? length,
    String? width,
    String? height,
  }) {
    return AddVehicleState(
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rcNumber: rcNumber ?? this.rcNumber,
      makeModel: makeModel ?? this.makeModel,
      isVehicleBodyCovered: isVehicleBodyCovered ?? this.isVehicleBodyCovered,
      capacity: capacity ?? this.capacity,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [
        vehicleNumber,
        rcNumber,
        makeModel,
        isVehicleBodyCovered,
        capacity,
        length,
        width,
        height,
      ];
}

// Initial state
class AddVehicleInitial extends AddVehicleState {}

// Loading state
class AddVehicleLoading extends AddVehicleState {
  AddVehicleLoading({
    super.vehicleNumber,
    super.rcNumber,
    super.makeModel,
    super.isVehicleBodyCovered,
    super.capacity,
    super.length,
    super.width,
    super.height,
  });
}

// Vehicle added successfully
class VehicleAddedSuccess extends AddVehicleState {
  final String message;

  VehicleAddedSuccess({
    required this.message,
    super.vehicleNumber,
    super.rcNumber,
    super.makeModel,
    super.isVehicleBodyCovered,
    super.capacity,
    super.length,
    super.width,
    super.height,
  });

  @override
  List<Object?> get props => [
        message,
        vehicleNumber,
        rcNumber,
        makeModel,
        isVehicleBodyCovered,
        capacity,
        length,
        width,
        height,
      ];
}

// Vehicle addition failed
class VehicleAdditionError extends AddVehicleState {
  final String error;

  VehicleAdditionError({
    required this.error,
    super.vehicleNumber,
    super.rcNumber,
    super.makeModel,
    super.isVehicleBodyCovered,
    super.capacity,
    super.length,
    super.width,
    super.height,
  });

  @override
  List<Object?> get props => [
        error,
        vehicleNumber,
        rcNumber,
        makeModel,
        isVehicleBodyCovered,
        capacity,
        length,
        width,
        height,
      ];
}
