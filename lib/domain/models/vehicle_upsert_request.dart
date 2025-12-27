class VehicleUpsertRequest {
  final String driverId;
  final String vehicleNumberPlate;
  final String rcNumber;
  final String chassisNumber;
  final String bodyCoverType; // "Open", "Covered", etc.
  final String capacity;
  final double length;
  final double width;
  final double height;
  final int numberOfWheels;

  VehicleUpsertRequest({
    required this.driverId,
    required this.vehicleNumberPlate,
    required this.rcNumber,
    required this.chassisNumber,
    required this.bodyCoverType,
    required this.capacity,
    required this.length,
    required this.width,
    required this.height,
    required this.numberOfWheels,
  });

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'vehicleNumberPlate': vehicleNumberPlate,
      'rcNumber': rcNumber,
      'chassisNumber': chassisNumber,
      'bodyCoverType': bodyCoverType,
      'capacity': capacity,
      'length': length,
      'width': width,
      'height': height,
      'numberOfWheels': numberOfWheels,
    };
  }
}
