import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController(text: 'Naimur Rahman');
  final emailController = TextEditingController(text: 'naimurrahman@email.com');
  final phoneController = TextEditingController(text: '+8801542658884');
  final genderController = 'Male'.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void updateProfile() {
    // TODO: Implement profile update logic
    Get.back();
  }

  void updateGender(String value) {
    genderController.value = value;
  }
}
