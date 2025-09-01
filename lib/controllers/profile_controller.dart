import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/profile_repository.dart';
import '../repositories/exceptions/api_exception.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  // final phoneController = TextEditingController();
  final genderController = ''.obs;
  final isLoading = false.obs;
  final isUpdateLoading = false.obs;
  final isButtonEnabled = false.obs;
  final profileImagePath = RxnString();

  String _initialName = '';
  String _initialGender = '';
  String _initialEmail = '';
  String _initialPhone = '';
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  void onInit() {
    super.onInit();
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
      final data = await _profileRepository.fetchProfile();
      isLoading.value = false;
      _initialName = data['name'] ?? '';
      _initialGender = data['gender'] ?? '';
      _initialEmail = data['email'] ?? '';
      _initialPhone = data['phone'] ?? '';

      nameController.text = _initialName;
      genderController.value = _initialGender;
      emailController.text = _initialEmail;
      // phoneController.text = _initialPhone;
      isButtonEnabled.value = false;
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
      await _profileRepository.updateProfile(updateData);
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

  void onImageSelected(String? imagePath) {
    if (imagePath != null) {
      profileImagePath.value = imagePath;
      // Here you can add logic to upload the image to your server
      Get.snackbar(
        'Success',
        'Profile picture selected successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF62BE24),
        colorText: Colors.white,
      );
    }
  }
}
