import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'reports_screen.dart';
import 'more_screen.dart';

class MainNavigationController extends GetxController {
  final _selectedIndex = 0.obs;
  final _showWelcomeDialog = true.obs;
  
  int get selectedIndex => _selectedIndex.value;
  bool get showWelcomeDialog => _showWelcomeDialog.value;

  void changeIndex(int index) {
    _selectedIndex.value = index;
  }

  void dismissWelcomeDialog() {
    _showWelcomeDialog.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    // Auto dismiss welcome dialog after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _showWelcomeDialog.value = false;
    });
  }

  final List<Widget> screens = [
    const HomeScreen(),
    const ChatScreen(),
    const ReportsScreen(),
    const MoreScreen(),
  ];
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController());

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => controller.screens[controller.selectedIndex]),
          
          // Welcome Dialog Overlay
          Obx(() => controller.showWelcomeDialog 
            ? _buildWelcomeDialog(context, controller)
            : const SizedBox.shrink()),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex,
            onTap: controller.changeIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary500,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment_outlined),
                activeIcon: Icon(Icons.assessment),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz_outlined),
                activeIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeDialog(BuildContext context, MainNavigationController controller) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: controller.dismissWelcomeDialog,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Welcome illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8E8),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Welcome text
              const Text(
                'Welcome to Smart Soil AI',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Real-time soil insights to grow smarter and healthier crops with confidence, naturally and productively.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Start monitoring button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.dismissWelcomeDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Monitoring',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
