/// Model for user data in verify OTP response
class VerifyOtpUser {
  final String userID;
  final String userName;
  final String userMobile;
  final String userEmail;
  final String roleName;
  final String status;

  VerifyOtpUser({
    required this.userID,
    required this.userName,
    required this.userMobile,
    required this.userEmail,
    required this.roleName,
    required this.status,
  });

  factory VerifyOtpUser.fromJson(Map<String, dynamic> json) {
    return VerifyOtpUser(
      userID: json['userID'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userMobile: json['userMobile'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      roleName: json['roleName'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userName': userName,
      'userMobile': userMobile,
      'userEmail': userEmail,
      'roleName': roleName,
      'status': status,
    };
  }
}

/// Model for verify OTP data
class VerifyOtpData {
  final bool isVerified;
  final String message;
  final String accessToken;
  final String refreshToken;
  final VerifyOtpUser user;

  VerifyOtpData({
    required this.isVerified,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      isVerified: json['isVerified'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: VerifyOtpUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVerified': isVerified,
      'message': message,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

/// Model for full verify OTP response
class VerifyOtpResponse {
  final String message;
  final VerifyOtpData data;

  VerifyOtpResponse({
    required this.message,
    required this.data,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] as String? ?? '',
      data: VerifyOtpData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}
