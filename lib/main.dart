import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/app_colors.dart';
import 'controllers/auth_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/network_service.dart';
import 'services/user_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(LanguageController());
    Get.put(ThemeController());
    Get.put(NetworkService());
    Get.put(UserService());

    return GetMaterialApp(
      title: 'Smart Soil AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary500,
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary400,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      themeMode: Get.find<ThemeController>().themeMode,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
