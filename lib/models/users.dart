import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final int coins;
  final int streak;
  final DateTime? createdAt;
  final int totalQuestsCreated;
  final int totalQuestsCompleted;
  
  // New fields for real-time progress tracking
  final int requiredXP;
  final int streakCount;
  final int totalQuests;
  final int activeQuests;
  final double successRate;
  final String? selectedCharacterId;
  final String? selectedAnimationId;
  final DateTime? lastQuestCompletionDate;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.coins,
    required this.streak,
    this.createdAt,
    this.totalQuestsCreated = 0,
    this.totalQuestsCompleted = 0,
    this.requiredXP = 100,
    this.streakCount = 0,
    this.totalQuests = 0,
    this.activeQuests = 0,
    this.successRate = 0.0,
    this.selectedCharacterId,
    this.selectedAnimationId,
    this.lastQuestCompletionDate,
    this.updatedAt,
  });
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      username: data['username'] ?? 'User',
      level: (data['level'] as num?)?.toInt() ?? 1,
      currentXP: (data['currentXP'] as num?)?.toInt() ?? 0,
      xpForNextLevel: (data['xpForNextLevel'] as num?)?.toInt() ?? 100,
      coins: (data['coins'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      totalQuestsCreated: (data['totalQuestsCreated'] as num?)?.toInt() ?? 0,
      totalQuestsCompleted: (data['totalQuestsCompleted'] as num?)?.toInt() ?? 0,
    );
  }
  


}
