import 'user.dart';

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
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
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
  final String? otp; // For development only

  SignupResponse({
    required this.message,
    required this.user,
    this.otp,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      otp: json['otp'] as String?,
    );
  }
}

class ForgotPasswordResponse {
  final String message;
  final String? otp; // For development only

  ForgotPasswordResponse({
    required this.message,
    this.otp,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] as String,
      otp: json['otp'] as String?,
    );
  }
}

class ResetPasswordResponse {
  final String message;

  ResetPasswordResponse({
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] as String,
    );
  }
}

class ResendOtpResponse {
  final String message;
  final String? otp; // For development only

  ResendOtpResponse({
    required this.message,
    this.otp,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      message: json['message'] as String,
      otp: json['otp'] as String?,
    );
  }
}
