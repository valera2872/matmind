import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF102F39);
  static const muted = Color(0xFF607780);
  static const teal = Color(0xFF236B78);
  static const tealSoft = Color(0xFFDDEDEC);
  static const sand = Color(0xFFF3E8D8);
  static const rose = Color(0xFFF1E2E1);
  static const blueSoft = Color(0xFFDDE8F1);
  static const lavender = Color(0xFFE9E4F2);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF3F6F5);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.12,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.16,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.muted,
      ),
    ),
  );
}
