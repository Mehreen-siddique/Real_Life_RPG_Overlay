import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color primaryPurple = Color(0xFF6C4AB6);
  static const Color electricBlue = Color(0xFF4A90E2);
  static const Color goldYellow = Color(0xFFFFD700);
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color rubyRed = Color(0xFFE74C3C);

  // Background colors
  static const Color darkNavy = Color(0xFF1A1D2E);
  static const Color charcoal = Color(0xFF2D3142);
  static const Color cardBackground = Color(0xFF3A3D4E);

  // Text colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textGray,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );
}

class AppSizes {
  static const double padding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double iconSize = 24.0;
}
