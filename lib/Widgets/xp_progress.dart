import 'package:flutter/material.dart';

import '../utils/constants.dart';

class XPProgressBar extends StatelessWidget {
  final int level;
  final int currentXP;
  final int xpForNextLevel;

  const XPProgressBar({
    Key? key,
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkCard : AppColors.lightBackground;
    final surfaceAlt = isDark ? AppColors.darkCardAlt : AppColors.leaderboardSilver;
    final textPrimary = isDark ? AppColors.textWhite : AppColors.textDark;
    final textSecondary = isDark ? AppColors.textLavender : AppColors.textGray;
    // Progress calculate karo (safety ke saath)
    double progress = xpForNextLevel > 0 ? currentXP / xpForNextLevel : 0.0;
    progress = progress.clamp(0.0, 1.0); // 0% se 100% ke beech mein rakho

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        gradient: isDark
            ? LinearGradient(
                colors: [
                  AppColors.darkCard.withOpacity(0.95),
                  AppColors.darkCardAlt.withOpacity(0.95),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.lightBackground.withOpacity(0.3),
                  AppColors.accentBlue.withOpacity(0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(isDark ? 0.6 : 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.25),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Level and XP text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.highlightGold,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.highlightGold.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'LEVEL $level',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.stars,
                    color: AppColors.highlightGold,
                    size: 24,
                  ),
                ],
              ),
              Text(
                '$currentXP / $xpForNextLevel XP',
                style: AppTextStyles.body.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    border: Border.all(
                      color: AppColors.highlightGold.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,  // ← Yahaan progress use ho raha hai
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.highlightGold, AppColors.highlightGold],
                      ),
                      border: Border.all(
                        color: AppColors.highlightGold.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.highlightGold.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Progress percentage
          Text(
            '${(progress * 100).toInt()}% to next level',
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
