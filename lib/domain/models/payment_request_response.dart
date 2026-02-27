class PaymentRequestResponse {
  final String orderId;
  final double totalAmount;
  final double amountPayable;
  final String quotationId;
  final String currency;
  final String email;
  final String contact;

  PaymentRequestResponse({
    required this.orderId,
    required this.totalAmount,
    required this.amountPayable,
    required this.quotationId,
    required this.currency,
    required this.email,
    required this.contact,
  });

  factory PaymentRequestResponse.fromJson(Map<String, dynamic> json) {
    return PaymentRequestResponse(
      orderId: json['orderId'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      amountPayable: (json['amountPayable'] ?? 0).toDouble(),
      // Check for both quotationId and subscriptionId field names
      quotationId: json['quotationId'] ?? json['subscriptionId'] ?? '',
      currency: json['currency'] ?? 'INR',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'totalAmount': totalAmount,
      'amountPayable': amountPayable,
      'quotationId': quotationId,
      'currency': currency,
      'email': email,
      'contact': contact,
    };
  }
}
