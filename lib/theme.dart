import 'package:flutter/material.dart';

/// Central color/theme constants — kept clean and minimal like a
/// well-organized Tailwind config, translated to Flutter's ThemeData.
class AppColors {
  static const primary = Color(0xFF0F766E); // teal-700
  static const primaryLight = Color(0xFFCCFBF1); // teal-100
  static const emergency = Color(0xFFDC2626); // red-600
  static const emergencyLight = Color(0xFFFEE2E2); // red-100
  static const surface = Color(0xFFF8FAFC); // slate-50
  static const card = Colors.white;
  static const textPrimary = Color(0xFF0F172A); // slate-900
  static const textSecondary = Color(0xFF64748B); // slate-500
  static const star = Color(0xFFF59E0B); // amber-500
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}
