import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Models/users.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Services/QuestFirestore/questfirestore.dart';
import 'package:real_life_rpg/Services/ARTrigger/ar_trigger_service.dart';
import 'package:real_life_rpg/Services/Notifications/notification_service.dart';
import 'package:real_life_rpg/Services/AnimatedProgress/animated_progress_service.dart';
import 'package:real_life_rpg/Services/Challenge/challenge_service.dart';
import 'package:real_life_rpg/Services/Streaks/streaks_service.dart';
import 'package:real_life_rpg/Services/Achievements/achievement_service.dart';
import 'package:real_life_rpg/Services/CharacterSelection/character_unlock_service.dart';

class DataService with ChangeNotifier{
  // Singleton pattern - ensures all parts of the app use the same instance
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _currentUserData;
  UserModel? get currentUserData => _currentUserData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Performance optimization: Debounce timer for rapid updates
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  
  // Performance optimization: Cache for user data
  Map<String, UserModel> _userCache = {};
  
  // Performance optimization: Stream subscription management
  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;

  // Track current user ID for listener management
  String? _currentListeningUid;

  // CRITICAL: Track quests currently being processed to prevent duplicate rewards
  // This prevents race conditions when multiple completion triggers fire simultaneously
  final Set<String> _processingQuests = {};

  Future<void> fetchUserData(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        _currentUserData = UserModel.fromFirestore(
          docSnapshot.data()!,
          uid,
        );
        print('User data fetched: ${_currentUserData?.username} (Level: ${_currentUserData?.level})');
      } else {
        _error = 'User document not found for UID: $uid';
        print(_error);
      }
    } catch (e) {
      _error = 'Error fetching user data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch other user data without affecting current user data (for leaderboard profile viewing)
  Future<UserModel?> fetchOtherUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final otherUser = UserModel.fromFirestore(
          docSnapshot.data()!,
          uid,
        );
        print('Other user data fetched: ${otherUser.username} (Level: ${otherUser.level})');
        return otherUser;
      } else {
        print('Other user document not found for UID: $uid');
        return null;
      }
    } catch (e) {
      print('Error fetching other user data: $e');
      return null;
    }
  }



// for real time update
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot.data()!, uid);
      }
      return null;
    });
  }


  // Real-time listen karo.. with duplicate prevention
  void startListeningToUser(String uid) async {
    // 🎯 CRITICAL: Prevent duplicate listeners for same user
    if (_currentListeningUid == uid && _userStreamSubscription != null) {
      print('DataService: Already listening to user $uid, skipping duplicate listener');
      return;
    }
    
    // Cancel any existing listener before creating new one
    if (_userStreamSubscription != null) {
      print('DataService: Cancelling existing listener for user $_currentListeningUid');
      await _userStreamSubscription!.cancel();
      _userStreamSubscription = null;
    }
    
    _currentListeningUid = uid;
    print('DataService: Starting to listen for user $uid');
    
    // First, try to get the user document to see if it exists
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (docSnapshot.exists) {
        _currentUserData = UserModel.fromFirestore(docSnapshot.data()!, uid);
        notifyListeners();
        print('DataService: User data loaded: Level ${_currentUserData?.level}, Coins ${_currentUserData?.coins}');
      } else {
        print('DataService: No user document found for uid: $uid');
        print('DataService: Waiting for AuthService to create user document...');
        _currentUserData = null;
        notifyListeners();
      }
    } catch (e) {
      print('DataService: Error fetching user document (non-blocking): $e');
    }
    
    // Now start real-time listening with proper subscription tracking
    try {
      _userStreamSubscription = _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          _currentUserData = UserModel.fromFirestore(snapshot.data()!, uid);
          notifyListeners();
          print('DataService: Real-time update: Level ${_currentUserData?.level}, Coins ${_currentUserData?.coins}, XP ${_currentUserData?.currentXP}');
        } else {
          print('DataService: User document deleted in real-time stream');
          _currentUserData = null;
          notifyListeners();
        }
      }, onError: (error) {
        print('DataService: Real-time stream error: $error');
      });
      print('DataService: Real-time listener established for user $uid');
    } catch (e) {
      print('DataService: Error starting real-time listener (non-blocking): $e');
    }
  }
  
  // Stop listening to user data (call on logout)
  void stopListeningToUser() async {
    if (_userStreamSubscription != null) {
      print('DataService: Stopping user data listener');
      await _userStreamSubscription!.cancel();
      _userStreamSubscription = null;
      _currentListeningUid = null;
    }
  }

  // Enhanced quest completion with real-time UI updates and level progression
  Future<bool> completeQuestAndAwardRewards(Quest quest) async {
    print('[DataService] ===========================================');
    print('[DataService] completeQuestAndAwardRewards called for quest: ${quest.id}, title: ${quest.title}');
    print('[DataService] Quest rewards: XP=${quest.xpReward}, Coins=${quest.goldReward}');
    print('[DataService] Quest isCompleted: ${quest.isCompleted}');
    print('[DataService] Current _processingQuests: $_processingQuests');
    
    // Validate quest ID
    if (quest.id == null || quest.id!.isEmpty) {
      print('[DataService] ERROR: Quest ID is null or empty, cannot process!');
      return false;
    }
    
    // Check if this quest is already being processed (prevent duplicate rewards)
    if (_processingQuests.contains(quest.id)) {
      print('[DataService] Quest ${quest.id} ALREADY being processed, skipping duplicate');
      return false;
    }
    
    // Check if quest rewards were already awarded (quest may be marked complete from sensor service)
    // We still want to award rewards even if isCompleted is true, as long as we haven't processed it yet
    if (quest.isCompleted) {
      print('[DataService] Quest is marked complete (from sensor), proceeding with reward award...');
    }

    // Add quest to processing set to prevent concurrent processing
    _processingQuests.add(quest.id!);
    print('[DataService] Added ${quest.id} to processing set');

    try {
      _isLoading = true;
      notifyListeners();

      final uid = _auth.currentUser?.uid;
      print('[DataService] Current user UID: $uid');
      
      if (uid == null) {
        print('[DataService] No user logged in, returning false');
        return false;
      }

      // Check if user data is available, if not, fetch it first
      if (_currentUserData == null) {
        print('[DataService] User data not loaded, fetching...');
        await fetchUserData(uid);
        
        if (_currentUserData == null) {
          print('[DataService] Failed to fetch user data, returning false');
          return false;
        }
      }
      print('[DataService] User data loaded: level=${_currentUserData!.level}, xp=${_currentUserData!.currentXP}, coins=${_currentUserData!.coins}');

      // Store old values for comparison
      final oldLevel = _currentUserData!.level;
      final oldXP = _currentUserData!.currentXP;
      final oldCoins = _currentUserData!.coins;
      final oldTotalQuestsCompleted = _currentUserData!.totalQuestsCompleted;

      // Calculate new values (mutable for transaction)
      int newXP = oldXP + quest.xpReward;
      int newCoins = oldCoins + quest.goldReward;

      // Check if user leveled up (multiple levels possible)
      int newLevel = oldLevel;
      int xpForNextLevel = _currentUserData!.xpForNextLevel;
      bool leveledUp = false;
      int levelsGained = 0;
      
      // Handle multiple level-ups in case of large XP rewards
      int remainingXP = newXP;
      while (remainingXP >= xpForNextLevel) {
        remainingXP -= xpForNextLevel;
        newLevel++;
        levelsGained++;
        xpForNextLevel = newLevel * 100;
        leveledUp = true;
      }
      
      // Final XP after level-ups (mutable for transaction)
      int finalXP = remainingXP;

      // Update user document with new XP, coins, and level using TRANSACTION
      print('[DataService] Updating Firestore with: XP=$finalXP, coins=$newCoins, level=$newLevel');
      final userRef = _firestore.collection('users').doc(uid);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) throw Exception('User document not found');

        final data = snapshot.data()!;
        final currentLevel = (data['level'] as num?)?.toInt() ?? oldLevel;
        final currentXP = (data['currentXP'] as num?)?.toInt() ?? oldXP;
        final currentCoins = (data['coins'] as num?)?.toInt() ?? oldCoins;
        final currentTotal = (data['totalQuestsCompleted'] as num?)?.toInt() ?? oldTotalQuestsCompleted;

        // Recalculate from transaction-fresh values
        final txNewXP = currentXP + quest.xpReward;
        final txNewCoins = currentCoins + quest.goldReward;

        int txNewLevel = currentLevel;
        int txXpForNextLevel = (data['xpForNextLevel'] as num?)?.toInt() ?? currentLevel * 100;
        bool txLeveledUp = false;
        int txRemainingXP = txNewXP;
        while (txRemainingXP >= txXpForNextLevel) {
          txRemainingXP -= txXpForNextLevel;
          txNewLevel++;
          txXpForNextLevel = txNewLevel * 100;
          txLeveledUp = true;
        }

        transaction.update(userRef, {
          'currentXP': txRemainingXP,
          'coins': txNewCoins,
          'level': txNewLevel,
          'xpForNextLevel': txXpForNextLevel,
          'updatedAt': Timestamp.now(),
          'lastQuestCompleted': Timestamp.now(),
          'totalQuestsCompleted': currentTotal + 1,
        });

        // Update local values from transaction results
        newLevel = txNewLevel;
        finalXP = txRemainingXP;
        newCoins = txNewCoins;
        xpForNextLevel = txXpForNextLevel;
        leveledUp = txLeveledUp;
      });
      print('[DataService] Firestore transaction successful');

      // Mark the quest as completed in Firestore
      if (uid != null && quest.id != null) {
        await _firestore.collection('users').doc(uid).collection('quests').doc(quest.id).update({
          'isCompleted': true,
          'completedAt': Timestamp.now(),
        });
      }

      // Streak update: keeps streak-based achievements deterministic.
      final streaksService = StreaksService();
      await streaksService.updateStreakOnQuestCompletion(uid);

      // Achievement update: quests + level + streak + social (partyId from user doc).
      await AchievementService().updateAchievementProgress(
        uid,
        questsCompleted: oldTotalQuestsCompleted + 1,
        level: newLevel,
      );

      // Challenge match integration: update realtime challenge progress.
      final challengeService = ChallengeService();
      await challengeService.syncMyProgressFromQuestCompletion(
        questId: quest.id,
        questType: quest.type.name,
        xpGained: quest.xpReward,
      );

      // SEND NOTIFICATIONS for quest completion
      final notificationService = NotificationService();
      await notificationService.showQuestCompletedNotification(
        quest.title,
        quest.xpReward,
        quest.goldReward,
      );
      
      // SEND LEVEL UP NOTIFICATION if user leveled up
      if (leveledUp) {
        await notificationService.showLevelUpNotification(newLevel);
      }
      
      // CHECK FOR NEW CHARACTER UNLOCKS
      // This triggers when user levels up or earns enough coins
      final unlockService = CharacterUnlockService();
      final newlyUnlocked = await unlockService.checkForNewUnlocks(
        newLevel,
        newCoins,
        finalXP,
      );
      
      // Store the newly unlocked characters for later display
      // The unlock celebration will be shown in the UI layer
      if (newlyUnlocked.isNotEmpty) {
        print('[DataService] New characters unlocked: ${newlyUnlocked.map((c) => c.name).join(', ')}');
      }
      
      // Trigger animated progress updates
      print('[DataService] 🎮 Triggering animated progress updates');
      final progressService = AnimatedProgressService.instance;
      progressService.animateQuestCompletion(
        currentXP: oldXP,
        xpGained: quest.xpReward,
        totalXPForNextLevel: xpForNextLevel,
        currentCoins: oldCoins,
        coinsGained: quest.goldReward,
        currentLevel: oldLevel,
        newLevel: leveledUp ? newLevel : null,
      );
      print('[DataService] 🎮 Animated progress updates triggered successfully');

      // Update local data immediately for responsive UI
      _currentUserData = UserModel(
        uid: _currentUserData!.uid,
        email: _currentUserData!.email,
        username: _currentUserData!.username,
        level: newLevel,
        currentXP: finalXP,
        xpForNextLevel: xpForNextLevel,
        coins: newCoins,
        streak: _currentUserData!.streak,
        createdAt: _currentUserData!.createdAt,
        totalQuestsCreated: _currentUserData!.totalQuestsCreated,
        totalQuestsCompleted: _currentUserData!.totalQuestsCompleted + 1,
      );

      _isLoading = false;
      notifyListeners();
      
      print('[DataService] Quest completion SUCCESS - New values: level=$newLevel, xp=$finalXP, coins=$newCoins');
      return true;
    } catch (e, stackTrace) {
      _error = 'Error completing quest: $e';
      print('[DataService] ERROR: $_error');
      print('[DataService] Stack trace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      // Always remove quest from processing set to allow future completions
      if (quest.id != null) {
        _processingQuests.remove(quest.id);
        print('[DataService] Quest ${quest.id} removed from processing set');
      }
    }
  }

  // Enhanced quest completion with AR trigger support
  Future<bool> completeQuestWithARTrigger(Quest quest, BuildContext context) async {
    final oldLevel = _currentUserData?.level ?? 1;
    
    try {
      // First, complete the quest and award rewards
      final success = await completeQuestAndAwardRewards(quest);
      
      if (!success) {
        return false;
      }
      
      // Then try AR celebration (non-blocking)
      if (context.mounted) {
        try {
          final newLevel = _currentUserData?.level ?? oldLevel;
          final newCoins = _currentUserData?.coins ?? 0;
          final newUserXp = _currentUserData?.currentXP ?? 0;
          final arService = ARTriggerService();
          
          // Trigger AR celebration with timeout
          await arService.triggerQuestCompletionCelebration(
            context,
            userLevel: newLevel,
            userCoins: newCoins,
            userXp: newUserXp,
            questType: quest.type.toString().split('.').last,
            xpGained: quest.xpReward,
            coinsGained: quest.goldReward,
            leveledUp: newLevel > oldLevel,
          ).timeout(
            Duration(seconds: 5),
            onTimeout: () {},
          );
        } catch (e) {
          // Don't fail the quest completion if AR fails
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

// for clearence of previous data
  void clearUserData() {
    _currentUserData = null;
    _error = null;
    _debounceTimer?.cancel();
    _userStreamSubscription?.cancel();
    _userCache.clear();
    notifyListeners();
  }

  // Performance optimization: Debounced notify listeners
  void _debouncedNotifyListeners() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      notifyListeners();
    });
  }

  // Performance optimization: Optimized real-time updates
  void _updateUserDataWithDebounce(UserModel newUser) {
    _currentUserData = newUser;
    _userCache[newUser.uid] = newUser;
    _debouncedNotifyListeners();
  }

  // Performance optimization: Get cached user data
  UserModel? getCachedUserData(String uid) {
    return _userCache[uid];
  }

  // Performance optimization: Batch update for better performance
  Future<void> batchUpdateUserData(Map<String, dynamic> updates) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentUserData == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Batch update in Firestore
      await _firestore.collection('users').doc(uid).update(updates);

      // Update local cache immediately
      final updatedUser = _currentUserData!;
      _userCache[uid] = updatedUser;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Batch update error: $e';
      print('DataService: $_error');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to increment total quests created
  Future<void> incrementTotalQuestsCreated() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentUserData == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'totalQuestsCreated': FieldValue.increment(1),
      });

      // Update local data
      _currentUserData = UserModel(
        uid: _currentUserData!.uid,
        email: _currentUserData!.email,
        username: _currentUserData!.username,
        level: _currentUserData!.level,
        currentXP: _currentUserData!.currentXP,
        xpForNextLevel: _currentUserData!.xpForNextLevel,
        coins: _currentUserData!.coins,
        streak: _currentUserData!.streak,
        createdAt: _currentUserData!.createdAt,
        totalQuestsCreated: _currentUserData!.totalQuestsCreated + 1,
        totalQuestsCompleted: _currentUserData!.totalQuestsCompleted,
      );
      
      notifyListeners();
    } catch (e) {
      print('DataService: Error incrementing total quests created: $e');
    }
  }

}