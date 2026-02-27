import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

abstract class SubscriptionEvent extends BaseEventState {}

/// Event to request subscription payment
class RequestSubscriptionPayment extends SubscriptionEvent {
  @override
  List<Object?> get props => [];
}

/// Event to verify subscription payment after Razorpay checkout
class VerifySubscriptionPayment extends SubscriptionEvent {
  final String subscriptionId;
  final double amount;
  final bool success;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final String? errorCode;
  final String? errorDescription;
  final String? errorSource;
  final String? errorStep;
  final String? errorReason;
  final String? errorOrderId;
  final String? errorPaymentId;

  VerifySubscriptionPayment({
    required this.subscriptionId,
    required this.amount,
    required this.success,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    this.errorCode,
    this.errorDescription,
    this.errorSource,
    this.errorStep,
    this.errorReason,
    this.errorOrderId,
    this.errorPaymentId,
  });

  @override
  List<Object?> get props => [
        subscriptionId,
        amount,
        success,
        razorpayPaymentId,
        razorpayOrderId,
        razorpaySignature,
        errorCode,
        errorDescription,
        errorSource,
        errorStep,
        errorReason,
        errorOrderId,
        errorPaymentId,
      ];
}

/// Event to reset state
class ResetSubscriptionState extends SubscriptionEvent {
  @override
  List<Object?> get props => [];
}
