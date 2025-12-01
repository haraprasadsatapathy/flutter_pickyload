enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum PaymentMethod {
  card,
  upi,
  wallet,
  netBanking,
  cash,
}

class Payment {
  final String id;
  final String tripId;
  final String userId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? failureReason;

  Payment({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.failureReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'amount': amount,
      'method': method.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'failureReason': failureReason,
    };
  }
}
