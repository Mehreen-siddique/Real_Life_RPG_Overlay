import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

class NotificationPreferences {
  final bool notificationsEnabled;
  final bool questReminders;
  final bool streakBreakReminders;
  final bool matchRequestNotifications;

  const NotificationPreferences({
    required this.notificationsEnabled,
    required this.questReminders,
    required this.streakBreakReminders,
    required this.matchRequestNotifications,
  });

  static const NotificationPreferences defaults = NotificationPreferences(
    notificationsEnabled: true,
    questReminders: true,
    streakBreakReminders: true,
    matchRequestNotifications: true,
  );

  factory NotificationPreferences.fromFirestore(Map<String, dynamic> data) {
    final enabled =
        data['notificationsEnabled'] as bool? ?? defaults.notificationsEnabled;
    if (!enabled) {
      return const NotificationPreferences(
        notificationsEnabled: false,
        questReminders: false,
        streakBreakReminders: false,
        matchRequestNotifications: false,
      );
    }

    return NotificationPreferences(
      notificationsEnabled: enabled,
      questReminders: data['questReminders'] as bool? ?? defaults.questReminders,
      streakBreakReminders:
          data['streakBreakReminders'] as bool? ?? defaults.streakBreakReminders,
      matchRequestNotifications: data['matchRequestNotifications'] as bool? ??
          defaults.matchRequestNotifications,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'questReminders': questReminders,
      'streakBreakReminders': streakBreakReminders,
      'matchRequestNotifications': matchRequestNotifications,
    };
  }
}

/// Stores notification preferences under:
/// `users/{uid}.settings`
class NotificationPreferencesService {
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NotificationPreferences? _cached;
  DateTime _cachedAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _cachedUid;
  static const Duration cacheTtl = Duration(seconds: 30);

  bool _isCacheValidFor(String uid) {
    return _cached != null &&
        _cachedUid == uid &&
        DateTime.now().difference(_cachedAt) < cacheTtl;
  }

  Future<NotificationPreferences> getForCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return NotificationPreferences.defaults;
    return getForUser(uid);
  }

  Future<NotificationPreferences> getForUser(String uid) async {
    if (_isCacheValidFor(uid)) return _cached!;

    try {
      final snap = await _firestore.collection('users').doc(uid).get();
      final settings = (snap.data()?['settings'] as Map<String, dynamic>?) ?? {};
      final prefs = NotificationPreferences.fromFirestore(settings);
      _cached = prefs;
      _cachedAt = DateTime.now();
      _cachedUid = uid;
      return prefs;
    } catch (e) {
      debugPrint(
        'NotificationPreferencesService: failed to load prefs for $uid: $e',
      );
      return NotificationPreferences.defaults;
    }
  }

  Future<void> updateForCurrentUser({
    bool? notificationsEnabled,
    bool? questReminders,
    bool? streakBreakReminders,
    bool? matchRequestNotifications,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final current = await getForUser(uid);
    final nextNotificationsEnabled =
        notificationsEnabled ?? current.notificationsEnabled;
    final next = NotificationPreferences(
      notificationsEnabled: nextNotificationsEnabled,
      questReminders: nextNotificationsEnabled
          ? (questReminders ?? current.questReminders)
          : false,
      streakBreakReminders:
          nextNotificationsEnabled
              ? (streakBreakReminders ?? current.streakBreakReminders)
              : false,
      matchRequestNotifications: nextNotificationsEnabled
          ? (matchRequestNotifications ?? current.matchRequestNotifications)
          : false,
    );

    _cached = next;
    _cachedAt = DateTime.now();

    await _firestore.collection('users').doc(uid).set({
      'settings': next.toFirestore(),
    }, SetOptions(merge: true));
  }
}

