/// Response model for booking history API
class BookingHistoryResponse {
  final String message;
  final List<BookingHistory> data;

  BookingHistoryResponse({
    required this.message,
    required this.data,
  });

  factory BookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BookingHistoryResponse(
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BookingHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// Individual booking history item
class BookingHistory {
  final String bookingId;
  final String pickupAddress;
  final String dropAddress;
  final String vehicleType;
  final double loadCapacity;
  final DateTime bookingDate;
  final bool isInsured;
  final String bookingStatus;

  BookingHistory({
    required this.bookingId,
    required this.pickupAddress,
    required this.dropAddress,
    required this.vehicleType,
    required this.loadCapacity,
    required this.bookingDate,
    required this.isInsured,
    required this.bookingStatus,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      bookingId: json['bookingId'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropAddress: json['dropAddress'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? '',
      loadCapacity: (json['loadCapacity'] as num?)?.toDouble() ?? 0.0,
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'] as String)
          : DateTime.now(),
      isInsured: json['isInsured'] as bool? ?? false,
      bookingStatus: json['bookingStatus'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'vehicleType': vehicleType,
      'loadCapacity': loadCapacity,
      'bookingDate': bookingDate.toIso8601String(),
      'isInsured': isInsured,
      'bookingStatus': bookingStatus,
    };
  }

  /// Get route string from pickup and drop addresses
  String get route => '$pickupAddress to $dropAddress';

  /// Get status color based on booking status
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return 'blue';
      case 'accepted':
      case 'in_progress':
      case 'in progress':
        return 'orange';
      case 'completed':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }
}
