import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/exceptions/api_exception.dart';
import '../services/user_service.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  // final phoneController = TextEditingController();
  final genderController = ''.obs;
  final isLoading = false.obs;
  final isUpdateLoading = false.obs;
  final isImageUploading = false.obs;
  final isButtonEnabled = false.obs;
  final profileImagePath = RxnString();

  String _initialName = '';
  String _initialGender = '';
  String _initialEmail = '';

  @override
  void onInit() {
    super.onInit();
    // Listen to user service data changes
    ever(UserService.to.userData, (_) => _syncWithUserService());

    fetchProfile();
    nameController.addListener(_onFieldChanged);
    genderController.listen((_) => _onFieldChanged());
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    // phoneController.dispose();
    super.onClose();
  }

  void _syncWithUserService() {
    final userData = UserService.to.userData;
    if (userData.isNotEmpty) {
      _initialName = userData['name'] ?? '';
      _initialGender = userData['gender'] ?? '';
      _initialEmail = userData['email'] ?? '';

      nameController.text = _initialName;
      genderController.value = _initialGender;
      emailController.text = _initialEmail;
      // phoneController.text = _initialPhone;
      isButtonEnabled.value = false;
    }
  }

  void _onFieldChanged() {
    final hasNameChanged = nameController.text.trim() != _initialName.trim();
    final hasGenderChanged = genderController.value != _initialGender;
    final hasEmailChanged = emailController.text.trim() != _initialEmail.trim();
    // final hasPhoneChanged = phoneController.text.trim() != _initialPhone.trim();

    isButtonEnabled.value =
        hasNameChanged || hasGenderChanged || hasEmailChanged;
    // hasPhoneChanged;
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      await UserService.to.fetchUserData();
      isLoading.value = false;
    } catch (e) {
      if (e is ApiException) {
        // Optionally show error message: e.message
      }
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (!isButtonEnabled.value) return;
    isUpdateLoading.value = true;
    try {
      final Map<String, dynamic> updateData = {};
      if (nameController.text.trim() != _initialName.trim()) {
        updateData['name'] = nameController.text.trim();
        _initialName = nameController.text.trim();
      }
      if (genderController.value != _initialGender) {
        updateData['gender'] = genderController.value;
        _initialGender = genderController.value;
      }
      if (emailController.text.trim() != _initialEmail.trim()) {
        updateData['email'] = emailController.text.trim();
      }
      // if (phoneController.text.trim() != _initialPhone.trim()) {
      //   updateData['phone'] = phoneController.text.trim();
      // }
      if (updateData.isEmpty) {
        isUpdateLoading.value = false;
        return;
      }

      await UserService.to.updateUserData(updateData);
      isUpdateLoading.value = false;
      isButtonEnabled.value = false;

      // Optionally show success message
    } catch (e) {
      if (e is ApiException) {
        // Optionally show error message: e.message
      }
      isUpdateLoading.value = false;
    }
  }

  void updateGender(String value) {
    genderController.value = value;
  }

  void onImageSelected(String? imagePath) async {
    if (imagePath != null) {
      profileImagePath.value = imagePath;

      // Upload image through user service
      isImageUploading.value = true;
      try {
        await UserService.to.updateProfileImage(imagePath);
      } catch (e) {
        // If upload fails, revert the local image
        profileImagePath.value = null;
      } finally {
        isImageUploading.value = false;
      }
    }
  }
}
