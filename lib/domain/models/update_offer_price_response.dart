class UpdateOfferPriceData {
  final String quotationId;
  final String bookingId;
  final String offerId;
  final double quotedPrice;
  final DateTime? createdOn;
  final DateTime? modifiedOn;
  final String quotationStatus;

  UpdateOfferPriceData({
    required this.quotationId,
    required this.bookingId,
    required this.offerId,
    required this.quotedPrice,
    this.createdOn,
    this.modifiedOn,
    required this.quotationStatus,
  });

  factory UpdateOfferPriceData.fromJson(Map<String, dynamic> json) {
    return UpdateOfferPriceData(
      quotationId: json['quotationId'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      offerId: json['offerId'] as String? ?? '',
      quotedPrice: (json['quotedPrice'] as num?)?.toDouble() ?? 0.0,
      createdOn: json['createdOn'] != null
          ? DateTime.tryParse(json['createdOn'] as String)
          : null,
      modifiedOn: json['modifiedOn'] != null
          ? DateTime.tryParse(json['modifiedOn'] as String)
          : null,
      quotationStatus: json['quotationStatus'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotationId': quotationId,
      'bookingId': bookingId,
      'offerId': offerId,
      'quotedPrice': quotedPrice,
      'createdOn': createdOn?.toIso8601String(),
      'modifiedOn': modifiedOn?.toIso8601String(),
      'quotationStatus': quotationStatus,
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
