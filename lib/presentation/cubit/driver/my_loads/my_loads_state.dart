import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// My Load Model for MyLoadsTab
class MyLoadModel {
  final String offerId;
  final String driverId;
  final String vehicleId;
  final double price;
  final DateTime availableTimeStart;
  final DateTime availableTimeEnd;
  final String status;
  final List<double> pickupLocation;
  final List<double> dropLocation;
  final String pickupAddress;
  final String dropAddress;

  MyLoadModel({
    required this.offerId,
    required this.driverId,
    required this.vehicleId,
    required this.price,
    required this.availableTimeStart,
    required this.availableTimeEnd,
    required this.status,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupAddress,
    required this.dropAddress,
  });

  factory MyLoadModel.fromJson(Map<String, dynamic> json) {
    return MyLoadModel(
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
      pickupLocation: json['pickupLocation'] != null
          ? List<double>.from(json['pickupLocation'].map((x) => (x as num).toDouble()))
          : [0.0, 0.0],
      dropLocation: json['dropLocation'] != null
          ? List<double>.from(json['dropLocation'].map((x) => (x as num).toDouble()))
          : [0.0, 0.0],
      pickupAddress: json['pickupAddress'] ?? '',
      dropAddress: json['dropAddress'] ?? '',
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
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
    };
  }

  // Helper getters
  String get route => '$pickupAddress to $dropAddress';

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  String get formattedStartTime {
    return '${availableTimeStart.day}/${availableTimeStart.month}/${availableTimeStart.year}';
  }

  String get formattedEndTime {
    return '${availableTimeEnd.day}/${availableTimeEnd.month}/${availableTimeEnd.year}';
  }
}

// Base state class for My Loads feature
class MyLoadsState extends BaseEventState {
  final List<MyLoadModel> loads;
  final int count;

  MyLoadsState({
    this.loads = const [],
    this.count = 0,
  });

  @override
  List<Object?> get props => [loads, count];
}

// Initial state
class MyLoadsInitial extends MyLoadsState {}

// Loading state
class MyLoadsLoading extends MyLoadsState {
  MyLoadsLoading({
    super.loads,
    super.count,
  });
}

// Loads fetched successfully
class MyLoadsSuccess extends MyLoadsState {
  final String message;

  MyLoadsSuccess({
    required this.message,
    required super.loads,
    required super.count,
  });

  @override
  List<Object?> get props => [message, loads, count];
}

// Error state
class MyLoadsError extends MyLoadsState {
  final String error;

  MyLoadsError({
    required this.error,
    super.loads,
    super.count,
  });

  @override
  List<Object?> get props => [error, loads, count];
}
