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
  final String userId;
  final String vehicleBodyCoverType;
  final String vehicleCapacity;
  final double length;
  final double width;
  final double height;
  final DateTime pickupTime;
  final bool isInsured;
  final String bookingStatus;
  final List<double> pickupLocation; // [longitude, latitude]
  final List<double> dropLocation; // [longitude, latitude]
  final String pickupAddress;
  final String dropAddress;
  final String loadName;

  BookingHistory({
    required this.bookingId,
    required this.userId,
    required this.vehicleBodyCoverType,
    required this.vehicleCapacity,
    required this.length,
    required this.width,
    required this.height,
    required this.pickupTime,
    required this.isInsured,
    required this.bookingStatus,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupAddress,
    required this.dropAddress,
    required this.loadName,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      bookingId: json['bookingId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      vehicleBodyCoverType: json['vehicleBodyCoverType'] as String? ?? '',
      vehicleCapacity: json['vehicleCapacity'] as String? ?? '',
      length: (json['length'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'] as String)
          : DateTime.now(),
      isInsured: json['isInsured'] as bool? ?? false,
      bookingStatus: json['bookingStatus'] as String? ?? 'Unknown',
      pickupLocation: json['pickupLocation'] != null
          ? List<double>.from(
              (json['pickupLocation'] as List).map((e) => (e as num).toDouble()))
          : [0.0, 0.0],
      dropLocation: json['dropLocation'] != null
          ? List<double>.from(
              (json['dropLocation'] as List).map((e) => (e as num).toDouble()))
          : [0.0, 0.0],
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropAddress: json['dropAddress'] as String? ?? '',
      loadName: json['loadName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'vehicleBodyCoverType': vehicleBodyCoverType,
      'vehicleCapacity': vehicleCapacity,
      'length': length,
      'width': width,
      'height': height,
      'pickupTime': pickupTime.toIso8601String(),
      'isInsured': isInsured,
      'bookingStatus': bookingStatus,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'loadName': loadName,
    };
  }

  /// Get route string from pickup and drop addresses
  String get route => '$pickupAddress to $dropAddress';

  /// Get vehicle type display string
  String get vehicleType => '$vehicleBodyCoverType - $vehicleCapacity';

  /// Get load capacity in kg (convert from vehicleCapacity string)
  double get loadCapacity {
    // Extract capacity from strings like "upto_01_tonne"
    if (vehicleCapacity.contains('01_tonne')) return 1000;
    if (vehicleCapacity.contains('02_tonne')) return 2000;
    if (vehicleCapacity.contains('03_tonne')) return 3000;
    if (vehicleCapacity.contains('05_tonne')) return 5000;
    if (vehicleCapacity.contains('07_tonne')) return 7000;
    if (vehicleCapacity.contains('10_tonne')) return 10000;
    return 0.0;
  }

  /// Get booking date from pickup time
  DateTime get bookingDate => pickupTime;

  /// Get status color based on booking status
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return 'blue';
      case 'accepted':
        return 'green';
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
