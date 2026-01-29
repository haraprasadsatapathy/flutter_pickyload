class VehicleListResponse {
  final String message;
  final List<Vehicle> vehicles;

  VehicleListResponse({
    required this.message,
    required this.vehicles,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<Vehicle> vehicleList = [];

    if (data is List) {
      vehicleList = data
          .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    return VehicleListResponse(
      message: json['message'] ?? '',
      vehicles: vehicleList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': vehicles.map((v) => v.toJson()).toList(),
    };
  }

  // Helper getter for count
  int get count => vehicles.length;
}

class Vehicle {
  final String vehicleId;
  final String? documentId;
  final String driverId;
  final String capacity;
  final int numberOfWheels;
  final double length;
  final double width;
  final double height;
  final String rcNumber;
  final String vehicleNumber;
  final String chassisNumber;
  final String makerModel;
  final String bodyCoverType; // "Open", "Closed", "SemiClosed"
  final String? status;
  final DateTime? verifiedOn;
  final DateTime? updatedOn;

  Vehicle({
    required this.vehicleId,
    this.documentId,
    required this.driverId,
    required this.capacity,
    required this.numberOfWheels,
    required this.length,
    required this.width,
    required this.height,
    required this.rcNumber,
    required this.vehicleNumber,
    required this.chassisNumber,
    required this.makerModel,
    required this.bodyCoverType,
    this.status,
    this.verifiedOn,
    this.updatedOn,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'] ?? '',
      documentId: json['documentId'],
      driverId: json['driverId'] ?? '',
      capacity: json['capacity'] ?? '',
      numberOfWheels: json['numberOfWheels'] ?? 0,
      length: (json['length'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      rcNumber: json['rcNumber'] ?? '',
      vehicleNumber: json['vehicleNumberPlate'] ?? json['vehicleNumber'] ?? '',
      chassisNumber: json['chassisNumber'] ?? '',
      makerModel: json['makerModel'] ?? '',
      bodyCoverType: json['bodyCoverType'] ?? 'Open',
      status: json['status'],
      verifiedOn: json['verifiedOn'] != null
          ? DateTime.tryParse(json['verifiedOn'])
          : null,
      updatedOn: json['updatedOn'] != null
          ? DateTime.tryParse(json['updatedOn'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      if (documentId != null) 'documentId': documentId,
      'driverId': driverId,
      'capacity': capacity,
      'numberOfWheels': numberOfWheels,
      'length': length,
      'width': width,
      'height': height,
      'rcNumber': rcNumber,
      'vehicleNumber': vehicleNumber,
      'chassisNumber': chassisNumber,
      'makerModel': makerModel,
      'bodyCoverType': bodyCoverType,
      if (status != null) 'status': status,
      if (verifiedOn != null) 'verifiedOn': verifiedOn!.toIso8601String(),
      if (updatedOn != null) 'updatedOn': updatedOn!.toIso8601String(),
    };
  }

  // Helper getter for backward compatibility
  bool get isVehicleBodyCovered => bodyCoverType != 'Open';

  // Helper getter for makeModel (backward compatibility)
  String get makeModel => makerModel;

  // Helper method to get user-friendly capacity label
  String get capacityLabel {
    switch (capacity) {
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
        return capacity;
    }
  }

  // Helper method to get user-friendly body cover type label
  String get bodyCoverTypeLabel {
    switch (bodyCoverType) {
      case 'Open':
        return 'Open';
      case 'Closed':
        return 'Closed';
      case 'SemiClosed':
        return 'Semi-Closed';
      default:
        return bodyCoverType;
    }
  }

  // Helper method to check if vehicle is verified
  bool get isVerified => status?.toLowerCase() == 'verified';
}
