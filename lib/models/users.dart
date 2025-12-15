class UserModel {
  final String id;
  final String name;
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final int health;
  final int maxHealth;
  final int strength;
  final int maxStrength;
  final int intelligence;
  final int maxIntelligence;
  final int goldCoins;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.health,
    required this.maxHealth,
    required this.strength,
    required this.maxStrength,
    required this.intelligence,
    required this.maxIntelligence,
    required this.goldCoins,
    this.avatarUrl = '',
  });

  // Dummy data for testing
  factory UserModel.dummy() {
    return UserModel(
      id: '1',
      name: 'Hero Knight',
      level: 15,
      currentXP: 2450,
      xpForNextLevel: 3000,
      health: 85,
      maxHealth: 100,
      strength: 60,
      maxStrength: 100,
      intelligence: 75,
      maxIntelligence: 100,
      goldCoins: 1250,
    );
  }

  // XP progress percentage
  double get xpProgress => currentXP / xpForNextLevel;

  // Health progress percentage
  double get healthProgress => health / maxHealth;

  // Strength progress percentage
  double get strengthProgress => strength / maxStrength;

  // Intelligence progress percentage
  double get intelligenceProgress => intelligence / maxIntelligence;
}
