import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../data/data_source/api_client.dart';
import '../../models/user_model.dart';
import '../../services/local/saved_service.dart';
import '../models/api_response.dart';
import '../models/document_upload_response.dart';
import '../models/document_list_response.dart';
import '../models/vehicle_upsert_request.dart';
import '../models/vehicle_upsert_response.dart';
import '../models/vehicle_list_response.dart';
import '../models/offer_loads_response.dart';
import '../models/offer_loads_list_response.dart';
import '../models/update_offer_price_response.dart';
import '../models/home_page_response.dart';

/// Repository for driver-related operations
class DriverRepository {
  final ApiClient _apiClient;

  // final Uuid _uuid = const Uuid();
  final SavedService _savedService;

  DriverRepository(this._apiClient, this._savedService);

  /// Get user details from SharedPreferences
  Future<User?> getUserDetailsSp() async {
    return await _savedService.getUserDetailsSp();
  }

  // ============================================
  // DOCUMENT OPERATIONS
  // ============================================

  /// Upload document (Driving License or Registration Certificate)
  ///
  /// Parameters:
  /// - userId: User ID (UUID)
  /// - documentType: Type of document (e.g., 'DrivingLicense', 'RegistrationCertificate')
  /// - documentNumber: Document number
  /// - dateOfBirth: Date of birth (required for verification)
  /// - documentImagePath: Path to the document image file (optional, not used in current API)
  /// - validTill: Document validity date (optional, not used in current API)
  /// - verifiedOn: Document verification date (optional, not used in current API)
  Future<ApiResponse<DocumentUploadResponse>> uploadDocument({
    required String userId,
    required String documentType,
    required String documentNumber,
    required DateTime dateOfBirth,
    String? documentImagePath,
    DateTime? validTill,
    DateTime? verifiedOn,
  }) async {
    try {
      // Prepare request body for DocumentVerify API
      final requestBody = {
        'userId': userId,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'dob': dateOfBirth.toUtc().toIso8601String(),
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/Driver/DocumentVerify',
        queryParameters: {'isDryRun': 'true'},
        data: requestBody,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.data != null) {
        final data = response.data!;
        final message = response.message;
        // final message = responseData['message'] as String? ?? '';
        // final data = responseData['data'];

        // print('DEBUG: Response data type: ${responseData.runtimeType}');
        // print('DEBUG: Message: $message');
        // print('DEBUG: Data type: ${data.runtimeType}');
        // print('DEBUG: Data value: $data');
        // print('DEBUG: Data is null: ${data == null}');
        // print('DEBUG: Data is Map: ${data is Map<String, dynamic>}');
        // print('DEBUG: Data is empty: ${data is Map ? (data as Map).isEmpty : "not a map"}');
        // print('DEBUG: Has documentId: ${data is Map ? (data as Map).containsKey('documentId') : false}');
        // print('DEBUG: Has userId: ${data is Map ? (data as Map).containsKey('userId') : false}');

        // Check if data is a non-empty object (success)
        // Error responses have data as empty array [] or null
        // Success responses have data as object with documentId and userId
        bool isSuccess = data.isNotEmpty && data.containsKey('documentId') && data.containsKey('userId');

        print('DEBUG: isSuccess: $isSuccess');

        if (isSuccess) {
          // Parse the document verification response (success)
          final documentUploadResponse = DocumentUploadResponse(
            message: message!,
            data: DocumentUploadData.fromJson(data),
          );

          return ApiResponse(status: true, message: message, data: documentUploadResponse);
        } else {
          // API returned error message (data is [] or null)
          return ApiResponse(
            status: false,
            message: message!.isNotEmpty ? message : 'Failed to verify document',
            data: null,
          );
        }
      }

      return ApiResponse(status: false, message: response.message ?? 'Failed to verify document', data: null);
    } catch (e) {
      // Handle validation errors from API
      String errorMessage = 'An error occurred while verifying document: ${e.toString()}';

      // Try to parse validation errors if present
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;

        // Check for the new API error format with "message" field
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        } else if (responseData is Map<String, dynamic> && responseData['errors'] != null) {
          // Handle validation errors format
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            }
          });

          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join(', ');
          }
        } else if (responseData is Map<String, dynamic> && responseData['title'] != null) {
          errorMessage = responseData['title'] as String;
        }
      }

      return ApiResponse(status: false, message: errorMessage, data: null);
    }
  }

  /// Upload Driving License (convenience method)
  Future<ApiResponse<DocumentUploadResponse>> uploadDrivingLicense({
    required String userId,
    required String dlNumber,
    required DateTime dateOfBirth,
    String? dlImagePath,
    DateTime? validTill,
  }) async {
    return uploadDocument(
      userId: userId,
      documentType: 'DrivingLicense',
      documentNumber: dlNumber,
      dateOfBirth: dateOfBirth,
      documentImagePath: dlImagePath,
      validTill: validTill,
      verifiedOn: DateTime.now(),
    );
  }

  /// Upload Registration Certificate (convenience method)
  Future<ApiResponse<DocumentUploadResponse>> uploadRegistrationCertificate({
    required String userId,
    required String rcNumber,
    required DateTime dateOfBirth,
    String? rcImagePath,
    DateTime? validTill,
  }) async {
    return uploadDocument(
      userId: userId,
      documentType: 'RegistrationCertificate',
      documentNumber: rcNumber,
      dateOfBirth: dateOfBirth,
      documentImagePath: rcImagePath,
      validTill: validTill,
      verifiedOn: DateTime.now(),
    );
  }

  /// Get all documents for a user
  /// Note: This endpoint returns response format: {message, data: {documents, count}}
  Future<ApiResponse<DocumentListResponse>> getAllDocuments({required String userId}) async {
    try {
      // Use getRaw since this endpoint has a specific response format
      final response = await _apiClient.getRaw<DocumentListResponse>(
        '/Driver/GetAllDocsByUserId/$userId',
        fromJson: (json) => DocumentListResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while fetching documents: ${e.toString()}',
        data: null,
      );
    }
  }

  // ============================================
  // VEHICLE MANAGEMENT OPERATIONS
  // ============================================

  /// Upsert vehicle (add or update) for driver
  ///
  /// Parameters:
  /// - driverId: Driver ID (UUID)
  /// - vehicleNumberPlate: Vehicle number plate/registration number
  /// - rcNumber: RC (Registration Certificate) number
  /// - chassisNumber: Chassis number of the vehicle
  /// - bodyCoverType: Type of body cover (e.g., 'Open', 'Closed', 'SemiClosed')
  /// - capacity: Vehicle capacity (e.g., 'upto_half_tonne', 'upto_01_tonne', etc.)
  /// - length: Vehicle length in meters (max 18.75m)
  /// - width: Vehicle width in meters (max 2.6m)
  /// - height: Vehicle height in meters (max 4.75m)
  /// - numberOfWheels: Number of wheels (must be positive integer)
  Future<ApiResponse<VehicleUpsertResponse>> upsertVehicle({
    required String driverId,
    required String vehicleNumberPlate,
    required String rcNumber,
    required String chassisNumber,
    required String bodyCoverType,
    required String capacity,
    required double length,
    required double width,
    required double height,
    required int numberOfWheels,
  }) async {
    try {
      final request = VehicleUpsertRequest(
        driverId: driverId,
        vehicleNumberPlate: vehicleNumberPlate,
        rcNumber: rcNumber,
        chassisNumber: chassisNumber,
        bodyCoverType: bodyCoverType,
        capacity: capacity,
        length: length,
        width: width,
        height: height,
        numberOfWheels: numberOfWheels,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/Driver/UpsertVehicle',
        data: request.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true || response.data != null) {
        final vehicleUpsertResponse = VehicleUpsertResponse.fromJson(response.data!);

        return ApiResponse(status: true, message: vehicleUpsertResponse.message, data: vehicleUpsertResponse);
      }

      return ApiResponse(status: false, message: response.message ?? 'Failed to upsert vehicle', data: null);
    } catch (e) {
      // Handle specific error responses from API
      String errorMessage = 'An error occurred while adding/updating vehicle: ${e.toString()}';

      // Check for RC not verified error
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        }
      }

      return ApiResponse(status: false, message: errorMessage, data: null);
    }
  }

  /// Get all vehicles for a driver
  ///
  /// Parameters:
  /// - driverId: Driver ID (UUID)
  Future<ApiResponse<VehicleListResponse>> getDriverVehicles({required String driverId}) async {
    try {
      final response = await _apiClient.getRaw<VehicleListResponse>(
        '/Driver/GetAllVehiclesByDriverId/$driverId',
        fromJson: (json) => VehicleListResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while fetching vehicles: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Update vehicle information
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> updateVehicle({
    required String vehicleId,
    String? vehicleType,
    String? vehicleNumber,
    String? vehicleModel,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Update-Vehicle
      throw UnimplementedError('Update vehicle API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  /// Delete vehicle
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> deleteVehicle({required String vehicleId}) async {
    try {
      // TODO: Implement API call to /Driver/Delete-Vehicle
      throw UnimplementedError('Delete vehicle API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  // ============================================
  // DRIVER PROFILE OPERATIONS
  // ============================================

  /// Get driver profile
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> getDriverProfile({required String driverId}) async {
    try {
      // TODO: Implement API call to /Driver/Get-Profile
      throw UnimplementedError('Get driver profile API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  /// Update driver availability status
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> updateDriverAvailability({required String driverId, required bool isAvailable}) async {
    try {
      // TODO: Implement API call to /Driver/Update-Availability
      throw UnimplementedError('Update availability API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  // ============================================
  // TRIP/BOOKING OPERATIONS
  // ============================================

  /// Offer loads - Driver posts availability for loads
  ///
  /// Parameters:
  /// - driverId: Driver ID (UUID)
  /// - vehicleId: Vehicle ID (UUID)
  /// - availableTimeStart: Start of availability window
  /// - availableTimeEnd: End of availability window
  /// - pickupLat: Pickup location latitude
  /// - pickupLng: Pickup location longitude
  /// - dropLat: Drop-off location latitude
  /// - dropLng: Drop-off location longitude
  /// - pickupAddress: Pickup address (string)
  /// - dropAddress: Drop-off address (string)
  /// - fullRoutePoints: Array of route points with latitude/longitude
  /// - price: Offer price
  Future<ApiResponse<OfferLoadsResponse>> offerLoadsUpsert({
    required String driverId,
    required String vehicleId,
    required DateTime availableTimeStart,
    required DateTime availableTimeEnd,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required String pickupAddress,
    required String dropAddress,
    required List<Map<String, double>> fullRoutePoints,
    required double price,
  }) async {
    try {
      // Convert fullRoutePoints from List<Map<String, double>> to List<List<double>>
      // Format: [[longitude, latitude], [longitude, latitude], ...]
      final convertedRoutePoints = fullRoutePoints.map((point) {
        return [point['longitude']!, point['latitude']!];
      }).toList();

      final requestData = {
        'vehicleId': vehicleId,
        'driverId': driverId,
        'availableTimeStart': availableTimeStart.toUtc().toIso8601String(),
        'availableTimeEnd': availableTimeEnd.toUtc().toIso8601String(),
        'pickupLocation': [pickupLng, pickupLat],
        'dropLocation': [dropLng, dropLat],
        'pickupAddress': pickupAddress,
        'dropAddress': dropAddress,
        'fullRoutePoints': convertedRoutePoints,
        'price': price,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/Driver/OfferLoads-Upsert',
        data: requestData,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.data != null) {
        final offerLoadsResponse = OfferLoadsResponse.fromJson(response.data!);

        return ApiResponse(status: true, message: offerLoadsResponse.message, data: offerLoadsResponse);
      }

      return ApiResponse(status: false, message: response.message ?? 'Failed to submit load offer', data: null);
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while submitting load offer: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get all offered loads for a driver
  ///
  /// Parameters:
  /// - driverId: Driver ID (UUID)
  Future<ApiResponse<OfferLoadsListResponse>> getAllOfferLoads({required String driverId}) async {
    try {
      final response = await _apiClient.getRaw<OfferLoadsListResponse>(
        '/Driver/GetAllOfferLoadsByDriverId/$driverId',
        fromJson: (json) => OfferLoadsListResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while fetching offered loads: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Update offer price
  ///
  /// Parameters:
  /// - offerId: Offer ID (UUID)
  /// - driverId: Driver ID (UUID)
  /// - vehicleId: Vehicle ID (UUID)
  /// - price: New price for the offer
  Future<ApiResponse<UpdateOfferPriceResponse>> updateOfferPrice({
    required String offerId,
    required String driverId,
    required String vehicleId,
    required double price,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/Driver/Update-OfferPrice',
        queryParameters: {'OfferId': offerId, 'DriverId': driverId, 'VehicleId': vehicleId, 'Price': price.toString()},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true && response.data != null) {
        final updateOfferPriceResponse = UpdateOfferPriceResponse.fromJson(response.data!);

        return ApiResponse(status: true, message: updateOfferPriceResponse.message, data: updateOfferPriceResponse);
      }

      return ApiResponse(status: false, message: response.message ?? 'Failed to update offer price', data: null);
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while updating offer price: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get available trips for driver
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<List<dynamic>>> getAvailableTrips({required String driverId, String? location}) async {
    try {
      // TODO: Implement API call to /Driver/Get-Available-Trips
      throw UnimplementedError('Get available trips API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  /// Accept trip/booking
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> acceptTrip({required String driverId, required String tripId}) async {
    try {
      // TODO: Implement API call to /Driver/Accept-Trip
      throw UnimplementedError('Accept trip API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  /// Get driver's active trips
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<List<dynamic>>> getActiveTrips({required String driverId}) async {
    try {
      // TODO: Implement API call to /Driver/Get-Active-Trips
      throw UnimplementedError('Get active trips API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  /// Get driver's trip history
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<List<dynamic>>> getTripHistory({required String driverId, int? page, int? limit}) async {
    try {
      // TODO: Implement API call to /Driver/Get-Trip-History
      throw UnimplementedError('Get trip history API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  /// Update trip status
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> updateTripStatus({required String tripId, required String status}) async {
    try {
      // TODO: Implement API call to /Driver/Update-Trip-Status
      throw UnimplementedError('Update trip status API not yet implemented');
    } catch (e) {
      return ApiResponse(status: false, message: 'An error occurred: ${e.toString()}', data: null);
    }
  }

  // ============================================
  // HOME PAGE OPERATIONS
  // ============================================

  /// Get driver home page data including trip details
  ///
  /// Parameters:
  /// - driverId: Driver ID (UUID)
  Future<ApiResponse<HomePageResponse>> getHomePage({required String driverId}) async {
    try {
      print('DriverRepository: Calling GET /Driver/GetHomePageByDriverId/$driverId');

      final response = await _apiClient.getRaw<HomePageResponse>(
        '/Driver/GetHomePageByDriverId/$driverId',
        fromJson: (json) => HomePageResponse.fromJson(json),
      );

      print('DriverRepository: Response received - status: ${response.status}, message: ${response.message}');

      return response;
    } catch (e) {
      print('DriverRepository: Error in getHomePage: $e');
      return ApiResponse(
        status: false,
        message: 'An error occurred while fetching home page data: ${e.toString()}',
        data: null,
      );
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Generate a proper UUID v4
  // String _generateUuid() {
  //   return _uuid.v4();
  // }
}
