import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';
import '../../../../domain/models/document_list_response.dart';

// Base state class for Add Vehicle feature
class AddVehicleState extends BaseEventState {
  final String? vehicleNumberPlate;
  final String? rcNumber;
  final String? chassisNumber;
  final String bodyCoverType; // "Open", "Closed", "SemiClosed"
  final String? capacity;
  final String? length;
  final String? width;
  final String? height;
  final String? numberOfWheels;
  final List<DocumentInfo>? rcDocuments; // List of RC documents from API
  final bool isLoadingDocuments;

  AddVehicleState({
    this.vehicleNumberPlate,
    this.rcNumber,
    this.chassisNumber,
    this.bodyCoverType = 'Open',
    this.capacity,
    this.length,
    this.width,
    this.height,
    this.numberOfWheels,
    this.rcDocuments,
    this.isLoadingDocuments = false,
  });

  AddVehicleState copyWith({
    String? vehicleNumberPlate,
    String? rcNumber,
    String? chassisNumber,
    String? bodyCoverType,
    String? capacity,
    String? length,
    String? width,
    String? height,
    String? numberOfWheels,
    List<DocumentInfo>? rcDocuments,
    bool? isLoadingDocuments,
  }) {
    return AddVehicleState(
      vehicleNumberPlate: vehicleNumberPlate ?? this.vehicleNumberPlate,
      rcNumber: rcNumber ?? this.rcNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      bodyCoverType: bodyCoverType ?? this.bodyCoverType,
      capacity: capacity ?? this.capacity,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      numberOfWheels: numberOfWheels ?? this.numberOfWheels,
      rcDocuments: rcDocuments ?? this.rcDocuments,
      isLoadingDocuments: isLoadingDocuments ?? this.isLoadingDocuments,
    );
  }

  @override
  List<Object?> get props => [
        vehicleNumberPlate,
        rcNumber,
        chassisNumber,
        bodyCoverType,
        capacity,
        length,
        width,
        height,
        numberOfWheels,
        rcDocuments,
        isLoadingDocuments,
      ];
}

// Initial state
class AddVehicleInitial extends AddVehicleState {}

// Loading state
class AddVehicleLoading extends AddVehicleState {
  AddVehicleLoading({
    super.vehicleNumberPlate,
    super.rcNumber,
    super.chassisNumber,
    super.bodyCoverType,
    super.capacity,
    super.length,
    super.width,
    super.height,
    super.numberOfWheels,
    super.rcDocuments,
    super.isLoadingDocuments,
  });
}

// Vehicle added successfully
class VehicleAddedSuccess extends AddVehicleState {
  final String message;

  VehicleAddedSuccess({
    required this.message,
    super.vehicleNumberPlate,
    super.rcNumber,
    super.chassisNumber,
    super.bodyCoverType,
    super.capacity,
    super.length,
    super.width,
    super.height,
    super.numberOfWheels,
    super.rcDocuments,
    super.isLoadingDocuments,
  });

  @override
  List<Object?> get props => [
        message,
        vehicleNumberPlate,
        rcNumber,
        chassisNumber,
        bodyCoverType,
        capacity,
        length,
        width,
        height,
        numberOfWheels,
        rcDocuments,
        isLoadingDocuments,
      ];
}

// Vehicle addition failed
class VehicleAdditionError extends AddVehicleState {
  final String error;

  VehicleAdditionError({
    required this.error,
    super.vehicleNumberPlate,
    super.rcNumber,
    super.chassisNumber,
    super.bodyCoverType,
    super.capacity,
    super.length,
    super.width,
    super.height,
    super.numberOfWheels,
    super.rcDocuments,
    super.isLoadingDocuments,
  });

  @override
  List<Object?> get props => [
        error,
        vehicleNumberPlate,
        rcNumber,
        chassisNumber,
        bodyCoverType,
        capacity,
        length,
        width,
        height,
        numberOfWheels,
        rcDocuments,
        isLoadingDocuments,
      ];
}
