import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base event class for Add Vehicle feature
class AddVehicleEvent extends BaseEventState {}

// Load user documents (to get RC numbers)
class LoadDocuments extends AddVehicleEvent {
  @override
  List<Object?> get props => [];
}

// Update vehicle fields
class UpdateVehicleNumberPlate extends AddVehicleEvent {
  final String vehicleNumberPlate;

  UpdateVehicleNumberPlate(this.vehicleNumberPlate);

  @override
  List<Object?> get props => [vehicleNumberPlate];
}

class UpdateRcNumber extends AddVehicleEvent {
  final String rcNumber;

  UpdateRcNumber(this.rcNumber);

  @override
  List<Object?> get props => [rcNumber];
}

class UpdateChassisNumber extends AddVehicleEvent {
  final String chassisNumber;

  UpdateChassisNumber(this.chassisNumber);

  @override
  List<Object?> get props => [chassisNumber];
}

class UpdateBodyCoverType extends AddVehicleEvent {
  final String bodyCoverType;

  UpdateBodyCoverType(this.bodyCoverType);

  @override
  List<Object?> get props => [bodyCoverType];
}

class UpdateCapacity extends AddVehicleEvent {
  final String capacity;

  UpdateCapacity(this.capacity);

  @override
  List<Object?> get props => [capacity];
}

class UpdateLength extends AddVehicleEvent {
  final String length;

  UpdateLength(this.length);

  @override
  List<Object?> get props => [length];
}

class UpdateWidth extends AddVehicleEvent {
  final String width;

  UpdateWidth(this.width);

  @override
  List<Object?> get props => [width];
}

class UpdateHeight extends AddVehicleEvent {
  final String height;

  UpdateHeight(this.height);

  @override
  List<Object?> get props => [height];
}

class UpdateNumberOfWheels extends AddVehicleEvent {
  final String numberOfWheels;

  UpdateNumberOfWheels(this.numberOfWheels);

  @override
  List<Object?> get props => [numberOfWheels];
}

// Submit vehicle
class SubmitVehicle extends AddVehicleEvent {
  @override
  List<Object?> get props => [];
}
