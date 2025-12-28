import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Today's Stats Model
class TodayStatsModel {
  final int completedTrips;
  final double earnedAmount;
  final double traveledDistance;

  TodayStatsModel({
    required this.completedTrips,
    required this.earnedAmount,
    required this.traveledDistance,
  });

  factory TodayStatsModel.fromJson(Map<String, dynamic> json) {
    return TodayStatsModel(
      completedTrips: json['completedTrips'] ?? 0,
      earnedAmount: (json['earnedAmount'] ?? 0).toDouble(),
      traveledDistance: (json['traveledDistance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedTrips': completedTrips,
      'earnedAmount': earnedAmount,
      'traveledDistance': traveledDistance,
    };
  }

  // Default/empty stats
  static TodayStatsModel empty() {
    return TodayStatsModel(
      completedTrips: 0,
      earnedAmount: 0.0,
      traveledDistance: 0.0,
    );
  }
}

// Load Request Model
class LoadRequestModel {
  final String loadRequestId;
  final String route;
  final String fromLocation;
  final String toLocation;
  final String capacity;
  final double price;
  final String? description;
  final DateTime? pickupDateTime;

  LoadRequestModel({
    required this.loadRequestId,
    required this.route,
    required this.fromLocation,
    required this.toLocation,
    required this.capacity,
    required this.price,
    this.description,
    this.pickupDateTime,
  });

  factory LoadRequestModel.fromJson(Map<String, dynamic> json) {
    return LoadRequestModel(
      loadRequestId: json['loadRequestId'] ?? '',
      route: json['route'] ?? '',
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      capacity: json['capacity'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      pickupDateTime: json['pickupDateTime'] != null
          ? DateTime.parse(json['pickupDateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loadRequestId': loadRequestId,
      'route': route,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'capacity': capacity,
      'price': price,
      'description': description,
      'pickupDateTime': pickupDateTime?.toIso8601String(),
    };
  }
}

// Base state class for Home Tab feature
class HomeTabState extends BaseEventState {
  final bool isOnline;
  final TodayStatsModel todayStats;
  final List<LoadRequestModel> loadRequests;

  HomeTabState({
    this.isOnline = false,
    TodayStatsModel? todayStats,
    this.loadRequests = const [],
  }) : todayStats = todayStats ?? TodayStatsModel.empty();

  @override
  List<Object?> get props => [isOnline, todayStats, loadRequests];
}

// Initial state
class HomeTabInitial extends HomeTabState {}

// Loading state
class HomeTabLoading extends HomeTabState {
  HomeTabLoading({
    super.isOnline,
    super.todayStats,
    super.loadRequests,
  });
}

// Online status updated
class OnlineStatusUpdated extends HomeTabState {
  final String message;

  OnlineStatusUpdated({
    required this.message,
    required super.isOnline,
    super.todayStats,
    super.loadRequests,
  });

  @override
  List<Object?> get props => [message, isOnline, todayStats, loadRequests];
}

// Today's stats fetched successfully
class TodayStatsFetched extends HomeTabState {
  final String message;

  TodayStatsFetched({
    required this.message,
    super.isOnline,
    required super.todayStats,
    super.loadRequests,
  });

  @override
  List<Object?> get props => [message, isOnline, todayStats, loadRequests];
}

// Load requests fetched successfully
class LoadRequestsFetched extends HomeTabState {
  final String message;

  LoadRequestsFetched({
    required this.message,
    super.isOnline,
    super.todayStats,
    required super.loadRequests,
  });

  @override
  List<Object?> get props => [message, isOnline, todayStats, loadRequests];
}

// Home tab data loaded successfully (stats + load requests)
class HomeTabSuccess extends HomeTabState {
  final String message;

  HomeTabSuccess({
    required this.message,
    super.isOnline,
    required super.todayStats,
    required super.loadRequests,
  });

  @override
  List<Object?> get props => [message, isOnline, todayStats, loadRequests];
}

// Load request accepted
class LoadRequestAccepted extends HomeTabState {
  final String message;
  final String loadRequestId;

  LoadRequestAccepted({
    required this.message,
    required this.loadRequestId,
    super.isOnline,
    super.todayStats,
    required super.loadRequests,
  });

  @override
  List<Object?> get props => [
        message,
        loadRequestId,
        isOnline,
        todayStats,
        loadRequests,
      ];
}

// Load request declined
class LoadRequestDeclined extends HomeTabState {
  final String message;
  final String loadRequestId;

  LoadRequestDeclined({
    required this.message,
    required this.loadRequestId,
    super.isOnline,
    super.todayStats,
    required super.loadRequests,
  });

  @override
  List<Object?> get props => [
        message,
        loadRequestId,
        isOnline,
        todayStats,
        loadRequests,
      ];
}

// Error state
class HomeTabError extends HomeTabState {
  final String error;

  HomeTabError({
    required this.error,
    super.isOnline,
    super.todayStats,
    super.loadRequests,
  });

  @override
  List<Object?> get props => [error, isOnline, todayStats, loadRequests];
}
