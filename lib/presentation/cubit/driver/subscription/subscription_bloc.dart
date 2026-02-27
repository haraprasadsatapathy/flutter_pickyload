import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repository/driver_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final DriverRepository driverRepository;

  SubscriptionBloc(this.driverRepository) : super(SubscriptionInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Request Subscription Payment
    on<RequestSubscriptionPayment>((event, emit) async {
      emit(SubscriptionLoading());

      try {
        // Get user details from SharedPreferences
        final user = await driverRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(SubscriptionError(error: 'Driver ID not found. Please login again.'));
          return;
        }

        final driverId = user.id;
        debugPrint('SubscriptionBloc: Requesting subscription payment for driverId: $driverId');

        final response = await driverRepository.requestSubscriptionPayment(
          driverId: driverId,
        );

        debugPrint('SubscriptionBloc: Response status: ${response.status}, message: ${response.message}');

        if (response.status == true && response.data != null) {
          emit(SubscriptionPaymentReady(
            message: response.data!.message,
            paymentData: response.data!.data,
          ));
        } else {
          emit(SubscriptionError(
            error: response.message ?? 'Failed to request subscription payment',
          ));
        }
      } catch (e) {
        debugPrint('SubscriptionBloc: Error requesting subscription payment: $e');
        emit(SubscriptionError(
          error: 'Failed to request subscription payment: ${e.toString()}',
        ));
      }
    });

    // Verify Subscription Payment
    on<VerifySubscriptionPayment>((event, emit) async {
      emit(SubscriptionVerifying(paymentData: state.paymentData));

      try {
        // Get user details from SharedPreferences
        final user = await driverRepository.getUserDetailsSp();

        if (user == null || user.id.isEmpty) {
          emit(SubscriptionPaymentFailed(
            message: 'Driver ID not found. Please login again.',
            paymentData: state.paymentData,
          ));
          return;
        }

        final userId = user.id;
        debugPrint('SubscriptionBloc: Verifying subscription payment');

        final response = await driverRepository.verifySubscriptionPayment(
          userId: userId,
          subscriptionId: event.subscriptionId,
          amount: event.amount,
          isSuccess: event.success,
          razorpayPaymentId: event.razorpayPaymentId,
          razorpayOrderId: event.razorpayOrderId,
          razorpaySignature: event.razorpaySignature,
          errorCode: event.errorCode,
          errorDescription: event.errorDescription,
          errorSource: event.errorSource,
          errorStep: event.errorStep,
          errorReason: event.errorReason,
          errorOrderId: event.errorOrderId,
          errorPaymentId: event.errorPaymentId,
        );

        debugPrint('SubscriptionBloc: Verify response status: ${response.status}, message: ${response.message}');

        if (response.status == true) {
          emit(SubscriptionPaymentSuccess(
            message: response.message ?? 'Payment verified successfully',
          ));
        } else {
          emit(SubscriptionPaymentFailed(
            message: response.message ?? 'Payment verification failed',
            paymentData: state.paymentData,
          ));
        }
      } catch (e) {
        debugPrint('SubscriptionBloc: Error verifying payment: $e');
        emit(SubscriptionPaymentFailed(
          message: 'Failed to verify payment: ${e.toString()}',
          paymentData: state.paymentData,
        ));
      }
    });

    // Reset State
    on<ResetSubscriptionState>((event, emit) {
      emit(SubscriptionInitial());
    });
  }
}
