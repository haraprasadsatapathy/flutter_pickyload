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
    required String pickupAddress,
    required String dropAddress,
    required String vehicleType,
    required double loadCapacity,
    required DateTime bookingDate,
    required bool isInsured,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/create-booking',
        data: {
          'userId': userId,
          'pickupAddress': pickupAddress,
          'dropAddress': dropAddress,
          'vehicleType': vehicleType,
          'loadCapacity': loadCapacity,
          'bookingDate': bookingDate.toUtc().toIso8601String(),
          'isInsured': isInsured,
          'pickupLat': pickupLat,
          'pickupLng': pickupLng,
          'dropLat': dropLat,
          'dropLng': dropLng,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.data != null) {
        // Parse the booking response
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
      // We don't use fromJsonT here because the API returns a structure
      // where 'data' is a List, not a Map
      final response = await _apiClient.get<dynamic>(
        '/User/booking-history',
        queryParameters: {
          'userId': userId,
        },
      );

      // The response.message contains the API message
      // The response.data contains the list of bookings (json['data'])
      if (response.data != null) {
        // Manually construct BookingHistoryResponse
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
