// Auth Response Models
class User {
  final String id;
  final String name;
  final String email;
  final String? gender;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

class SignupResponse {
  final String message;
  final User user;
  final String? otp; // Only in development mode

  SignupResponse({
    required this.message,
    required this.user,
    this.otp,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
      otp: json['otp'],
    );
  }
}

class OtpResponse {
  final String message;
  final String? otp; // Only in development mode

  OtpResponse({
    required this.message,
    this.otp,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'],
      otp: json['otp'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(
      success: false,
      error: error,
    );
  }
}
