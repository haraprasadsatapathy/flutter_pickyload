/// Model for verify payment API request
class VerifyPaymentRequest {
  final PaymentSuccess? success;
  final PaymentError? error;
  final String bookingId;
  final String subscriptionId;
  final String userId;
  final double amount;

  VerifyPaymentRequest({
    this.success,
    this.error,
    required this.bookingId,
    required this.subscriptionId,
    required this.userId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success?.toJson(),
      'error': error?.toJson(),
      'bookingId': bookingId,
      'subscriptionId': subscriptionId,
      'userId': userId,
      'amount': amount,
    };
  }
}

/// Payment success details from Razorpay
class PaymentSuccess {
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;

  PaymentSuccess({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
    };
  }
}

/// Payment error details from Razorpay
class PaymentError {
  final String code;
  final String description;
  final String source;
  final String step;
  final String reason;
  final String orderId;
  final String paymentId;

  PaymentError({
    required this.code,
    required this.description,
    required this.source,
    required this.step,
    required this.reason,
    required this.orderId,
    required this.paymentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'source': source,
      'step': step,
      'reason': reason,
      'orderId': orderId,
      'paymentId': paymentId,
    };
  }
}
