import 'package:get/get.dart';
import '../screens/settings_screen.dart';

class MoreController extends GetxController {
  final userName = 'Naimur Rahman'.obs;

  void openProfile() {
    // TODO: navigate to profile
  }

  void openOrders() {}
  void openSettings() {
    Get.to(() => const SettingsScreen());
  }

  void openSubscription() {}
  void openAbout() {}
  void openPrivacy() {}

  void logout() {
    // implement logout logic
  }
}
