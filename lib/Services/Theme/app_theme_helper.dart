import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';

class AppThemeHelper {
  static const Color _lightPrimary = Color(0xFF7C3AED);
  static const Color _darkPrimary = Color(0xFFA855F7);
  static const Color _darkSurface = Color(0xFF151521);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textDark,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: AppTextStyles.heading.copyWith(color: AppColors.primaryPurple),
      contentTextStyle: AppTextStyles.bodyDark,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryPurple,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F17),
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      surface: _darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Color(0x66A855F7), // soft purple glow
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1A1A26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: AppTextStyles.headingWhite.copyWith(color: AppColors.primaryPurple),
      contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.textWhite),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryPurple,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: const Color(0x66A855F7), // subtle glow
      ),
    ),
  );
}

