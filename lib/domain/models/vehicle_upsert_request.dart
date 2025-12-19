class VehicleUpsertRequest {
  final String? vehicleId;
  final String driverId;
  final bool isVehicleBodyCovered;
  final String capacity;
  final double length;
  final double width;
  final double height;
  final String vehicleNumber;
  final String rcNumber;
  final String makeModel;

  VehicleUpsertRequest({
    this.vehicleId,
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

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId ?? '00000000-0000-0000-0000-000000000000',
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
