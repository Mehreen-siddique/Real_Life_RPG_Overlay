import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Category strings used by the UI.
class AchievementCategory {
  static const String quests = 'Quests';
  static const String social = 'Social';
  static const String streaks = 'Streaks';
  static const String levels = 'Levels';
  static const String steps = 'Steps';
  static const String challenges = 'Challenges';
}

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String category;
  final int targetValue;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
  });
}

/// User achievement document model.
class UserAchievement {
  final String id;
  final String title;
  final String description;
  final String category;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const UserAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    required this.unlockedAt,
  });

  double get progress =>
      targetValue <= 0 ? 0 : (currentValue / targetValue).clamp(0.0, 1.0);

  factory UserAchievement.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final unlockedAtTs = data['unlockedAt'] as Timestamp?;
    return UserAchievement(
      id: id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      targetValue: (data['targetValue'] ?? 0).toInt(),
      currentValue: (data['currentValue'] ?? 0).toInt(),
      isUnlocked: data['isUnlocked'] as bool? ?? false,
      unlockedAt: unlockedAtTs?.toDate(),
    );
  }
}

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // IDs (used for doc paths and UI mapping).
  static const String firstQuestId = 'first_quest';
  static const String questMaster50Id = 'quest_master_50';
  static const String streak7Id = 'streak_7';
  static const String streak30Id = 'streak_30';
  static const String level10Id = 'level_10';
  static const String level20Id = 'level_20';
  static const String level30Id = 'level_30';
  static const String steps10kId = 'steps_10k';
  static const String partyJoinFirstId = 'party_join_1';
  static const String firstChallengeWinId = 'first_challenge_win';

  final List<AchievementDefinition> _definitions = const [
    AchievementDefinition(
      id: firstQuestId,
      title: 'First Quest',
      description: 'Complete your first quest',
      category: AchievementCategory.quests,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: questMaster50Id,
      title: 'Quest Master',
      description: 'Complete 50 quests',
      category: AchievementCategory.quests,
      targetValue: 50,
    ),
    AchievementDefinition(
      id: streak7Id,
      title: '7 Day Streak',
      description: 'Maintain a 7-day streak',
      category: AchievementCategory.streaks,
      targetValue: 7,
    ),
    AchievementDefinition(
      id: streak30Id,
      title: '30 Day Warrior',
      description: 'Maintain a 30-day streak',
      category: AchievementCategory.streaks,
      targetValue: 30,
    ),
    AchievementDefinition(
      id: level10Id,
      title: 'Level 10',
      description: 'Reach level 10',
      category: AchievementCategory.levels,
      targetValue: 10,
    ),
    AchievementDefinition(
      id: level20Id,
      title: 'Level 20',
      description: 'Reach level 20',
      category: AchievementCategory.levels,
      targetValue: 20,
    ),
    AchievementDefinition(
      id: level30Id,
      title: 'Level 30',
      description: 'Reach level 30',
      category: AchievementCategory.levels,
      targetValue: 30,
    ),
    AchievementDefinition(
      id: steps10kId,
      title: 'Steps Collector',
      description: 'Reach 10,000 steps today',
      category: AchievementCategory.steps,
      targetValue: 10000,
    ),
    AchievementDefinition(
      id: partyJoinFirstId,
      title: 'Joined the Party',
      description: 'Join a party',
      category: AchievementCategory.social,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: firstChallengeWinId,
      title: 'First Challenge Win',
      description: 'Complete your first challenge competition',
      category: AchievementCategory.challenges,
      targetValue: 1,
    ),
  ];

  /// Initialize achievement docs for a user.
  /// Idempotent: will not overwrite existing docs.
  Future<void> initializeAchievementsForUser(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    final userSnap = await userRef.get();
    final userData = userSnap.data() ?? <String, dynamic>{};

    final questsCompleted = (userData['totalQuestsCompleted'] ?? 0).toInt();
    final streak = (userData['streak'] ?? 0).toInt();
    final level = (userData['level'] ?? 1).toInt();
    final partyId = userData['partyId'] as String?;
    final partyJoined = partyId != null && partyId.trim().isNotEmpty;

    final achievementsRef = userRef.collection('achievements');

    final existing = await achievementsRef.get();
    final existingIds = existing.docs.map((d) => d.id).toSet();

    final batch = _firestore.batch();
    for (final def in _definitions) {
      if (existingIds.contains(def.id)) continue;

      final initialCurrentValue = _initialCurrentValueForDefinition(
        defId: def.id,
        questsCompleted: questsCompleted,
        streak: streak,
        level: level,
        partyJoined: partyJoined,
        stepsToday: null,
        challengeWin: null,
      );

      final unlocked = initialCurrentValue >= def.targetValue;

      batch.set(
        achievementsRef.doc(def.id),
        {
          'title': def.title,
          'description': def.description,
          'category': def.category,
          'targetValue': def.targetValue,
          'currentValue': initialCurrentValue,
          'isUnlocked': unlocked,
          'unlockedAt': unlocked ? FieldValue.serverTimestamp() : null,
        },
      );
    }

    await batch.commit();
  }

  /// Update progress for relevant achievements.
  ///
  /// If [stepsToday] is provided it updates the steps achievement only.
  /// If [challengeWin] is provided it updates the challenge completion achievement.
  /// Always recomputes deterministic quest/streak/level/social progress from the user doc.
  Future<void> updateAchievementProgress(
    String uid, {
    int? stepsToday,
    bool? challengeWin,
    int? questsCompleted,
    int? streak,
    int? level,
    bool? partyJoined,
  }) async {
    await initializeAchievementsForUser(uid);

    final userRef = _firestore.collection('users').doc(uid);
    final userSnap = await userRef.get();
    final userData = userSnap.data() ?? <String, dynamic>{};

    final resolvedQuestsCompleted =
        questsCompleted ?? (userData['totalQuestsCompleted'] ?? 0).toInt();
    final resolvedStreak = streak ?? (userData['streak'] ?? 0).toInt();
    final resolvedLevel = level ?? (userData['level'] ?? 1).toInt();
    final resolvedPartyJoined = partyJoined ??
        (() {
          final partyId = userData['partyId'] as String?;
          return partyId != null && partyId.trim().isNotEmpty;
        })();

    final achievementsRef = userRef.collection('achievements');
    final achievementsSnap = await achievementsRef.get();
    final Map<String, Map<String, dynamic>?> existingById = {
      for (final d in achievementsSnap.docs) d.id: d.data(),
    };

    final batch = _firestore.batch();

    for (final def in _definitions) {
      final docData = existingById[def.id];
      final prevUnlocked = docData?['isUnlocked'] as bool? ?? false;
      final prevUnlockedAt = docData?['unlockedAt'];
      final prevCurrentValue = (docData?['currentValue'] ?? 0).toInt();

      final newCurrentValue = def.id == steps10kId
          ? (stepsToday ?? prevCurrentValue)
          : def.id == firstChallengeWinId
              ? (challengeWin == true ? 1 : prevCurrentValue)
              : _initialCurrentValueForDefinition(
                  defId: def.id,
                  questsCompleted: resolvedQuestsCompleted,
                  streak: resolvedStreak,
                  level: resolvedLevel,
                  partyJoined: resolvedPartyJoined,
                  stepsToday: null,
                  challengeWin: null,
                );

      final targetReached = newCurrentValue >= def.targetValue;
      final unlocked = prevUnlocked || targetReached;

      batch.set(
        achievementsRef.doc(def.id),
        {
          'title': def.title,
          'description': def.description,
          'category': def.category,
          'targetValue': def.targetValue,
          'currentValue': newCurrentValue,
          'isUnlocked': unlocked,
          'unlockedAt': unlocked
              ? (prevUnlocked ? prevUnlockedAt : FieldValue.serverTimestamp())
              : null,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Backfill unlock state based on currentValue >= targetValue.
  /// (Keeps unlocked achievements unlocked.)
  Future<void> checkAndUnlockAchievements(String uid) async {
    await initializeAchievementsForUser(uid);

    final achievementsRef =
        _firestore.collection('users').doc(uid).collection('achievements');
    final snap = await achievementsRef.get();

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    for (final doc in snap.docs) {
      final data = doc.data() ?? <String, dynamic>{};
      final targetValue = (data['targetValue'] ?? 0).toInt();
      final currentValue = (data['currentValue'] ?? 0).toInt();
      final isUnlocked = data['isUnlocked'] as bool? ?? false;

      if (isUnlocked) continue;
      if (targetValue <= 0) continue;
      if (currentValue < targetValue) continue;

      batch.set(
        doc.reference,
        {
          'isUnlocked': true,
          'unlockedAt': now,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Realtime achievements stream.
  Stream<List<UserAchievement>> getAchievementsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => UserAchievement.fromFirestore(d.id, d.data()))
          .toList();
    });
  }

  int _initialCurrentValueForDefinition({
    required String defId,
    required int questsCompleted,
    required int streak,
    required int level,
    required bool partyJoined,
    required int? stepsToday,
    required bool? challengeWin,
  }) {
    switch (defId) {
      case firstQuestId:
        return questsCompleted;
      case questMaster50Id:
        return questsCompleted;
      case streak7Id:
        return streak;
      case streak30Id:
        return streak;
      case level10Id:
      case level20Id:
      case level30Id:
        return level;
      case steps10kId:
        return stepsToday ?? 0;
      case partyJoinFirstId:
        return partyJoined ? 1 : 0;
      case firstChallengeWinId:
        return (challengeWin ?? false) ? 1 : 0;
      default:
        return 0;
    }
  }

  /// Convenience for internal callers when a uid isn't passed.
  String? get _uid => _auth.currentUser?.uid;

  Future<void> updateAchievementProgressForCurrentUser({
    int? stepsToday,
    bool? challengeWin,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await updateAchievementProgress(uid, stepsToday: stepsToday, challengeWin: challengeWin);
  }
}

