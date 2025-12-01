enum DocumentType {
  drivingLicense,
  registrationCertificate,
  aadhar,
}

enum DocumentStatus {
  pending,
  underReview,
  approved,
  rejected,
}

class Document {
  final String id;
  final String userId;
  final DocumentType type;
  final String documentNumber;
  final String? frontImagePath;
  final String? backImagePath;
  final DocumentStatus status;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;

  Document({
    required this.id,
    required this.userId,
    required this.type,
    required this.documentNumber,
    this.frontImagePath,
    this.backImagePath,
    this.status = DocumentStatus.pending,
    required this.uploadedAt,
    this.verifiedAt,
    this.rejectionReason,
  });

  String get typeName {
    switch (type) {
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.registrationCertificate:
        return 'Registration Certificate';
      case DocumentType.aadhar:
        return 'Aadhar Card';
    }
  }
}
