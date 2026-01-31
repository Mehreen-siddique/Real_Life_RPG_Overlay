import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Models/daily_health_data.dart';
import 'package:real_life_rpg/Services/Gemini/gemini_suggestion_service.dart';
import 'package:real_life_rpg/Services/Health/health_connect_service.dart';
import 'package:real_life_rpg/Services/DataServices/dataServices.dart';
import 'package:real_life_rpg/Services/QuestFirestore/questfirestore.dart';
import 'package:real_life_rpg/Services/Streaks/streaks_service.dart';
import 'package:real_life_rpg/utils/constants.dart';
import 'CreateQuest.dart';

class SmartSuggestionsScreen extends StatefulWidget {
  const SmartSuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<SmartSuggestionsScreen> createState() => _SmartSuggestionsScreenState();
}

class _SmartSuggestionsScreenState extends State<SmartSuggestionsScreen> {
  final GeminiSuggestionService _suggestionService = GeminiSuggestionService();
  List<QuestSuggestion> _suggestions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch REAL 7-day activity data from HealthConnect
      List<int> steps7 = [];
      List<double> cal7 = [];
      List<double> dist7 = [];
      List<int> active7 = [];
      int streak = 0;
      List<String> completedTypes = [];

      try {
        final healthService = HealthConnectService();
        await healthService.initialize();
        final weekData = await healthService.getWeeklyHealthData();
        debugPrint('[SmartSuggestions] Fetched ${weekData.length} days of real health data');
        for (final day in weekData) {
          steps7.add(day.steps);
          cal7.add(day.calories);
          dist7.add(day.distanceKm);
          active7.add(day.activeMinutes);
        }
      } catch (e) {
        debugPrint('[SmartSuggestions] Weekly health data fetch failed: $e');
      }

      // Fallback: if no weekly data, use today's snapshot
      if (steps7.isEmpty) {
        try {
          final healthService = HealthConnectService();
          await healthService.initialize();
          final summary = await healthService.getAllActivityData();
          steps7 = List.filled(7, summary.steps);
          cal7 = List.filled(7, summary.calories);
          dist7 = List.filled(7, summary.distanceKm);
          active7 = List.filled(7, summary.activeMinutes);
        } catch (e) {
          debugPrint('[SmartSuggestions] Today health data also failed: $e');
        }
      }

      try {
        final dataService = DataService();
        final userData = dataService.currentUserData;
        if (userData != null) {
          streak = userData.streak;
        }
      } catch (e) {
        debugPrint('[SmartSuggestions] UserData fetch failed: $e');
      }

      final activityData = UserActivityData(
        stepsLast7Days: steps7,
        caloriesLast7Days: cal7,
        distanceLast7Days: dist7,
        activeMinutesLast7Days: active7,
        completedQuestTypes: completedTypes,
        missedDays: streak > 0 ? 0 : 2,
        currentStreak: streak,
      );

      final suggestions = await _suggestionService.getSuggestions(activityData);
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load suggestions: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _getDifficultyLabel(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 'Easy';
      case QuestDifficulty.medium:
        return 'Medium';
      case QuestDifficulty.hard:
        return 'Hard';
    }
  }

  // Get difficulty gradient to match QuestCard theme
  List<Color> _getDifficultyGradient(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return AppColors.gradientEasy;
      case QuestDifficulty.medium:
        return AppColors.gradientMedium;
      case QuestDifficulty.hard:
        return AppColors.gradientHard;
    }
  }

  String _getTargetText(QuestSuggestion suggestion) {
    if (suggestion.targetSteps > 0) {
      return '${suggestion.targetSteps} steps';
    } else if (suggestion.targetDistanceKm > 0) {
      return '${suggestion.targetDistanceKm.toStringAsFixed(1)} km';
    } else if (suggestion.targetDurationMinutes > 0) {
      return '${suggestion.targetDurationMinutes} min';
    }
    return 'Complete activity';
  }

  IconData _getTypeIcon(QuestType type) {
    switch (type) {
      case QuestType.health:
        return Icons.favorite;
      case QuestType.exercise:
        return Icons.fitness_center;
      case QuestType.study:
        return Icons.menu_book;
      case QuestType.sleep:
        return Icons.bedtime;
      case QuestType.social:
        return Icons.people;
      case QuestType.custom:
        return Icons.star;
    }
  }

  /// Create quest directly from suggestion and save to Firebase
  Future<void> _createQuestFromSuggestion(QuestSuggestion suggestion) async {
    // Safety check: ensure suggestion has valid data
    if (suggestion.targetSteps <= 0 &&
        suggestion.targetDistanceKm <= 0 &&
        suggestion.targetDurationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid suggestion data — no target set')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
      );

      // Map suggestion → Quest model
      final quest = Quest(
        id: '', // Firestore will generate
        title: suggestion.title,
        description: suggestion.description,
        type: suggestion.type,
        difficulty: suggestion.difficulty,
        xpReward: suggestion.xpReward,
        statBonus: 0,
        goldReward: suggestion.goldReward,
        icon: _getTypeIcon(suggestion.type),
        gradientColors: _getDifficultyGradient(suggestion.difficulty),
        activityType: QuestActivityType.walking,
        targetSteps: suggestion.targetSteps > 0 ? suggestion.targetSteps : null,
        targetDistanceKm: suggestion.targetDistanceKm > 0 ? suggestion.targetDistanceKm : null,
        targetDurationMinutes: suggestion.targetDurationMinutes > 0 ? suggestion.targetDurationMinutes : null,
      );

      // Save via QuestServiceFirestore (captures baseline automatically)
      final questService = QuestServiceFirestore();
      await questService.addQuest(quest);

      // Close loading, pop back to HomeScreen
      if (mounted) {
        Navigator.of(context).pop(); // close loading dialog
        Navigator.of(context).pop(); // pop back to HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${suggestion.title}" quest created!')),
        );
      }
    } catch (e) {
      debugPrint('[SmartSuggestions] Error creating quest: $e');
      if (mounted) {
        Navigator.of(context).pop(); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create quest: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Suggestions',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Custom quest creation button
          TextButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateQuestScreen())),
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primaryPurple, size: 20),
            label: const Text('Custom',
                style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Powered Quest Ideas',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 24,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your recent activity',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: AppTextStyles.body.copyWith(color: AppColors.textDark),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadSuggestions,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _suggestions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 64,
                                  color: AppColors.textGray.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No suggestions available',
                                  style: AppTextStyles.body.copyWith(color: AppColors.textGray),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              // Fade + slide animation per card
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutCubic,
                                duration: Duration(milliseconds: 300 + index * 100),
                                builder: (context, anim, child) {
                                  return Opacity(
                                    opacity: anim,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - anim)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildSuggestionCard(suggestion),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(QuestSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        gradient: LinearGradient(
          colors: _getDifficultyGradient(suggestion.difficulty),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Icon + Title + Difficulty
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getDifficultyGradient(suggestion.difficulty),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getTypeIcon(suggestion.type),
                    color: AppColors.lightBackground,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: AppTextStyles.subheading.copyWith(
                          fontSize: 16,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getDifficultyLabel(suggestion.difficulty),
                          style: TextStyle(
                            color: AppColors.lightBackground,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Target value
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  size: 16,
                  color: AppColors.lightBackground,
                ),
                const SizedBox(width: 6),
                Text(
                  'Target: ${_getTargetText(suggestion)}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: AppColors.lightBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // AI Explanation
            Text(
              suggestion.description,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: AppColors.lightBackground.withOpacity(0.9),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Rewards row
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 14,
                  color: AppColors.lightBackground,
                ),
                const SizedBox(width: 4),
                Text(
                  '${suggestion.goldReward} coins',
                  style: TextStyle(
                    color: AppColors.lightBackground,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.bolt,
                  size: 14,
                  color: AppColors.lightBackground,
                ),
                const SizedBox(width: 4),
                Text(
                  '${suggestion.xpReward} XP',
                  style: TextStyle(
                    color: AppColors.lightBackground,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Create Quest Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _createQuestFromSuggestion(suggestion),
                icon: const Icon(Icons.add, size: 18, color: AppColors.primaryPurple),
                label: const Text('Create Quest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBackground,
                  foregroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
