class VehicleListResponse {
  final String message;
  final VehicleListData? data;

  VehicleListResponse({
    required this.message,
    this.data,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) {
    return VehicleListResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VehicleListData.fromJson(json['data'])
          : null,
    );
  }
}

class VehicleListData {
  final String message;
  final List<Vehicle> vehicles;
  final int count;

  VehicleListData({
    required this.message,
    required this.vehicles,
    required this.count,
  });

  factory VehicleListData.fromJson(Map<String, dynamic> json) {
    return VehicleListData(
      message: json['message'] ?? '',
      vehicles: (json['vehicles'] as List<dynamic>?)
              ?.map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
      'count': count,
    };
  }
}

class Vehicle {
  final String vehicleId;
  final String driverId;
  final bool isVehicleBodyCovered;
  final String capacity;
  final double length;
  final double width;
  final double height;
  final String vehicleNumber;
  final String rcNumber;
  final String makeModel;

  Vehicle({
    required this.vehicleId,
    required this.driverId,
    required this.isVehicleBodyCovered,
    required this.capacity,
    required this.length,
    required this.width,
    required this.height,
    required this.vehicleNumber,
    required this.rcNumber,
    required this.makeModel,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'] ?? '',
      driverId: json['driverId'] ?? '',
      isVehicleBodyCovered: json['isVehicleBodyCovered'] ?? false,
      capacity: json['capacity'] ?? '',
      length: (json['length'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      vehicleNumber: json['vehicleNumber'] ?? '',
      rcNumber: json['rcNumber'] ?? '',
      makeModel: json['makeModel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'driverId': driverId,
      'isVehicleBodyCovered': isVehicleBodyCovered,
      'capacity': capacity,
      'length': length,
      'width': width,
      'height': height,
      'vehicleNumber': vehicleNumber,
      'rcNumber': rcNumber,
      'makeModel': makeModel,
    };
  }
}
