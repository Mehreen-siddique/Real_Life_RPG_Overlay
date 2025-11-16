import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart' show AppColors, AppSizes, AppTextStyles;

class XPProgressBar  extends StatelessWidget {

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
    double progress = currentXP / xpForNextLevel;
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryPurple.withOpacity(0.3),
              AppColors.electricBlue.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: AppColors.primaryPurple.withOpacity(0.5),
            width: 1,
          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldYellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldYellow.withOpacity(0.3),
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
                    const Icon(
                      Icons.stars,
                      color: AppColors.goldYellow,
                      size: 24,
                    ),
                  ],
                ),
                Text(
                  '$currentXP / $xpForNextLevel XP',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textWhite,
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
                    color: AppColors.charcoal,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.goldYellow,
                            AppColors.electricBlue,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldYellow.withOpacity(0.5),
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
              style: AppTextStyles.body.copyWith(fontSize: 12),
            ),
          ],
        ),
    );
  }
}
