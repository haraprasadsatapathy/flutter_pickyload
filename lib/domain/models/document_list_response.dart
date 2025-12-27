/// Document list response model
class DocumentListResponse {
  final String message;
  final List<DocumentInfo> documents;
  final int count;

  DocumentListResponse({
    required this.message,
    required this.documents,
    required this.count,
  });

  factory DocumentListResponse.fromJson(Map<String, dynamic> json) {
    // API can return two formats:
    // Format 1: {message, data: {documents, count}}
    // Format 2: {message, data: [...]} (array of documents directly)

    final data = json['data'];
    List<DocumentInfo> documentsList = [];
    int documentCount = 0;

    if (data is List) {
      // Format 2: data is an array of documents
      documentsList = data
          .map((doc) => DocumentInfo.fromJson(doc as Map<String, dynamic>))
          .toList();
      documentCount = documentsList.length;
    } else if (data is Map<String, dynamic>) {
      // Format 1: data is an object with documents and count fields
      documentsList = (data['documents'] as List<dynamic>?)
              ?.map((doc) => DocumentInfo.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [];
      documentCount = data['count'] as int? ?? documentsList.length;
    }

    return DocumentListResponse(
      message: json['message'] as String? ?? '',
      documents: documentsList,
      count: documentCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'count': count,
    };
  }
}

/// Document information model
class DocumentInfo {
  final String documentId;
  final String userId;
  final String documentType;
  final String documentNumber;
  final DateTime? validTill;
  final DateTime? verifiedOn;

  DocumentInfo({
    required this.documentId,
    required this.userId,
    required this.documentType,
    required this.documentNumber,
    this.validTill,
    this.verifiedOn,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      documentId: json['documentId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      documentNumber: json['documentNumber'] as String? ?? '',
      validTill: json['validTill'] != null
          ? DateTime.tryParse(json['validTill'] as String)
          : null,
      verifiedOn: json['verifiedOn'] != null
          ? DateTime.tryParse(json['verifiedOn'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'userId': userId,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'validTill': validTill?.toIso8601String(),
      'verifiedOn': verifiedOn?.toIso8601String(),
    };
  }

  /// Get a human-readable document type name
  String get documentTypeName {
    switch (documentType) {
      case 'DrivingLicense':
        return 'Driving License';
      case 'RegistrationCertificate':
        return 'Registration Certificate';
      default:
        return documentType;
    }
  }

  /// Get the icon for the document type
  String get documentIcon {
    switch (documentType) {
      case 'DrivingLicense':
        return '🪪';
      case 'RegistrationCertificate':
        return '📋';
      default:
        return '📄';
    }
  }

  /// Check if document is expired
  bool get isExpired {
    if (validTill == null) return false;
    return validTill!.isBefore(DateTime.now());
  }

  /// Check if document is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (validTill == null) return false;
    final daysUntilExpiry = validTill!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }
}
