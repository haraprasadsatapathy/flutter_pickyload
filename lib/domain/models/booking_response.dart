/// Response model for create booking API
class BookingResponse {
  final String message;
  final String bookingId;

  BookingResponse({
    required this.message,
    required this.bookingId,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return BookingResponse(
      message: json['message'] as String? ?? '',
      bookingId: data?['bookingId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'bookingId': bookingId,
    };
  }
}
