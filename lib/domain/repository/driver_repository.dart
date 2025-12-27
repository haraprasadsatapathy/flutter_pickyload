import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../data/data_source/api_client.dart';
import '../models/api_response.dart';
import '../models/document_upload_response.dart';
import '../models/document_list_response.dart';
import '../models/vehicle_upsert_request.dart';
import '../models/vehicle_upsert_response.dart';
import '../models/vehicle_list_response.dart';
import '../models/offer_loads_response.dart';
import '../models/offer_loads_list_response.dart';
import '../models/update_offer_price_response.dart';

/// Repository for driver-related operations
class DriverRepository {
  final ApiClient _apiClient;
  final Uuid _uuid = const Uuid();

  DriverRepository(this._apiClient);

  // ============================================
  // DOCUMENT OPERATIONS
  // ============================================

  /// Upload document (Driving License or Registration Certificate)
  ///
  /// Parameters:
  /// - userId: User ID (UUID)
  /// - documentType: Type of document (e.g., 'DrivingLicense', 'RegistrationCertificate')
  /// - documentNumber: Document number
  /// - documentImagePath: Path to the document image file (optional for now)
  /// - validTill: Document validity date (optional)
  /// - verifiedOn: Document verification date (optional)
  /// - dateOfBirth: Date of birth (optional)
  Future<ApiResponse<DocumentUploadResponse>> uploadDocument({
    required String userId,
    required String documentType,
    required String documentNumber,
    String? documentImagePath,
    DateTime? validTill,
    DateTime? verifiedOn,
    DateTime? dateOfBirth,
  }) async {
    try {
      final formData = FormData();

      // Generate a new document ID (UUID format)
      // In a real app, you might want to use the uuid package
      final documentId = _generateUuid();

      // Add required fields
      formData.fields.add(MapEntry('DocumentId', documentId));
      formData.fields.add(MapEntry('UserId', userId));
      formData.fields.add(MapEntry('DocumentType', documentType));
      formData.fields.add(MapEntry('DocumentNumber', documentNumber));

      // Add optional date fields if provided
      // Convert to UTC to ensure PostgreSQL compatibility (timestamp with time zone)
      if (validTill != null) {
        formData.fields.add(
          MapEntry('ValidTill', validTill.toUtc().toIso8601String()),
        );
      }
      if (verifiedOn != null) {
        formData.fields.add(
          MapEntry('VerifiedOn', verifiedOn.toUtc().toIso8601String()),
        );
      }
      if (dateOfBirth != null) {
        formData.fields.add(
          MapEntry('DateOfBirth', dateOfBirth.toUtc().toIso8601String()),
        );
      }

      // Add document image if provided
      // Note: The API might expect a specific field name for the image
      // You may need to update this based on actual API requirements
      if (documentImagePath != null && documentImagePath.isNotEmpty) {
        final fileName = documentImagePath.split('/').last;
        formData.files.add(
          MapEntry(
            'DocumentImage', // Update this field name if API expects something different
            await MultipartFile.fromFile(documentImagePath, filename: fileName),
          ),
        );
      }

      final response = await _apiClient.postMultipart<Map<String, dynamic>>(
        '/Driver/Upload-Doc',
        formData: formData,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true || response.message != null) {
        // Parse the document upload response
        final documentUploadResponse = DocumentUploadResponse(
          message: response.message ?? 'Document uploaded successfully',
          data: response.data != null
              ? DocumentUploadData.fromJson(response.data!)
              : null,
        );

        return ApiResponse(
          status: true,
          message: documentUploadResponse.message,
          data: documentUploadResponse,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to upload document',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while uploading document: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Upload Driving License (convenience method)
  Future<ApiResponse<DocumentUploadResponse>> uploadDrivingLicense({
    required String userId,
    required String dlNumber,
    String? dlImagePath,
    DateTime? validTill,
  }) async {
    return uploadDocument(
      userId: userId,
      documentType: 'DrivingLicense',
      documentNumber: dlNumber,
      documentImagePath: dlImagePath,
      validTill: validTill,
      verifiedOn: DateTime.now(),
    );
  }

  /// Upload Registration Certificate (convenience method)
  Future<ApiResponse<DocumentUploadResponse>> uploadRegistrationCertificate({
    required String userId,
    required String rcNumber,
    String? rcImagePath,
    DateTime? validTill,
  }) async {
    return uploadDocument(
      userId: userId,
      documentType: 'RegistrationCertificate',
      documentNumber: rcNumber,
      documentImagePath: rcImagePath,
      validTill: validTill,
      verifiedOn: DateTime.now(),
    );
  }

  /// Get all documents for a user
  /// Note: This endpoint returns response format: {message, data: {documents, count}}
  Future<ApiResponse<DocumentListResponse>> getAllDocuments({
    required String userId,
  }) async {
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
  /// - vehicleId: Optional vehicle ID (UUID) for update, null for new vehicle
  /// - driverId: Driver ID (UUID)
  /// - isVehicleBodyCovered: Whether vehicle body is covered
  /// - capacity: Vehicle capacity (e.g., 'upto_half_tonne', 'half_to_one_tonne', etc.)
  /// - length: Vehicle length in cm
  /// - width: Vehicle width in cm
  /// - height: Vehicle height in cm
  /// - vehicleNumber: Vehicle registration number
  /// - rcNumber: RC (Registration Certificate) number
  /// - makeModel: Vehicle make and model
  Future<ApiResponse<VehicleUpsertResponse>> upsertVehicle({
    String? vehicleId,
    required String driverId,
    required bool isVehicleBodyCovered,
    required String capacity,
    required double length,
    required double width,
    required double height,
    required String vehicleNumber,
    required String rcNumber,
    required String makeModel,
  }) async {
    try {
      final request = VehicleUpsertRequest(
        vehicleId: vehicleId,
        driverId: driverId,
        isVehicleBodyCovered: isVehicleBodyCovered,
        capacity: capacity,
        length: length,
        width: width,
        height: height,
        vehicleNumber: vehicleNumber,
        rcNumber: rcNumber,
        makeModel: makeModel,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/Driver/UpsertVehicle',
        data: request.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true || response.data != null) {
        final vehicleUpsertResponse = VehicleUpsertResponse.fromJson(
          response.data!,
        );

        return ApiResponse(
          status: true,
          message: vehicleUpsertResponse.message,
          data: vehicleUpsertResponse,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to upsert vehicle',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message:
            'An error occurred while adding/updating vehicle: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get all vehicles for a driver
  ///
  /// Parameters:
  /// - driverId: Driver ID (UUID)
  Future<ApiResponse<VehicleListResponse>> getDriverVehicles({
    required String driverId,
  }) async {
    try {
      final response = await _apiClient.getRaw<VehicleListResponse>(
        '/Driver/GetAll-VehiclesForDriver',
        queryParameters: {'DriverId': driverId},
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
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Delete vehicle
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> deleteVehicle({
    required String vehicleId,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Delete-Vehicle
      throw UnimplementedError('Delete vehicle API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  // ============================================
  // DRIVER PROFILE OPERATIONS
  // ============================================

  /// Get driver profile
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> getDriverProfile({
    required String driverId,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Get-Profile
      throw UnimplementedError('Get driver profile API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Update driver availability status
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> updateDriverAvailability({
    required String driverId,
    required bool isAvailable,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Update-Availability
      throw UnimplementedError('Update availability API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  // ============================================
  // TRIP/BOOKING OPERATIONS
  // ============================================

  /// Offer loads - Driver posts availability for loads
  ///
  /// Parameters:
  /// - offerId: Unique offer ID (UUID)
  /// - driverId: Driver ID (UUID)
  /// - vehicleId: Vehicle ID (UUID)
  /// - origin: Starting location
  /// - destination: Destination location
  /// - availableTimeStart: Start of availability window
  /// - availableTimeEnd: End of availability window
  /// - status: Offer status (default: 'DriverOffered')
  Future<ApiResponse<OfferLoadsResponse>> offerLoadsUpsert({
    required String offerId,
    required String driverId,
    required String vehicleId,
    required String origin,
    required String destination,
    required DateTime availableTimeStart,
    required DateTime availableTimeEnd,
    String status = 'DriverOffered',
  }) async {
    try {
      final requestData = {
        'offerId': offerId,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'origin': origin,
        'destination': destination,
        'availableTimeStart': availableTimeStart.toUtc().toIso8601String(),
        'availableTimeEnd': availableTimeEnd.toUtc().toIso8601String(),
        'status': status,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/Driver/OfferLoads-Upsert',
        data: requestData,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true && response.data != null) {
        final offerLoadsResponse = OfferLoadsResponse.fromJson(response.data!);

        return ApiResponse(
          status: true,
          message: offerLoadsResponse.message,
          data: offerLoadsResponse,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to submit load offer',
        data: null,
      );
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
  Future<ApiResponse<OfferLoadsListResponse>> getAllOfferLoads({
    required String driverId,
  }) async {
    try {
      final response = await _apiClient.getRaw<OfferLoadsListResponse>(
        '/Driver/GetAll-OfferLoads',
        queryParameters: {'DriverId': driverId},
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
        queryParameters: {
          'OfferId': offerId,
          'DriverId': driverId,
          'VehicleId': vehicleId,
          'Price': price.toString(),
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.status == true && response.data != null) {
        final updateOfferPriceResponse =
            UpdateOfferPriceResponse.fromJson(response.data!);

        return ApiResponse(
          status: true,
          message: updateOfferPriceResponse.message,
          data: updateOfferPriceResponse,
        );
      }

      return ApiResponse(
        status: false,
        message: response.message ?? 'Failed to update offer price',
        data: null,
      );
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
  Future<ApiResponse<List<dynamic>>> getAvailableTrips({
    required String driverId,
    String? location,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Get-Available-Trips
      throw UnimplementedError('Get available trips API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Accept trip/booking
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> acceptTrip({
    required String driverId,
    required String tripId,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Accept-Trip
      throw UnimplementedError('Accept trip API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get driver's active trips
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<List<dynamic>>> getActiveTrips({
    required String driverId,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Get-Active-Trips
      throw UnimplementedError('Get active trips API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get driver's trip history
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<List<dynamic>>> getTripHistory({
    required String driverId,
    int? page,
    int? limit,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Get-Trip-History
      throw UnimplementedError('Get trip history API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Update trip status
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> updateTripStatus({
    required String tripId,
    required String status,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Update-Trip-Status
      throw UnimplementedError('Update trip status API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  // ============================================
  // EARNINGS & PAYMENTS
  // ============================================

  /// Get driver earnings
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<dynamic>> getDriverEarnings({
    required String driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Get-Earnings
      throw UnimplementedError('Get earnings API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get payment history
  /// TODO: Implement when API endpoint is available
  Future<ApiResponse<List<dynamic>>> getPaymentHistory({
    required String driverId,
  }) async {
    try {
      // TODO: Implement API call to /Driver/Get-Payment-History
      throw UnimplementedError('Get payment history API not yet implemented');
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Generate a proper UUID v4
  String _generateUuid() {
    return _uuid.v4();
  }
}
