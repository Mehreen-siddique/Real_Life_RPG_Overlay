import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/challenge_match.dart';
import 'challenge_rank_helper.dart';

/// One row in the realtime challenge ranks screen.
class ChallengeRankEntry {
  final String userId;
  final String username;
  final double progress;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime updatedAt;

  final int streak;
  final int currentXP;

  final int rank;
  final double targetValue;

  const ChallengeRankEntry({
    required this.userId,
    required this.username,
    required this.progress,
    required this.isCompleted,
    required this.completedAt,
    required this.updatedAt,
    required this.streak,
    required this.currentXP,
    required this.rank,
    required this.targetValue,
  });

  double get percent =>
      targetValue <= 0 ? 0 : (progress / targetValue).clamp(0.0, 1.0);
}

class ChallengeRankService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cache to avoid frequent user-doc reads.
  final Map<String, _UserStatsCache> _userStatsCache = {};
  static const _cacheTtl = Duration(seconds: 45);

  Future<Map<String, _UserStatsCache>> _getUserStats(
    List<String> userIds,
  ) async {
    final now = DateTime.now();
    final missing = <String>[];
    for (final uid in userIds) {
      final c = _userStatsCache[uid];
      if (c == null || now.difference(c.fetchedAt) > _cacheTtl) {
        missing.add(uid);
      }
    }

    if (missing.isNotEmpty) {
      // Firestore whereIn supports up to 10 values.
      for (var i = 0; i < missing.length; i += 10) {
        final chunk = missing.sublist(i, (i + 10).clamp(0, missing.length));
        final snap = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final d in snap.docs) {
          final data = d.data();
          final uid = d.id;
          _userStatsCache[uid] = _UserStatsCache(
            streak: (data['streak'] as num?)?.toInt() ?? 0,
            currentXP: (data['currentXP'] as num?)?.toInt() ?? 0,
            fetchedAt: now,
          );
        }
      }
    }

    return {
      for (final uid in userIds)
        uid: _userStatsCache[uid] ??
            _UserStatsCache(
              streak: 0,
              currentXP: 0,
              fetchedAt: now,
            )
    };
  }

  Stream<List<ChallengeRankEntry>> streamChallengeRankEntries({
    required String challengeId,
    required double targetValue,
    Duration? minUpdateInterval,
  }) async* {
    DateTime? lastYieldAt;

    Stream<QuerySnapshot<Map<String, dynamic>>> participantsStream = _firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('participants')
        .snapshots();

    await for (final snap in participantsStream) {
      final now = DateTime.now();
      if (minUpdateInterval != null && lastYieldAt != null) {
        if (now.difference(lastYieldAt!) < minUpdateInterval) continue;
      }
      if (minUpdateInterval != null) {
        lastYieldAt = now;
      }

      final participants = snap.docs
          .map((d) =>
              ChallengeParticipant.fromFirestore(d.id, d as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      participants.sort(compareParticipantsForRank);
      for (var i = 0; i < participants.length; i++) {
        // assign rank after sorting
      }

      final userIds = participants.map((p) => p.userId).toList();
      final statsMap = await _getUserStats(userIds);

      final ranked = <ChallengeRankEntry>[];
      for (var i = 0; i < participants.length; i++) {
        final p = participants[i];
        final rank = i + 1;
        final stats = statsMap[p.userId]!;

        ranked.add(ChallengeRankEntry(
          userId: p.userId,
          username: p.username,
          progress: p.progress,
          isCompleted: p.isCompleted,
          completedAt: p.completedAt,
          updatedAt: p.updatedAt,
          streak: stats.streak,
          currentXP: stats.currentXP,
          rank: rank,
          targetValue: targetValue,
        ));
      }

      yield ranked;
    }
  }
}

class _UserStatsCache {
  final int streak;
  final int currentXP;
  final DateTime fetchedAt;

  _UserStatsCache({
    required this.streak,
    required this.currentXP,
    required this.fetchedAt,
  });
}

