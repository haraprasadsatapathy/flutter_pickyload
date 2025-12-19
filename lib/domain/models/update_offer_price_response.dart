class UpdateOfferPriceData {
  final String offerId;
  final String driverId;
  final String vehicleId;
  final double price;
  final String message;

  UpdateOfferPriceData({
    required this.offerId,
    required this.driverId,
    required this.vehicleId,
    required this.price,
    required this.message,
  });

  factory UpdateOfferPriceData.fromJson(Map<String, dynamic> json) {
    return UpdateOfferPriceData(
      offerId: json['offerId'] ?? '',
      driverId: json['driverId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'price': price,
      'message': message,
    };
  }
}

class UpdateOfferPriceResponse {
  final String message;
  final UpdateOfferPriceData? data;

  UpdateOfferPriceResponse({
    required this.message,
    this.data,
  });

  factory UpdateOfferPriceResponse.fromJson(Map<String, dynamic> json) {
    return UpdateOfferPriceResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UpdateOfferPriceData.fromJson(json['data'])
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
