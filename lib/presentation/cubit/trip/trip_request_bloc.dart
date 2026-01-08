import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_request_event.dart';
import 'trip_request_state.dart';
import '../../../domain/repository/trip_repository.dart';

class TripRequestBloc extends Bloc<TripRequestEvent, TripRequestStates> {
  final BuildContext context;
  final TripRepository tripRepository;

  DateTime? scheduledDate;

  TripRequestBloc(this.context, this.tripRepository)
      : super(TripRequestInitialState()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<SelectScheduledDate>((event, emit) {
      scheduledDate = event.scheduledDate;
      emit(OnScheduledDateSelected(scheduledDate!));
    });

    on<SubmitTripRequest>((event, emit) async {
      emit(OnLoading());

      // ============================================
      // BUSINESS LOGIC: Input Validation
      // ============================================

      // Validation Rule 1: Check if pickup and drop locations are filled
      if (event.pickupLocation.isEmpty || event.dropLocation.isEmpty) {
        emit(OnTripRequestError('Please fill pickup and drop locations'));
        return;
      }

      // Validation Rule 2: Validate load capacity is selected
      if (event.loadCapacity.isEmpty) {
        emit(OnTripRequestError('Please select load capacity'));
        return;
      }

      // Validation Rule 3: Validate body cover type is selected
      if (event.bodyCoverType.isEmpty) {
        emit(OnTripRequestError('Please select body cover type'));
        return;
      }

      // Validation Rule 4: Validate load name is filled
      if (event.loadName.isEmpty) {
        emit(OnTripRequestError('Please enter load name'));
        return;
      }

      // Validation Rule 5: Validate dimensions
      if (event.length <= 0) {
        emit(OnTripRequestError('Please enter a valid length'));
        return;
      }

      if (event.width <= 0) {
        emit(OnTripRequestError('Please enter a valid width'));
        return;
      }

      if (event.height <= 0) {
        emit(OnTripRequestError('Please enter a valid height'));
        return;
      }

      // Validation Rule 6: Validate pickup time
      if (event.pickupTime == null) {
        emit(OnTripRequestError('Please select pickup date and time'));
        return;
      }

      // Validation Rule 7: Validate pickup time is in future
      if (event.pickupTime!.isBefore(DateTime.now())) {
        emit(OnTripRequestError('Pickup time must be in the future'));
        return;
      }

      // Validation Rule 8: Check if userId is provided
      if (event.userId.isEmpty) {
        emit(OnTripRequestError('User ID is required'));
        return;
      }

      // Validation Rule 9: Validate location coordinates
      if (event.pickupLat == 0.0 || event.pickupLng == 0.0) {
        emit(OnTripRequestError('Please select pickup location from map'));
        return;
      }

      if (event.dropLat == 0.0 || event.dropLng == 0.0) {
        emit(OnTripRequestError('Please select drop location from map'));
        return;
      }

      // ============================================
      // BUSINESS LOGIC: Trip Request Submission
      // ============================================

      try {
        final result = await tripRepository.createBooking(
          userId: event.userId,
          vehicleBodyCoverType: event.bodyCoverType,
          loadCapacity: event.loadCapacity,
          loadName: event.loadName,
          length: event.length,
          width: event.width,
          height: event.height,
          pickupTime: event.pickupTime!,
          isInsured: true,
          pickupLat: event.pickupLat,
          pickupLng: event.pickupLng,
          dropLat: event.dropLat,
          dropLng: event.dropLng,
          pickupAddress: event.pickupLocation,
          dropAddress: event.dropLocation,
        );

        if (result.status == true && result.data != null) {
          emit(
            OnTripRequestSuccess(
              tripId: result.data!.bookingId,
              message: result.data!.message,
            ),
          );
        } else {
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
