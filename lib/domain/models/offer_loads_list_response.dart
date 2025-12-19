import '../../presentation/cubit/driver/offer_loads_list/offer_loads_list_state.dart';

class OfferLoadsListResponse {
  final String message;
  final List<OfferLoadModel> offerLoads;
  final int count;

  OfferLoadsListResponse({
    required this.message,
    required this.offerLoads,
    required this.count,
  });

  factory OfferLoadsListResponse.fromJson(Map<String, dynamic> json) {
    return OfferLoadsListResponse(
      message: json['message'] ?? '',
      offerLoads: (json['offer'] as List<dynamic>?)
              ?.map((item) => OfferLoadModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'offer': offerLoads.map((load) => load.toJson()).toList(),
      'count': count,
    };
  }
}
