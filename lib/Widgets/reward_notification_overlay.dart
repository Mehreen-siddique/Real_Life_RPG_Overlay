import 'package:flutter/material.dart';
import 'dart:async';
import '../Services/AnimatedProgress/animated_progress_service.dart';

/// 🎮 Game-like reward notification overlay
/// Shows floating +XP and +Coins animations when rewards are earned
class RewardNotificationOverlay extends StatefulWidget {
  final Widget child;

  const RewardNotificationOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<RewardNotificationOverlay> createState() => _RewardNotificationOverlayState();
}

class _RewardNotificationOverlayState extends State<RewardNotificationOverlay>
    with TickerProviderStateMixin {
  final List<RewardAnimation> _activeRewards = [];
  final AnimatedProgressService _progressService = AnimatedProgressService.instance;
  StreamSubscription<ProgressUpdate>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _listenToProgressUpdates();
  }

  void _listenToProgressUpdates() {
    _progressSubscription = _progressService.progressStream.listen((update) {
      if (mounted) {
        _showRewardAnimation(update);
      }
    });
  }

  void _showRewardAnimation(ProgressUpdate update) {
    final controller = AnimationController(
      duration: update.duration,
      vsync: this,
    );

    final animation = RewardAnimation(
      update: update,
      controller: controller,
      onComplete: () {
        setState(() {
          _activeRewards.removeWhere((a) => a.controller == controller);
        });
        controller.dispose();
      },
    );

    setState(() {
      _activeRewards.add(animation);
    });

    controller.forward();

    // Auto-remove after animation completes
    Future.delayed(update.duration + const Duration(milliseconds: 500), () {
      if (mounted && _activeRewards.contains(animation)) {
        animation.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    for (final reward in _activeRewards) {
      reward.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._activeRewards.map((reward) => _buildRewardWidget(reward)),
      ],
    );
  }

  Widget _buildRewardWidget(RewardAnimation reward) {
    final update = reward.update;

    // Different positions for different reward types
    final startPosition = _getStartPosition(update.type);

    return AnimatedBuilder(
      animation: reward.controller,
      builder: (context, child) {
        final progress = reward.controller.value;

        // Floating upward animation
        final yOffset = -100 * progress; // Move up 100 pixels
        final opacity = 1.0 - (progress * 0.8); // Fade out slowly
        final scale = 1.0 + (0.3 * (1 - progress)); // Slight scale pulse

        return Positioned(
          left: startPosition.dx,
          top: startPosition.dy + yOffset,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: _buildRewardCard(update),
            ),
          ),
        );
      },
    );
  }

  Offset _getStartPosition(ProgressType type) {
    final screenSize = MediaQuery.of(context).size;
    final random = DateTime.now().millisecond;

    // Position based on reward type with some randomness
    double x, y;
    switch (type) {
      case ProgressType.xp:
        x = screenSize.width * 0.15 + (random % 50);
        y = screenSize.height * 0.25;
        break;
      case ProgressType.coins:
        x = screenSize.width * 0.55 + (random % 50);
        y = screenSize.height * 0.25;
        break;
      case ProgressType.level:
        x = screenSize.width * 0.2;
        y = screenSize.height * 0.2;
        break;
    }

    return Offset(x, y);
  }

  Widget _buildRewardCard(ProgressUpdate update) {
    final isLevelUp = update.type == ProgressType.level;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            update.color.withOpacity(0.9),
            update.color.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: update.color.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          _buildAnimatedIcon(update),
          const SizedBox(width: 10),
          // Reward text
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                update.message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLevelUp ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (isLevelUp) ...[
                const SizedBox(height: 4),
                Text(
                  'New Level ${update.newLevel}!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(ProgressUpdate update) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159, // Full rotation
          child: Icon(
            update.icon,
            color: Colors.white,
            size: update.type == ProgressType.level ? 40 : 32,
          ),
        );
      },
    );
  }
}

/// Data class for active reward animations
class RewardAnimation {
  final ProgressUpdate update;
  final AnimationController controller;
  final VoidCallback onComplete;

  RewardAnimation({
    required this.update,
    required this.controller,
    required this.onComplete,
  });
}

/// 🎮 Floating stat change indicator
/// Shows in the header when stats change
class FloatingStatChange extends StatelessWidget {
  final int value;
  final Color color;
  final IconData icon;
  final String label;

  const FloatingStatChange({
    Key? key,
    required this.value,
    required this.color,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: 1.0 - value,
          child: Transform.translate(
            offset: Offset(0, -30 * value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '+$value',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
