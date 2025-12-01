/// Model for OTP response data
class OtpData {
  final bool isOtpSent;
  final String message;
  final String otp;

  OtpData({
    required this.isOtpSent,
    required this.message,
    required this.otp,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      isOtpSent: json['isOtpSent'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      otp: json['otp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOtpSent': isOtpSent,
      'message': message,
      'otp': otp,
    };
  }
}

/// Model for full OTP response
class OtpResponse {
  final String message;
  final OtpData data;

  OtpResponse({
    required this.message,
    required this.data,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] as String? ?? '',
      data: OtpData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}
