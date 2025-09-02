import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(String?) onImageSelected;

  const ImagePickerBottomSheet({super.key, required this.onImageSelected});

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check if running on iOS simulator
      if (Platform.isIOS && source == ImageSource.camera) {
        // On iOS simulator, camera is not available
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));

        Get.snackbar(
          'Camera Unavailable',
          'Camera is not available on iOS simulator. Please test on a real device.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // For iOS, try to pick image directly without explicit permission check
      // iOS 14+ has built-in limited photo access that works without permission_handler
      if (Platform.isIOS && source == ImageSource.gallery) {
        final ImagePicker picker = ImagePicker();

        // Show loading indicator
        Get.snackbar(
          'Loading',
          'Opening photo library...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );

        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 800,
          maxHeight: 800,
        );

        if (image != null) {
          // Close bottom sheet and show success
          Get.back();
          await Future.delayed(const Duration(milliseconds: 300));

          onImageSelected(image.path);

          Get.snackbar(
            'Success',
            'Image selected successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          // User cancelled the picker - just close bottom sheet
          Get.back();
        }
        return;
      }

      // For Android and iOS camera, continue with permission checking
      PermissionStatus permissionStatus;
      if (source == ImageSource.camera) {
        permissionStatus = await Permission.camera.request();
        if (permissionStatus.isGranted) {
          // Double-check camera availability on iOS
          if (Platform.isIOS) {
            final picker = ImagePicker();
            try {
              // Try to access camera briefly to check availability
              await picker.pickImage(
                source: ImageSource.camera,
                maxWidth: 1,
                maxHeight: 1,
              );
            } catch (e) {
              if (e.toString().contains('not available') ||
                  e.toString().contains('simulator')) {
                Get.back();
                await Future.delayed(const Duration(milliseconds: 300));
                Get.snackbar(
                  'Camera Unavailable',
                  'Camera is not available on this device. Please check your camera settings.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                return;
              }
            }
          }
        }
      } else {
        // For Android gallery access
        if (Platform.isAndroid) {
          // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
          // For older versions, use READ_EXTERNAL_STORAGE
          permissionStatus = await Permission.photos.request();
          if (permissionStatus.isDenied ||
              permissionStatus.isPermanentlyDenied) {
            // Fallback to storage permission for older Android versions
            permissionStatus = await Permission.storage.request();
          }
        } else {
          // This should not reach here for iOS gallery as we handle it above
          permissionStatus = PermissionStatus.granted;
        }
      }

      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        // Close bottom sheet first, then show permission dialog
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));

        Get.snackbar(
          'Permission Required',
          source == ImageSource.camera
              ? 'Camera permission is required to take pictures. Please enable it in settings.'
              : 'Photo library permission is required to select pictures. Please enable it in settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();

      // Show loading indicator
      Get.snackbar(
        'Loading',
        source == ImageSource.camera
            ? 'Opening camera...'
            : 'Opening gallery...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.rear, // Use rear camera by default
      );

      if (image != null) {
        // Close bottom sheet and show success
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));

        onImageSelected(image.path);

        Get.snackbar(
          'Success',
          'Image selected successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // User cancelled the picker - just close bottom sheet
        Get.back();
      }
    } catch (e) {
      // Close bottom sheet first
      Get.back();
      await Future.delayed(const Duration(milliseconds: 300));

      String errorMessage = 'Failed to pick image';
      String errorTitle = 'Error';

      // Handle specific error types
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('camera') ||
          errorString.contains('permission')) {
        errorTitle = 'Camera Permission Error';
        errorMessage =
            Platform.isIOS
                ? 'Camera access denied. Please go to Settings > Privacy & Security > Camera and enable access for this app.'
                : 'Camera permission denied. Please enable camera permission in app settings.';
      } else if (errorString.contains('photo') ||
          errorString.contains('gallery') ||
          errorString.contains('storage')) {
        errorTitle = 'Gallery Permission Error';
        errorMessage =
            Platform.isIOS
                ? 'Photo library access denied. Please go to Settings > Privacy & Security > Photos and enable access for this app.'
                : 'Storage permission denied. Please enable storage permission in app settings.';
      } else if (errorString.contains('simulator')) {
        errorTitle = 'Simulator Limitation';
        errorMessage =
            'Camera is not available on iOS simulator. Please test on a real device.';
      } else if (errorString.contains('cancelled') ||
          errorString.contains('user')) {
        // User cancelled, don't show error
        return;
      } else {
        errorTitle = 'Image Picker Error';
        errorMessage =
            'An unexpected error occurred while accessing ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please try again.';
      }

      Get.snackbar(
        errorTitle,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton:
            errorString.contains('permission')
                ? TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
            'Choose Profile Picture',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 32),

          // Options
          _buildOption(
            icon: Icons.camera_alt,
            title: 'Take Picture',
            subtitle: 'Use camera to take a new photo',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 16),

          _buildOption(
            icon: Icons.photo_library,
            title: 'Select from Gallery',
            subtitle: 'Choose from your photo library',
            onTap: () => _pickImage(ImageSource.gallery),
          ),

          const SizedBox(height: 24),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF62BE24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF62BE24), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
