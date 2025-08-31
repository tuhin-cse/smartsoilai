import 'package:flutter/material.dart';

class AppFonts {
  static const String fontFamily = 'Inter';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Common text styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.2,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: regular,
    height: 1.3,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.2,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.4,
  );
}
