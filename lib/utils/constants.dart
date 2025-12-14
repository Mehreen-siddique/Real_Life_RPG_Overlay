
import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // PRIMARY BACKGROUND COLORS
  // ============================================
  static const Color lightBackground = Color(0xFFF8F8FA); // Very light gray
  static const Color whiteBackground = Color(0xFFFFFFFF); // Pure white
  static const Color cardBackground = Color(0xFFFFFFFF); // White cards

  // ============================================
  // ACCENT COLORS (Main Theme Colors)
  // ============================================
  static const Color primaryPurple = Color(0xFF9458F7); // Main purple
  static const Color errorRed = Color(0xFFFF0000);
  static const Color accentMagenta = Color(0xFFC459E1); // Magenta
  static const Color accentBlue = Color(0xFF6C82F8); // Blue
  static const Color statsBackground = Color(0xFFF2F1F1); //grey
  static const Color accentGreen = Color(0xFF34D399); // Green
  static const Color highlightGold = Color(0xFFFFC107); // Gold/Yellow

  // ============================================
  // SECONDARY ACCENT SHADES
  // ============================================
  static const Color lightPurple = Color(0xFFEAE0FB); // Light purple bg
  static const Color lightYellow = Color(0xFFFFFBEB); // Light yellow bg
  static const Color lightGreen = Color(0xFFF0FDF4); // Light green bg
  static const Color darkPurple = Color(0xFF6C29A6); // Dark purple text

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textDark = Color(0xFF333333); // Dark gray/black
  static const Color textWhite = Color(0xFFFFFFFF); // White
  static const Color textLavender = Color(0xFFD9C7F7); // Light lavender
  static const Color textGray = Color(0xFF8E8E93); // Medium gray
  static const Color textMuted = Color(0xFFB0B0B0); // Muted gray

  // Text colors for light backgrounds
 // static const Color textOnPurpleBg = Color(0xFF8A52E5);
  static const Color textOnYellowBg = Color(0xFFD97706);
 // static const Color textOnGreenBg = Color(0xFF16A34A);

  // ============================================
  // LEADERBOARD COLORS
  // ============================================
  static const Color leaderboardGold = Color(0xFFFFC107);
  static const Color leaderboardSilver = Color(0xFFBDC3C7);
  static const Color leaderboardBronze = Color(0xFFE67E22);

  // // ============================================
  // // QUEST CARD COLORS
  // // ============================================
  // static const Color questPurple = Color(0xFF8A52E5);
  // static const Color questMagenta = Color(0xFFC459E1);
  // static const Color questBlue = Color(0xFF6C82F8);

  // ============================================
  //Light Container Colors
  static const Color lightBackgroundBox = Color(0x78EBDCFF);
  static const Color strokeColor = Color(0x7AB16AFF);
  static const Color yellowBoxBackground = Color(0x63FFCC11);
  static const Color yellowText = Color(0xCCFFCC11);
  static const Color greenBackgroundBox = Color(0x6334D399);
  static const Color greenStroke = Color(0xFF34D399);


  // ============================================

  // BUTTON COLORS
  // ============================================
  static const Color buttonWhite = Color(0xFFFFFFFF);
  static const Color buttonPurple = Color(0xFF8A52E5);

  // ============================================
  // PROGRESS BAR COLORS
  // ============================================
  static const Color progressFill = Color(0xFFFFFFFF);
  static const Color progressTrack = Color(0xFF6E39C8);

  // ============================================
  // BORDER COLORS
  // ============================================
  static const Color borderGold = Color(0xFFFFC107);
  static const Color borderWhite = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE8E8E8);

  // ============================================
  // SHADOW COLORS
  // ============================================
  static const Color shadowDark = Color(0x1A000000); // 10% black
  static const Color shadowGold = Color(0x40FFC107); // 25% gold
  static const Color shadowPurple = Color(0x408A52E5); // 25% purple

  // ============================================
  // GRADIENT COLORS
  // ============================================

  //Gradient color for background Appbars and splash screen.
  static const List<Color> gradientPrimary = [
    Color(0xFF9458F7),
    Color(0xFF573491),
  ];

  // Primary gradient (Purple to Pink)
  static const List<Color> gradientPrimaryPurple = [
    Color(0xFFA033FF),
    Color(0xFFE84DFF),
  ];

  // AR Pet background gradient
  static const List<Color> gradientARBackground = [
    Color(0xFFD3C2F7),
    Color(0xFFEAE6F9),
  ];



  // Gradients for quest
  static const List<Color> gradientEasy = [
    Color(0xFFB16AFF),
    Color(0xCCA952FF),
  ];

  static const List<Color> gradientMedium = [
    Color(0xFF93A8FD),
    Color(0xFF6C82F8),
  ];

  static const List<Color> gradientHard = [
    Color(0xCCD988ED),
    Color(0xCCC459E1),

  ];

  static const List<Color>  Easy  = [Color(0xFFB16AFF), Color(0xCCA952FF)];
  static const List<Color> Medium  = [Color(0xFF93A8FD), Color(0xFF6C82F8)];
  static const List<Color> Hard   = [Color(0xCCD988ED), Color(0xCCC459E1)];

  // ============================================
  // HELPER METHODS
  // ============================================

  // Get quest color by type
  // static Color getQuestColor(String type) {
  //   switch (type.toLowerCase()) {
  //     case 'health':
  //       return questPurple;
  //     case 'study':
  //       return questBlue;
  //     case 'exercise':
  //       return questPurple;
  //     case 'social':
  //       return questMagenta;
  //     case 'sleep':
  //       return questPurple;
  //     default:
  //       return primaryPurple;
  //   }
  // }

  // Get gradient by quest type
  static List<Color> getQuestGradient(String type) {
    switch (type.toLowerCase()) {
      case 'health':
        return gradientHard;
      case 'study':
        return gradientHard;
      case 'exercise':
        return gradientMedium;
      case 'social':
        return gradientEasy;
      default:
        return gradientPrimaryPurple;
    }
  }
}

// ============================================
// TEXT STYLES
// ============================================

class AppTextStyles {
  // Heading styles
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
  static const TextStyle screenHeading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryPurple,
    letterSpacing: -0.5,
  );

  static const TextStyle headingWhite = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
    letterSpacing: -0.5,
  );

  // Subheading styles
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static const TextStyle subheadingWhite = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: -0.3,
  );

  // Body text styles
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textGray,
    height: 1.5,
  );

  static const TextStyle bodyDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
  );

  static const TextStyle bodyWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textWhite,
    height: 1.5,
  );

  // Small text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textGray,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textGray,
  );

  // Stat value styles
  static const TextStyle statValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle statValueLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonPurple = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryPurple,
    letterSpacing: 0.5,
  );

  // Tab text
  static const TextStyle tabSelected = TextStyle(
    fontSize: 14,
    color: AppColors.textWhite,
  );

  static const TextStyle tabUnselected = TextStyle(
    fontSize: 14,
    color: AppColors.primaryPurple,
  );
}

// ============================================
// APP SIZES
// ============================================

class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double padding = 16.0;
  static const double paddingMD = 20.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radius = 16.0;
  static const double radiusMD = 20.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 30.0;

  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double icon = 24.0;
  static const double iconMD = 28.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;

  // Card dimensions
  static const double cardHeight = 120.0;
  static const double cardElevation = 4.0;

  // Avatar sizes
  static const double avatarSM = 40.0;
  static const double avatar = 60.0;
  static const double avatarLG = 80.0;

  // Button heights
  static const double buttonHeight = 50.0;
  static const double buttonHeightSM = 40.0;
}

// ============================================
// APP SHADOWS
// ============================================

class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> cardShadowLarge = [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> glowPurple = [
    BoxShadow(
      color: AppColors.shadowPurple,
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> glowGold = [
    BoxShadow(
      color: AppColors.shadowGold,
      blurRadius: 15,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: AppColors.primaryPurple.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}

// ============================================
// GRADIENT HELPERS
// ============================================

class AppGradients {
  static LinearGradient primaryPurple = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientPrimaryPurple,
  );
  static LinearGradient secondaryPurple = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientPrimary,
  );

  static LinearGradient feed = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientEasy,
  );

  static LinearGradient play = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientMedium,
  );

  static LinearGradient train = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientMedium,
  );

  static RadialGradient arBackground = const RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: AppColors.gradientARBackground,
  );

  static LinearGradient getQuestGradient(String type) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.getQuestGradient(type),
    );
  }
}

// ============================================
// ANIMATION DURATIONS
// ============================================

class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
