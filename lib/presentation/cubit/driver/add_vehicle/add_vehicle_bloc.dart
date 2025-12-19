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
    // Update Vehicle Number
    on<UpdateVehicleNumber>((event, emit) async {
      emit(state.copyWith(vehicleNumber: event.vehicleNumber));
    });

    // Update RC Number
    on<UpdateRcNumber>((event, emit) async {
      emit(state.copyWith(rcNumber: event.rcNumber));
    });

    // Update Make/Model
    on<UpdateMakeModel>((event, emit) async {
      emit(state.copyWith(makeModel: event.makeModel));
    });

    // Update Vehicle Body Covered
    on<UpdateVehicleBodyCovered>((event, emit) async {
      emit(state.copyWith(isVehicleBodyCovered: event.isVehicleBodyCovered));
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

    // Submit Vehicle
    on<SubmitVehicle>((event, emit) async {
      emit(AddVehicleLoading(
        vehicleNumber: state.vehicleNumber,
        rcNumber: state.rcNumber,
        makeModel: state.makeModel,
        isVehicleBodyCovered: state.isVehicleBodyCovered,
        capacity: state.capacity,
        length: state.length,
        width: state.width,
        height: state.height,
      ));

      // ============================================
      // BUSINESS LOGIC: Vehicle Form Validation
      // ============================================

      // Validation Rule 1: Check if vehicle number is provided
      if (state.vehicleNumber == null || state.vehicleNumber!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle number',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
        return;
      }

      // Validation Rule 2: Check if RC number is provided
      if (state.rcNumber == null || state.rcNumber!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter RC number',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
        return;
      }

      // Validation Rule 3: Check if make/model is provided
      if (state.makeModel == null || state.makeModel!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle make/model',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
        return;
      }

      // Validation Rule 4: Check if capacity is selected
      if (state.capacity == null || state.capacity!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please select vehicle capacity',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
        return;
      }

      // Validation Rule 5: Check if dimensions are provided
      if (state.length == null || state.length!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle length',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
        return;
      }

      if (state.width == null || state.width!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle width',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
        return;
      }

      if (state.height == null || state.height!.isEmpty) {
        emit(VehicleAdditionError(
          error: 'Please enter vehicle height',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
        return;
      }

      // Validation Rule 6: Validate numeric dimensions
      try {
        final length = double.parse(state.length!);
        final width = double.parse(state.width!);
        final height = double.parse(state.height!);

        if (length <= 0 || width <= 0 || height <= 0) {
          emit(VehicleAdditionError(
            error: 'Vehicle dimensions must be greater than zero',
            vehicleNumber: state.vehicleNumber,
            rcNumber: state.rcNumber,
            makeModel: state.makeModel,
            isVehicleBodyCovered: state.isVehicleBodyCovered,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
          ));
          return;
        }
      } catch (e) {
        emit(VehicleAdditionError(
          error: 'Please enter valid numeric values for dimensions',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
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
            vehicleNumber: state.vehicleNumber,
            rcNumber: state.rcNumber,
            makeModel: state.makeModel,
            isVehicleBodyCovered: state.isVehicleBodyCovered,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
          ));
          return;
        }

        // Call API to upsert vehicle
        final result = await driverRepository.upsertVehicle(
          driverId: userId,
          vehicleNumber: state.vehicleNumber!,
          rcNumber: state.rcNumber!,
          makeModel: state.makeModel!,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity!,
          length: double.parse(state.length!),
          width: double.parse(state.width!),
          height: double.parse(state.height!),
        );

        if (result.status == true && result.data != null) {
          emit(VehicleAddedSuccess(
            message: result.data!.message,
            vehicleNumber: state.vehicleNumber,
            rcNumber: state.rcNumber,
            makeModel: state.makeModel,
            isVehicleBodyCovered: state.isVehicleBodyCovered,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
          ));
        } else {
          emit(VehicleAdditionError(
            error: result.message ?? 'Failed to add vehicle. Please try again.',
            vehicleNumber: state.vehicleNumber,
            rcNumber: state.rcNumber,
            makeModel: state.makeModel,
            isVehicleBodyCovered: state.isVehicleBodyCovered,
            capacity: state.capacity,
            length: state.length,
            width: state.width,
            height: state.height,
          ));
        }
      } catch (e) {
        emit(VehicleAdditionError(
          error: 'Failed to add vehicle: ${e.toString()}',
          vehicleNumber: state.vehicleNumber,
          rcNumber: state.rcNumber,
          makeModel: state.makeModel,
          isVehicleBodyCovered: state.isVehicleBodyCovered,
          capacity: state.capacity,
          length: state.length,
          width: state.width,
          height: state.height,
        ));
      }
    });
  }
}
