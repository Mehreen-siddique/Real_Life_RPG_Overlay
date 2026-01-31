import 'package:flutter/material.dart';

/// Quest Progress Widget
/// Shows progress bar with steps and percentage for party quests
class QuestProgressWidget extends StatelessWidget {
  final double progress;
  final int currentSteps;
  final int targetSteps;
  final String questTitle;
  final bool showDetails;

  const QuestProgressWidget({
    super.key,
    required this.progress,
    required this.currentSteps,
    required this.targetSteps,
    this.questTitle = 'Quest Progress',
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).clamp(0, 100).toStringAsFixed(1);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final textPrimary = isDark ? Colors.white : null;
    final textSecondary = isDark ? const Color(0xFF9AA0B4) : Colors.grey.shade600;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2CBF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.track_changes,
                  color: Color(0xFF7B2CBF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  questTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),
          
          if (showDetails) ...[
            const SizedBox(height: 12),
            // Details row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentSteps steps',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                Text(
                  'of $targetSteps',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return const Color(0xFF7B2CBF);
    if (progress >= 0.4) return Colors.blue;
    return Colors.orange;
  }
}

/// Party Quest Battle Progress Widget
/// Shows individual member's contribution to party quest
class PartyQuestBattleProgress extends StatelessWidget {
  final String username;
  final String characterClass;
  final double progress;
  final int currentSteps;
  final int targetSteps;
  final bool isCurrentUser;
  final int? rank;

  const PartyQuestBattleProgress({
    super.key,
    required this.username,
    required this.characterClass,
    required this.progress,
    required this.currentSteps,
    required this.targetSteps,
    this.isCurrentUser = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade50;
    final border = isDark ? Colors.white24 : const Color(0xFF7B2CBF).withValues(alpha: 0.3);
    final textSecondary = isDark ? const Color(0xFF9AA0B4) : Colors.grey.shade600;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF7B2CBF).withValues(alpha: 0.15)
            : surface,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: border)
            : null,
      ),
      child: Row(
        children: [
          // Rank or avatar
          if (rank != null)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getRankColor(rank!),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getClassGradient(),
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getClassIcon(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          
          const SizedBox(width: 12),
          
          // Username and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                    color: isCurrentUser ? const Color(0xFF7B2CBF) : null,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCurrentUser ? const Color(0xFF7B2CBF) : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Steps count
          Text(
            '$currentSteps/$targetSteps',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCurrentUser ? const Color(0xFF7B2CBF) : textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // Gold
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFCD7F32); // Bronze
      default: return Colors.grey.shade500;
    }
  }

  String _getClassIcon() {
    switch (characterClass.toLowerCase()) {
      case 'mage': return '🔮';
      case 'healer': return '💚';
      case 'rogue': return '🗡️';
      default: return '⚔️';
    }
  }

  List<Color> _getClassGradient() {
    switch (characterClass.toLowerCase()) {
      case 'mage': return [const Color(0xFF7B1FA2), const Color(0xFF4A148C)];
      case 'healer': return [const Color(0xFF43A047), const Color(0xFF1B5E20)];
      case 'rogue': return [const Color(0xFFFFA000), const Color(0xFFFF6F00)];
      default: return [const Color(0xFFE53935), const Color(0xFFB71C1C)];
    }
  }
}
