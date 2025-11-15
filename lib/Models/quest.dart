import 'package:flutter/material.dart';

enum QuestType {
  health,
  study,
  exercise,
  social,
  sleep,
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int xpReward;
  final int statBonus;
  final bool isCompleted;
  final IconData icon;
  final Color color;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.statBonus,
    this.isCompleted = false,
    required this.icon,
    required this.color,
  });

  // Dummy quest list for testing
  static List<Quest> getDailyQuests() {
    return [
      Quest(
        id: '1',
        title: 'Brush Your Teeth',
        description: 'Start your day fresh!',
        type: QuestType.health,
        xpReward: 10,
        statBonus: 5,
        isCompleted: true,
        icon: Icons.cleaning_services,
        color: const Color(0xFF50C878),
      ),
      Quest(
        id: '2',
        title: 'Morning Exercise',
        description: '30 minutes workout',
        type: QuestType.exercise,
        xpReward: 25,
        statBonus: 10,
        isCompleted: false,
        icon: Icons.fitness_center,
        color: const Color(0xFFE74C3C),
      ),
      Quest(
        id: '3',
        title: 'Study Session',
        description: 'Focus for 1 hour',
        type: QuestType.study,
        xpReward: 30,
        statBonus: 15,
        isCompleted: false,
        icon: Icons.menu_book,
        color: const Color(0xFF4A90E2),
      ),
      Quest(
        id: '4',
        title: 'Drink 8 Glasses Water',
        description: 'Stay hydrated!',
        type: QuestType.health,
        xpReward: 15,
        statBonus: 8,
        isCompleted: false,
        icon: Icons.water_drop,
        color: const Color(0xFF87CEEB),
      ),
      Quest(
        id: '5',
        title: 'Family Time',
        description: 'Spend quality time',
        type: QuestType.social,
        xpReward: 20,
        statBonus: 10,
        isCompleted: false,
        icon: Icons.family_restroom,
        color: const Color(0xFFFF6B9D),
      ),
    ];
  }
}