import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/challenge_match.dart';
import '../CharacterSelection/ar_character_selection_storage.dart';
import '../Achievements/achievement_service.dart';
import '../Leaderboard/challenge_rank_helper.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  final ARCharacterSelectionStorage _characterSelectionStorage =
      ARCharacterSelectionStorage();

  String get _todayStr {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  // ══════════════════════════════════════════════════════════
  // CHALLENGE MATCH (Realtime competitive progress)
  // ══════════════════════════════════════════════════════════

  /// Create a Firestore-backed challenge match.
  ///
  /// Simplification:
  /// - Creator is automatically added as a participant.
  /// - Progress starts at `0`.
  /// - Completion + ranks are managed by [updateParticipantProgress] /
  ///   [completeParticipantChallenge].
  Future<String?> createChallenge({
    required String title,
    required String description,
    required ChallengeTargetType targetType,
    required double targetValue,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final uid = _uid;
    if (uid == null) return null;

    final userSnap = await _firestore.collection('users').doc(uid).get();
    final data = userSnap.data() ?? <String, dynamic>{};
    final username = (data['username'] ?? 'Unknown') as String;

    final selectedCharacterId =
        await _characterSelectionStorage.getSelectedCharacterId();
    final createdAt = DateTime.now();

    try {
      final docRef = await _firestore.collection('challenges').add({
        'title': title,
        'description': description,
        'targetType': targetType.asString,
        'targetValue': targetValue,
        'createdBy': uid,
        'createdByName': username,
        'isActive': true,
        'startAt': Timestamp.fromDate(startAt),
        'endAt': Timestamp.fromDate(endAt),
        'participantIds': [uid],
        'createdAt': Timestamp.fromDate(createdAt),
        // Optional fields can be added later without breaking UI.
      });

      await _firestore
          .collection('challenges')
          .doc(docRef.id)
          .collection('participants')
          .doc(uid)
          .set({
        'userId': uid,
        'username': username,
        'progress': 0.0,
        'isCompleted': false,
        'completedAt': null,
        'rank': null,
        'selectedCharacterId': selectedCharacterId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('[ChallengeService] createChallenge error: $e');
      return null;
    }
  }

  /// Legacy wrapper used by `CreateQuest.dart` for simple step challenges.
  /// Creates a `targetType=steps` challenge using `targetSteps` as `targetValue`.
  Future<String?> createChallengeFromQuest({
    required String title,
    required String description,
    required String type,
    required int targetSteps,
    required int xpReward,
    required int coinReward,
    required String difficulty,
  }) {
    // Keep signature but map to the new schema. Rewards/difficulty are ignored for now.
    return createChallenge(
      title: title,
      description: description,
      targetType: ChallengeTargetType.steps,
      targetValue: targetSteps.toDouble(),
      startAt: DateTime.now(),
      endAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Future<List<String>> _getCurrentUserPartyMembers() async {
    final uid = _uid;
    if (uid == null) return const [];
    final userSnap = await _firestore.collection('users').doc(uid).get();
    final userData = userSnap.data() ?? <String, dynamic>{};
    final partyId = userData['partyId'] as String?;
    if (partyId == null || partyId.trim().isEmpty) return const [];

    final partySnap = await _firestore.collection('parties').doc(partyId).get();
    if (!partySnap.exists) return const [];

    final data = partySnap.data() ?? <String, dynamic>{};
    return List<String>.from(data['memberIds'] ?? const []);
  }

  /// Get challenges created by:
  /// - the current user
  /// - users you follow
  /// - your party members
  ///
  /// Returned in realtime, so UI can use a `StreamBuilder`.
  Stream<List<ChallengeMatch>> getChallengesStream() async* {
    final uid = _uid;
    if (uid == null) {
      yield const [];
      return;
    }

    await for (final followDoc
        in _firestore.collection('following').doc(uid).snapshots()) {
      final followingUids =
          List<String>.from((followDoc.data() ?? <String, dynamic>{})['uids'] ?? const []);
      final partyMemberUids = await _getCurrentUserPartyMembers();

      final creators = <String>{
        uid,
        ...followingUids,
        ...partyMemberUids,
      };

      final creatorsList = creators.toList();
      final all = <String, ChallengeMatch>{};

      for (var i = 0; i < creatorsList.length; i += 10) {
        final chunk = creatorsList.sublist(i, (i + 10).clamp(0, creatorsList.length));
        if (chunk.isEmpty) continue;

        try {
          final snap = await _firestore
              .collection('challenges')
              .where('createdBy', whereIn: chunk)
              .get();

          for (final d in snap.docs) {
            final match =
                ChallengeMatch.fromFirestore(d.id, d as DocumentSnapshot<Map<String, dynamic>>);
            all[d.id] = match;
          }
        } catch (e) {
          debugPrint('[ChallengeService] getChallengesStream(createdBy): $e');
        }
      }

      // Include challenges where I am already a participant.
      try {
        final myJoined = await _firestore
            .collection('challenges')
            .where('participantIds', arrayContains: uid)
            .get();
        for (final d in myJoined.docs) {
          final match = ChallengeMatch.fromFirestore(
            d.id,
            d as DocumentSnapshot<Map<String, dynamic>>,
          );
          all[d.id] = match;
        }
      } catch (e) {
        debugPrint('[ChallengeService] getChallengesStream(participant): $e');
      }

      // Include challenges that I was invited to (pending).
      try {
        final inviteSnap = await _firestore
            .collection('challengeInvitations')
            .where('toUserId', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .get();
        final invitedChallengeIds = inviteSnap.docs
            .map((d) => (d.data()['challengeId'] ?? '').toString())
            .where((id) => id.isNotEmpty)
            .toSet();
        for (final cid in invitedChallengeIds) {
          final cDoc = await _firestore.collection('challenges').doc(cid).get();
          if (!cDoc.exists) continue;
          final match = ChallengeMatch.fromFirestore(
            cDoc.id,
            cDoc as DocumentSnapshot<Map<String, dynamic>>,
          );
          all[cDoc.id] = match;
        }
      } catch (e) {
        debugPrint('[ChallengeService] getChallengesStream(invites): $e');
      }

      final list = all.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield list;
    }
  }

  /// Real-time stream of participants for a given challenge.
  Stream<List<ChallengeParticipant>> getChallengeParticipantsStream(
    String challengeId,
  ) {
    return _firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('participants')
        .orderBy('progress', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ChallengeParticipant.fromFirestore(d.id, d as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }

  Future<void> joinChallenge(String challengeId) async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final challengeSnap = await _firestore.collection('challenges').doc(challengeId).get();
    if (!challengeSnap.exists) return;

    final challengeData = challengeSnap.data() ?? <String, dynamic>{};
    final endAt = (challengeData['endAt'] as Timestamp?)?.toDate() ?? now;
    final isActive = (challengeData['isActive'] ?? true) as bool;
    if (!isActive || now.isAfter(endAt)) return;

    final userSnap = await _firestore.collection('users').doc(uid).get();
    final data = userSnap.data() ?? <String, dynamic>{};
    final username = (data['username'] ?? 'Unknown') as String;
    final selectedCharacterId =
        await _characterSelectionStorage.getSelectedCharacterId();

    final batch = _firestore.batch();
    final challengeRef = _firestore.collection('challenges').doc(challengeId);

    batch.update(challengeRef, {
      'participantIds': FieldValue.arrayUnion([uid]),
    });

    batch.set(
      challengeRef.collection('participants').doc(uid),
      {
        'userId': uid,
        'username': username,
        'progress': 0.0,
        'isCompleted': false,
        'completedAt': null,
        'rank': null,
        'selectedCharacterId': selectedCharacterId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    // Achievement: first challenge win progression.
    await AchievementService().updateAchievementProgress(
      uid,
      challengeWin: true,
    );
  }

  Future<void> inviteUserToChallenge({
    required String challengeId,
    required String targetUid,
  }) async {
    final uid = _uid;
    if (uid == null || uid == targetUid) return;

    final me = await _firestore.collection('users').doc(uid).get();
    final meName = (me.data()?['username'] ?? 'Unknown') as String;

    final existing = await _firestore
        .collection('challengeInvitations')
        .where('challengeId', isEqualTo: challengeId)
        .where('fromUserId', isEqualTo: uid)
        .where('toUserId', isEqualTo: targetUid)
        .where('status', isEqualTo: 'pending')
        .get();
    if (existing.docs.isNotEmpty) return;

    await _firestore.collection('challengeInvitations').add({
      'challengeId': challengeId,
      'fromUserId': uid,
      'fromUsername': meName,
      'toUserId': targetUid,
      'status': 'pending',
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamIncomingChallengeInvites() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('challengeInvitations')
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> acceptChallengeInvite({
    required String inviteId,
    required String challengeId,
  }) async {
    await joinChallenge(challengeId);
    await _firestore.collection('challengeInvitations').doc(inviteId).update({
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> declineChallengeInvite(String inviteId) async {
    await _firestore.collection('challengeInvitations').doc(inviteId).update({
      'status': 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> leaveChallenge(String challengeId) async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final challengeSnap = await _firestore.collection('challenges').doc(challengeId).get();
    if (!challengeSnap.exists) return;
    final challengeData = challengeSnap.data() ?? <String, dynamic>{};
    final endAt = (challengeData['endAt'] as Timestamp?)?.toDate() ?? now;
    final isActive = (challengeData['isActive'] ?? true) as bool;
    if (!isActive || now.isAfter(endAt)) return;

    final challengeRef = _firestore.collection('challenges').doc(challengeId);
    final batch = _firestore.batch();
    batch.update(challengeRef, {
      'participantIds': FieldValue.arrayRemove([uid]),
    });
    batch.delete(challengeRef.collection('participants').doc(uid));
    await batch.commit();
  }

  /// Update a participant's progress.
  ///
  /// - If progress reaches target, completion + ranks are set via
  ///   [completeParticipantChallenge].
  /// - If the challenge has ended, progress is ignored (rank freeze).
  Future<void> updateParticipantProgress({
    required String challengeId,
    required double progress,
    String? userId,
  }) async {
    final uid = userId ?? _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final challengeRef = _firestore.collection('challenges').doc(challengeId);
    final challengeSnap = await challengeRef.get();
    if (!challengeSnap.exists) return;

    final challengeData = challengeSnap.data() ?? <String, dynamic>{};
    final endAt = (challengeData['endAt'] as Timestamp?)?.toDate() ?? now;
    final isActive = (challengeData['isActive'] ?? true) as bool;
    if (!isActive || now.isAfter(endAt)) return;

    final targetValue = (challengeData['targetValue'] ?? 0).toDouble();

    final participantRef = challengeRef.collection('participants').doc(uid);
    final participantSnap = await participantRef.get();
    if (participantSnap.exists) {
      final pData = participantSnap.data() ?? <String, dynamic>{};
      final isCompleted = (pData['isCompleted'] ?? false) as bool;
      if (isCompleted) return;
    }

    await participantRef.set({
      'progress': progress,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (progress >= targetValue) {
      await completeParticipantChallenge(challengeId: challengeId, userId: uid);
    }
  }

  /// Mark a participant as completed and compute ranks (frozen after end).
  Future<void> completeParticipantChallenge({
    required String challengeId,
    String? userId,
  }) async {
    final uid = userId ?? _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final challengeRef = _firestore.collection('challenges').doc(challengeId);
    final challengeSnap = await challengeRef.get();
    if (!challengeSnap.exists) return;

    final challengeData = challengeSnap.data() ?? <String, dynamic>{};
    final endAt = (challengeData['endAt'] as Timestamp?)?.toDate() ?? now;
    final isActive = (challengeData['isActive'] ?? true) as bool;
    if (!isActive || now.isAfter(endAt)) return;

    final participantRef = challengeRef.collection('participants').doc(uid);
    final participantSnap = await participantRef.get();
    if (!participantSnap.exists) return;

    final participantData = participantSnap.data() ?? <String, dynamic>{};
    final alreadyCompleted = (participantData['isCompleted'] ?? false) as bool;
    if (alreadyCompleted) return;

    final completedProgress = (participantData['progress'] ?? 0).toDouble();
    final targetValue = (challengeData['targetValue'] ?? 0).toDouble();
    if (completedProgress < targetValue) {
      // Guard: avoid completing early.
      return;
    }

    // Mark completed.
    await participantRef.set({
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Recompute ranks among completed participants.
    final allParticipantsSnap =
        await challengeRef.collection('participants').get();

    final completed = <MapEntry<String, DocumentSnapshot<Map<String, dynamic>>>>[];
    for (final doc in allParticipantsSnap.docs) {
      final d = doc.data() ?? <String, dynamic>{};
      final isCompleted = (d['isCompleted'] ?? false) as bool;
      if (!isCompleted) continue;
      completed.add(MapEntry(doc.id, doc as DocumentSnapshot<Map<String, dynamic>>));
    }

    // Rank among completed participants using the same tie-break rules:
    // higher progress first, then earlier completion time.
    final completedParticipants = completed
        .map((e) => ChallengeParticipant.fromFirestore(
              e.key,
              e.value as DocumentSnapshot<Map<String, dynamic>>,
            ))
        .toList()
      ..sort(compareParticipantsForRank);

    final batch = _firestore.batch();
    for (var i = 0; i < completedParticipants.length; i++) {
      final userId = completedParticipants[i].userId;
      batch.update(
        challengeRef.collection('participants').doc(userId),
        {'rank': i + 1},
      );
    }

    await batch.commit();
  }

  /// Integration point: update step + stationary challenge progress
  /// from live sensor/today step data.
  ///
  /// Called from `SensorService` persistence ticks.
  Future<void> syncMyProgressFromSensor({
    required int todaySteps,
    required bool isStationary,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();

    // Steps challenges.
    final stepChallengesSnap = await _firestore
        .collection('challenges')
        .where('participantIds', arrayContains: uid)
        .where('targetType', isEqualTo: ChallengeTargetType.steps.asString)
        .get();

    for (final c in stepChallengesSnap.docs) {
      final challengeData = c.data();
      final endAt = (challengeData['endAt'] as Timestamp?)?.toDate() ?? now;
      if (now.isAfter(endAt) || !(challengeData['isActive'] ?? true)) continue;
      await updateParticipantProgress(
        challengeId: c.id,
        progress: todaySteps.toDouble(),
      );
    }

    // Stationary minutes challenges.
    final stationaryChallengesSnap = await _firestore
        .collection('challenges')
        .where('participantIds', arrayContains: uid)
        .where(
          'targetType',
          isEqualTo: ChallengeTargetType.stationaryMinutes.asString,
        )
        .get();

    for (final c in stationaryChallengesSnap.docs) {
      final challengeData = c.data();
      final endAt = (challengeData['endAt'] as Timestamp?)?.toDate() ?? now;
      if (now.isAfter(endAt) || !(challengeData['isActive'] ?? true)) continue;
      if (!isStationary) continue;

      final participantDoc = await _firestore
          .collection('challenges')
          .doc(c.id)
          .collection('participants')
          .doc(uid)
          .get();

      final pData = participantDoc.data() ?? <String, dynamic>{};
      final currentProgress = (pData['progress'] ?? 0).toDouble();
      final lastUpdatedAt =
          (pData['updatedAt'] as Timestamp?)?.toDate() ?? now;

      final deltaMinutes =
          now.difference(lastUpdatedAt).inSeconds / 60.0;

      final nextProgress = currentProgress + deltaMinutes.clamp(0.0, 60.0);
      await updateParticipantProgress(
        challengeId: c.id,
        progress: nextProgress,
      );
    }
  }

  /// Integration point: update questCompletion and xpEarned challenges.
  ///
  /// Called after quest completion in `DataService`.
  Future<void> syncMyProgressFromQuestCompletion({
    required String questId,
    required String questType,
    required int xpGained,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final now = DateTime.now();

    // Quest completion challenges.
    final qcChallengesSnap = await _firestore
        .collection('challenges')
        .where('participantIds', arrayContains: uid)
        .where(
          'targetType',
          isEqualTo: ChallengeTargetType.questCompletion.asString,
        )
        .get();

    for (final c in qcChallengesSnap.docs) {
      final cData = c.data();
      final endAt = (cData['endAt'] as Timestamp?)?.toDate() ?? now;
      if (now.isAfter(endAt) || !(cData['isActive'] ?? true)) continue;

      final sourceQuestId = cData['sourceQuestId'] as String?;
      final sourceQuestType = cData['sourceQuestType'] as String?;
      final matchesQuest = (sourceQuestId != null && sourceQuestId == questId) ||
          (sourceQuestId == null && sourceQuestType != null && sourceQuestType == questType) ||
          (sourceQuestId == null && sourceQuestType == null);
      if (!matchesQuest) continue;

      final participantRef = _firestore
          .collection('challenges')
          .doc(c.id)
          .collection('participants')
          .doc(uid);
      final participantSnap = await participantRef.get();
      final pData = participantSnap.data() ?? <String, dynamic>{};
      final currentProgress = (pData['progress'] ?? 0).toDouble();

      await updateParticipantProgress(
        challengeId: c.id,
        progress: currentProgress + 1,
      );
    }

    // XP earned challenges.
    final xpChallengesSnap = await _firestore
        .collection('challenges')
        .where('participantIds', arrayContains: uid)
        .where(
          'targetType',
          isEqualTo: ChallengeTargetType.xpEarned.asString,
        )
        .get();

    for (final c in xpChallengesSnap.docs) {
      final cData = c.data();
      final endAt = (cData['endAt'] as Timestamp?)?.toDate() ?? now;
      if (now.isAfter(endAt) || !(cData['isActive'] ?? true)) continue;

      final sourceQuestId = cData['sourceQuestId'] as String?;
      final sourceQuestType = cData['sourceQuestType'] as String?;
      final matchesQuest = (sourceQuestId != null && sourceQuestId == questId) ||
          (sourceQuestId == null && sourceQuestType != null && sourceQuestType == questType) ||
          (sourceQuestId == null && sourceQuestType == null);
      if (!matchesQuest) continue;

      final participantRef = _firestore
          .collection('challenges')
          .doc(c.id)
          .collection('participants')
          .doc(uid);
      final participantSnap = await participantRef.get();
      final pData = participantSnap.data() ?? <String, dynamic>{};
      final currentProgress = (pData['progress'] ?? 0).toDouble();

      await updateParticipantProgress(
        challengeId: c.id,
        progress: currentProgress + xpGained.toDouble(),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // Legacy challenge APIs (kept so other code compiles)
  // ══════════════════════════════════════════════════════════

  /// Kept for older UI; now mapped to new schema.
  Stream<List<Map<String, dynamic>>> streamFriendsChallenges() async* {
    await for (final list in getChallengesStream()) {
      yield list
          .map((c) => {
                'id': c.id,
                'title': c.title,
                'description': c.description,
                'createdBy': c.createdBy,
                'createdByUsername': c.createdByName,
                'xpReward': 0,
                'coinReward': 0,
                'difficulty': 'easy',
                'targetSteps': (c.targetType == ChallengeTargetType.steps ? c.targetValue : 0).toInt(),
                'targetType': c.targetType.asString,
                'targetValue': c.targetValue,
                'participants': c.participantIds,
                'isActive': c.isActive,
                'endAt': c.endAt,
                'startAt': c.startAt,
              })
          .toList();
    }
  }

  /// Kept for older UI; now mapped to new schema.
  Stream<QuerySnapshot> streamChallengeProgress(String challengeId) {
    return _firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('participants')
        .orderBy('progress', descending: true)
        .snapshots();
  }

  /// Kept for older UI. Completion is now automatic from progress updates.
  Future<void> markChallengeComplete(String challengeId) {
    return completeParticipantChallenge(challengeId: challengeId);
  }

  // ══════════════════════════════════════════════════════════
  // FRIEND REQUESTS
  // ══════════════════════════════════════════════════════════

  /// Send a friend request (prevents duplicates).
  Future<void> sendFriendRequest(String targetUid) async {
    final uid = _uid;
    if (uid == null || uid == targetUid) return;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final username = userDoc.data()?['username'] ?? 'Unknown';

    final existing = await _firestore
        .collection('friendRequests')
        .where('fromUserId', isEqualTo: uid)
        .where('toUserId', isEqualTo: targetUid)
        .where('status', isEqualTo: 'pending')
        .get();
    if (existing.docs.isNotEmpty) return;

    await _firestore.collection('friendRequests').add({
      'fromUserId': uid,
      'fromUsername': username,
      'toUserId': targetUid,
      'status': 'pending',
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream of pending incoming friend requests for the logged-in user.
  Stream<QuerySnapshot> streamIncomingRequests() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Stream of pending outgoing friend requests sent by the logged-in user.
  Stream<QuerySnapshot> streamOutgoingRequests() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('friendRequests')
        .where('fromUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Accept a friend request → creates mutual following relationship.
  Future<void> acceptFriendRequest(String requestId, String fromUid) async {
    final uid = _uid;
    if (uid == null) return;
    final batch = _firestore.batch();
    batch.update(_firestore.collection('friendRequests').doc(requestId), {
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });
    // me → from
    batch.set(_firestore.collection('following').doc(uid),
        {'uids': FieldValue.arrayUnion([fromUid])}, SetOptions(merge: true));
    batch.set(_firestore.collection('followers').doc(fromUid),
        {'uids': FieldValue.arrayUnion([uid])}, SetOptions(merge: true));
    // from → me
    batch.set(_firestore.collection('following').doc(fromUid),
        {'uids': FieldValue.arrayUnion([uid])}, SetOptions(merge: true));
    batch.set(_firestore.collection('followers').doc(uid),
        {'uids': FieldValue.arrayUnion([fromUid])}, SetOptions(merge: true));
    await batch.commit();
  }

  /// Decline a friend request.
  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════════════════════
  // SOCIAL
  // ══════════════════════════════════════════════════════════

  Stream<QuerySnapshot> streamAllUsers() {
    return _firestore.collection('users').orderBy('username').snapshots();
  }

  Stream<DocumentSnapshot> streamFollowingDoc() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('following').doc(uid).snapshots();
  }

  Future<void> unfollowUser(String targetUid) async {
    final uid = _uid;
    if (uid == null) return;
    final batch = _firestore.batch();
    batch.update(_firestore.collection('following').doc(uid),
        {'uids': FieldValue.arrayRemove([targetUid])});
    batch.update(_firestore.collection('followers').doc(targetUid),
        {'uids': FieldValue.arrayRemove([uid])});
    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════
  // RANKS — Daily challenge completion leaderboard
  // ══════════════════════════════════════════════════════════

  Stream<List<Map<String, dynamic>>> streamDailyRankings() async* {
    final uid = _uid;
    if (uid == null) { yield []; return; }
    final today = _todayStr;

    await for (final followDoc in
        _firestore.collection('following').doc(uid).snapshots()) {
      final followingUids =
          List<String>.from(followDoc.data()?['uids'] ?? []);
      final allUids = <String>{uid, ...followingUids}.toList();
      final result = <Map<String, dynamic>>[];

      for (var i = 0; i < allUids.length; i += 10) {
        final chunk =
            allUids.sublist(i, (i + 10).clamp(0, allUids.length));
        try {
          final snap = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          for (final d in snap.docs) {
            final data = d.data();
            final lastDate = data['lastCompletionDate'] as String?;
            final dailyCount = lastDate == today
                ? (data['dailyChallengesCompleted'] as num?)?.toInt() ?? 0
                : 0;
            result.add({
              'uid': d.id,
              'username': data['username'] ?? 'Unknown',
              'avatarUrl': data['avatarUrl'],
              'characterClass': data['characterClass'] ?? 'warrior',
              'level': (data['level'] as num?)?.toInt() ?? 1,
              'streak': (data['streak'] as num?)?.toInt() ?? 0,
              'currentXP': (data['currentXP'] as num?)?.toInt() ?? 0,
              'totalQuestsCompleted':
                  (data['totalQuestsCompleted'] as num?)?.toInt() ?? 0,
              'dailyChallengesCompleted': dailyCount,
              'isOnline': data['isOnline'] ?? false,
            });
          }
        } catch (_) {}
      }

      result.sort((a, b) {
        final dc = (b['dailyChallengesCompleted'] as int)
            .compareTo(a['dailyChallengesCompleted'] as int);
        if (dc != 0) return dc;
        return (b['currentXP'] as int).compareTo(a['currentXP'] as int);
      });
      yield result;
    }
  }
}
