import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/auth_request.dart';
import '../repositories/auth_repository.dart';
import '../repositories/exceptions/api_exception.dart';
import '../services/user_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userDataKey = 'user';

  // Observable variables
  final _isAuthenticated = false.obs;
  final _user = Rxn<User>();
  final _isLoading = false.obs;

  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  User? get user => _user.value;
  bool get isLoading => _isLoading.value;

  // Display name helper
  String get displayName {
    final name = UserService.to.name;
    if (name.isNotEmpty) {
      return name;
    }
    return 'User';
  }

  String get firstName {
    final name = displayName;
    return name.split(' ').first;
  }

  String? get profileImage {
    return UserService.to.profileImage.isNotEmpty
        ? UserService.to.profileImage
        : null;
  }

  // Get access token for API calls
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Check if user has stored credentials
  Future<bool> hasStoredCredentials() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final userData = await _secureStorage.read(key: _userDataKey);
    return accessToken != null && userData != null;
  }

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Check if access token exists in secure storage
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final userDataJson = await _secureStorage.read(key: _userDataKey);

      if (accessToken != null && userDataJson != null) {
        // Parse user data from stored JSON
        final userData = json.decode(userDataJson) as Map<String, dynamic>;
        final user = User.fromJson(userData);

        _user.value = user;
        _isAuthenticated.value = true;

        // Update UserService with stored user data
        UserService.to.updateUserDataFromUser(user);
      } else {
        // Try to get profile from API if no stored data
        final isLoggedIn = await _authRepository.isLoggedIn();
        if (isLoggedIn) {
          final user = await _authRepository.getProfile();
          _user.value = user;
          _isAuthenticated.value = true;

          // Update UserService with fetched user data
          UserService.to.updateUserDataFromUser(user);
        }
      }
    } catch (e) {
      // Silent fail on init - user not logged in
      _isAuthenticated.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final request = SigninRequest(email: email, password: password);
      final response = await _authRepository.signin(request);

      print(response);

      // Save tokens to secure storage
      await _secureStorage.write(
        key: _accessTokenKey,
        value: response.accessToken,
      );
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: response.refreshToken,
      );

      // Save user data as JSON string
      final userJson = json.encode(response.user.toJson());
      await _secureStorage.write(key: _userDataKey, value: userJson);

      _user.value = response.user;
      _isAuthenticated.value = true;

      // Update UserService with user data
      UserService.to.updateUserDataFromUser(response.user);

      _showSuccessMessage('Login successful');
    } on ApiException catch (e) {
      _showErrorMessage('Login Failed', e.message);
      throw e;
    } catch (e) {
      _showErrorMessage('Login Failed', 'An unexpected error occurred');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signup(
    String email,
    String password,
    String fullName, {
    String? gender,
  }) async {
    _setLoading(true);
    try {
      final request = SignupRequest(
        name: fullName,
        email: email,
        password: password,
        gender: gender,
      );

      final response = await _authRepository.signup(request);
      _showSuccessMessage(response.message);

      // Return the OTP for development
      return response.otp;
    } on ApiException catch (e) {
      _showErrorMessage('Signup Failed', e.message);
      throw e;
    } catch (e) {
      _showErrorMessage('Signup Failed', 'An unexpected error occurred');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifySignupOtp(String email, String otp) async {
    _setLoading(true);
    try {
      final request = VerifyOtpRequest(email: email, otp: otp);
      final response = await _authRepository.verifySignupOtp(request);

      // Save tokens to secure storage after successful verification
      await _secureStorage.write(
        key: _accessTokenKey,
        value: response.accessToken,
      );
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: response.refreshToken,
      );

      // Save user data
      final userJson = json.encode(response.user.toJson());
      await _secureStorage.write(key: _userDataKey, value: userJson);

      _user.value = response.user;
      _isAuthenticated.value = true;

      // Update UserService with user data
      UserService.to.updateUserDataFromUser(response.user);

      _showSuccessMessage('Email verified successfully');
    } on ApiException catch (e) {
      _showErrorMessage('Verification Failed', e.message);
      throw e;
    } catch (e) {
      _showErrorMessage('Verification Failed', 'An unexpected error occurred');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> resendSignupOtp(String email) async {
    _setLoading(true);
    try {
      final request = ResendOtpRequest(email: email);
      final response = await _authRepository.resendSignupOtp(request);

      _showSuccessMessage(response.message);

      // Return the OTP for development
      return response.otp;
    } on ApiException catch (e) {
      _showErrorMessage('Resend Failed', e.message);
      throw e;
    } catch (e) {
      _showErrorMessage('Resend Failed', 'An unexpected error occurred');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authRepository.forgotPassword(request);

      _showSuccessMessage(response.message);

      // Return the OTP for development
      return response.otp;
    } on ApiException catch (e) {
      _showErrorMessage('Request Failed', e.message);
      throw e;
    } catch (e) {
      _showErrorMessage('Request Failed', 'An unexpected error occurred');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    _setLoading(true);
    try {
      final request = ResetPasswordRequest(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      final response = await _authRepository.resetPassword(request);
      _showSuccessMessage(response.message);
    } on ApiException catch (e) {
      _showErrorMessage('Reset Failed', e.message);
      throw e;
    } catch (e) {
      _showErrorMessage('Reset Failed', 'An unexpected error occurred');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();

      // Clear all stored data from secure storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userDataKey);

      _user.value = null;
      _isAuthenticated.value = false;

      // Clear UserService data
      UserService.to.clearUserData();

      Get.offAllNamed('/login');
    } catch (e) {
      _showErrorMessage('Logout Failed', 'An error occurred during logout');
    }
  }

  Future<void> updateProfile({String? name, String? gender}) async {
    _setLoading(true);
    try {
      final request = UpdateProfileRequest(name: name, gender: gender);
      final updatedUser = await _authRepository.updateProfile(request);

      _user.value = updatedUser;

      // Update UserService with updated user data
      UserService.to.updateUserDataFromUser(updatedUser);

      _showSuccessMessage('Profile updated successfully');
    } on ApiException catch (e) {
      _showErrorMessage('Update Failed', e.message);
      throw e;
    } catch (e) {
      _showErrorMessage('Update Failed', 'An unexpected error occurred');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
