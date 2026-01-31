import 'package:flutter/material.dart';

/// Streak Widget with Snapchat-style fire icon
/// Shows streak count with visual effects based on streak tier
class StreakWidget extends StatelessWidget {
  final int streak;
  final bool showLabel;
  final double iconSize;
  final bool showGlow;
  final bool showPulse;

  const StreakWidget({
    super.key,
    required this.streak,
    this.showLabel = true,
    this.iconSize = 20,
    this.showGlow = true,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    final tier = _getStreakTier();
    final color = _getStreakColor(tier);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fire icon with optional glow
        Container(
          decoration: showGlow && streak >= 7
              ? BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: Icon(
            Icons.local_fire_department,
            size: iconSize,
            color: color,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: iconSize * 0.85,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  StreakTier _getStreakTier() {
    if (streak >= 30) return StreakTier.legendary;
    if (streak >= 21) return StreakTier.epic;
    if (streak >= 14) return StreakTier.glowing;
    if (streak >= 7) return StreakTier.powered;
    return StreakTier.normal;
  }

  Color _getStreakColor(StreakTier tier) {
    switch (tier) {
      case StreakTier.legendary:
        return const Color(0xFFFFD700); // Gold
      case StreakTier.epic:
        return const Color(0xFF9C27B0); // Purple
      case StreakTier.glowing:
        return const Color(0xFFFF5722); // Deep Orange
      case StreakTier.powered:
        return const Color(0xFFFF9800); // Orange
      case StreakTier.normal:
        return Colors.orange;
    }
  }
}

/// Streak tier enum for visual effects
enum StreakTier {
  normal,      // 0-6 days
  powered,     // 7-13 days
  glowing,     // 14-20 days
  epic,        // 21-29 days
  legendary,  // 30+ days
}

/// Streak Badge Widget
/// Shows a badge with streak tier
class StreakBadge extends StatelessWidget {
  final int streak;
  final double size;

  const StreakBadge({
    super.key,
    required this.streak,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final tier = _getStreakTier();
    final color = _getStreakColor(tier);
    final icon = _getTierIcon(tier);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }

  StreakTier _getStreakTier() {
    if (streak >= 30) return StreakTier.legendary;
    if (streak >= 21) return StreakTier.epic;
    if (streak >= 14) return StreakTier.glowing;
    if (streak >= 7) return StreakTier.powered;
    return StreakTier.normal;
  }

  Color _getStreakColor(StreakTier tier) {
    switch (tier) {
      case StreakTier.legendary: return const Color(0xFFFFD700);
      case StreakTier.epic: return const Color(0xFF9C27B0);
      case StreakTier.glowing: return const Color(0xFFFF5722);
      case StreakTier.powered: return const Color(0xFFFF9800);
      case StreakTier.normal: return Colors.orange;
    }
  }

  String _getTierIcon(StreakTier tier) {
    switch (tier) {
      case StreakTier.legendary: return '🏆';
      case StreakTier.epic: return '👑';
      case StreakTier.glowing: return '🔥';
      case StreakTier.powered: return '⚡';
      case StreakTier.normal: return '💪';
    }
  }
}
