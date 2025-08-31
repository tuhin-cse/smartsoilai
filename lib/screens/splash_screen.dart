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
    // Navigate after animation

    checkDevices();

    Future.delayed(const Duration(milliseconds: 3000), () {
      Get.offNamed('/onboarding');
    });
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
          print('  Product ID: 0x${device.pid?.toRadixString(16) ?? 'unknown'}');
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
    final storage = await storageService;
    final isOnboardingCompleted = await storage.isOnboardingCompleted();

    if (authController.isAuthenticated) {
      Get.offNamed('/main-navigation');
    } else if (isOnboardingCompleted) {
      Get.offNamed('/login');
    } else {
      Get.offNamed('/onboarding');
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
