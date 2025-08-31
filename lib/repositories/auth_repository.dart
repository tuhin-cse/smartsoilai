import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'exceptions/api_exception.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<AuthResponse> signin(SigninRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/signin',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);
        return authResponse;
      } else {
        throw ApiException(
          message: 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred during login');
    }
  }

  Future<SignupResponse> signup(SignupRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return SignupResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Signup failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred during signup');
    }
  }

  Future<AuthResponse> verifySignupOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-signup-otp',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);
        return authResponse;
      } else {
        throw ApiException(
          message: 'OTP verification failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred during OTP verification');
    }
  }

  Future<ResendOtpResponse> resendSignupOtp(ResendOtpRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/resend-signup-otp',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ResendOtpResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to resend OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred while resending OTP');
    }
  }

  Future<ForgotPasswordResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ForgotPasswordResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to send password reset OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred during password reset request');
    }
  }

  Future<ResetPasswordResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/reset-password',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ResetPasswordResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to reset password',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred during password reset');
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to get profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred while fetching profile');
    }
  }

  Future<User> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.put(
        '/auth/profile',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        await _saveUser(user);
        return user;
      } else {
        throw ApiException(
          message: 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred while updating profile');
    }
  }

  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        await _saveUser(authResponse.user);
        return authResponse;
      } else {
        throw ApiException(
          message: 'Failed to refresh token',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred during token refresh');
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.accessTokenKey, accessToken);
    await prefs.setString(AppConfig.refreshTokenKey, refreshToken);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.userKey, user.toJson().toString());
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.accessTokenKey);
    await prefs.remove(AppConfig.refreshTokenKey);
    await prefs.remove(AppConfig.userKey);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.refreshTokenKey);
  }

  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConfig.userKey);
    if (userJson != null) {
      try {
        // Parse the saved user data
        // Note: This is a simplified implementation
        // In production, you might want to use json_annotation or similar
        return null; // Return parsed user
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}
