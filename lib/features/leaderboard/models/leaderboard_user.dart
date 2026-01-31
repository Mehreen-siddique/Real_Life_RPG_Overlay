import 'package:cloud_firestore/cloud_firestore.dart';

/// Leaderboard User Model
/// Represents a user with all data needed for leaderboard display
class LeaderboardUser {
  final String id;
  final String username;
  final String? avatarUrl;
  final int level;
  final String characterClass;
  final int xp;
  final int coins;
  final int streak;
  final int daysActive;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? partyId;
  final int totalQuestsCompleted;
  final int totalSteps;

  LeaderboardUser({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.level,
    required this.characterClass,
    required this.xp,
    required this.coins,
    required this.streak,
    required this.daysActive,
    required this.isOnline,
    this.lastSeen,
    this.partyId,
    this.totalQuestsCompleted = 0,
    this.totalSteps = 0,
  });

  /// Calculate combined score for ranking (XP + Coins + Streak * 10)
  int get combinedScore => xp + coins + (streak * 10);

  /// Get streak tier for visual display
  StreakTier get streakTier {
    if (streak >= 30) return StreakTier.legendary;
    if (streak >= 21) return StreakTier.epic;
    if (streak >= 14) return StreakTier.glowing;
    if (streak >= 7) return StreakTier.powered;
    return StreakTier.normal;
  }

  /// Create from Firestore document
  factory LeaderboardUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardUser(
      id: doc.id,
      username: data['username'] ?? 'Unknown',
      avatarUrl: data['avatarUrl'],
      level: (data['level'] ?? 1).toInt(),
      characterClass: data['characterClass'] ?? 'warrior',
      xp: (data['currentXP'] ?? 0).toInt(),
      coins: (data['coins'] ?? 0).toInt(),
      streak: (data['streak'] ?? 0).toInt(),
      daysActive: (data['totalDaysActive'] ?? 0).toInt(),
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      partyId: data['partyId'],
      totalQuestsCompleted: (data['totalQuestsCompleted'] ?? 0).toInt(),
      totalSteps: (data['totalSteps'] ?? 0).toInt(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'avatarUrl': avatarUrl,
      'level': level,
      'characterClass': characterClass,
      'currentXP': xp,
      'coins': coins,
      'streak': streak,
      'totalDaysActive': daysActive,
      'isOnline': isOnline,
      'lastActiveAt': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'partyId': partyId,
      'totalQuestsCompleted': totalQuestsCompleted,
      'totalSteps': totalSteps,
    };
  }

  /// Create copy with updated fields
  LeaderboardUser copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    int? level,
    String? characterClass,
    int? xp,
    int? coins,
    int? streak,
    int? daysActive,
    bool? isOnline,
    DateTime? lastSeen,
    String? partyId,
    int? totalQuestsCompleted,
    int? totalSteps,
  }) {
    return LeaderboardUser(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      characterClass: characterClass ?? this.characterClass,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      daysActive: daysActive ?? this.daysActive,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      partyId: partyId ?? this.partyId,
      totalQuestsCompleted: totalQuestsCompleted ?? this.totalQuestsCompleted,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}

/// Streak tier for visual effects
enum StreakTier {
  normal,      // 0-6 days
  powered,     // 7-13 days
  glowing,     // 14-20 days
  epic,        // 21-29 days
  legendary,  // 30+ days
}

/// Character class enum with display properties
enum CharacterClass {
  warrior,
  mage,
  healer,
  rogue;

  String get displayName {
    switch (this) {
      case CharacterClass.warrior: return 'Warrior';
      case CharacterClass.mage: return 'Mage';
      case CharacterClass.healer: return 'Healer';
      case CharacterClass.rogue: return 'Rogue';
    }
  }

  String get icon {
    switch (this) {
      case CharacterClass.warrior: return '⚔️';
      case CharacterClass.mage: return '🔮';
      case CharacterClass.healer: return '💚';
      case CharacterClass.rogue: return '🗡️';
    }
  }

  List<int> get gradientColors {
    switch (this) {
      case CharacterClass.warrior: return [0xFFE53935, 0xFFB71C1C]; // Red
      case CharacterClass.mage: return [0xFF7B1FA2, 0xFF4A148C]; // Purple
      case CharacterClass.healer: return [0xFF43A047, 0xFF1B5E20]; // Green
      case CharacterClass.rogue: return [0xFFFFA000, 0xFFFF6F00]; // Orange
    }
  }

  static CharacterClass fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mage': return CharacterClass.mage;
      case 'healer': return CharacterClass.healer;
      case 'rogue': return CharacterClass.rogue;
      default: return CharacterClass.warrior;
    }
  }
}
