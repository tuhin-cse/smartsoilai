// Auth DTOs (Data Transfer Objects)
class SigninDto {
  final String email;
  final String password;

  SigninDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SignupDto {
  final String name;
  final String email;
  final String? gender;
  final String password;

  SignupDto({
    required this.name,
    required this.email,
    this.gender,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (gender != null) 'gender': gender,
      'password': password,
    };
  }
}

class VerifyOtpDto {
  final String email;
  final String otp;

  VerifyOtpDto({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

class ResendOtpDto {
  final String email;

  ResendOtpDto({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ForgotPasswordDto {
  final String email;

  ForgotPasswordDto({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordDto {
  final String email;
  final String token;
  final String newPassword;

  ResetPasswordDto({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'newPassword': newPassword,
    };
  }
}

class RefreshTokenDto {
  final String refreshToken;

  RefreshTokenDto({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

class UpdateProfileDto {
  final String? name;
  final String? gender;

  UpdateProfileDto({
    this.name,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
    };
  }
}
