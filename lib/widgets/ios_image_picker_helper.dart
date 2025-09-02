import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class IOSImagePickerHelper {
  static Future<void> pickImageForIOS({
    required ImageSource source,
    required Function(String?) onImageSelected,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();

      // // Show loading indicator
      // Get.snackbar(
      //   'Loading',
      //   source == ImageSource.camera
      //       ? 'Opening camera...'
      //       : 'Opening photo library...',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.blue,
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 1),
      // );

      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      String errorMessage = 'Failed to pick image';
      String errorTitle = 'Error';

      final errorString = e.toString().toLowerCase();

      if (errorString.contains('camera') ||
          errorString.contains('permission')) {
        errorTitle = 'Camera Permission';
        errorMessage =
            'Please allow camera access in Settings > Privacy & Security > Camera';
      } else if (errorString.contains('photo') ||
          errorString.contains('gallery') ||
          errorString.contains('library')) {
        errorTitle = 'Photo Access';
        errorMessage =
            'Please allow photo access in Settings > Privacy & Security > Photos';
      } else if (errorString.contains('cancelled') ||
          errorString.contains('user')) {
        // User cancelled, don't show error
        return;
      }

      Get.snackbar(
        errorTitle,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
