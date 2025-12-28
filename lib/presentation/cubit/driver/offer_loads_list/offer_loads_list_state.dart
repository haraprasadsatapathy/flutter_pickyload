import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Offered Load Model
class OfferLoadModel {
  final String offerId;
  final String driverId;
  final String vehicleId;
  final double price;
  final DateTime availableTimeStart;
  final DateTime availableTimeEnd;
  final String status;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String pickupAddress;
  final String dropAddress;
  final List<Map<String, double>> fullRoutePoints;

  OfferLoadModel({
    required this.offerId,
    required this.driverId,
    required this.vehicleId,
    required this.price,
    required this.availableTimeStart,
    required this.availableTimeEnd,
    required this.status,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fullRoutePoints,
  });

  factory OfferLoadModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, double>> routePoints = [];
    if (json['fullRoutePoints'] != null) {
      routePoints = (json['fullRoutePoints'] as List).map((point) {
        return {
          'latitude': (point['latitude'] as num).toDouble(),
          'longitude': (point['longitude'] as num).toDouble(),
        };
      }).toList();
    }

    return OfferLoadModel(
      offerId: json['offerId'] ?? '',
      driverId: json['driverId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      availableTimeStart: json['availableTimeStart'] != null
          ? DateTime.parse(json['availableTimeStart'])
          : DateTime.now(),
      availableTimeEnd: json['availableTimeEnd'] != null
          ? DateTime.parse(json['availableTimeEnd'])
          : DateTime.now(),
      status: json['status'] ?? '',
      pickupLat: (json['pickupLat'] as num?)?.toDouble() ?? 0.0,
      pickupLng: (json['pickupLng'] as num?)?.toDouble() ?? 0.0,
      dropLat: (json['dropLat'] as num?)?.toDouble() ?? 0.0,
      dropLng: (json['dropLng'] as num?)?.toDouble() ?? 0.0,
      pickupAddress: json['pickupAddress'] ?? '',
      dropAddress: json['dropAddress'] ?? '',
      fullRoutePoints: routePoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'price': price,
      'availableTimeStart': availableTimeStart.toIso8601String(),
      'availableTimeEnd': availableTimeEnd.toIso8601String(),
      'status': status,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'fullRoutePoints': fullRoutePoints,
    };
  }

  // Backward compatibility getters
  String get origin => pickupAddress;
  String get destination => dropAddress;

  String get formattedStartTime {
    return '${availableTimeStart.day}/${availableTimeStart.month}/${availableTimeStart.year} ${availableTimeStart.hour.toString().padLeft(2, '0')}:${availableTimeStart.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    return '${availableTimeEnd.day}/${availableTimeEnd.month}/${availableTimeEnd.year} ${availableTimeEnd.hour.toString().padLeft(2, '0')}:${availableTimeEnd.minute.toString().padLeft(2, '0')}';
  }
}

// Base state class for Offer Loads List feature
class OfferLoadsListState extends BaseEventState {
  final List<OfferLoadModel> offerLoads;
  final int count;

  OfferLoadsListState({
    this.offerLoads = const [],
    this.count = 0,
  });

  @override
  List<Object?> get props => [offerLoads, count];
}

// Initial state
class OfferLoadsListInitial extends OfferLoadsListState {}

// Loading state
class OfferLoadsListLoading extends OfferLoadsListState {
  OfferLoadsListLoading({
    super.offerLoads,
    super.count,
  });
}

// Offer loads fetched successfully
class OfferLoadsListSuccess extends OfferLoadsListState {
  final String message;

  OfferLoadsListSuccess({
    required this.message,
    required super.offerLoads,
    required super.count,
  });

  @override
  List<Object?> get props => [message, offerLoads, count];
}

// Error state
class OfferLoadsListError extends OfferLoadsListState {
  final String error;

  OfferLoadsListError({
    required this.error,
    super.offerLoads,
    super.count,
  });

  @override
  List<Object?> get props => [error, offerLoads, count];
}
