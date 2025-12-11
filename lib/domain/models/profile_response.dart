/// Model for user profile data
class ProfileData {
  final String userName;
  final String userPhone;
  final String userEmail;
  final String? uProfileImageUrl;

  ProfileData({
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    this.uProfileImageUrl,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      uProfileImageUrl: json['uProfileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'uProfileImageUrl': uProfileImageUrl,
    };
  }
}

/// Model for full profile response
class ProfileResponse {
  final String message;
  final ProfileData data;

  ProfileResponse({
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'] as String? ?? '',
      data: ProfileData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}
