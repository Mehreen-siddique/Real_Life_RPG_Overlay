import 'package:flutter/material.dart';
import '../models/leaderboard_user.dart';
import 'online_status_indicator.dart';
import 'streak_widget.dart' as streak;

/// Find Member Card Widget
/// Card displayed in the social tab for finding users to invite
class FindMemberCard extends StatelessWidget {
  final LeaderboardUser user;
  final VoidCallback? onInvite;
  final VoidCallback? onViewProfile;

  const FindMemberCard({
    super.key,
    required this.user,
    this.onInvite,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E2E) : null;
    final textPrimary = isDark ? Colors.white : null;
    final textSecondary = isDark ? const Color(0xFF9AA0B4) : Colors.grey.shade600;
    return Card(
      margin: const EdgeInsets.only(right: 12),
      color: surface,
      child: SizedBox(
        width: 160,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section - Avatar and online status
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getGradientColors(),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getClassIcon(),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: OnlineStatusIndicator(isOnline: user.isOnline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Username
                  Text(
                    user.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  
                  // Level and class
                  Text(
                    'Lvl ${user.level} ${_getClassName()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Bottom section - Status and action
              Column(
                children: [
                  // Online/Offline status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: user.isOnline 
                          ? Colors.green.withValues(alpha: 0.1) 
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: user.isOnline ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 10,
                            color: user.isOnline ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Streak
                  streak.StreakWidget(streak: user.streak, showLabel: true, iconSize: 14),
                  
                  const SizedBox(height: 8),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onInvite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2CBF),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Invite',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getClassIcon() {
    switch (user.characterClass.toLowerCase()) {
      case 'mage': return '🔮';
      case 'healer': return '💚';
      case 'rogue': return '🗡️';
      default: return '⚔️';
    }
  }

  String _getClassName() {
    switch (user.characterClass.toLowerCase()) {
      case 'mage': return 'Mage';
      case 'healer': return 'Healer';
      case 'rogue': return 'Rogue';
      default: return 'Warrior';
    }
  }

  List<Color> _getGradientColors() {
    switch (user.characterClass.toLowerCase()) {
      case 'mage': return [const Color(0xFF7B1FA2), const Color(0xFF4A148C)];
      case 'healer': return [const Color(0xFF43A047), const Color(0xFF1B5E20)];
      case 'rogue': return [const Color(0xFFFFA000), const Color(0xFFFF6F00)];
      default: return [const Color(0xFFE53935), const Color(0xFFB71C1C)];
    }
  }
}
