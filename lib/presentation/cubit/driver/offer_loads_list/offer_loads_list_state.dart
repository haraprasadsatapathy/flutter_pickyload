import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Offered Load Model
class OfferLoadModel {
  final String offerId;
  final String driverId;
  final String vehicleId;
  final String origin;
  final String destination;
  final DateTime availableTimeStart;
  final DateTime availableTimeEnd;
  final String status;

  OfferLoadModel({
    required this.offerId,
    required this.driverId,
    required this.vehicleId,
    required this.origin,
    required this.destination,
    required this.availableTimeStart,
    required this.availableTimeEnd,
    required this.status,
  });

  factory OfferLoadModel.fromJson(Map<String, dynamic> json) {
    return OfferLoadModel(
      offerId: json['offerId'] ?? '',
      driverId: json['driverId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      availableTimeStart: json['availableTimeStart'] != null
          ? DateTime.parse(json['availableTimeStart'])
          : DateTime.now(),
      availableTimeEnd: json['availableTimeEnd'] != null
          ? DateTime.parse(json['availableTimeEnd'])
          : DateTime.now(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'origin': origin,
      'destination': destination,
      'availableTimeStart': availableTimeStart.toIso8601String(),
      'availableTimeEnd': availableTimeEnd.toIso8601String(),
      'status': status,
    };
  }

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
