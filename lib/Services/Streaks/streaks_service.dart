import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../features/leaderboard/models/leaderboard_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Notifications/enhanced_notification_service.dart';
import '../Notifications/notification_preferences_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════════
/// STREAKS SERVICE - Daily Streak Calculation & Achievement Badges
/// ═══════════════════════════════════════════════════════════════════════════════
/// 
/// Manages:
/// • Daily streak calculation based on last pedometer_reset_date
/// • Achievement badges for streak milestones
/// • Step-based badges (10k steps, etc.)
/// • Real-time streak updates
///
/// Author: Final Year Project Student
/// Course: CS/SE Final Year Project 2024-2025

class StreaksService {
  /// Singleton pattern - single instance across the app
  static final StreaksService _instance = StreaksService._internal();
  factory StreaksService() => _instance;
  StreaksService._internal();

  /// Firestore database instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream controller for real-time streak updates
  final StreamController<UserStreakData> _streakController = 
      StreamController<UserStreakData>.broadcast();

  /// Public stream to listen for streak updates
  Stream<UserStreakData> get streakStream => _streakController.stream;

  /// Cache for current user's streak data
  UserStreakData? _cachedStreakData;
  DateTime _lastCacheUpdate = DateTime(2000);

  /// ═══════════════════════════════════════════════════════════════════════════
  /// INITIALIZATION
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Initialize the streaks service and start listening for updates
  Future<void> initialize() async {
    print('[STREAKS-SERVICE] Initializing streaks service');
    
    final user = _auth.currentUser;
    if (user == null) {
      print('[STREAKS-SERVICE] No user logged in, skipping initialization');
      return;
    }

    // Start listening to user's streak data
    _listenToStreakUpdates(user.uid);
    
    print('[STREAKS-SERVICE] Streaks service initialized');
  }

  /// Listen to real-time streak updates from Firestore
  void _listenToStreakUpdates(String userId) {
    _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final streakData = UserStreakData.fromFirestore(userId, data);
        _cachedStreakData = streakData;
        _lastCacheUpdate = DateTime.now();
        _streakController.add(streakData);

        // Streak break reminder (best-effort, once per day).
        unawaited(_maybeSendStreakBreakReminder(userId, streakData));
      }
    }, onError: (error) {
      print('[STREAKS-SERVICE] Error listening to streak updates: $error');
    });
  }

  Future<void> _maybeSendStreakBreakReminder(
    String userId,
    UserStreakData streakData,
  ) async {
    if (!streakData.isStreakAtRisk) return;

    final prefsService = NotificationPreferencesService();
    final notificationPrefs = await prefsService.getForCurrentUser();
    if (!notificationPrefs.streakBreakReminders) return;

    final sharedPrefs = await SharedPreferences.getInstance();
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final reminderKey = 'streak_break_reminder_last_$userId';

    final lastSent = sharedPrefs.getString(reminderKey);
    if (lastSent == todayKey) return;

    await EnhancedNotificationService().showNotification(
      title: '🔥 Streak Break Reminder',
      body: "Your streak is at risk today. Complete a quest to keep it going!",
      type: 'streak_break_reminder',
    );

    await sharedPrefs.setString(reminderKey, todayKey);
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// STREAK CALCULATION
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Calculate current streak based on last pedometer_reset_date
  /// Returns the number of consecutive days with activity
  Future<int> calculateCurrentStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;

      final data = userDoc.data()!;
      final lastResetDate = (data['lastPedometerResetDate'] as Timestamp?)?.toDate();
      final currentStreak = (data['streak'] as num?)?.toInt() ?? 0;

      // If no reset date, return stored streak
      if (lastResetDate == null) return currentStreak;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastReset = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);
      final daysDifference = today.difference(lastReset).inDays;

      // If last reset was today or yesterday, streak continues
      if (daysDifference <= 1) {
        return currentStreak;
      }
      
      // If more than 1 day passed, streak is broken
      return 0;
    } catch (e) {
      print('[STREAKS-SERVICE] Error calculating streak: $e');
      return 0;
    }
  }

  /// Check if streak is still active (last activity was today or yesterday)
  Future<bool> isStreakActive(String userId) async {
    final streak = await calculateCurrentStreak(userId);
    return streak > 0;
  }

  /// Update user's streak after quest completion
  /// Call this when a user completes a quest
  Future<void> updateStreakOnQuestCompletion(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final data = userDoc.data()!;
      final lastResetDate = (data['lastPedometerResetDate'] as Timestamp?)?.toDate();
      var currentStreak = (data['streak'] as num?)?.toInt() ?? 0;

      if (lastResetDate != null) {
        final lastReset = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);
        final daysDifference = today.difference(lastReset).inDays;

        if (daysDifference == 0) {
          // Already updated today, don't increment
          print('[STREAKS-SERVICE] Streak already updated today');
          return;
        } else if (daysDifference == 1) {
          // Continue streak
          currentStreak++;
          print('[STREAKS-SERVICE] Streak continued: $currentStreak days');
        } else {
          // Streak broken, start new
          currentStreak = 1;
          print('[STREAKS-SERVICE] New streak started: 1 day');
        }
      } else {
        // First activity ever
        currentStreak = 1;
        print('[STREAKS-SERVICE] First streak started: 1 day');
      }

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'streak': currentStreak,
        'lastPedometerResetDate': Timestamp.fromDate(now),
        'lastActivityDate': Timestamp.fromDate(now),
      });

      // Check and award streak badges
      await _checkAndAwardStreakBadges(userId, currentStreak);

    } catch (e) {
      print('[STREAKS-SERVICE] Error updating streak: $e');
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// BADGE MANAGEMENT
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Check and award streak-based badges
  Future<void> _checkAndAwardStreakBadges(String userId, int streak) async {
    final badgesToAward = <AchievementBadge>[];

    // Check streak milestones
    if (streak == 3) {
      badgesToAward.add(AchievementBadge.streakStarter(userId));
    } else if (streak == 7) {
      badgesToAward.add(AchievementBadge.weekWarrior(userId));
    } else if (streak == 14) {
      badgesToAward.add(AchievementBadge.fortnightMaster(userId));
    } else if (streak == 30) {
      badgesToAward.add(AchievementBadge.monthlyLegend(userId));
    } else if (streak == 100) {
      badgesToAward.add(AchievementBadge.centuryChampion(userId));
    }

    // Award badges
    for (final badge in badgesToAward) {
      await _awardBadge(userId, badge);
    }
  }

  /// Check and award step-based badges
  Future<void> checkAndAwardStepBadges(String userId, int dailySteps) async {
    final badgesToAward = <AchievementBadge>[];

    if (dailySteps >= 10000) {
      badgesToAward.add(AchievementBadge.stepMaster10k(userId));
    }
    if (dailySteps >= 50000) {
      badgesToAward.add(AchievementBadge.stepLegend50k(userId));
    }

    for (final badge in badgesToAward) {
      await _awardBadge(userId, badge);
    }
  }

  /// Award a badge to a user
  Future<void> _awardBadge(String userId, AchievementBadge badge) async {
    try {
      // Check if user already has this badge
      final existingBadge = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .where('type', isEqualTo: badge.type)
          .where('tier', isEqualTo: badge.tier)
          .get();

      if (existingBadge.docs.isNotEmpty) {
        print('[STREAKS-SERVICE] Badge already awarded: ${badge.name}');
        return;
      }

      // Add badge to user's collection
      final badgeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc();

      await badgeRef.set(badge.toFirestore());

      // Create notification for badge earned
      await _createBadgeNotification(userId, badge);

      print('[STREAKS-SERVICE] Badge awarded: ${badge.name}');
    } catch (e) {
      print('[STREAKS-SERVICE] Error awarding badge: $e');
    }
  }

  /// Create notification for badge earned
  Future<void> _createBadgeNotification(String userId, AchievementBadge badge) async {
    try {
      final notificationRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc();

      await notificationRef.set({
        'id': notificationRef.id,
        'type': 'badge_earned',
        'title': '🏆 New Badge Earned!',
        'message': 'Congratulations! You earned the "${badge.name}" badge!',
        'badgeType': badge.type,
        'badgeName': badge.name,
        'badgeIcon': badge.icon,
        'badgeColor': badge.color,
        'read': false,
        'createdAt': Timestamp.now(),
      });

      // Update unread count
      await _firestore.collection('users').doc(userId).update({
        'hasUnreadNotifications': true,
        'unreadNotificationsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('[STREAKS-SERVICE] Error creating badge notification: $e');
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// GETTERS & QUERIES
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Get all badges earned by a user
  Future<List<AchievementBadge>> getUserBadges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .orderBy('awardedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AchievementBadge.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('[STREAKS-SERVICE] Error fetching badges: $e');
      return [];
    }
  }

  /// Stream user's badges for real-time updates
  Stream<List<AchievementBadge>> streamUserBadges(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('badges')
        .orderBy('awardedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AchievementBadge.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Get user's current streak data
  Future<UserStreakData?> getUserStreakData(String userId) async {
    // Return cached data if recent
    if (_cachedStreakData != null && 
        DateTime.now().difference(_lastCacheUpdate) < const Duration(minutes: 1)) {
      return _cachedStreakData;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      return UserStreakData.fromFirestore(userId, userDoc.data()!);
    } catch (e) {
      print('[STREAKS-SERVICE] Error fetching streak data: $e');
      return null;
    }
  }

  /// Get streak tier for visual display
  StreakTier getStreakTier(int streak) {
    if (streak >= 30) return StreakTier.legendary;
    if (streak >= 21) return StreakTier.epic;
    if (streak >= 14) return StreakTier.glowing;
    if (streak >= 7) return StreakTier.powered;
    return StreakTier.normal;
  }

  /// Get next streak milestone
  int getNextMilestone(int currentStreak) {
    if (currentStreak < 3) return 3;
    if (currentStreak < 7) return 7;
    if (currentStreak < 14) return 14;
    if (currentStreak < 30) return 30;
    if (currentStreak < 100) return 100;
    return ((currentStreak ~/ 100) + 1) * 100;
  }

  /// Dispose the service
  void dispose() {
    _streakController.close();
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// DATA MODELS
/// ═══════════════════════════════════════════════════════════════════════════════

/// User Streak Data Model
class UserStreakData {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final DateTime? lastResetDate;
  final int totalDaysActive;

  UserStreakData({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    this.lastResetDate,
    required this.totalDaysActive,
  });

  factory UserStreakData.fromFirestore(String userId, Map<String, dynamic> data) {
    return UserStreakData(
      userId: userId,
      currentStreak: (data['streak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
      lastActivityDate: (data['lastActivityDate'] as Timestamp?)?.toDate(),
      lastResetDate: (data['lastPedometerResetDate'] as Timestamp?)?.toDate(),
      totalDaysActive: (data['totalDaysActive'] as num?)?.toInt() ?? 0,
    );
  }

  /// Get formatted last activity date
  String get formattedLastActivity {
    if (lastActivityDate == null) return 'Never';
    return DateFormat('MMM d, yyyy').format(lastActivityDate!);
  }

  /// Check if streak is at risk (no activity today and yesterday)
  bool get isStreakAtRisk {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(lastActivityDate!.year, lastActivityDate!.month, lastActivityDate!.day);
    final daysDifference = today.difference(lastActivity).inDays;
    return daysDifference == 1 && currentStreak > 0;
  }
}

/// Achievement Badge Model
class AchievementBadge {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String type;
  final String tier;
  final String icon;
  final String color;
  final DateTime awardedAt;
  final Map<String, dynamic>? metadata;

  AchievementBadge({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    required this.icon,
    required this.color,
    required this.awardedAt,
    this.metadata,
  });

  /// Factory constructors for different badge types
  factory AchievementBadge.streakStarter(String userId) {
    return AchievementBadge(
      id: '',
      userId: userId,
      name: 'Streak Starter',
      description: 'Completed quests for 3 days in a row!',
      type: 'streak',
      tier: 'bronze',
      icon: '🔥',
      color: '#CD7F32',
      awardedAt: DateTime.now(),
    );
  }

  factory AchievementBadge.weekWarrior(String userId) {
    return AchievementBadge(
      id: '',
      userId: userId,
      name: 'Week Warrior',
      description: 'Amazing! 7-day streak completed!',
      type: 'streak',
      tier: 'silver',
      icon: '⚡',
      color: '#C0C0C0',
      awardedAt: DateTime.now(),
    );
  }

  factory AchievementBadge.fortnightMaster(String userId) {
    return AchievementBadge(
      id: '',
      userId: userId,
      name: 'Fortnight Master',
      description: 'Incredible dedication! 14-day streak!',
      type: 'streak',
      tier: 'gold',
      icon: '🌟',
      color: '#FFD700',
      awardedAt: DateTime.now(),
    );
  }

  factory AchievementBadge.monthlyLegend(String userId) {
    return AchievementBadge(
      id: '',
      userId: userId,
      name: 'Monthly Legend',
      description: 'Legendary status! 30-day streak!',
      type: 'streak',
      tier: 'platinum',
      icon: '👑',
      color: '#E5E4E2',
      awardedAt: DateTime.now(),
    );
  }

  factory AchievementBadge.centuryChampion(String userId) {
    return AchievementBadge(
      id: '',
      userId: userId,
      name: 'Century Champion',
      description: 'Unstoppable! 100-day streak!',
      type: 'streak',
      tier: 'diamond',
      icon: '💎',
      color: '#B9F2FF',
      awardedAt: DateTime.now(),
    );
  }

  factory AchievementBadge.stepMaster10k(String userId) {
    return AchievementBadge(
      id: '',
      userId: userId,
      name: 'Step Master',
      description: 'Walked 10,000 steps in a single day!',
      type: 'steps',
      tier: 'silver',
      icon: '👟',
      color: '#C0C0C0',
      awardedAt: DateTime.now(),
      metadata: {'steps': 10000},
    );
  }

  factory AchievementBadge.stepLegend50k(String userId) {
    return AchievementBadge(
      id: '',
      userId: userId,
      name: 'Step Legend',
      description: 'Epic achievement! 50,000 steps in one day!',
      type: 'steps',
      tier: 'gold',
      icon: '🏃',
      color: '#FFD700',
      awardedAt: DateTime.now(),
      metadata: {'steps': 50000},
    );
  }

  factory AchievementBadge.fromFirestore(String id, Map<String, dynamic> data) {
    return AchievementBadge(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Unknown Badge',
      description: data['description'] ?? '',
      type: data['type'] ?? 'unknown',
      tier: data['tier'] ?? 'bronze',
      icon: data['icon'] ?? '🏅',
      color: data['color'] ?? '#CD7F32',
      awardedAt: (data['awardedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'type': type,
      'tier': tier,
      'icon': icon,
      'color': color,
      'awardedAt': Timestamp.fromDate(awardedAt),
      'metadata': metadata,
    };
  }
}
