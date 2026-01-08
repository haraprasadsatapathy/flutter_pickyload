/// Response model for cancel booking API
class CancelBookingResponse {
  final String message;
  final CancelBookingData data;

  CancelBookingResponse({
    required this.message,
    required this.data,
  });

  factory CancelBookingResponse.fromJson(Map<String, dynamic> json) {
    return CancelBookingResponse(
      message: json['message'] as String? ?? '',
      data: CancelBookingData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Cancel booking data
class CancelBookingData {
  final BookingInfo bookingId;

  CancelBookingData({
    required this.bookingId,
  });

  factory CancelBookingData.fromJson(Map<String, dynamic> json) {
    return CancelBookingData(
      bookingId: BookingInfo.fromJson(json['bookingId'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId.toJson(),
    };
  }
}

/// Booking info returned after cancellation
class BookingInfo {
  final String userId;
  final String bookingId;

  BookingInfo({
    required this.userId,
    required this.bookingId,
  });

  factory BookingInfo.fromJson(Map<String, dynamic> json) {
    return BookingInfo(
      userId: json['userId'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bookingId': bookingId,
    };
  }
}
