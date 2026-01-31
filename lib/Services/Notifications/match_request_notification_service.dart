import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

import 'enhanced_notification_service.dart';
import 'notification_preferences_service.dart';

/// Lightweight local notification for incoming friend/match requests.
///
/// Listens to `friendRequests` where:
/// - `toUserId == currentUser`
/// - `status == pending`
class MatchRequestNotificationService {
  static final MatchRequestNotificationService _instance =
      MatchRequestNotificationService._internal();
  factory MatchRequestNotificationService() => _instance;
  MatchRequestNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  DateTime _lastNotifiedAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> initialize() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'match_request_last_notified_$uid';
    final millis = prefs.getInt(key);
    if (millis != null) _lastNotifiedAt = DateTime.fromMillisecondsSinceEpoch(millis);

    _sub?.cancel();
    _sub = _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .listen((snap) async {
      if (snap.docs.isEmpty) return;

      final prefsService = NotificationPreferencesService();
      final notifyEnabled =
          (await prefsService.getForCurrentUser()).matchRequestNotifications;
      if (!notifyEnabled) return;

      // Find any request that is newer than the last notification.
      final newest = snap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .map((data) {
        final sentAt = data['sentAt'] as Timestamp?;
        return sentAt?.toDate();
      })
          .whereType<DateTime>()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (newest.isEmpty) return;
      final newestAt = newest.first;

      if (!newestAt.isAfter(_lastNotifiedAt)) return;

      // Notify using the most recent document in the snapshot.
      final latestDoc = snap.docs.first;
      final latestData = latestDoc.data();

      final fromUsername = latestData['fromUsername']?.toString() ?? 'Unknown';

      await EnhancedNotificationService().showNotification(
        title: 'New Match Request',
        body: '$fromUsername sent you a match request.',
        type: 'match_request',
        data: {
          'friendRequestId': latestDoc.id,
        },
      );

      _lastNotifiedAt = newestAt;
      await prefs.setInt(
        'match_request_last_notified_$uid',
        _lastNotifiedAt.millisecondsSinceEpoch,
      );
    }, onError: (e) {
      debugPrint('MatchRequestNotificationService: $e');
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}

