import 'package:picky_load/presentation/cubit/base/base_event_state.dart';
import 'package:picky_load/domain/models/subscription_payment_response.dart';

/// Base state class for Subscription feature
class SubscriptionState extends BaseEventState {
  final SubscriptionPaymentData? paymentData;

  SubscriptionState({this.paymentData});

  @override
  List<Object?> get props => [paymentData];
}

/// Initial state
class SubscriptionInitial extends SubscriptionState {}

/// Loading state when requesting subscription payment
class SubscriptionLoading extends SubscriptionState {}

/// State when subscription payment request is successful
class SubscriptionPaymentReady extends SubscriptionState {
  final String message;

  SubscriptionPaymentReady({
    required this.message,
    required SubscriptionPaymentData paymentData,
  }) : super(paymentData: paymentData);

  @override
  List<Object?> get props => [message, paymentData];
}

/// Loading state when verifying payment
class SubscriptionVerifying extends SubscriptionState {
  SubscriptionVerifying({super.paymentData});
}

/// State when payment verification is successful
class SubscriptionPaymentSuccess extends SubscriptionState {
  final String message;

  SubscriptionPaymentSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when payment verification failed
class SubscriptionPaymentFailed extends SubscriptionState {
  final String message;

  SubscriptionPaymentFailed({
    required this.message,
    super.paymentData,
  });

  @override
  List<Object?> get props => [message, paymentData];
}

/// Error state
class SubscriptionError extends SubscriptionState {
  final String error;

  SubscriptionError({required this.error});

  @override
  List<Object?> get props => [error];
}
