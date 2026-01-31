import 'package:flutter/foundation.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Services/Health/health_connect_service.dart';
import 'package:real_life_rpg/Services/QuestFirestore/questfirestore.dart';
import 'package:real_life_rpg/Services/DataServices/dataServices.dart';

class QuestEvalResult {
  final Quest quest;
  final int incrementalSteps;
  final double incrementalDistance;
  final double incrementalCalories;
  final int incrementalActiveMinutes;
  final double incrementalSleepHours;
  final double progressRatio;
  final bool justCompleted;

  QuestEvalResult({
    required this.quest,
    required this.incrementalSteps,
    required this.incrementalDistance,
    required this.incrementalCalories,
    required this.incrementalActiveMinutes,
    required this.incrementalSleepHours,
    required this.progressRatio,
    required this.justCompleted,
  });
}

/// QuestEngine evaluates active quests against real health data
/// fetched from Google Fit / Health Connect via HealthConnectService.
class QuestEngine {
  static final QuestEngine _instance = QuestEngine._internal();
  factory QuestEngine() => _instance;
  QuestEngine._internal();

  final HealthConnectService _healthService = HealthConnectService();
  final QuestServiceFirestore _questService = QuestServiceFirestore();

  /// Track completed quests this session to avoid duplicate rewards
  final Set<String> _completedThisSession = {};

  /// Evaluate all active quests against current health data.
  /// Returns list of evaluation results.
  Future<List<QuestEvalResult>> evaluateQuests(List<Quest> quests) async {
    final results = <QuestEvalResult>[];

    debugPrint('[QuestEngine] ========== EVALUATING ${quests.length} QUESTS ==========');

    if (quests.isEmpty) {
      debugPrint('[QuestEngine] No quests to evaluate');
      return results;
    }

    // Fetch current health data
    HealthDataSummary current;
    try {
      current = await _healthService.getAllActivityData();
    } catch (e) {
      debugPrint('[QuestEngine] ERROR fetching health data: $e');
      return results;
    }

    debugPrint('[QuestEngine] Current: steps=${current.steps}, '
        'dist=${current.distanceKm.toStringAsFixed(2)}km, '
        'cal=${current.calories.toStringAsFixed(0)}, '
        'sleep=${current.sleepHours.toStringAsFixed(1)}h, '
        'active=${current.activeMinutes}min');

    for (final quest in quests) {
      if (quest.isCompleted || quest.isDeleted) continue;
      if (quest.id.isEmpty) continue;

      debugPrint('[QuestEngine] --- Quest: "${quest.title}" (type=${quest.type}, '
          'activity=${quest.activityType}) ---');

      // ── BASELINE SUBTRACTION: progress = current - baseline ──
      final incSteps = (current.steps - quest.baselineSteps).clamp(0, 999999999);
      final incDist = (current.distanceKm - quest.baselineDistanceKm).clamp(0.0, 999999.9);
      final incCal = (current.calories - quest.baselineCalories).clamp(0.0, 999999.9);
      final incActive = (current.activeMinutes - quest.baselineActiveMinutes).clamp(0, 999999999);
      final incSleep = (current.sleepHours - quest.baselineSleepHours).clamp(0.0, 999.9);

      debugPrint('[QuestEngine]   baseline: steps=${quest.baselineSteps}, dist=${quest.baselineDistanceKm}, '
          'cal=${quest.baselineCalories}, active=${quest.baselineActiveMinutes}, sleep=${quest.baselineSleepHours}');
      debugPrint('[QuestEngine]   INCREMENTAL: steps=$incSteps, dist=${incDist.toStringAsFixed(2)}, '
          'cal=${incCal.toStringAsFixed(0)}, active=$incActive, sleep=${incSleep.toStringAsFixed(1)}');

      // ── PROGRESS RATIO per target ──
      double stepsRatio = 0.0;
      double distRatio = 0.0;
      double durRatio = 0.0;
      int targetsSet = 0;

      if (quest.targetSteps != null && quest.targetSteps! > 0) {
        stepsRatio = (incSteps / quest.targetSteps!).clamp(0.0, 1.0);
        targetsSet++;
      }
      if (quest.targetDistanceKm != null && quest.targetDistanceKm! > 0) {
        distRatio = (incDist / quest.targetDistanceKm!).clamp(0.0, 1.0);
        targetsSet++;
      }
      if (quest.targetDurationMinutes != null && quest.targetDurationMinutes! > 0) {
        if (quest.type == QuestType.sleep) {
          durRatio = ((incSleep * 60) / quest.targetDurationMinutes!).clamp(0.0, 1.0);
        } else {
          durRatio = (incActive / quest.targetDurationMinutes!).clamp(0.0, 1.0);
        }
        targetsSet++;
      }

      double progressRatio = 0.0;
      if (targetsSet > 0) {
        progressRatio = ((stepsRatio + distRatio + durRatio) / targetsSet).clamp(0.0, 1.0);
      }

      // Also store incremental values on quest object for UI
      quest.currentSteps = incSteps;
      quest.currentDistanceKm = incDist;
      quest.currentDurationMinutes = quest.type == QuestType.sleep
          ? (incSleep * 60).toInt()
          : incActive;

      // ── COMPLETION CHECK: ALL set targets must be reached ──
      bool justCompleted = false;
      if (!quest.isCompleted && targetsSet > 0) {
        final stepsDone = quest.targetSteps == null || quest.targetSteps! <= 0 || incSteps >= quest.targetSteps!;
        final distDone = quest.targetDistanceKm == null || quest.targetDistanceKm! <= 0 || incDist >= quest.targetDistanceKm!;
        bool durDone = true;
        if (quest.targetDurationMinutes != null && quest.targetDurationMinutes! > 0) {
          if (quest.type == QuestType.sleep) {
            durDone = (incSleep * 60) >= quest.targetDurationMinutes!;
          } else {
            durDone = incActive >= quest.targetDurationMinutes!;
          }
        }
        justCompleted = stepsDone && distDone && durDone;
      }

      debugPrint('[QuestEngine]   progress=${(progressRatio * 100).toInt()}%, completed=$justCompleted');

      results.add(QuestEvalResult(
        quest: quest,
        incrementalSteps: incSteps,
        incrementalDistance: incDist,
        incrementalCalories: incCal,
        incrementalActiveMinutes: incActive,
        incrementalSleepHours: incSleep,
        progressRatio: progressRatio,
        justCompleted: justCompleted,
      ));

      // Update Firestore with incremental progress
      await _questService.updateQuestProgress(
        questId: quest.id,
        currentSteps: incSteps,
        currentDistanceKm: incDist,
        currentDurationMinutes: quest.type == QuestType.sleep
            ? (incSleep * 60).toInt()
            : incActive,
        detectedActivity: quest.activityType?.name,
      );

      // Auto-complete quest if all targets met
      if (justCompleted && !_completedThisSession.contains(quest.id)) {
        _completedThisSession.add(quest.id);
        debugPrint('[QuestEngine] 🎉 Quest "${quest.title}" COMPLETED!');
        debugPrint('[QuestEngine] Quest rewards: XP=${quest.xpReward}, Coins=${quest.goldReward}');
        // Mark quest completed in Firestore
        await _questService.markQuestCompleted(quest.id);
        // CRITICAL: Award rewards (XP, coins, level) via Firestore transaction
        try {
          final dataService = DataService();
          debugPrint('[QuestEngine] Calling completeQuestAndAwardRewards...');
          debugPrint('[QuestEngine] DataService currentUserData: uid=${dataService.currentUserData?.uid}, level=${dataService.currentUserData?.level}, xp=${dataService.currentUserData?.currentXP}, coins=${dataService.currentUserData?.coins}');
          final success = await dataService.completeQuestAndAwardRewards(quest);
          debugPrint('[QuestEngine] Rewards awarded: success=$success');
          if (success) {
            debugPrint('[QuestEngine] Coins added: ${quest.goldReward}');
            debugPrint('[QuestEngine] XP added: ${quest.xpReward}');
            debugPrint('[QuestEngine] New profile: level=${dataService.currentUserData?.level}, xp=${dataService.currentUserData?.currentXP}, coins=${dataService.currentUserData?.coins}');
          }
        } catch (e, stackTrace) {
          debugPrint('[QuestEngine] ERROR awarding rewards: $e');
          debugPrint('[QuestEngine] Stack: $stackTrace');
        }
      }
    }

    debugPrint('[QuestEngine] ========== EVALUATION COMPLETE: ${results.length} results ==========');
    return results;
  }

  /// Reset session tracking (e.g., on app restart)
  void resetSession() {
    _completedThisSession.clear();
  }
}
