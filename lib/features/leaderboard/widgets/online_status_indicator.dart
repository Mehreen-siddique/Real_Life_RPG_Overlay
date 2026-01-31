import 'package:flutter/material.dart';

/// Online Status Indicator Widget
/// Instagram-style online indicator with green dot
class OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;
  final double strokeWidth;

  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.grey.shade400,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: strokeWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? Colors.green : Colors.grey).withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Active Status Widget
/// Shows "Active now" or time since last seen
class ActiveStatusWidget extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSeen;
  final TextStyle? style;

  const ActiveStatusWidget({
    super.key,
    required this.isOnline,
    this.lastSeen,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 11,
      color: isOnline ? Colors.green : Colors.grey.shade600,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOnline) ...[
          OnlineStatusIndicator(isOnline: true, size: 8),
          const SizedBox(width: 4),
          Text('Active now', style: style ?? defaultStyle),
        ] else ...[
          Text(_getLastSeenText(), style: style ?? defaultStyle),
        ],
      ],
    );
  }

  String _getLastSeenText() {
    if (lastSeen == null) return 'Unknown';
    
    final now = DateTime.now();
    final diff = now.difference(lastSeen!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays}d ago';
  }
}

/// Streak Widget
/// Shows streak with fire icon and visual effects based on streak tier
class StreakWidget extends StatelessWidget {
  final int streak;
  final bool showLabel;
  final double iconSize;
  final bool showPulse;

  const StreakWidget({
    super.key,
    required this.streak,
    this.showLabel = true,
    this.iconSize = 16,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    final tier = _getStreakTier();
    final color = _getStreakColor(tier);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fire icon with animation
        AnimatedBuilder(
          animation: showPulse ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return Transform.scale(
              scale: showPulse ? 1.0 + (0.1 * _pulseAnimation.value) : 1.0,
              child: Icon(
                Icons.local_fire_department,
                size: iconSize,
                color: color,
              ),
            );
          },
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: iconSize * 0.8,
              fontWeight: FontWeight.w600,
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

  Animation<double> get _pulseAnimation {
    return AlwaysStoppedAnimation(1.0); // Placeholder for animation
  }
}

/// Streak tier enum
enum StreakTier {
  normal,      // 0-6 days
  powered,     // 7-13 days
  glowing,     // 14-20 days
  epic,        // 21-29 days
  legendary,  // 30+ days
}
