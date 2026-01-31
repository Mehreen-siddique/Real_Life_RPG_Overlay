import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:real_life_rpg/Models/quest.dart';

const String GEMINI_API_KEY = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

class QuestSuggestion {
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final int targetSteps;
  final double targetDistanceKm;
  final int targetDurationMinutes;
  final int xpReward;
  final int goldReward;

  QuestSuggestion({
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    this.targetSteps = 0,
    this.targetDistanceKm = 0.0,
    this.targetDurationMinutes = 0,
    this.xpReward = 0,
    this.goldReward = 0,
  });
}

class UserActivityData {
  final List<int> stepsLast7Days;
  final List<double> caloriesLast7Days;
  final List<double> distanceLast7Days;
  final List<int> activeMinutesLast7Days;
  final List<String> completedQuestTypes;
  final int missedDays;
  final int currentStreak;

  // Computed averages
  int get avgSteps => stepsLast7Days.isEmpty ? 0 : (stepsLast7Days.reduce((a, b) => a + b) / stepsLast7Days.length).round();
  double get avgCalories => caloriesLast7Days.isEmpty ? 0 : caloriesLast7Days.reduce((a, b) => a + b) / caloriesLast7Days.length;
  double get avgDistanceKm => distanceLast7Days.isEmpty ? 0 : distanceLast7Days.reduce((a, b) => a + b) / distanceLast7Days.length;
  int get avgActiveMinutes => activeMinutesLast7Days.isEmpty ? 0 : (activeMinutesLast7Days.reduce((a, b) => a + b) / activeMinutesLast7Days.length).round();
  int get completedQuests => completedQuestTypes.length;

  UserActivityData({
    this.stepsLast7Days = const [],
    this.caloriesLast7Days = const [],
    this.distanceLast7Days = const [],
    this.activeMinutesLast7Days = const [],
    this.completedQuestTypes = const [],
    this.missedDays = 0,
    this.currentStreak = 0,
  });
}

class GeminiSuggestionService {
  static final GeminiSuggestionService _instance = GeminiSuggestionService._internal();
  factory GeminiSuggestionService() => _instance;
  GeminiSuggestionService._internal();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<List<QuestSuggestion>> getSuggestions(UserActivityData data) async {
    try {
      if (GEMINI_API_KEY.isEmpty) {
        debugPrint('[Gemini] ❌ API key missing → using fallback');
        return _generateFallbackSuggestions(data);
      }

      debugPrint('[Gemini] 🚀 Calling Gemini API...');
      debugPrint('[Gemini] Steps avg: ${data.avgSteps}');
      debugPrint('[Gemini] Distance avg: ${data.avgDistanceKm}');
      debugPrint('[Gemini] Active mins avg: ${data.avgActiveMinutes}');

      final prompt = _buildPrompt(data);
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$GEMINI_API_KEY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('[Gemini] API response status: ${response.statusCode}');
      debugPrint('[Gemini] API response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (text != null) {
          debugPrint('[Gemini] Parsed text from API: ${text.substring(0, text.length > 200 ? 200 : text.length)}');
          return _parseGeminiResponse(text);
        }
      }

      debugPrint('[Gemini] API failed (${response.statusCode}), using fallback');
      return _generateFallbackSuggestions(data);
    } catch (e) {
      debugPrint('[Gemini] Error: $e, using fallback');
      return _generateFallbackSuggestions(data);
    }
  }

  String _buildPrompt(UserActivityData data) {
    return '''You are a fitness quest designer for a gamified health app called Real Life RPG.
Suggest 3-5 personalized fitness quests based on this user's activity data.

User activity data (last 7 days):
- Steps per day: ${data.stepsLast7Days}
- Calories per day: ${data.caloriesLast7Days.map((c) => c.toStringAsFixed(0)).toList()}
- Distance (km) per day: ${data.distanceLast7Days.map((d) => d.toStringAsFixed(1)).toList()}
- Active minutes per day: ${data.activeMinutesLast7Days}
- Completed quest types: ${data.completedQuestTypes}
- Missed days this week: ${data.missedDays}
- Current streak: ${data.currentStreak} days

Averages: ${data.avgSteps} steps, ${data.avgCalories.toStringAsFixed(0)} cal, ${data.avgDistanceKm.toStringAsFixed(1)} km, ${data.avgActiveMinutes} min/day

Rules:
- Suggest 3-5 quests with VARIED difficulty (mix of easy, medium, hard)
- Targets should be 10-30% above their average for that metric
- If activity is low, lean toward easy quests with encouraging descriptions
- If activity is high, challenge them with medium/hard quests
- VARY the quest types: include steps, distance, calories, AND active minutes quests
- Do NOT repeat the same quest type more than twice
- Make titles creative and motivating (e.g. "Sunrise Sprint", "Calorie Inferno", "Trail Blazer")
- Descriptions should explain WHY this quest fits them based on their data
- XP: easy=25-40, medium=50-75, hard=80-120
- Gold: easy=10-20, medium=25-40, hard=45-60

Respond ONLY with a valid JSON array, no markdown fences:
[
  {
    "title": "...",
    "description": "...",
    "type": "exercise|health|sleep",
    "difficulty": "easy|medium|hard",
    "targetSteps": 0,
    "targetDistanceKm": 0.0,
    "targetDurationMinutes": 0,
    "xpReward": 0,
    "goldReward": 0
  }
]''';
  }

  List<QuestSuggestion> _parseGeminiResponse(String text) {
    try {
      // Strip markdown code fences if present
      var cleaned = text.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```(?:json)?\n?'), '');
        cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      }

      final List<dynamic> items = jsonDecode(cleaned);
      return items.map((item) {
        final typeStr = item['type'] as String? ?? 'steps';
        final diffStr = item['difficulty'] as String? ?? 'easy';
        return QuestSuggestion(
          title: item['title'] as String? ?? 'Quest',
          description: item['description'] as String? ?? '',
          type: _parseQuestType(typeStr),
          difficulty: _parseDifficulty(diffStr),
          targetSteps: (item['targetSteps'] as num?)?.toInt() ?? 0,
          targetDistanceKm: (item['targetDistanceKm'] as num?)?.toDouble() ?? 0.0,
          targetDurationMinutes: (item['targetDurationMinutes'] as num?)?.toInt() ?? 0,
          xpReward: (item['xpReward'] as num?)?.toInt() ?? 50,
          goldReward: (item['goldReward'] as num?)?.toInt() ?? 25,
        );
      }).toList();
    } catch (e) {
      debugPrint('[Gemini] Parse error: $e');
      return [];
    }
  }

  List<QuestSuggestion> _generateFallbackSuggestions(UserActivityData data) {
    final r = Random();
    final isLowActivity = data.avgSteps < 3000;
    final isHighActivity = data.avgSteps > 8000;

    // Dynamic multipliers based on activity level
    final stepMulti = isLowActivity ? 1.15 : isHighActivity ? 1.25 : 1.2;
    final distMulti = isLowActivity ? 1.2 : isHighActivity ? 1.3 : 1.25;
    final calMulti = isLowActivity ? 1.1 : isHighActivity ? 1.2 : 1.15;
    final activeMulti = isLowActivity ? 1.15 : isHighActivity ? 1.25 : 1.2;

    // Varied creative titles based on activity level
    final stepTitles = isLowActivity
        ? ['First Steps', 'Gentle Stroll', 'Step by Step']
        : isHighActivity
            ? ['Marathon Prep', 'Step Master', 'Peak Walker']
            : ['Daily Stride', 'Step Challenge', 'Urban Walker'];
    final distTitles = isLowActivity
        ? ['Short Hop', 'Neighborhood Loop', 'Easy Mile']
        : isHighActivity
            ? ['Trail Blazer', 'Long Road', 'Distance King']
            : ['Park Circuit', 'Scenic Route', 'Km Crusher'];
    final activeTitles = isLowActivity
        ? ['Warm Up', 'Light Burn', 'Easy Move']
        : isHighActivity
            ? ['Beast Mode', 'Active Inferno', 'Power Hour']
            : ['Sweat Session', 'Active Burst', 'Move It'];

    final suggestions = <QuestSuggestion>[];

    // Steps quest (easy or medium)
    suggestions.add(QuestSuggestion(
      title: stepTitles[r.nextInt(stepTitles.length)],
      description: isLowActivity
          ? 'A gentle walk to build your habit. You\'ve averaged ${data.avgSteps} steps — let\'s push a bit further!'
          : 'Your average is ${data.avgSteps} steps. Can you beat it today?',
      type: QuestType.exercise,
      difficulty: isLowActivity ? QuestDifficulty.easy : QuestDifficulty.medium,
      targetSteps: (data.avgSteps * stepMulti).round().clamp(100, 50000),
      xpReward: isLowActivity ? 30 : 55,
      goldReward: isLowActivity ? 12 : 25,
    ));

    // Distance quest (medium)
    suggestions.add(QuestSuggestion(
      title: distTitles[r.nextInt(distTitles.length)],
      description: 'You usually cover ${data.avgDistanceKm.toStringAsFixed(1)} km. Try going the extra distance!',
      type: QuestType.exercise,
      difficulty: QuestDifficulty.medium,
      targetDistanceKm: double.parse((data.avgDistanceKm * distMulti).toStringAsFixed(1)).clamp(0.5, 50.0),
      xpReward: isLowActivity ? 40 : 65,
      goldReward: isLowActivity ? 18 : 30,
    ));

    // Active minutes quest (varies)
    suggestions.add(QuestSuggestion(
      title: activeTitles[r.nextInt(activeTitles.length)],
      description: isLowActivity
          ? 'Just ${data.avgActiveMinutes} active minutes/day so far. Let\'s increase that!'
          : '${data.avgActiveMinutes} active minutes is solid — let\'s push for more!',
      type: QuestType.health,
      difficulty: isHighActivity ? QuestDifficulty.hard : QuestDifficulty.medium,
      targetDurationMinutes: (data.avgActiveMinutes * activeMulti).round().clamp(10, 180),
      xpReward: isLowActivity ? 35 : isHighActivity ? 90 : 60,
      goldReward: isLowActivity ? 15 : isHighActivity ? 45 : 28,
    ));

    // Hard challenge (if high activity or streak > 3)
    if (isHighActivity || data.currentStreak > 3) {
      suggestions.add(QuestSuggestion(
        title: 'Elite Challenger',
        description: 'You\'re on fire with a ${data.currentStreak}-day streak! Time for a real challenge.',
        type: QuestType.exercise,
        difficulty: QuestDifficulty.hard,
        targetSteps: (data.avgSteps * 1.4).round().clamp(5000, 50000),
        xpReward: 110,
        goldReward: 55,
      ));
    }

    // Easy recovery quest (if missed days > 2)
    if (data.missedDays > 2) {
      suggestions.add(QuestSuggestion(
        title: 'Comeback Quest',
        description: 'You\'ve missed ${data.missedDays} days recently. Start small and rebuild your streak!',
        type: QuestType.health,
        difficulty: QuestDifficulty.easy,
        targetSteps: (data.avgSteps * 0.8).round().clamp(500, 10000),
        xpReward: 25,
        goldReward: 10,
      ));
    }

    return suggestions;
  }

  QuestType _parseQuestType(String s) {
    switch (s.toLowerCase()) {
      case 'distance': return QuestType.exercise;
      case 'calories': return QuestType.health;
      case 'active': return QuestType.exercise;
      case 'sleep': return QuestType.sleep;
      case 'study': return QuestType.study;
      case 'social': return QuestType.social;
      default: return QuestType.health;
    }
  }

  QuestDifficulty _parseDifficulty(String s) {
    switch (s.toLowerCase()) {
      case 'medium': return QuestDifficulty.medium;
      case 'hard': return QuestDifficulty.hard;
      default: return QuestDifficulty.easy;
    }
  }
}
