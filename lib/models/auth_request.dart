class SigninRequest {
  final String email;
  final String password;

  SigninRequest({
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

class SignupRequest {
  final String name;
  final String email;
  final String password;
  final String? gender;

  SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      if (gender != null) 'gender': gender!.toLowerCase(),
    };
  }
}

class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({
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

class ResendOtpRequest {
  final String email;

  ResendOtpRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequest {
  final String email;
  final String token;
  final String newPassword;

  ResetPasswordRequest({
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

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? gender;

  UpdateProfileRequest({
    this.name,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender!.toLowerCase(),
    };
  }
}
