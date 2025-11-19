import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/utils/constants.dart';


class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onTap;

  const QuestCard({
    Key? key,
    required this.quest,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        gradient: LinearGradient(
          colors: quest.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors:quest.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,),
                    borderRadius: BorderRadius.circular(12),

                  ),
                  child: Icon(
                    quest.icon,
                    color: AppColors.lightBackground,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Quest info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: AppTextStyles.subheading.copyWith(
                          fontSize: 16,
                          color: AppColors.textWhite,
                          decoration: quest.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                          color: AppColors.textWhite
                        ),
                      ),
                    ],
                  ),
                ),

                // Reward badge
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${quest.xpReward} XP',
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (quest.isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.lightBackground,
                        size: 24,
                      )
                    else
                      const Icon(
                        Icons.radio_button_unchecked,
                        color: AppColors.lightBackground,
                        size: 24,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
