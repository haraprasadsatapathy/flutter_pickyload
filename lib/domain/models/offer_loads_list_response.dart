import '../../presentation/cubit/driver/offer_loads_list/offer_loads_list_state.dart';

class OfferLoadsListResponse {
  final String message;
  final List<OfferLoadModel> offerLoads;

  OfferLoadsListResponse({
    required this.message,
    required this.offerLoads,
  });

  factory OfferLoadsListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<OfferLoadModel> loadsList = [];

    if (data is List) {
      loadsList = data
          .map((item) => OfferLoadModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return OfferLoadsListResponse(
      message: json['message'] ?? '',
      offerLoads: loadsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': offerLoads.map((load) => load.toJson()).toList(),
    };
  }

  // Helper getter for count
  int get count => offerLoads.length;
}
