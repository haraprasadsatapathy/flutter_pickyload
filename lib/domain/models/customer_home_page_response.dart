import 'dart:ui';

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
  final List<OngoingTrip> ongoingTrips;

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
              ?.map((e) => OngoingTrip.fromJson(e as Map<String, dynamic>))
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

class VehicleMatch {
  final String bookingId;
  final String vehicleNo;
  final String vehicleId;
  final String offerId;
  final int vehicleWheels;
  final String vehicleModel;
  final String loadType;
  final double quotedPrice;
  String status;

  VehicleMatch({
    required this.bookingId,
    required this.vehicleNo,
    required this.vehicleId,
    required this.offerId,
    required this.vehicleWheels,
    required this.vehicleModel,
    required this.loadType,
    required this.quotedPrice,
    required this.status,
  });

  factory VehicleMatch.fromJson(Map<String, dynamic> json) {
    return VehicleMatch(
      bookingId: json['bookingId'] as String? ?? '',
      vehicleNo: json['vehicle_no'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      offerId: json['offerID'] as String? ?? json['offerId'] as String? ?? '',
      vehicleWheels: json['vehicleWheels'] as int? ?? 0,
      vehicleModel: json['vehicleModel'] as String? ?? '',
      loadType: json['loadType'] as String? ?? '',
      quotedPrice: (json['quotedPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'vehicle_no': vehicleNo,
      'vehicleId': vehicleId,
      'offerId': offerId,
      'vehicleWheels': vehicleWheels,
      'vehicleModel': vehicleModel,
      'loadType': loadType,
      'quotedPrice': quotedPrice,
      'status': status,
    };
  }

  /// QuotationStatus helpers
  bool get isRequestQuote => status.toLowerCase() == 'requestquoate' || status.toLowerCase() == 'requestquote';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isUpdated => status.toLowerCase() == 'updated';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isWithdrawn => status.toLowerCase() == 'withdrawn';
  bool get isExpired => status.toLowerCase() == 'expired';

  /// Check if user can take action (Request Quote or Accept/Reject)
  bool get canRequestQuote => isRequestQuote;
  bool get canAcceptOrReject => isPending || isUpdated;

  /// Get display status text
  String get displayStatus {
    if (isRequestQuote) return 'Request Quote';
    if (isPending) return 'Pending';
    if (isUpdated) return 'Quotation Sent';
    if (isAccepted) return 'Accepted';
    if (isRejected) return 'Rejected';
    if (isWithdrawn) return 'Withdrawn';
    if (isExpired) return 'Expired';
    return status;
  }
}

class OngoingTrip {
  final String tripId;
  final String vehicleNo;
  final String tripStatus;
  final DateTime createdOn;
  final DateTime modifiedOn;
  final String status;
  final double finalPrice;
  final bool insuranceOpted;
  final double advanceAmountPaid;
  final bool isPaidFull;
  final String pickUpConfirmationOtp;
  final String pickupAddress;
  final String dropAddress;

  OngoingTrip({
    required this.tripId,
    required this.vehicleNo,
    required this.tripStatus,
    required this.createdOn,
    required this.modifiedOn,
    required this.status,
    required this.finalPrice,
    required this.insuranceOpted,
    required this.advanceAmountPaid,
    required this.isPaidFull,
    required this.pickUpConfirmationOtp,
    required this.pickupAddress,
    required this.dropAddress,
  });

  factory OngoingTrip.fromJson(Map<String, dynamic> json) {
    return OngoingTrip(
      tripId: json['tripId'] as String? ?? '',
      vehicleNo: json['vehicleNo'] as String? ?? '',
      tripStatus: json['tripstatus'] as String? ?? json['tripStatus'] as String? ?? '',
      createdOn: json['createdOn'] != null
          ? DateTime.parse(json['createdOn'] as String)
          : DateTime.now(),
      modifiedOn: json['modifiedOn'] != null
          ? DateTime.parse(json['modifiedOn'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? '',
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      insuranceOpted: json['insuranceOpted'] as bool? ?? false,
      advanceAmountPaid: (json['advanceAmountPaid'] as num?)?.toDouble() ?? 0.0,
      isPaidFull: json['isPaidFull'] as bool? ?? false,
      pickUpConfirmationOtp: json['pickUpConfirmationOtp'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropAddress: json['dropAddress'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'vehicleNo': vehicleNo,
      'tripstatus': tripStatus,
      'createdOn': createdOn.toIso8601String(),
      'modifiedOn': modifiedOn.toIso8601String(),
      'status': status,
      'finalPrice': finalPrice,
      'insuranceOpted': insuranceOpted,
      'advanceAmountPaid': advanceAmountPaid,
      'isPaidFull': isPaidFull,
      'pickUpConfirmationOtp': pickUpConfirmationOtp,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
    };
  }

  String get formattedFinalPrice => '₹${finalPrice.toStringAsFixed(0)}';
  String get formattedAdvancePaid => '₹${advanceAmountPaid.toStringAsFixed(0)}';
  double get remainingAmount => finalPrice - advanceAmountPaid;
  String get formattedRemainingAmount => '₹${remainingAmount.toStringAsFixed(0)}';

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'scheduled':
        return 'Scheduled';
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFB300); // Amber
      case 'accepted':
        return const Color(0xFF4CAF50); // Green
      case 'rejected':
        return const Color(0xFFF44336); // Red
      case 'scheduled':
        return const Color(0xFFFF9800); // Orange
      case 'inprogress':
        return const Color(0xFF2196F3); // Blue
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E);
    }
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
  final List<VehicleMatch> vehicleMatch;

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
      vehicleMatch: (json['vehicleMatch'] as List<dynamic>?)
              ?.map((e) => VehicleMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'vehicleMatch': vehicleMatch.map((e) => e.toJson()).toList(),
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
