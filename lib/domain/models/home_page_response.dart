/// Response model for Driver Home Page API
/// GET /Driver/GetHomePageByDriverId/{driverId}
class HomePageResponse {
  final String message;
  final HomePageData data;

  HomePageResponse({
    required this.message,
    required this.data,
  });

  factory HomePageResponse.fromJson(Map<String, dynamic> json) {
    return HomePageResponse(
      message: json['message'] as String? ?? '',
      data: HomePageData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Home page data containing load status and trip details
class HomePageData {
  final String loadStatus;
  final List<TripDetail> tripDetails;
  final List<dynamic> tripStatus;

  HomePageData({
    required this.loadStatus,
    required this.tripDetails,
    required this.tripStatus,
  });

  factory HomePageData.fromJson(Map<String, dynamic> json) {
    return HomePageData(
      loadStatus: json['loadStatus'] as String? ?? '',
      tripDetails: (json['tripDetails'] as List<dynamic>?)
              ?.map((e) => TripDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tripStatus: json['tripStatus'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loadStatus': loadStatus,
      'tripDetails': tripDetails.map((e) => e.toJson()).toList(),
      'tripStatus': tripStatus,
    };
  }
}

/// Trip detail model for driver's offered trips
class TripDetail {
  final String pickupAddress;
  final String dropAddress;
  final String tripStatus;
  final String vehicleNo;
  final String offerId;
  final List<UserOffer> userOffers;

  TripDetail({
    required this.pickupAddress,
    required this.dropAddress,
    required this.tripStatus,
    required this.vehicleNo,
    required this.offerId,
    required this.userOffers,
  });

  factory TripDetail.fromJson(Map<String, dynamic> json) {
    return TripDetail(
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropAddress: json['dropAddress'] as String? ?? '',
      tripStatus: json['tripstatus'] as String? ?? '',
      vehicleNo: json['vehicleNo'] as String? ?? '',
      offerId: json['offerId'] as String? ?? '',
      userOffers: (json['userOffer'] as List<dynamic>?)
              ?.map((e) => UserOffer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'tripstatus': tripStatus,
      'vehicleNo': vehicleNo,
      'offerId': offerId,
      'userOffer': userOffers.map((e) => e.toJson()).toList(),
    };
  }

  /// Get a formatted route string
  String get route {
    final pickup = _getShortAddress(pickupAddress);
    final drop = _getShortAddress(dropAddress);
    return '$pickup to $drop';
  }

  /// Extract short address (city name) from full address
  String _getShortAddress(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.isNotEmpty) {
      return parts.first.trim();
    }
    return fullAddress;
  }
}

/// User offer model for offers made by users on driver's trips
class UserOffer {
  final String quotationId;
  final String pickupAddress;
  final String dropAddress;
  final DateTime? offerDate;
  final double tripDistance;
  final String bookingId;
  final String status;
  final double quotedPrice;

  UserOffer({
    required this.quotationId,
    required this.pickupAddress,
    required this.dropAddress,
    this.offerDate,
    required this.tripDistance,
    required this.bookingId,
    required this.status,
    required this.quotedPrice,
  });

  factory UserOffer.fromJson(Map<String, dynamic> json) {
    return UserOffer(
      quotationId: json['quotationId'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropAddress: json['dropAddress'] as String? ?? '',
      offerDate: json['offerDate'] != null
          ? DateTime.tryParse(json['offerDate'] as String)
          : null,
      tripDistance: (json['tripDistance'] as num?)?.toDouble() ?? 0.0,
      bookingId: json['bookingId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      quotedPrice: (json['quotedPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotationId': quotationId,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'offerDate': offerDate?.toIso8601String(),
      'tripDistance': tripDistance,
      'bookingId': bookingId,
      'status': status,
      'quotedPrice': quotedPrice,
    };
  }

  /// Get a formatted route string
  String get route {
    final pickup = _getShortAddress(pickupAddress);
    final drop = _getShortAddress(dropAddress);
    return '$pickup to $drop';
  }

  /// Extract short address (city name) from full address
  String _getShortAddress(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.isNotEmpty) {
      return parts.first.trim();
    }
    return fullAddress;
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (tripDistance == 0) return 'N/A';
    return '${tripDistance.toStringAsFixed(2)} km';
  }

  /// Status helpers
  bool get isRequestQuote => status.toLowerCase() == 'requestquote';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isUpdated => status.toLowerCase() == 'updated';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isWithdrawn => status.toLowerCase() == 'withdrawn';
  bool get isExpired => status.toLowerCase() == 'expired';

  /// Check if driver can respond with a price (only when status is Pending)
  bool get canUpdatePrice => isPending;

  /// Get display status text
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'requestquote':
        return 'Quote Requested';
      case 'pending':
        return 'Pending';
      case 'updated':
        return 'Price Updated';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }
}
