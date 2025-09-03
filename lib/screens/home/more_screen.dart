import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsoilai/widgets/settings_tile.dart';
import '../../controllers/more_controller.dart';
import '../../widgets/settings_tile.dart';
import '../../services/user_service.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MoreController>(
      init: MoreController(),
      global: false,
      builder:
          (controller) => Scaffold(
            body: SafeArea(
              child: Obx(() {
                final userService = UserService.to;
                return Column(
                  children: [
                    // Profile Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  userService.profileImage.isNotEmpty
                                      ? Image.network(
                                        userService.profileImage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  'assets/images/icon.png',
                                                  fit: BoxFit.cover,
                                                ),
                                      )
                                      : Image.asset(
                                        'assets/images/icon.png',
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userService.name.isNotEmpty
                                ? userService.name
                                : 'User',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // Settings List
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SettingsTile(
                                icon: 'assets/icons/user.svg',
                                title: 'Your Profile',
                                onTap: controller.openProfile,
                                showDivider: true,
                              ),
                              SettingsTile(
                                icon: 'assets/icons/order.svg',
                                title: 'My Order',
                                onTap: controller.openOrders,
                                showDivider: true,
                              ),
                              SettingsTile(
                                icon: 'assets/icons/settings.svg',
                                title: 'Settings',
                                onTap: controller.openSettings,
                                showDivider: true,
                              ),
                              SettingsTile(
                                icon: 'assets/icons/subscription.svg',
                                title: 'Subscription Plan',
                                onTap: controller.openSubscription,
                                showDivider: true,
                              ),
                              SettingsTile(
                                icon: 'assets/icons/about.svg',
                                title: 'About',
                                onTap: controller.openAbout,
                                showDivider: true,
                              ),
                              SettingsTile(
                                icon: 'assets/icons/privacy.svg',
                                title: 'Privacy Policy',
                                onTap: controller.openPrivacy,
                                showDivider: true,
                              ),
                              SettingsTile(
                                icon: 'assets/icons/logout.svg',
                                title: 'Log Out',
                                onTap: controller.logout,

                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Version Text
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
    );
  }
}
