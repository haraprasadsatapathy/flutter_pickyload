/// Response model for Customer Home Page API
class CustomerHomePageResponse {
  final String message;
  final CustomerHomePageData data;

  CustomerHomePageResponse({
    required this.message,
    required this.data,
  });

  factory CustomerHomePageResponse.fromJson(Map<String, dynamic> json) {
    return CustomerHomePageResponse(
      message: json['message'] as String? ?? '',
      data: CustomerHomePageData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class CustomerHomePageData {
  final String bookingStatus;
  final List<BookingDetail> bookingDetails;
  final List<BookingDetail> ongoingTrips;

  CustomerHomePageData({
    required this.bookingStatus,
    required this.bookingDetails,
    required this.ongoingTrips,
  });

  factory CustomerHomePageData.fromJson(Map<String, dynamic> json) {
    return CustomerHomePageData(
      bookingStatus: json['bookingStatus'] as String? ?? '',
      bookingDetails: (json['bookingDetails'] as List<dynamic>?)
              ?.map((e) => BookingDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ongoingTrips: (json['ongoingTrips'] as List<dynamic>?)
              ?.map((e) => BookingDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingStatus': bookingStatus,
      'bookingDetails': bookingDetails.map((e) => e.toJson()).toList(),
      'ongoingTrips': ongoingTrips.map((e) => e.toJson()).toList(),
    };
  }
}

class BookingDetail {
  final String bookingId;
  final String loadCapacity;
  final String loadName;
  final String pickupAddress;
  final String dropAddress;
  final double distance;
  final DateTime bookingOn;
  final DateTime createdOn;
  final List<dynamic> vehicleMatch;

  BookingDetail({
    required this.bookingId,
    required this.loadCapacity,
    required this.loadName,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distance,
    required this.bookingOn,
    required this.createdOn,
    required this.vehicleMatch,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      bookingId: json['bookingId'] as String? ?? '',
      loadCapacity: json['loadCapacity'] as String? ?? '',
      loadName: json['loadName'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropAddress: json['dropAddress'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      bookingOn: json['booking_on'] != null
          ? DateTime.parse(json['booking_on'] as String)
          : DateTime.now(),
      createdOn: json['created_on'] != null
          ? DateTime.parse(json['created_on'] as String)
          : DateTime.now(),
      vehicleMatch: json['vehicleMatch'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'loadCapacity': loadCapacity,
      'loadName': loadName,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'distance': distance,
      'booking_on': bookingOn.toIso8601String(),
      'created_on': createdOn.toIso8601String(),
      'vehicleMatch': vehicleMatch,
    };
  }

  /// Get formatted load capacity label
  String get loadCapacityLabel {
    switch (loadCapacity) {
      case 'upto_half_tonne':
        return 'Up to 0.5 Tonne';
      case 'upto_01_tonne':
        return 'Up to 1 Tonne';
      case 'upto_05_tonne':
        return 'Up to 5 Tonne';
      case 'upto_15_tonne':
        return 'Up to 15 Tonne';
      case 'upto_25_tonne':
        return 'Up to 25 Tonne';
      case 'upto_35_tonne':
        return 'Up to 35 Tonne';
      case 'upto_45_tonne':
        return 'Up to 45 Tonne';
      case 'upto_55_tonne':
        return 'Up to 55 Tonne';
      default:
        return loadCapacity;
    }
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (distance == 0) return 'N/A';
    return '${distance.toStringAsFixed(2)} km';
  }
}
