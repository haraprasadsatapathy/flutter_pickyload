/// Request model for canceling a booking
class CancelBookingRequest {
  final String userId;
  final String bookingId;

  CancelBookingRequest({
    required this.userId,
    required this.bookingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bookingId': bookingId,
    };
  }
}
