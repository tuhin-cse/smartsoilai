import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'reports_screen.dart';
import 'more_screen.dart';

class MainNavigationController extends GetxController {
  final _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  void changeIndex(int index) {
    _selectedIndex.value = index;
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
      body: Obx(() => controller.screens[controller.selectedIndex]),
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
}
