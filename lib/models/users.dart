import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // final String id;
  // final String name;
  // final int level;
  // final int currentXP;
  // final int xpForNextLevel;
  // final int health;
  // final int maxHealth;
  // final int strength;
  // final int maxStrength;
  // final int intelligence;
  // final int maxIntelligence;
  // final int goldCoins;
  final String uid;
  final String email;
  final String username;
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final int coins;
  final int streak;
  final DateTime? createdAt;


  UserModel({
    // required this.id,
    // required this.name,
    // required this.level,
    // required this.currentXP,
    // required this.xpForNextLevel,
    // required this.health,
    // required this.maxHealth,
    // required this.strength,
    // required this.maxStrength,
    // required this.intelligence,
    // required this.maxIntelligence,
    // required this.goldCoins,
    required this.uid,
    required this.email,
    required this.username,
    required this.level,
    required this.currentXP,        // ← Yeh add karo
    required this.xpForNextLevel,
    required this.coins,
    required this.streak,
    this.createdAt,

  });
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      username: data['username'] ?? 'User',
      level: (data['level'] as num?)?.toInt() ?? 1,
      currentXP: (data['currentXP'] as num?)?.toInt() ?? 0,
      xpForNextLevel: (data['xpForNextLevel'] as num?)?.toInt() ?? 0,
      coins: (data['coins'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
  


}
