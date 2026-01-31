import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Models/quest.dart';
import '../../Services/DataServices/dataServices.dart';
import '../../Services/Health/health_connect_service.dart';
import '../../utils/constants.dart';

class QuestServiceFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DataService _dataService;

  // Constructor to inject DataService
  QuestServiceFirestore({DataService? dataService}) {
    _dataService = dataService ?? DataService();
  }
 
  //  user  UID
  String? get _uid => _auth.currentUser?.uid;

  // User ke quests subcollection  reference
  CollectionReference<Map<String, dynamic>> get _questsRef {
    if (_uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_uid).collection('quests');
  }

  // 1. Add new quest - captures baseline health data at creation time
  Future<String> addQuest(Quest quest) async {
    try {
      // Fetch current health data as baseline (progress starts from HERE)
      int baselineSteps = 0;
      double baselineDistanceKm = 0.0;
      double baselineCalories = 0.0;
      int baselineActiveMinutes = 0;
      double baselineSleepHours = 0.0;

      try {
        final healthService = HealthConnectService();
        await healthService.initialize();
        final summary = await healthService.getAllActivityData();
        baselineSteps = summary.steps;
        baselineDistanceKm = summary.distanceKm;
        baselineCalories = summary.calories;
        baselineActiveMinutes = summary.activeMinutes;
        baselineSleepHours = summary.sleepHours;
        print('QuestService: Baseline captured - steps=$baselineSteps, dist=$baselineDistanceKm, cal=$baselineCalories, active=$baselineActiveMinutes, sleep=$baselineSleepHours');
      } catch (e) {
        print('QuestService: WARNING - could not fetch baseline, using 0: $e');
      }

      final questMap = {
        'title': quest.title,
        'description': quest.description,
        'type': quest.type.toString().split('.').last,
        'difficulty': quest.difficulty.toString().split('.').last,
        'xpReward': quest.xpReward,
        'statBonus': quest.statBonus,
        'goldReward': quest.goldReward,
        'isCompleted': quest.isCompleted,
        'dueDate': quest.dueDate != null ? Timestamp.fromDate(quest.dueDate!) : null,
        'duration': quest.duration,
        'icon': quest.icon.toString(),
        'gradientColors': quest.gradientColors.map((color) => color.value.toRadixString(16)).toList(),
        'createdAt': Timestamp.now(),
        'isDaily': quest.isDaily,
        'isCustom': quest.isCustom,
        // Activity tracking fields
        'activityType': quest.activityType?.toString().split('.').last,
        'targetSteps': quest.targetSteps,
        'targetDistanceKm': quest.targetDistanceKm,
        'targetDurationMinutes': quest.targetDurationMinutes,
        // Baseline fields - captured at creation, NEVER overwritten
        'baselineSteps': baselineSteps,
        'baselineDistanceKm': baselineDistanceKm,
        'baselineCalories': baselineCalories,
        'baselineActiveMinutes': baselineActiveMinutes,
        'baselineSleepHours': baselineSleepHours,
        // Progress tracking fields (initialized to 0)
        'currentSteps': 0,
        'currentDistanceKm': 0.0,
        'currentDurationMinutes': 0,
        'trackingStartedAt': Timestamp.now(),
        'lastUpdatedAt': Timestamp.now(),
        'detectedActivity': null,
      };

      // Add to Firestore aur generated ID le lo
      final docRef = await _questsRef.add(questMap);
      print('QuestService: Quest added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('QuestService: Error adding quest: $e');
      rethrow;
    }
  }

  // 2. User ke saare quests fetch karne ke liye (Stream)
  Stream<List<Quest>> userQuestsStream({bool includeCompleted = true}) {
    try {
      Query<Map<String, dynamic>> query = _questsRef;

      // Temporarily removed isDeleted filter to avoid index requirement
      // query = query.where('isDeleted', isEqualTo: false);

      if (!includeCompleted) {
        query = query.where('isCompleted', isEqualTo: false);
      }

      return query.snapshots().map<List<Quest>>((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Quest(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            type: _stringToQuestType(data['type'] ?? 'custom'),
            difficulty: _stringToDifficulty(data['difficulty'] ?? 'medium'),
            xpReward: data['xpReward'] ?? 10,
            statBonus: data['statBonus'] ?? 5,
            goldReward: data['goldReward'] ?? 5,
            isCompleted: data['isCompleted'] ?? !(data['isActive'] ?? true),  // Support both isCompleted and isActive fields
            dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
            duration: data['duration'],
            icon: _stringToIcon(data['icon'] ?? 'Icons.star'),
            gradientColors: (data['gradientColors'] as List<dynamic>?)
                ?.map((colorStr) => Color(int.parse(colorStr, radix: 16)))
                .toList() ?? [AppColors.primaryPurple, AppColors.accentBlue],
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isDaily: data['isDaily'] as bool? ?? false,
            isCustom: data['isCustom'] as bool? ?? false,
            isDeleted: data['isDeleted'] as bool? ?? false,
            // Activity tracking fields - CRITICAL: restore from backend
            activityType: _stringToQuestActivityType(data['activityType']),
            targetSteps: data['targetSteps'] as int?,
            targetDistanceKm: (data['targetDistanceKm'] as num?)?.toDouble(),
            targetDurationMinutes: data['targetDurationMinutes'] as int?,
            // Baseline fields - CRITICAL: restore from backend, never overwrite
            baselineSteps: (data['baselineSteps'] as num?)?.toInt() ?? 0,
            baselineDistanceKm: (data['baselineDistanceKm'] as num?)?.toDouble() ?? 0.0,
            baselineCalories: (data['baselineCalories'] as num?)?.toDouble() ?? 0.0,
            baselineActiveMinutes: (data['baselineActiveMinutes'] as num?)?.toInt() ?? 0,
            baselineSleepHours: (data['baselineSleepHours'] as num?)?.toDouble() ?? 0.0,
            // Progress tracking fields - CRITICAL: restore from backend so progress doesn't reset
            currentSteps: data['currentSteps'] as int? ?? 0,
            currentDistanceKm: (data['currentDistanceKm'] as num?)?.toDouble() ?? 0.0,
            currentDurationMinutes: data['currentDurationMinutes'] as int? ?? 0,
            trackingStartedAt: (data['trackingStartedAt'] as Timestamp?)?.toDate(),
            lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate(),
            detectedActivity: data['detectedActivity'] as String?,
          );
        }).where((quest) => !quest.isDeleted).toList(); // Filter out deleted quests
      });
    } catch (e) {
      print('QuestService: Error creating quest stream: $e');
      return Stream.value([]);
    }
  }

  // Get quest by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getQuestById(String questId) async {
    return await _questsRef.doc(questId).get();
  }

  // Delete quest method (soft delete)
  Future<void> deleteQuest(String questId) async {
    try {
      print('QuestService: Attempting to delete quest $questId');
      await _questsRef.doc(questId).update({'isDeleted': true});
      print('QuestService: Quest $questId successfully marked as deleted');
    } catch (e) {
      print('QuestService: Error deleting quest $questId: $e');
      rethrow;
    }
  }

  // Permanent delete quest method - ACTUALLY removes from Firestore
  Future<void> permanentlyDeleteQuest(String questId) async {
    try {
      print('QuestService: Attempting to permanently delete quest $questId');
      
      // Delete the document completely from Firestore
      await _questsRef.doc(questId).delete();
      print('QuestService: Quest $questId permanently deleted from Firestore');
      
    } catch (e) {
      print('QuestService: Error permanently deleting quest $questId: $e');
      rethrow;
    }
  }

  // Update quest method
  Future<void> updateQuest(Quest quest) async {
    try {
      final questMap = {
        'title': quest.title,
        'description': quest.description,
        'type': quest.type.toString().split('.').last,
        'difficulty': quest.difficulty.toString().split('.').last,
        'xpReward': quest.xpReward,
        'statBonus': quest.statBonus,
        'goldReward': quest.goldReward,
        'isCompleted': quest.isCompleted,
        'dueDate': quest.dueDate != null ? Timestamp.fromDate(quest.dueDate!) : null,
        'duration': quest.duration,
        'icon': quest.icon.toString(),
        'gradientColors': quest.gradientColors.map((color) => color.value.toRadixString(16)).toList(),
        'isDaily': quest.isDaily,
        'isCustom': quest.isCustom,
        // Activity tracking fields
        'activityType': quest.activityType?.toString().split('.').last,
        'targetSteps': quest.targetSteps,
        'targetDistanceKm': quest.targetDistanceKm,
        'targetDurationMinutes': quest.targetDurationMinutes,
        // Progress tracking fields - CRITICAL: persist progress to backend
        'currentSteps': quest.currentSteps,
        'currentDistanceKm': quest.currentDistanceKm,
        'currentDurationMinutes': quest.currentDurationMinutes,
        'trackingStartedAt': quest.trackingStartedAt != null ? Timestamp.fromDate(quest.trackingStartedAt!) : null,
        'lastUpdatedAt': Timestamp.now(),
        'detectedActivity': quest.detectedActivity,
      };

      await _questsRef.doc(quest.id).update(questMap);
      print('QuestService: Quest ${quest.id} updated successfully');
    } catch (e) {
      print('QuestService: Error updating quest: $e');
      rethrow;
    }
  }

  /// Mark quest as completed in Firestore
  Future<void> completeQuest(String questId, {int? finalSteps, int? finalMinutes}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      print('QuestService: Attempting to complete quest $questId for user ${user.uid}');

      final updateData = {
        'isCompleted': true,
        'isActive': false,
        'status': 'completed',
        'completedAt': Timestamp.now(),
        'lastUpdatedAt': Timestamp.now(),
      };

      // Add final progress if provided
      if (finalSteps != null) {
        updateData['currentSteps'] = finalSteps;
      }
      if (finalMinutes != null) {
        updateData['currentDurationMinutes'] = finalMinutes;
      }

      print('QuestService: Update data: $updateData');
      await _questsRef.doc(questId).update(updateData);
      print('QuestService: ✅ Quest $questId marked as completed in Firestore successfully');
    } catch (e) {
      print('QuestService: ❌ Error completing quest $questId: $e');
      rethrow;
    }
  }

  // All quests (completed + active)
  Stream<List<Quest>> allUserQuestsStream() {
    return userQuestsStream(includeCompleted: true);
  }

  // Active quests (not completed)
  Stream<List<Quest>> activeQuestsStream() {
    return userQuestsStream(includeCompleted: false);
  }

  // Completed quests
  Stream<List<Quest>> completedQuestsStream() {
    return userQuestsStream(includeCompleted: true).map(
          (quests) => quests.where((q) => q.isCompleted).toList(),
    );
  }

  /// 🎯 CRITICAL: Get all incomplete quests for resuming tracking when app reopens
  Future<List<Quest>> getIncompleteQuests() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[QuestServiceFirestore] getIncompleteQuests: No user logged in');
        return [];
      }

      debugPrint('[QuestServiceFirestore] Fetching incomplete quests for user: ${user.uid}');
      
      // FIXED: Removed userId filter - quests are already in the user's subcollection
      // so they automatically belong to the current user
      final querySnapshot = await _questsRef
          .where('isCompleted', isEqualTo: false)
          .get();

      final quests = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quest(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: _stringToQuestType(data['type'] ?? 'custom'),
          difficulty: _stringToDifficulty(data['difficulty'] ?? 'medium'),
          xpReward: data['xpReward'] ?? 10,
          statBonus: data['statBonus'] ?? 5,
          goldReward: data['goldReward'] ?? 5,
          isCompleted: data['isCompleted'] ?? false,
          dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
          duration: data['duration'],
          icon: _stringToIcon(data['icon'] ?? 'Icons.star'),
          gradientColors: (data['gradientColors'] as List<dynamic>?)
              ?.map((colorStr) => Color(int.parse(colorStr.toString(), radix: 16)))
              .toList() ?? [AppColors.primaryPurple, AppColors.accentBlue],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isDaily: data['isDaily'] as bool? ?? false,
          isCustom: data['isCustom'] as bool? ?? false,
          isDeleted: data['isDeleted'] as bool? ?? false,
          activityType: _stringToQuestActivityType(data['activityType']),
          targetSteps: data['targetSteps'] as int?,
          targetDistanceKm: (data['targetDistanceKm'] as num?)?.toDouble(),
          targetDurationMinutes: data['targetDurationMinutes'] as int?,
          // Baseline fields - CRITICAL: restore from backend
          baselineSteps: (data['baselineSteps'] as num?)?.toInt() ?? 0,
          baselineDistanceKm: (data['baselineDistanceKm'] as num?)?.toDouble() ?? 0.0,
          baselineCalories: (data['baselineCalories'] as num?)?.toDouble() ?? 0.0,
          baselineActiveMinutes: (data['baselineActiveMinutes'] as num?)?.toInt() ?? 0,
          baselineSleepHours: (data['baselineSleepHours'] as num?)?.toDouble() ?? 0.0,
          currentSteps: data['currentSteps'] as int? ?? 0,
          currentDistanceKm: (data['currentDistanceKm'] as num?)?.toDouble() ?? 0.0,
          currentDurationMinutes: data['currentDurationMinutes'] as int? ?? 0,
          trackingStartedAt: (data['trackingStartedAt'] as Timestamp?)?.toDate(),
          lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate(),
          detectedActivity: data['detectedActivity'] as String?,
        );
      }).toList();

      debugPrint('[QuestServiceFirestore] Found ${quests.length} incomplete quests');
      return quests;
    } catch (e) {
      debugPrint('[QuestServiceFirestore] ERROR fetching incomplete quests: $e');
      return [];
    }
  }

  // Helper functions (enum/string conversion)
  QuestType _stringToQuestType(String typeStr) {
    switch (typeStr) {
      case 'health': return QuestType.health;
      case 'study': return QuestType.study;
      case 'exercise': return QuestType.exercise;
      case 'social': return QuestType.social;
      case 'sleep': return QuestType.sleep;
      default: return QuestType.custom;
    }
  }

  QuestActivityType _stringToQuestActivityType(String? typeStr) {
    switch (typeStr) {
      case 'walking': return QuestActivityType.walking;
      case 'running': return QuestActivityType.running;
      case 'driving': return QuestActivityType.driving;
      case 'cycling': return QuestActivityType.cycling;
      case 'stationary': return QuestActivityType.stationary;
      default: return QuestActivityType.unknown;
    }
  }

  /// CRITICAL: Update quest progress in real-time to backend (Firestore)
  /// This ensures progress persists across app restarts
  Future<void> updateQuestProgress({
    required String questId,
    int? currentSteps,
    double? currentDistanceKm,
    int? currentDurationMinutes,
    String? detectedActivity,
  }) async {
    try {
      final updateMap = <String, dynamic>{
        'lastUpdatedAt': Timestamp.now(),
      };
      
      if (currentSteps != null) updateMap['currentSteps'] = currentSteps;
      if (currentDistanceKm != null) updateMap['currentDistanceKm'] = currentDistanceKm;
      if (currentDurationMinutes != null) updateMap['currentDurationMinutes'] = currentDurationMinutes;
      if (detectedActivity != null) updateMap['detectedActivity'] = detectedActivity;
      
      await _questsRef.doc(questId).update(updateMap);
      print('QuestService: Progress updated for quest $questId');
    } catch (e) {
      print('QuestService: Error updating quest progress: $e');
      rethrow;
    }
  }

  /// Mark quest as completed and reset progress
  Future<void> markQuestCompleted(String questId) async {
    try {
      await _questsRef.doc(questId).update({
        'isCompleted': true,
        'lastUpdatedAt': Timestamp.now(),
      });
      print('QuestService: Quest $questId marked as completed');
    } catch (e) {
      print('QuestService: Error completing quest: $e');
      rethrow;
    }
  }

  QuestDifficulty _stringToDifficulty(String diffStr) {
    switch (diffStr) {
      case 'easy': return QuestDifficulty.easy;
      case 'hard': return QuestDifficulty.hard;
      default: return QuestDifficulty.medium;
    }
  }

  IconData _stringToIcon(String iconStr) {
    if (iconStr.contains('fitness_center')) return Icons.fitness_center;
    if (iconStr.contains('menu_book')) return Icons.menu_book;
    if (iconStr.contains('water_drop')) return Icons.water_drop;
    if (iconStr.contains('people')) return Icons.people;
    if (iconStr.contains('bedtime')) return Icons.bedtime;
    if (iconStr.contains('directions_walk')) return Icons.directions_walk;
    if (iconStr.contains('directions_car')) return Icons.directions_car;
    if (iconStr.contains('pedal_bike')) return Icons.pedal_bike;
    if (iconStr.contains('keyboard')) return Icons.keyboard;
    return Icons.star;
  }
}
