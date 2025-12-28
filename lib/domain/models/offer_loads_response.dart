class OfferLoadsResponseData {
  final String offerId;
  final String driverId;
  final String status;

  OfferLoadsResponseData({
    required this.offerId,
    required this.driverId,
    required this.status,
  });

  factory OfferLoadsResponseData.fromJson(Map<String, dynamic> json) {
    return OfferLoadsResponseData(
      offerId: json['offerId'] ?? '',
      driverId: json['driverId'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'driverId': driverId,
      'status': status,
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
