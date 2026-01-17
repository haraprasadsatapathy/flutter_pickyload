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
  ///
  /// Parameters:
  /// - userId: User ID (UUID)
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
}
