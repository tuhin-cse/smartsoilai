import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/auth_request.dart';
import '../repositories/auth_repository.dart';
import '../repositories/exceptions/api_exception.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

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
    if (user?.name != null) {
      return user!.name;
    }
    return 'User';
  }

  String get firstName {
    final name = displayName;
    return name.split(' ').first;
  }

  String? get profileImage {
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getProfile();
        _user.value = user;
        _isAuthenticated.value = true;
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
      
      _user.value = response.user;
      _isAuthenticated.value = true;
      
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

  Future<String?> signup(String email, String password, String fullName, {String? gender}) async {
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
      
      _user.value = response.user;
      _isAuthenticated.value = true;
      
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

  Future<void> resetPassword(String email, String token, String newPassword) async {
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
      _user.value = null;
      _isAuthenticated.value = false;
      
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
