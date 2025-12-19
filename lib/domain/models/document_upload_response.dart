/// Document upload response model
class DocumentUploadResponse {
  final String message;
  final DocumentUploadData? data;

  DocumentUploadResponse({
    required this.message,
    this.data,
  });

  factory DocumentUploadResponse.fromJson(Map<String, dynamic> json) {
    return DocumentUploadResponse(
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? DocumentUploadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// Document upload data model
class DocumentUploadData {
  final String documentId;
  final String userId;

  DocumentUploadData({
    required this.documentId,
    required this.userId,
  });

  factory DocumentUploadData.fromJson(Map<String, dynamic> json) {
    return DocumentUploadData(
      documentId: json['documentId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'userId': userId,
    };
  }
}
