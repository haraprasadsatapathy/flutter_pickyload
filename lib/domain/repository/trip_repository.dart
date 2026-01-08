import '../../data/data_source/api_client.dart';
import '../models/api_response.dart';
import '../models/booking_response.dart';
import '../models/booking_history_response.dart';

/// Repository for trip-related operations
class TripRepository {
  final ApiClient _apiClient;

  TripRepository(this._apiClient);

  /// Create a new booking
  Future<ApiResponse<BookingResponse>> createBooking({
    required String userId,
    required String vehicleBodyCoverType,
    required String loadCapacity,
    required String loadName,
    required double length,
    required double width,
    required double height,
    required DateTime pickupTime,
    required bool isInsured,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required String pickupAddress,
    required String dropAddress,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/create-booking',
        data: {
          'userId': userId,
          'vehicleBodyCoverType': vehicleBodyCoverType,
          'loadCapacity': loadCapacity,
          'loadName': loadName,
          'length': length,
          'width': width,
          'height': height,
          'pickupTime': pickupTime.toUtc().toIso8601String(),
          'isInsured': isInsured,
          'pickupLocation': {
            'latitude': pickupLat,
            'longitude': pickupLng,
          },
          'dropLocation': {
            'latitude': dropLat,
            'longitude': dropLng,
          },
          'pickupAddress': pickupAddress,
          'dropAddress': dropAddress,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.data != null) {
        final bookingResponse = BookingResponse.fromJson(response.data!);

        return ApiResponse(
          status: true,
          message: bookingResponse.message,
          data: bookingResponse,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Booking failed',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get booking history for a user
  Future<ApiResponse<BookingHistoryResponse>> getUserBookings({
    required String userId,
  }) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/User/booking-history',
        queryParameters: {
          'userId': userId,
        },
      );

      if (response.data != null) {
        final bookingHistoryResponse = BookingHistoryResponse(
          message: response.message ?? 'Booking history fetched successfully',
          data: (response.data as List<dynamic>)
              .map((e) => BookingHistory.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

        return ApiResponse(
          status: true,
          message: bookingHistoryResponse.message,
          data: bookingHistoryResponse,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to fetch booking history',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}
