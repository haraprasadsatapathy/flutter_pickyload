class VehicleDetails {
  final String vehicleId;
  final String capacity;
  final int numberOfWheels;
  final double length;
  final double width;
  final double height;
  final String vehicleNumberPlate;
  final String makerModel;
  final String bodyCoverType;

  VehicleDetails({
    required this.vehicleId,
    required this.capacity,
    required this.numberOfWheels,
    required this.length,
    required this.width,
    required this.height,
    required this.vehicleNumberPlate,
    required this.makerModel,
    required this.bodyCoverType,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      vehicleId: json['vehicleId'] ?? '',
      capacity: json['capacity'] ?? '',
      numberOfWheels: json['numberOfWheels'] ?? 0,
      length: (json['length'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      vehicleNumberPlate: json['vehicleNumberPlate'] ?? '',
      makerModel: json['makerModel'] ?? '',
      bodyCoverType: json['bodyCoverType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'capacity': capacity,
      'numberOfWheels': numberOfWheels,
      'length': length,
      'width': width,
      'height': height,
      'vehicleNumberPlate': vehicleNumberPlate,
      'makerModel': makerModel,
      'bodyCoverType': bodyCoverType,
    };
  }
}

class OfferLoadsResponseData {
  final String offerId;
  final String driverId;
  final String vehicleId;
  final double price;
  final DateTime? availableTimeStart;
  final DateTime? availableTimeEnd;
  final String status;
  final List<double> pickupLocation;
  final List<double> dropLocation;
  final String pickupAddress;
  final String dropAddress;
  final List<dynamic> potentialTripMatch;
  final VehicleDetails? vehicleDetails;

  OfferLoadsResponseData({
    required this.offerId,
    required this.driverId,
    required this.vehicleId,
    required this.price,
    this.availableTimeStart,
    this.availableTimeEnd,
    required this.status,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupAddress,
    required this.dropAddress,
    required this.potentialTripMatch,
    this.vehicleDetails,
  });

  factory OfferLoadsResponseData.fromJson(Map<String, dynamic> json) {
    return OfferLoadsResponseData(
      offerId: json['offerId'] ?? '',
      driverId: json['driverId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      availableTimeStart: json['availableTimeStart'] != null
          ? DateTime.tryParse(json['availableTimeStart'])
          : null,
      availableTimeEnd: json['availableTimeEnd'] != null
          ? DateTime.tryParse(json['availableTimeEnd'])
          : null,
      status: json['status'] ?? '',
      pickupLocation: json['pickupLocation'] != null
          ? List<double>.from(json['pickupLocation'].map((x) => x.toDouble()))
          : [],
      dropLocation: json['dropLocation'] != null
          ? List<double>.from(json['dropLocation'].map((x) => x.toDouble()))
          : [],
      pickupAddress: json['pickupAddress'] ?? '',
      dropAddress: json['dropAddress'] ?? '',
      potentialTripMatch: json['potentialTripMatch'] ?? [],
      vehicleDetails: json['vehicleDetails'] != null
          ? VehicleDetails.fromJson(json['vehicleDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'price': price,
      if (availableTimeStart != null)
        'availableTimeStart': availableTimeStart!.toIso8601String(),
      if (availableTimeEnd != null)
        'availableTimeEnd': availableTimeEnd!.toIso8601String(),
      'status': status,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'potentialTripMatch': potentialTripMatch,
      if (vehicleDetails != null) 'vehicleDetails': vehicleDetails!.toJson(),
    };
  }
}

class OfferLoadsResponse {
  final String message;
  final OfferLoadsResponseData? data;

  OfferLoadsResponse({
    required this.message,
    this.data,
  });

  factory OfferLoadsResponse.fromJson(Map<String, dynamic> json) {
    return OfferLoadsResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? OfferLoadsResponseData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}
