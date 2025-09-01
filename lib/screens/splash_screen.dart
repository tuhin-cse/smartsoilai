import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/screens/sensor_test.dart';

import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../services/storage_service.dart';

import 'package:usb_serial/usb_serial.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate after animation and auth check
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check for USB devices in background
    checkDevices();

    // Wait for auth controller to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    // Small delay for splash screen visibility
    await Future.delayed(const Duration(milliseconds: 2500));

    _navigateToNext();
  }

  void checkDevices() async {
    try {
      print('Checking for USB devices...');
      List<UsbDevice> devices = await UsbSerial.listDevices();
      print('Found ${devices.length} USB devices:');

      if (devices.isEmpty) {
        print('No USB devices found');
        print('Make sure:');
        print('1. USB device is connected to your computer');
        print('2. USB debugging is enabled on the device');
        print('3. You have proper USB permissions');
      } else {
        for (var device in devices) {
          print('Device: ${device.deviceName}');
          print('  Vendor ID: 0x${device.vid?.toRadixString(16) ?? 'unknown'}');
          print(
            '  Product ID: 0x${device.pid?.toRadixString(16) ?? 'unknown'}',
          );
          print('  Serial: ${device.serial ?? 'unknown'}');
          print('  Manufacturer: ${device.manufacturerName ?? 'unknown'}');
          print('  Product: ${device.productName ?? 'unknown'}');
        }
      }
    } catch (e) {
      print('Error checking USB devices: $e');
    }
  }

  void _navigateToNext() async {
    final authController = Get.find<AuthController>();

    // Check if user has stored credentials (access token)
    final hasCredentials = await authController.hasStoredCredentials();

    print('🔐 Auth Check:');
    print('  - Has stored credentials: $hasCredentials');
    print('  - Is authenticated: ${authController.isAuthenticated}');

    if (hasCredentials && authController.isAuthenticated) {
      // User has valid credentials and is authenticated
      print('  → Navigating to: /main-navigation (authenticated user)');
      Get.offNamed('/main-navigation');
    } else if (hasCredentials) {
      // User has stored credentials but not authenticated (maybe token expired)
      print(
        '  → Navigating to: /login (has credentials but not authenticated)',
      );
      Get.offNamed('/login');
    } else {
      // No stored credentials, check onboarding status
      final storage = await storageService;
      final isOnboardingCompleted = await storage.isOnboardingCompleted();

      print('  - Onboarding completed: $isOnboardingCompleted');

      if (isOnboardingCompleted) {
        print('  → Navigating to: /login (onboarding completed)');
        Get.offNamed('/login');
      } else {
        print('  → Navigating to: /onboarding (first time user)');
        Get.offNamed('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(child: Image.asset("assets/images/logo.png", width: 220)),
    );
  }
}
