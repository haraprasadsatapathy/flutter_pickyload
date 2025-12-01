enum TripStatus {
  requested,
  accepted,
  inProgress,
  completed,
  cancelled,
}

class Trip {
  final String id;
  final String customerId;
  final String? driverId;
  final String pickupLocation;
  final String dropLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String vehicleType;
  final double loadCapacity;
  final double estimatedPrice;
  final DateTime requestedAt;
  final DateTime? scheduledAt;
  final TripStatus status;
  final String? vehicleNumber;
  final String? driverName;
  final String? driverPhone;
  final String? confirmationOtp;
  final bool insuranceOpted;
  final double? insurancePremium;

  Trip({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.vehicleType,
    required this.loadCapacity,
    required this.estimatedPrice,
    required this.requestedAt,
    this.scheduledAt,
    this.status = TripStatus.requested,
    this.vehicleNumber,
    this.driverName,
    this.driverPhone,
    this.confirmationOtp,
    this.insuranceOpted = false,
    this.insurancePremium,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'vehicleType': vehicleType,
      'loadCapacity': loadCapacity,
      'estimatedPrice': estimatedPrice,
      'requestedAt': requestedAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'status': status.toString(),
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'confirmationOtp': confirmationOtp,
      'insuranceOpted': insuranceOpted,
      'insurancePremium': insurancePremium,
    };
  }
}
