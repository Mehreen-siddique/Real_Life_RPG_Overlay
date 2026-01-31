import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A lightweight leaderboard service for Flutter + Firebase without provider
/// Supports real-time streams and direct method APIs.
class LeaderboardService {
  LeaderboardService._privateConstructor();

  static final LeaderboardService _instance = LeaderboardService._privateConstructor();
  static LeaderboardService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Real-time global leaderboard stream ordered by currentXP desc, coins desc.
  Stream<List<Map<String, dynamic>>> getGlobalLeaderboardStream({int limit = 50}) {
    try {
      return _firestore
          .collection('users')
          .orderBy('currentXP', descending: true)
          .orderBy('coins', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'uid': doc.id,
                  'username': data['username'] ?? '',
                  'email': data['email'] ?? '',
                  'currentXP': (data['currentXP'] ?? 0) as int,
                  'coins': (data['coins'] ?? 0) as int,
                  'streak': (data['streak'] ?? 0) as int,
                  'level': (data['level'] ?? 0) as int,
                  'partyId': data['partyId'],
                };
              }).toList());
    } catch (e) {
      return Stream.error('Global leaderboard stream failed: $e');
    }
  }

  /// Real-time party leaderboard stream for current user party.
  Stream<List<Map<String, dynamic>>> getPartyLeaderboardStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.error('User not authenticated');
    }

    final userDocStream = _firestore.collection('users').doc(currentUser.uid).snapshots();

    return userDocStream.asyncExpand((userDocSnapshot) {
      if (!userDocSnapshot.exists) {
        return Stream.value(<Map<String, dynamic>>[]);
      }

      final userData = userDocSnapshot.data() ?? {};
      final partyId = (userData['partyId'] as String?)?.trim();
      if (partyId == null || partyId.isEmpty) {
        return Stream.value(<Map<String, dynamic>>[]);
      }

      final partyDocStream = _firestore.collection('parties').doc(partyId).snapshots();
      return partyDocStream.asyncExpand((partyDocSnapshot) {
        if (!partyDocSnapshot.exists) {
          return Stream.value(<Map<String, dynamic>>[]);
        }

        final partyData = partyDocSnapshot.data() ?? {};
        final memberIds = List<String>.from(partyData['memberIds'] ?? []);
        if (memberIds.isEmpty) {
          return Stream.value(<Map<String, dynamic>>[]);
        }

        final chunks = <List<String>>[];
        for (var i = 0; i < memberIds.length; i += 10) {
          chunks.add(memberIds.sublist(i, i + 10 > memberIds.length ? memberIds.length : i + 10));
        }

        final memberStreams = chunks.map((chunk) {
          return _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: chunk)
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) {
                    final data = doc.data();
                    return {
                      'uid': doc.id,
                      'username': data['username'] ?? '',
                      'currentXP': (data['currentXP'] ?? 0) as int,
                      'coins': (data['coins'] ?? 0) as int,
                      'streak': (data['streak'] ?? 0) as int,
                      'level': (data['level'] ?? 0) as int,
                    };
                  })
                  .toList());
        }).toList();

        if (memberStreams.isEmpty) {
          return Stream.value(<Map<String, dynamic>>[]);
        }

        return StreamZip<List<Map<String, dynamic>>>(memberStreams).map((listOfLists) {
          final merged = <Map<String, dynamic>>[];
          for (final part in listOfLists) {
            merged.addAll(part);
          }
          merged.sort((a, b) {
            final xpA = (a['currentXP'] ?? 0) as int;
            final xpB = (b['currentXP'] ?? 0) as int;
            final cmpXP = xpB.compareTo(xpA);
            if (cmpXP != 0) return cmpXP;
            final coinsA = (a['coins'] ?? 0) as int;
            final coinsB = (b['coins'] ?? 0) as int;
            return coinsB.compareTo(coinsA);
          });
          return merged;
        });
      });
    });
  }

  /// Get current user leaderboard entry.
  Future<Map<String, dynamic>?> getCurrentUserEntry() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    try {
      final snapshot = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data() ?? {};
      return {
        'uid': snapshot.id,
        'username': data['username'] ?? '',
        'email': data['email'] ?? '',
        'currentXP': (data['currentXP'] ?? 0) as int,
        'coins': (data['coins'] ?? 0) as int,
        'streak': (data['streak'] ?? 0) as int,
        'level': (data['level'] ?? 0) as int,
        'partyId': data['partyId'],
      };
    } catch (e) {
      throw Exception('Failed to load current user entry: $e');
    }
  }

  Future<int> getCurrentUserRank() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('currentXP', descending: true)
          .orderBy('coins', descending: true)
          .get();

      int rank = 0;
      for (final doc in snapshot.docs) {
        rank += 1;
        if (doc.id == currentUser.uid) {
          return rank;
        }
      }

      throw Exception('Current user not found in leaderboard');
    } catch (e) {
      throw Exception('Failed to compute user rank: $e');
    }
  }

  /// Get current user's party member UIDs. If no party => empty list.
  Future<List<String>> getCurrentUserPartyMembers() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final userSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!userSnapshot.exists) {
      return [];
    }

    final partyId = (userSnapshot.data()?['partyId'] as String?)?.trim();
    if (partyId == null || partyId.isEmpty) {
      return [];
    }

    final partySnapshot = await _firestore.collection('parties').doc(partyId).get();
    if (!partySnapshot.exists) {
      return [];
    }

    final data = partySnapshot.data() ?? {};
    final memberIds = List<String>.from(data['memberIds'] ?? []);
    return memberIds;
  }

  Future<List<Map<String, dynamic>>> getChallengeNotifications() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await _firestore
        .collection('challenges')
        .where('isActive', isEqualTo: true)
        .where('participants', arrayContains: currentUser.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'challengeId': doc.id,
        'title': data['title'] ?? '',
        'description': data['description'] ?? '',
        'status': data['status'] ?? 'unknown',
        'endsAt': data['endsAt'],
      };
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> getStreakStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.error('User not authenticated');
    }

    final userDoc = _firestore.collection('users').doc(currentUser.uid);
    return userDoc.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return <Map<String, dynamic>>[];
      }
      final data = snapshot.data() ?? {};
      return [
        {
          'uid': snapshot.id,
          'streak': (data['streak'] ?? 0) as int,
          'lastUpdated': data['streakLastUpdated'],
        }
      ];
    });
  }

  Future<void> refreshLeaderboardData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('users').doc(currentUser.uid).update({
      'lastRefreshedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LEGACY API COMPATIBILITY — used by LeaderboardScreen / UserProfileScreen
  // ─────────────────────────────────────────────────────────────────────────

  /// No-op initialiser kept for API compatibility.
  Future<void> initialize() async {}

  /// Get the 1-based rank for [userId] in the global leaderboard.
  Future<int> getUserRank(String userId) async {
    return getCurrentUserRank();
  }

  /// Get full [LeaderboardEntry] for [userId].
  Future<LeaderboardEntry?> getUserPosition(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      if (!snapshot.exists) return null;

      final data = snapshot.data() ?? {};

      // Compute rank by counting users with more XP
      final aboveSnapshot = await _firestore
          .collection('users')
          .where('currentXP', isGreaterThan: (data['currentXP'] ?? 0))
          .get();
      final rank = aboveSnapshot.docs.length + 1;

      return LeaderboardEntry(
        userId: snapshot.id,
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        level: (data['level'] as num?)?.toInt() ?? 1,
        currentXP: (data['currentXP'] as num?)?.toInt() ?? 0,
        coins: (data['coins'] as num?)?.toInt() ?? 0,
        streak: (data['streak'] as num?)?.toInt() ?? 0,
        totalQuestsCompleted: (data['totalQuestsCompleted'] as num?)?.toInt() ?? 0,
        rank: rank,
        lastActive: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch up to [limit] top users as [LeaderboardEntry] list.
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('currentXP', descending: true)
          .orderBy('coins', descending: true)
          .limit(limit)
          .get();

      int rank = 0;
      return snapshot.docs.map((doc) {
        rank++;
        final data = doc.data();
        return LeaderboardEntry(
          userId: doc.id,
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          level: (data['level'] as num?)?.toInt() ?? 1,
          currentXP: (data['currentXP'] as num?)?.toInt() ?? 0,
          coins: (data['coins'] as num?)?.toInt() ?? 0,
          streak: (data['streak'] as num?)?.toInt() ?? 0,
          totalQuestsCompleted: (data['totalQuestsCompleted'] as num?)?.toInt() ?? 0,
          rank: rank,
          lastActive: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Real-time stream of [LeaderboardEntry] list (top 100).
  Stream<List<LeaderboardEntry>> get leaderboardStream {
    return _firestore
        .collection('users')
        .orderBy('currentXP', descending: true)
        .orderBy('coins', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      int rank = 0;
      return snapshot.docs.map((doc) {
        rank++;
        final data = doc.data();
        return LeaderboardEntry(
          userId: doc.id,
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          level: (data['level'] as num?)?.toInt() ?? 1,
          currentXP: (data['currentXP'] as num?)?.toInt() ?? 0,
          coins: (data['coins'] as num?)?.toInt() ?? 0,
          streak: (data['streak'] as num?)?.toInt() ?? 0,
          totalQuestsCompleted: (data['totalQuestsCompleted'] as num?)?.toInt() ?? 0,
          rank: rank,
          lastActive: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEADERBOARD ENTRY MODEL
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a single entry in the global leaderboard.
class LeaderboardEntry {
  final String userId;
  final String username;
  final String email;
  final int level;
  final int currentXP;
  final int coins;
  final int streak;
  final int totalQuestsCompleted;
  final int rank;
  final DateTime lastActive;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.email,
    required this.level,
    required this.currentXP,
    required this.coins,
    required this.streak,
    required this.totalQuestsCompleted,
    required this.rank,
    required this.lastActive,
  });

  /// Emoji / text badge for rank.
  String get rankBadge {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    if (rank <= 10) return '⭐';
    return '#$rank';
  }

  /// Colour associated with rank.
  Color get rankColor {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    if (rank <= 10) return Colors.purple;
    return Colors.blue;
  }
}

