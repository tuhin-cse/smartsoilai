import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user.dart';
import '../repositories/profile_repository.dart';
import '../repositories/exceptions/api_exception.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final ProfileRepository _profileRepository = ProfileRepository();

  // Reactive user data
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  // User data getters
  String get userId => userData['id'] ?? '';
  String get name => userData['name'] ?? '';
  String get email => userData['email'] ?? '';
  String get gender => userData['gender'] ?? '';
  String get phone => userData['phone'] ?? '';
  String get profileImage => userData['profileImage'] ?? '';

  @override
  void onInit() {
    super.onInit();
    // Auto-fetch user data when service initializes
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final data = await _profileRepository.fetchProfile();
      userData.value = data;
      isAuthenticated.value = true;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isAuthenticated.value = false;
      if (e is ApiException) {
        // Handle specific API errors
        print('Failed to fetch user data: ${e.message}');
      } else {
        print('Unexpected error fetching user data: $e');
      }
    }
  }

  Future<void> updateUserData(Map<String, dynamic> updateData) async {
    try {
      await _profileRepository.updateProfile(updateData);

      // Update local data with the changes
      userData.addAll(updateData);

      // Optionally show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF62BE24),
        colorText: Colors.white,
      );
    } catch (e) {
      if (e is ApiException) {
        // Handle specific API errors
        Get.snackbar(
          'Error',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      rethrow;
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      // Here you would upload the image to your server
      // For now, we'll just update the local data
      userData['profileImage'] = imagePath;

      Get.snackbar(
        'Success',
        'Profile picture updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF62BE24),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearUserData() {
    userData.clear();
    isAuthenticated.value = false;
  }

  // Update user data from User model
  void updateUserDataFromUser(User user) {
    userData.value = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'gender': user.gender,
      'profileImage': user.profileImage,
      'isActive': user.isActive,
      'isVerified': user.isVerified,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };
    isAuthenticated.value = true;
  }

  // Helper method to check if user data has specific fields
  bool hasData(String key) {
    return userData.containsKey(key) &&
        userData[key] != null &&
        userData[key].toString().isNotEmpty;
  }

  // Method to refresh user data
  Future<void> refreshUserData() async {
    await fetchUserData();
  }
}
