import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Add Vehicle feature
class AddVehicleEvent extends BaseEventState {}

// Update vehicle fields
class UpdateVehicleNumber extends AddVehicleEvent {
  final String vehicleNumber;

  UpdateVehicleNumber(this.vehicleNumber);

  @override
  List<Object?> get props => [vehicleNumber];
}

class UpdateRcNumber extends AddVehicleEvent {
  final String rcNumber;

  UpdateRcNumber(this.rcNumber);

  @override
  List<Object?> get props => [rcNumber];
}

class UpdateMakeModel extends AddVehicleEvent {
  final String makeModel;

  UpdateMakeModel(this.makeModel);

  @override
  List<Object?> get props => [makeModel];
}

class UpdateVehicleBodyCovered extends AddVehicleEvent {
  final bool isVehicleBodyCovered;

  UpdateVehicleBodyCovered(this.isVehicleBodyCovered);

  @override
  List<Object?> get props => [isVehicleBodyCovered];
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

// Submit vehicle
class SubmitVehicle extends AddVehicleEvent {
  @override
  List<Object?> get props => [];
}
