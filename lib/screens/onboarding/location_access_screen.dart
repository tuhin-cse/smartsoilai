import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';


class LocationAccessScreen extends StatelessWidget {
  const LocationAccessScreen({super.key});

  Future<void> _handleLocationRequest() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.dialog(
          AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text('Location services are disabled. Please enable location services and try again.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.dialog(
            AlertDialog(
              title: const Text('Location Access Denied'),
              content: const Text('Location access is required for the best experience. You can enable it later in settings.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.dialog(
          AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Geolocator.openAppSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        );
        return;
      }

      // Permission granted, navigate to language selection
      Get.offNamed('/language-select');
    } catch (error) {
      print('Error requesting location permission: $error');
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to request location permission'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _handleSkip() {
    Get.offNamed('/language-select');
  }

  void _handleBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary100, // Light green background
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF435C5C),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Location Icon with Concentric Circles
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer circle - lightest
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withOpacity(0.1), // 10% opacity green
                              borderRadius: BorderRadius.circular(55),
                            ),
                          ),

                          // Second circle
                          Container(
                            width: 94,
                            height: 94,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withOpacity(0.15), // 15% opacity green
                              borderRadius: BorderRadius.circular(47),
                            ),
                          ),

                          // Third circle
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withOpacity(0.18), // 18% opacity green
                              borderRadius: BorderRadius.circular(38),
                            ),
                          ),

                          // Inner circle - solid green with location icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary500, // Solid green
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'Enable Location Access',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'To provide a seamless and efficient experience, please enable location access.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF838896),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                children: [
                  // Confirm Button
                  CustomButton(
                    title: 'Confirm',
                    onPressed: _handleLocationRequest,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    fullWidth: true,
                  ),

                  const SizedBox(height: 8),

                  // Skip Link
                  GestureDetector(
                    onTap: _handleSkip,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1F1F1F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}