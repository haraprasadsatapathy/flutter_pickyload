class VehicleUpsertResponse {
  final String message;
  final VehicleUpsertData? data;

  VehicleUpsertResponse({
    required this.message,
    this.data,
  });

  factory VehicleUpsertResponse.fromJson(Map<String, dynamic> json) {
    return VehicleUpsertResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VehicleUpsertData.fromJson(json['data'])
          : null,
    );
  }
}

class VehicleUpsertData {
  final String vehicleId;
  final String driverId;

  VehicleUpsertData({
    required this.vehicleId,
    required this.driverId,
  });

  factory VehicleUpsertData.fromJson(Map<String, dynamic> json) {
    return VehicleUpsertData(
      vehicleId: json['vehicleId'] ?? '',
      driverId: json['driverId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'driverId': driverId,
    };
  }
}
