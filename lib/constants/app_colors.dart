import 'package:flutter/material.dart';

/// Color scheme extracted from Figma design system
class AppColors {
  // Primary green color scale from Figma
  static const Color primary50 = Color(0xFFF2FBE9);
  static const Color primary100 = Color(0xFFE3F8CF);
  static const Color primary200 = Color(0xFFC7F2A4);
  static const Color primary300 = Color(0xFFA9E978);
  static const Color primary400 = Color(0xFF82D942);
  static const Color primary500 = Color(0xFF62BE24); // Main primary color
  static const Color primary600 = Color(0xFF499818);
  static const Color primary700 = Color(0xFF397417);
  static const Color primary800 = Color(0xFF305C18);
  static const Color primary900 = Color(0xFF2B4E19);
  static const Color primary950 = Color(0xFF132B08);

  // Text colors from Figma
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF83888D);
  static const Color textTertiary = Color(0xFFA2A8AF);

  // Button states from Figma
  static const Color buttonHover = Color(0xFF62BE24);
  static const Color buttonDisabled = Color(0xFFB2B8BD);

  // Light theme colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundSecondaryLight = Color(0xFFFAFAF8);
  static const Color borderLight = Color(0xFFC7F2A4);
  static const Color successLight = Color(0xFF62BE24);
  static const Color successLightBg = Color(0xFFE3F8CF);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundSecondaryDark = Color(0xFF1F1F1F);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA2A8AF);
  static const Color textTertiaryDark = Color(0xFF83888D);
  static const Color borderDark = Color(0xFF305C18);
  static const Color successDark = Color(0xFF82D942);
  static const Color successDarkBg = Color(0xFF2B4E19);

  // Common colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Social colors
  static const Color google = Color(0xFF4285F4);
  static const Color facebook = Color(0xFF1877F2);

  // Weather card colors
  static const Color weatherCloud = Color(0xFF5B82F1);
  static const Color weatherSun = Color(0xFFF5D547);
  static const Color weatherBackground = Color(0xFFFFFFFF);
  static const Color weatherBorder = Color(0xFFE8EAE8);
  
  // Overlay colors
  static const Color overlayDark = Color(0x99000000); // 60% opacity
  static const Color overlayLight = Color(0x0DFFFFFF); // 5% opacity

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF62BE24),
    Color(0xFF82D942),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFF6F7F9),
    Color(0xFFFFFFFF),
  ];
}

/// Extension to get theme-aware colors
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => isDarkMode ? AppColors.primary400 : AppColors.primary500;
  Color get backgroundColor => isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get backgroundSecondary => isDarkMode ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight;
  Color get textColor => isDarkMode ? AppColors.textDark : AppColors.textPrimary;
  Color get textSecondary => isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get borderColor => isDarkMode ? AppColors.borderDark : AppColors.borderLight;
  Color get successColor => isDarkMode ? AppColors.successDark : AppColors.successLight;
  Color get successBackgroundColor => isDarkMode ? AppColors.successDarkBg : AppColors.successLightBg;
}
