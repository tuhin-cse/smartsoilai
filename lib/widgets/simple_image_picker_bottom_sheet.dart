import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SimpleImagePickerBottomSheet extends StatelessWidget {
  final Function(String?) onImageSelected;

  const SimpleImagePickerBottomSheet({
    super.key,
    required this.onImageSelected,
  });

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Close bottom sheet first
      Get.back();

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
        // Ensure the file has a proper extension
        String imagePath = image.path;

        // Check if the file has a proper image extension
        final extension = imagePath.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
          // If no proper extension, add .jpg (most common)
          imagePath = '${imagePath}.jpg';

          // Copy the file with new extension
          final originalFile = File(image.path);
          await originalFile.copy(imagePath);
        }

        onImageSelected(imagePath);

        
      }
    } catch (e) {
      String errorMessage = 'Failed to pick image';
      String errorTitle = 'Error';

      final errorString = e.toString().toLowerCase();

      if (errorString.contains('camera') ||
          errorString.contains('permission')) {
        errorTitle = 'Camera Permission';
        errorMessage =
            Platform.isIOS
                ? 'Please allow camera access in Settings > Privacy & Security > Camera > SmartSoilAI'
                : 'Please allow camera permission in app settings';
      } else if (errorString.contains('photo') ||
          errorString.contains('gallery') ||
          errorString.contains('library')) {
        errorTitle = 'Photo Access';
        errorMessage =
            Platform.isIOS
                ? 'Please allow photo access in Settings > Privacy & Security > Photos > SmartSoilAI'
                : 'Please allow storage permission in app settings';
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
        mainButton: TextButton(
          onPressed: () {
            // You can add code here to open app settings if needed
          },
          child: const Text('Settings', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Select Photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 24),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera option
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF62BE24).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: Color(0xFF62BE24),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Gallery option
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF62BE24).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            size: 32,
                            color: Color(0xFF62BE24),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
