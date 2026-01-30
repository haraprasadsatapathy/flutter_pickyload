import '../../data/data_source/api_client.dart';
import '../../models/user_model.dart';
import '../../services/local/saved_service.dart';
import '../models/api_response.dart';
import '../models/customer_home_page_response.dart';

/// Repository for customer-related operations
class CustomerRepository {
  final ApiClient _apiClient;
  final SavedService _savedService;

  CustomerRepository(this._apiClient, this._savedService);

  /// Get user details from SharedPreferences
  Future<User?> getUserDetailsSp() async {
    return await _savedService.getUserDetailsSp();
  }

  /// Clear user data (logout)
  Future<void> logout() async {
    await _savedService.clearUserData();
  }

  /// Get customer home page data including bookings and ongoing trips
  Future<ApiResponse<CustomerHomePageResponse>> getHomePage({
    required String userId,
  }) async {
    try {
      final response = await _apiClient.getRaw<CustomerHomePageResponse>(
        '/User/GetHomePageByUserId/$userId',
        fromJson: (json) => CustomerHomePageResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while fetching home page data: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Request a quote update from a driver
  Future<ApiResponse<Map<String, dynamic>>> requestQuote({
    required String userId,
    required String bookingId,
    required String offerId,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/OfferPrice-UpdateRequest',
        data: {
          'userId': userId,
          'bookingId': bookingId,
          'offerId': offerId,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while requesting quote: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Accept an offer price and confirm booking
  Future<ApiResponse<Map<String, dynamic>>> acceptOffer({
    required String userId,
    required String offerId,
    required String bookingId,
    required double advanceAmountPaid,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/OfferPrice-Accept',
        data: {
          'userId': userId,
          'offerId': offerId,
          'bookingId': bookingId,
          'advanceAmountPaid': advanceAmountPaid,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while accepting offer: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Cancel/reject a booking
  Future<ApiResponse<Map<String, dynamic>>> cancelBooking({
    required String userId,
    required String bookingId,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/User/Booking-Cancel',
        data: {
          'userId': userId,
          'bookingId': bookingId,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while cancelling booking: ${e.toString()}',
        data: null,
      );
    }
  }
}
