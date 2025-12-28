import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import '../../../../services/local/storage_service.dart';
import 'add_vehicle_event.dart';
import 'add_vehicle_state.dart';

class AddVehicleBloc extends Bloc<AddVehicleEvent, AddVehicleState> {
  // Dependencies
  final BuildContext context;
  final DriverRepository driverRepository;

  // Constructor
  AddVehicleBloc(this.context, this.driverRepository) : super(AddVehicleInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Load Documents (to get RC numbers)
    on<LoadDocuments>((event, emit) async {
      emit(state.copyWith(isLoadingDocuments: true));

      try {
        // Get logged-in user ID from SharedPreferences
        final userId = StorageService.getString('userId');

        if (userId == null || userId.isEmpty) {
          emit(state.copyWith(isLoadingDocuments: false));
          return;
        }

        // Call API to fetch all documents
        final result = await driverRepository.getAllDocuments(
          userId: userId,
        );

        if (result.status == true && result.data != null) {
          // Filter only RC documents (RegistrationCertificate)
          final rcDocuments = result.data!.documents
              .where((doc) => doc.documentType == 'RegistrationCertificate')
              .toList();

          emit(state.copyWith(
            rcDocuments: rcDocuments,
            isLoadingDocuments: false,
          ));
        } else {
          emit(state.copyWith(isLoadingDocuments: false));
        }
      } catch (e) {
        emit(state.copyWith(isLoadingDocuments: false));
      }
    });

    // Update Vehicle Number Plate
    on<UpdateVehicleNumberPlate>((event, emit) async {
      emit(state.copyWith(vehicleNumberPlate: event.vehicleNumberPlate));
    });

    // Update RC Number
    on<UpdateRcNumber>((event, emit) async {
      emit(state.copyWith(rcNumber: event.rcNumber));
    });

    // Update Chassis Number
    on<UpdateChassisNumber>((event, emit) async {
      emit(state.copyWith(chassisNumber: event.chassisNumber));
    });

    // Update Body Cover Type
    on<UpdateBodyCoverType>((event, emit) async {
      emit(state.copyWith(bodyCoverType: event.bodyCoverType));
    });

    // Update Capacity
    on<UpdateCapacity>((event, emit) async {
      emit(state.copyWith(capacity: event.capacity));
    });

    // Update Length
    on<UpdateLength>((event, emit) async {
      emit(state.copyWith(length: event.length));
    });

    // Update Width
    on<UpdateWidth>((event, emit) async {
      emit(state.copyWith(width: event.width));
    });

    // Update Height
    on<UpdateHeight>((event, emit) async {
      emit(state.copyWith(height: event.height));
    });

    // Update Number of Wheels
    on<UpdateNumberOfWheels>((event, emit) async {
      emit(state.copyWith(numberOfWheels: event.numberOfWheels));
    });

    // Submit Vehicle
    on<SubmitVehicle>((event, emit) async {
      emit(AddVehicleLoading(
        vehicleNumberPlate: state.vehicleNumberPlate,
        rcNumber: state.rcNumber,
        chassisNumber: state.chassisNumber,
        bodyCoverType: state.bodyCoverType,
        capacity: state.capacity,
        length: state.length,
        width: state.width,
        height: state.height,
        numberOfWheels: state.numberOfWheels,
        rcDocuments: state.rcDocuments,
        isLoadingDocuments: state.isLoadingDocuments,
      ));

      // ============================================
      // BUSINESS LOGIC: Vehicle Form Validation
      // ============================================

      // Validation Rule 1: Check if vehicle number plate is provided
      if (state.vehicleNumberPlate == null || state.vehicleNumberPlate!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle number plate',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      // Validation Rule 2: Check if RC number is provided
      if (state.rcNumber == null || state.rcNumber!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please select RC number',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      // Validation Rule 3: Check if chassis number is provided
      if (state.chassisNumber == null || state.chassisNumber!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter chassis number',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      // Validation Rule 4: Check if capacity is selected
      if (state.capacity == null || state.capacity!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please select vehicle capacity',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      // Validation Rule 5: Check if dimensions are provided
      if (state.length == null || state.length!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle length',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      if (state.width == null || state.width!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle width',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      if (state.height == null || state.height!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle height',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      // Validation Rule 6: Check if number of wheels is provided
      if (state.numberOfWheels == null || state.numberOfWheels!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter number of wheels',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      // Validation Rule 7: Validate numeric dimensions and wheels
      try {
        final length = double.parse(state.length!);
        final width = double.parse(state.width!);
        final height = double.parse(state.height!);
        final numberOfWheels = int.parse(state.numberOfWheels!);

        // Validate minimum values
        if (length <= 0 || width <= 0 || height <= 0) {
          emit(VehicleAdditionError(
            error: 'Vehicle dimensions must be greater than zero',
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
          return;
        }

        // Validate maximum values as per API constraints
        if (length > 18.75) {
          emit(VehicleAdditionError(
            error: 'Length must not exceed 18.75 meters',
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
          return;
        }

        if (width > 2.6) {
          emit(VehicleAdditionError(
            error: 'Width must not exceed 2.6 meters',
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
          return;
        }

        if (height > 4.75) {
          emit(VehicleAdditionError(
            error: 'Height must not exceed 4.75 meters',
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
          return;
        }

        if (numberOfWheels <= 0) {
          emit(VehicleAdditionError(
            error: 'Number of wheels must be greater than zero',
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
          return;
        }
      } catch (e) {
        emit(VehicleAdditionError(
          error: 'Please enter valid numeric values for dimensions and wheels',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
        return;
      }

      // ============================================
      // BUSINESS LOGIC: Submit Vehicle to Server
      // ============================================

      try {
        // Get logged-in user ID from SharedPreferences
        final userId = StorageService.getString('userId');

        if (userId == null || userId.isEmpty) {
          emit(VehicleAdditionError(
            error: 'User not logged in. Please login again.',
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
          return;
        }

        // Call API to upsert vehicle
        final result = await driverRepository.upsertVehicle(
          driverId: userId,
          vehicleNumberPlate: state.vehicleNumberPlate!,
          rcNumber: state.rcNumber!,
          chassisNumber: state.chassisNumber!,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity!,
          length: double.parse(state.length!),
          width: double.parse(state.width!),
          height: double.parse(state.height!),
          numberOfWheels: int.parse(state.numberOfWheels!),
        );

        if (result.status == true && result.data != null) {
          emit(VehicleAddedSuccess(
            message: result.data!.message,
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
        } else {
          emit(VehicleAdditionError(
            error: result.message ?? 'Failed to add vehicle. Please try again.',
            vehicleNumberPlate: state.vehicleNumberPlate,
            rcNumber: state.rcNumber,
            chassisNumber: state.chassisNumber,
            bodyCoverType: state.bodyCoverType,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
            numberOfWheels: state.numberOfWheels,
            rcDocuments: state.rcDocuments,
            isLoadingDocuments: state.isLoadingDocuments,
          ));
        }
      } catch (e) {
        emit(VehicleAdditionError(
          error: 'Failed to add vehicle: ${e.toString()}',
          vehicleNumberPlate: state.vehicleNumberPlate,
          rcNumber: state.rcNumber,
          chassisNumber: state.chassisNumber,
          bodyCoverType: state.bodyCoverType,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
          numberOfWheels: state.numberOfWheels,
          rcDocuments: state.rcDocuments,
          isLoadingDocuments: state.isLoadingDocuments,
        ));
      }
    });
  }
}
