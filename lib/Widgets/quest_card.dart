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
    // Calculate progress for each target type
    final targetSteps = quest.targetSteps ?? 0;
    final targetDistKm = quest.targetDistanceKm ?? 0.0;
    final targetDurationMin = quest.targetDurationMinutes ?? 0;

    final currentSteps = quest.currentSteps;
    final currentDistKm = quest.currentDistanceKm;
    final currentDurationMin = quest.currentDurationMinutes;

    // Calculate overall progress ratio (average of all active targets)
    List<double> ratios = [];
    if (targetSteps > 0) ratios.add((currentSteps / targetSteps).clamp(0.0, 1.0));
    if (targetDistKm > 0) ratios.add((currentDistKm / targetDistKm).clamp(0.0, 1.0));
    if (targetDurationMin > 0) ratios.add((currentDurationMin / targetDurationMin).clamp(0.0, 1.0));
    final progress = ratios.isEmpty ? 0.0 : (ratios.reduce((a, b) => a + b) / ratios.length).clamp(0.0, 1.0);

    // Build per-metric progress rows
    List<Widget> progressRows = [];

    if (targetSteps > 0) {
      final ratio = (currentSteps / targetSteps).clamp(0.0, 1.0);
      progressRows.add(_metricRow(Icons.directions_walk, '$currentSteps/$targetSteps steps', ratio));
    }
    if (targetDistKm > 0) {
      final ratio = (currentDistKm / targetDistKm).clamp(0.0, 1.0);
      final icon = quest.activityType == QuestActivityType.cycling ? Icons.pedal_bike : Icons.map;
      progressRows.add(_metricRow(icon, '${currentDistKm.toStringAsFixed(1)}/${targetDistKm.toStringAsFixed(1)} km', ratio));
    }
    if (targetDurationMin > 0) {
      if (quest.type == QuestType.sleep) {
        final sleepH = (currentDurationMin / 60).toStringAsFixed(1);
        final targetH = (targetDurationMin / 60).toStringAsFixed(1);
        final ratio = (currentDurationMin / targetDurationMin).clamp(0.0, 1.0);
        progressRows.add(_metricRow(Icons.bedtime, '$sleepH/$targetH hrs', ratio));
      } else {
        final ratio = (currentDurationMin / targetDurationMin).clamp(0.0, 1.0);
        progressRows.add(_metricRow(Icons.timer, '$currentDurationMin/$targetDurationMin min', ratio));
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        gradient: LinearGradient(
          colors: quest.difficultyGradient,
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:quest.difficultyGradient,
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
                      if (progressRows.isNotEmpty && !quest.isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...progressRows,
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Overall: ${(progress * 100).toInt()}%',
                                    style: TextStyle(
                                      color: AppColors.lightBackground.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: AppColors.lightBackground.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.lightBackground,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

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
                        color: Colors.greenAccent,
                        size: 28,
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

  Widget _metricRow(IconData icon, String label, double ratio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightBackground, size: 12),
          const SizedBox(width: 4),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  color: AppColors.lightBackground,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
          ),
          Text('${(ratio * 100).toInt()}%',
              style: TextStyle(
                color: AppColors.lightBackground.withOpacity(0.8),
                fontSize: 10,
              )),
        ],
      ),
    );
  }
}
