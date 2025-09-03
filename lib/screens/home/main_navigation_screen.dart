import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../constants/app_colors.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'reports_screen.dart';
import 'more_screen.dart';
import '../placeholder_screens.dart' show ShopScreen;

class MainNavigationController extends GetxController {
  final _selectedIndex = 0.obs;
  final _showWelcomeDialog = true.obs;

  int get selectedIndex => _selectedIndex.value;
  bool get showWelcomeDialog => _showWelcomeDialog.value;

  void changeIndex(int index) {
    if (index >= 0 && index < screens.length) {
      _selectedIndex.value = index;
    }
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
      extendBody: true,
      body: Stack(
        children: [
          Obx(
            () =>
                controller.selectedIndex < controller.screens.length
                    ? controller.screens[controller.selectedIndex]
                    : controller.screens[0],
          ),

          // Welcome Dialog Overlay
          Obx(
            () =>
                controller.showWelcomeDialog
                    ? _buildWelcomeDialog(context, controller)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      isActive: controller.selectedIndex == 0,
                      onTap: () => controller.changeIndex(0),
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.chat_bubble_outline,
                      activeIcon: Icons.chat_bubble,
                      label: 'Chat',
                      isActive: controller.selectedIndex == 1,
                      onTap: () => controller.changeIndex(1),
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.assessment_outlined,
                      activeIcon: Icons.assessment,
                      label: 'Reports',
                      isActive: controller.selectedIndex == 2,
                      onTap: () => controller.changeIndex(2),
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view,
                      label: 'More',
                      isActive: controller.selectedIndex == 4,
                      onTap: () => controller.changeIndex(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary500 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.primary500 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeDialog(
    BuildContext context,
    MainNavigationController controller,
  ) {
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
