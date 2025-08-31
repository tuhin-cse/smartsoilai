import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.light.obs;
  final _isDarkMode = false.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    // TODO: Load theme preference from SharedPreferences
    // For now, default to light mode
  }

  void toggleTheme() {
    if (_themeMode.value == ThemeMode.light) {
      _themeMode.value = ThemeMode.dark;
      _isDarkMode.value = true;
    } else {
      _themeMode.value = ThemeMode.light;
      _isDarkMode.value = false;
    }
    
    // TODO: Save theme preference to SharedPreferences
    update();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _isDarkMode.value = mode == ThemeMode.dark;
    
    // TODO: Save theme preference to SharedPreferences
    update();
  }

  // Theme colors based on current mode
  Color get primaryColor => isDarkMode 
    ? const Color(0xFF82D942) 
    : const Color(0xFF62BE24);

  Color get backgroundColor => isDarkMode 
    ? const Color(0xFF000000) 
    : const Color(0xFFFFFFFF);

  Color get backgroundSecondary => isDarkMode 
    ? const Color(0xFF1F1F1F) 
    : const Color(0xFFF6F7F9);

  Color get textColor => isDarkMode 
    ? const Color(0xFFFFFFFF) 
    : const Color(0xFF1F1F1F);

  Color get textSecondary => isDarkMode 
    ? const Color(0xFFA2A8AF) 
    : const Color(0xFF83888D);

  Color get borderColor => isDarkMode 
    ? const Color(0xFF305C18) 
    : const Color(0xFFC7F2A4);
}
