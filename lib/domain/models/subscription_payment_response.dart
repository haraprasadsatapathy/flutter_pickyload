/// Response model for Driver Subscription Payment Request API
/// GET /Driver/RequestSubscriptionPayment?driverId={driverId}
class SubscriptionPaymentResponse {
  final String message;
  final SubscriptionPaymentData data;

  SubscriptionPaymentResponse({
    required this.message,
    required this.data,
  });

  factory SubscriptionPaymentResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentResponse(
      message: json['message'] as String? ?? '',
      data: SubscriptionPaymentData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Subscription payment data containing order details for Razorpay
class SubscriptionPaymentData {
  final String orderId;
  final double totalAmount;
  final double amountPayable;
  final String subscriptionId;
  final String currency;
  final String email;
  final String contact;

  SubscriptionPaymentData({
    required this.orderId,
    required this.totalAmount,
    required this.amountPayable,
    required this.subscriptionId,
    required this.currency,
    required this.email,
    required this.contact,
  });

  factory SubscriptionPaymentData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentData(
      orderId: json['orderId'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountPayable: (json['amountPayable'] as num?)?.toDouble() ?? 0.0,
      subscriptionId: json['subscriptionId'] as String? ?? '',
      currency: json['currency'] as String? ?? 'INR',
      email: json['email'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'totalAmount': totalAmount,
      'amountPayable': amountPayable,
      'subscriptionId': subscriptionId,
      'currency': currency,
      'email': email,
      'contact': contact,
    };
  }
}
