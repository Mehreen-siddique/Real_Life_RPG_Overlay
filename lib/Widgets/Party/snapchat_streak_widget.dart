import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════════════════════
/// SNAPCHAT-STYLE STREAK WIDGET
/// ═══════════════════════════════════════════════════════════════════════════════
/// 
/// This widget replicates Snapchat's streak display system with:
/// • Bold number + 🔥 emoji side by side
/// • Animated fire effects for different streak levels
/// • Color changes based on streak duration
/// • Broken streak indicator for inactive users
///
/// Author: Final Year Project Student
/// Course: CS/SE Final Year Project 2024-2025

class SnapchatStreakWidget extends StatelessWidget {
  /// Number of consecutive active days
  final int streakDays;
  
  /// Size variant: small for lists, large for profile
  final StreakSize size;
  
  /// Whether this streak is broken (user missed a day)
  final bool isBroken;

  const SnapchatStreakWidget({
    Key? key,
    required this.streakDays,
    this.size = StreakSize.medium,
    this.isBroken = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ═════════════════════════════════════════════════════════════════════════
    // STREAK LEVEL DETERMINATION
    // Based on Snapchat's streak tiers: 1-6, 7-29, 30+ days
    // ═════════════════════════════════════════════════════════════════════════
    final StreakLevel level = _getStreakLevel(streakDays);
    
    // Get styling based on level
    final colors = _getColorsForLevel(level);
    final shouldAnimate = !isBroken && level != StreakLevel.normal;
    
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: isBroken ? Colors.grey.shade100 : colors.backgroundColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: isBroken ? Colors.grey.shade300 : colors.backgroundColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // STREAK NUMBER - Bold and prominent like Snapchat
          Text(
            '$streakDays',
            style: TextStyle(
              fontSize: _getNumberFontSize(),
              fontWeight: FontWeight.w900, // Extra bold
              color: isBroken ? Colors.grey.shade500 : colors.textColor,
              letterSpacing: -0.5, // Tight letter spacing for modern look
            ),
          ),
          
          const SizedBox(width: 2),
          
          // FIRE ICON with animation
          _buildFireIcon(level, colors, shouldAnimate),
          
          // CROWN for 30+ day streaks (Snapchat-style)
          if (level == StreakLevel.legendary && !isBroken) ...[
            const SizedBox(width: 2),
            _buildCrown(),
          ],
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// STREAK LEVEL CLASSIFICATION
  /// ═══════════════════════════════════════════════════════════════════════════
  StreakLevel _getStreakLevel(int days) {
    if (isBroken) return StreakLevel.broken;
    if (days >= 30) return StreakLevel.legendary;
    if (days >= 7) return StreakLevel.advanced;
    return StreakLevel.normal;
  }

  /// Get visual properties based on streak level
  StreakColors _getColorsForLevel(StreakLevel level) {
    switch (level) {
      case StreakLevel.broken:
        return StreakColors(
          backgroundColor: Colors.grey,
          textColor: Colors.grey.shade500,
          fireColor: Colors.grey.shade400,
        );
      case StreakLevel.normal:
        // Days 1-6: Normal grey/orange fire
        return StreakColors(
          backgroundColor: Colors.orange.shade200,
          textColor: Colors.orange.shade800,
          fireColor: Colors.orange.shade600,
        );
      case StreakLevel.advanced:
        // Days 7-29: Glowing orange fire
        return StreakColors(
          backgroundColor: Colors.deepOrange.shade200,
          textColor: Colors.deepOrange.shade800,
          fireColor: Colors.deepOrange.shade600,
        );
      case StreakLevel.legendary:
        // Days 30+: Red/gold fire with crown
        return StreakColors(
          backgroundColor: Colors.red.shade200,
          textColor: Colors.red.shade800,
          fireColor: Colors.red.shade600,
        );
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// FIRE ICON BUILDER with animations
  /// ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFireIcon(StreakLevel level, StreakColors colors, bool shouldAnimate) {
    final fireWidget = Icon(
      Icons.local_fire_department,
      size: _getFireIconSize(),
      color: isBroken ? Colors.grey.shade400 : colors.fireColor,
    );

    if (!shouldAnimate) {
      // No animation for broken or normal streaks
      return fireWidget;
    }

    // Animated fire for 7+ day streaks
    return AnimatedFire(
      level: level,
      child: fireWidget,
    );
  }

  /// Crown widget for 30+ day streaks
  Widget _buildCrown() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.amber.shade400, width: 1),
      ),
      child: Icon(
        Icons.emoji_events,
        size: _getCrownIconSize(),
        color: Colors.amber.shade700,
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// SIZING METHODS based on widget size variant
  /// ═══════════════════════════════════════════════════════════════════════════
  double _getNumberFontSize() {
    switch (size) {
      case StreakSize.small:
        return 12;
      case StreakSize.medium:
        return 14;
      case StreakSize.large:
        return 18;
    }
  }

  double _getFireIconSize() {
    switch (size) {
      case StreakSize.small:
        return 14;
      case StreakSize.medium:
        return 16;
      case StreakSize.large:
        return 22;
    }
  }

  double _getCrownIconSize() {
    switch (size) {
      case StreakSize.small:
        return 10;
      case StreakSize.medium:
        return 12;
      case StreakSize.large:
        return 16;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case StreakSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
      case StreakSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case StreakSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case StreakSize.small:
        return 8;
      case StreakSize.medium:
        return 10;
      case StreakSize.large:
        return 12;
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// ANIMATED FIRE WIDGET - Pulsing/glowing effect for high streaks
/// ═══════════════════════════════════════════════════════════════════════════════
class AnimatedFire extends StatefulWidget {
  final StreakLevel level;
  final Widget child;

  const AnimatedFire({
    Key? key,
    required this.level,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedFire> createState() => _AnimatedFireState();
}

class _AnimatedFireState extends State<AnimatedFire>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller for fire effects
    _controller = AnimationController(
      duration: widget.level == StreakLevel.legendary 
          ? const Duration(milliseconds: 1500) // Slower pulse for legendary
          : const Duration(milliseconds: 2000), // Faster for advanced
      vsync: this,
    )..repeat(reverse: true);

    // Pulsing scale animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: widget.level == StreakLevel.legendary ? 1.15 : 1.08,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Glow intensity animation
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: widget.level == StreakLevel.legendary ? 0.8 : 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Outer glow effect
              BoxShadow(
                color: widget.level == StreakLevel.legendary
                    ? Colors.red.withOpacity(_glowAnimation.value)
                    : Colors.orange.withOpacity(_glowAnimation.value),
                blurRadius: _pulseAnimation.value * 10,
                spreadRadius: _pulseAnimation.value * 2,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// STREAK DISPLAY WITH BREAK INDICATOR
/// ═══════════════════════════════════════════════════════════════════════════════
/// Extended widget that shows streak status with "BROKEN" text when applicable
class StreakWithStatus extends StatelessWidget {
  final int streakDays;
  final bool isBroken;
  final StreakSize size;

  const StreakWithStatus({
    Key? key,
    required this.streakDays,
    this.isBroken = false,
    this.size = StreakSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SnapchatStreakWidget(
          streakDays: streakDays,
          isBroken: isBroken,
          size: size,
        ),
        if (isBroken)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'BROKEN',
              style: TextStyle(
                fontSize: size == StreakSize.small ? 8 : 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// SUPPORTING ENUMS AND CLASSES
/// ═══════════════════════════════════════════════════════════════════════════════

/// Streak level tiers matching Snapchat's system
enum StreakLevel {
  broken,     // Grey, no animation, "BROKEN" text
  normal,     // 1-6 days: Grey/orange fire, no animation
  advanced,   // 7-29 days: Orange fire, glowing animation
  legendary,  // 30+ days: Red/gold fire, pulsing animation, crown
}

/// Size variants for different UI contexts
enum StreakSize {
  small,   // For compact lists
  medium,  // Default for most uses
  large,   // For profile headers
}

/// Color scheme for streak visual theming
class StreakColors {
  final Color backgroundColor;
  final Color textColor;
  final Color fireColor;

  StreakColors({
    required this.backgroundColor,
    required this.textColor,
    required this.fireColor,
  });
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// STREAK FLAME PROGRESS INDICATOR
/// ═══════════════════════════════════════════════════════════════════════════════
/// Visual bar showing how close user is to next streak milestone
class StreakProgressBar extends StatelessWidget {
  final int currentStreak;
  final int nextMilestone;

  const StreakProgressBar({
    Key? key,
    required this.currentStreak,
    required this.nextMilestone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (currentStreak / nextMilestone).clamp(0.0, 1.0);
    
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade400,
                Colors.red.shade500,
              ],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
