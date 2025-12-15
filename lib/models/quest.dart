import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';

enum QuestType {
  health,
  study,
  exercise,
  social,
  sleep,
  custom,
}

enum QuestDifficulty {
  easy,
  medium,
  hard,
}





class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final int xpReward;
  final int statBonus;
  final int goldReward;
  final bool isCompleted;
  final DateTime? dueDate;
  final int? duration; // in minutes
  final IconData icon;
  final List<Color> gradientColors;
  final DateTime createdAt;
  final bool isDaily;
  final bool isCustom;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.difficulty = QuestDifficulty.medium,
    required this.xpReward,
    required this.statBonus,
    this.goldReward = 10,
    this.isCompleted = false,
    this.dueDate,
    this.duration,
    required this.icon,
    required this.gradientColors,
    DateTime? createdAt,
    this.isDaily = false,
    this.isCustom = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create a copy with modified fields
  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    QuestDifficulty? difficulty,
    int? xpReward,
    int? statBonus,
    int? goldReward,
    bool? isCompleted,
    DateTime? dueDate,
    int? duration,
    IconData? icon,
    // gradient colors  parameter
    List<Color>? gradientColors,
    DateTime? createdAt,
    bool? isDaily,
    bool? isCustom,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      statBonus: statBonus ?? this.statBonus,
      goldReward: goldReward ?? this.goldReward,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      duration: duration ?? this.duration,
      icon: icon ?? this.icon,
      gradientColors: gradientColors ?? this.gradientColors,
      createdAt: createdAt ?? this.createdAt,
      isDaily: isDaily ?? this.isDaily,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  // Get difficulty text
  String get difficultyText {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 'Easy';
      case QuestDifficulty.medium:
        return 'Medium';
      case QuestDifficulty.hard:
        return 'Hard';
    }
  }
  // Get difficulty color
  List<Color> get difficultyGradient {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return AppColors.gradientEasy;
      case QuestDifficulty.medium:
        return AppColors.gradientMedium;
      case QuestDifficulty.hard:
        return AppColors.gradientHard;
    }
  }


  // Dummy quest list for testing
  static List<Quest> getDailyQuests() {
    return [
      Quest(
        id: '1',
        title: 'Morning Workout',
        description: 'Complete 30 minutes of exercise',
        type: QuestType.exercise,
        difficulty: QuestDifficulty.medium,
        xpReward: 25,
        statBonus: 10,
        goldReward: 15,
        isCompleted: false,
        duration: 30,
        icon: Icons.fitness_center,
        gradientColors: AppColors.gradientMedium,
        isDaily: true,
      ),
      Quest(
        id: '2',
        title: 'Study Session',
        description: 'Focus on learning for 1 hour',
        type: QuestType.study,
        difficulty: QuestDifficulty.hard,
        xpReward: 40,
        statBonus: 15,
        goldReward: 20,
        isCompleted: false,
        duration: 60,
        icon: Icons.menu_book,
        gradientColors: AppColors.gradientHard,
        isDaily: true,
      ),
      Quest(
        id: '3',
        title: 'Drink 8 Glasses Water',
        description: 'Stay hydrated throughout the day',
        type: QuestType.health,
        difficulty: QuestDifficulty.easy,
        xpReward: 15,
        statBonus: 8,
        goldReward: 10,
        isCompleted: true,
        icon: Icons.water_drop,
        gradientColors: AppColors.gradientMedium,
        isDaily: true,
      ),
      Quest(
        id: '4',
        title: 'Family Time',
        description: 'Spend quality time with family',
        type: QuestType.social,
        difficulty: QuestDifficulty.easy,
        xpReward: 20,
        statBonus: 10,
        goldReward: 12,
        isCompleted: false,
        duration: 45,
        icon: Icons.people,
        gradientColors: AppColors.gradientMedium,
        isDaily: true,
      ),
      Quest(
        id: '5',
        title: 'Early Sleep',
        description: 'Sleep before 11 PM',
        type: QuestType.sleep,
        difficulty: QuestDifficulty.medium,
        xpReward: 30,
        statBonus: 12,
        goldReward: 15,
        isCompleted: false,
        icon: Icons.bedtime,
        gradientColors: AppColors.gradientHard,
        isDaily: true,
      ),
    ];
  }
}
