/// Response model for trip history API
/// API: GET /Driver/GetTriphistoryByDriverId/{driverId}
class TripHistoryResponse {
  final String message;
  final List<TripHistoryModel> trips;

  TripHistoryResponse({
    required this.message,
    required this.trips,
  });

  factory TripHistoryResponse.fromJson(Map<String, dynamic> json) {
    final tripsList = json['data'] as List<dynamic>? ?? [];
    return TripHistoryResponse(
      message: json['message'] as String? ?? '',
      trips: tripsList.map((e) => TripHistoryModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': trips.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model representing a single trip in trip history
class TripHistoryModel {
  final String tripId;
  final String vehicleNo;
  final DateTime bookingDate;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String status;
  final double finalPrice;
  final double advanceAmountPaid;
  final String pickupAddress;
  final String dropAddress;
  final String clientName;

  TripHistoryModel({
    required this.tripId,
    required this.vehicleNo,
    required this.bookingDate,
    this.tripStartDate,
    this.tripEndDate,
    required this.status,
    required this.finalPrice,
    required this.advanceAmountPaid,
    required this.pickupAddress,
    required this.dropAddress,
    required this.clientName,
  });

  factory TripHistoryModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryModel(
      tripId: json['tripId'] as String? ?? '',
      vehicleNo: json['vehicleNo'] as String? ?? '',
      bookingDate: json['bookigDate'] != null
          ? DateTime.parse(json['bookigDate'] as String)
          : DateTime.now(),
      tripStartDate: json['tripStartDate'] != null
          ? DateTime.parse(json['tripStartDate'] as String)
          : null,
      tripEndDate: json['tripEndDate'] != null
          ? DateTime.parse(json['tripEndDate'] as String)
          : null,
      status: json['status'] as String? ?? '',
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      advanceAmountPaid: (json['advanceAmountPaid'] as num?)?.toDouble() ?? 0.0,
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropAddress: json['dropAddress'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'vehicleNo': vehicleNo,
      'bookigDate': bookingDate.toIso8601String(),
      'tripStartDate': tripStartDate?.toIso8601String(),
      'tripEndDate': tripEndDate?.toIso8601String(),
      'status': status,
      'finalPrice': finalPrice,
      'advanceAmountPaid': advanceAmountPaid,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'clientName': clientName,
    };
  }

  // Helper getters
  String get formattedFinalPrice => '₹${finalPrice.toStringAsFixed(0)}';

  String get formattedAdvanceAmount => '₹${advanceAmountPaid.toStringAsFixed(0)}';

  double get remainingAmount => finalPrice - advanceAmountPaid;

  String get formattedRemainingAmount => '₹${remainingAmount.toStringAsFixed(0)}';

  String get route => '$pickupAddress to $dropAddress';
}
