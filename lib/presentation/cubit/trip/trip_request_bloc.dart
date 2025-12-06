import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_request_event.dart';
import 'trip_request_state.dart';
import '../../../domain/repository/trip_repository.dart';

class TripRequestBloc extends Bloc<TripRequestEvent, TripRequestStates> {
  // Dependencies
  final BuildContext context;
  final TripRepository tripRepository;

  // State management fields
  String selectedVehicleType = 'Mini Truck';
  DateTime? scheduledDate;
  bool needsInsurance = false;
  bool isLoading = false;

  // Constructor
  TripRequestBloc(this.context, this.tripRepository)
      : super(TripRequestInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Select vehicle type event
    on<SelectVehicleType>((event, emit) {
      selectedVehicleType = event.vehicleType;
      emit(OnVehicleTypeSelected(selectedVehicleType));
    });

    // Select scheduled date event
    on<SelectScheduledDate>((event, emit) {
      scheduledDate = event.scheduledDate;
      emit(OnScheduledDateSelected(scheduledDate!));
    });

    // Toggle insurance event
    on<ToggleInsurance>((event, emit) {
      needsInsurance = event.needsInsurance;
      emit(OnInsuranceToggled(needsInsurance));
    });

    // Submit trip request event
    on<SubmitTripRequest>((event, emit) async {
      emit(OnLoading());

      // ============================================
      // BUSINESS LOGIC: Input Validation
      // ============================================

      // Validation Rule 1: Check if all required fields are filled
      if (event.pickupLocation.isEmpty || event.dropLocation.isEmpty) {
        emit(OnTripRequestError('Please fill all required fields'));
        return;
      }

      // Validation Rule 2: Validate load capacity
      if (event.loadCapacity.isEmpty) {
        emit(OnTripRequestError('Please enter load capacity'));
        return;
      }

      // Validation Rule 3: Validate load capacity is a valid number
      final loadCapacity = double.tryParse(event.loadCapacity);
      if (loadCapacity == null || loadCapacity <= 0) {
        emit(OnTripRequestError('Please enter a valid load capacity'));
        return;
      }

      // Validation Rule 4: Validate scheduled date
      if (event.scheduledDate == null) {
        emit(OnTripRequestError('Please select a scheduled date'));
        return;
      }

      // Validation Rule 5: Check if userId is provided
      if (event.userId.isEmpty) {
        emit(OnTripRequestError('User ID is required'));
        return;
      }

      // ============================================
      // BUSINESS LOGIC: Trip Request Submission
      // ============================================

      try {
        // Call API to create booking
        final result = await tripRepository.createBooking(
          userId: event.userId,
          pickupAddress: event.pickupLocation,
          dropAddress: event.dropLocation,
          vehicleType: event.vehicleType,
          loadCapacity: loadCapacity,
          bookingDate: event.scheduledDate!,
          isInsured: true, // Always true as per requirement
          pickupLat: event.pickupLat,
          pickupLng: event.pickupLng,
          dropLat: event.dropLat,
          dropLng: event.dropLng,
        );

        if (result.status == true && result.data != null) {
          // Booking created successfully
          emit(
            OnTripRequestSuccess(
              tripId: result.data!.bookingId,
              message: result.data!.message,
              needsInsurance: event.needsInsurance,
            ),
          );
        } else {
          // Booking creation failed
          emit(OnTripRequestError(
            result.message ?? 'Failed to create booking',
          ));
        }
      } catch (e) {
        emit(OnTripRequestError('An error occurred: ${e.toString()}'));
      }
    });
  }
}
