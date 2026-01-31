import 'package:flutter/material.dart';
import '../models/leaderboard_user.dart';

/// Superlative Awards Row Widget
/// Shows monthly award badges for top performers
class SuperlativeAwardsRow extends StatelessWidget {
  final Map<SuperlativeType, LeaderboardUser> winners;
  final double cardWidth;

  const SuperlativeAwardsRow({
    super.key,
    required this.winners,
    this.cardWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (winners.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: winners.entries.map((entry) {
          final user = entry.value;
          return _buildAwardCard(entry.key, user);
        }).toList(),
      ),
    );
  }

  Widget _buildAwardCard(SuperlativeType type, LeaderboardUser user) {
    final award = _getAwardData(type);
    
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            award.color.withValues(alpha: 0.1),
            award.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: award.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Award icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: award.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(award.icon, color: award.color, size: 24),
          ),
          const SizedBox(height: 8),
          
          // Award title
          Text(
            award.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: award.color,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // Winner name
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Winning value
          Text(
            award.getValue(user),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  AwardData _getAwardData(SuperlativeType type) {
    switch (type) {
      case SuperlativeType.longestStreak:
        return AwardData(
          title: 'Streak Master',
          icon: Icons.local_fire_department,
          color: Colors.orange,
          valueExtractor: (user) => '${user.streak} days',
        );
      case SuperlativeType.mostQuests:
        return AwardData(
          title: 'Quest King',
          icon: Icons.check_circle,
          color: Colors.blue,
          valueExtractor: (user) => '${user.totalQuestsCompleted} quests',
        );
      case SuperlativeType.mostCoins:
        return AwardData(
          title: 'Coin Collector',
          icon: Icons.monetization_on,
          color: Colors.amber,
          valueExtractor: (user) => '${user.coins} coins',
        );
      case SuperlativeType.mostSteps:
        return AwardData(
          title: 'Step Champion',
          icon: Icons.directions_walk,
          color: Colors.green,
          valueExtractor: (user) => '${user.totalSteps} steps',
        );
      case SuperlativeType.mostActive:
        return AwardData(
          title: 'Most Active',
          icon: Icons.access_time,
          color: Colors.purple,
          valueExtractor: (user) => '${user.daysActive} days',
        );
    }
  }
}

/// Award data holder
class AwardData {
  final String title;
  final IconData icon;
  final Color color;
  final String Function(LeaderboardUser) valueExtractor;

  AwardData({
    required this.title,
    required this.icon,
    required this.color,
    required this.valueExtractor,
  });

  String getValue(LeaderboardUser user) => valueExtractor(user);
}

/// Superlative type enum
enum SuperlativeType {
  longestStreak,
  mostQuests,
  mostCoins,
  mostSteps,
  mostActive,
}

/// Superlative Badge Model
class SuperlativeBadge {
  final SuperlativeType type;
  final String winnerId;
  final String winnerUsername;
  final String winningValue;
  final DateTime month;

  SuperlativeBadge({
    required this.type,
    required this.winnerId,
    required this.winnerUsername,
    required this.winningValue,
    required this.month,
  });
}
