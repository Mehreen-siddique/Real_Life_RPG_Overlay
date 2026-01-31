import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_preferences_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════════
/// ENHANCED NOTIFICATION SERVICE - FCM & Local Notifications
/// ═══════════════════════════════════════════════════════════════════════════════
/// 
/// Handles:
/// • Firebase Cloud Messaging (FCM) push notifications
/// • Local in-app notifications
/// • Background message handling
/// • Notification channels (Android)
/// • Notification actions and navigation
///
/// Author: Final Year Project Student
/// Course: CS/SE Final Year Project 2024-2025

class EnhancedNotificationService {
  /// Singleton pattern
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  /// Firebase instances
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Navigation callback for handling notification taps
  Function(String type, Map<String, dynamic> data)? _onNotificationTap;

  /// ═══════════════════════════════════════════════════════════════════════════
  /// INITIALIZATION
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Initialize both FCM and local notifications
  Future<void> initialize({Function(String type, Map<String, dynamic> data)? onNotificationTap}) async {
    _onNotificationTap = onNotificationTap;

    print('[ENHANCED-NOTIFICATION] Initializing notification service...');

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize FCM
    await _initializeFCM();

    print('[ENHANCED-NOTIFICATION] Notification service initialized');
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Party invitations channel
    const partyChannel = AndroidNotificationChannel(
      'party_invitations',
      'Party Invitations',
      description: 'Notifications for party invitations',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Quest completions channel
    const questChannel = AndroidNotificationChannel(
      'quest_completions',
      'Quest Completions',
      description: 'Notifications for completed quests',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Streak milestones channel
    const streakChannel = AndroidNotificationChannel(
      'streak_milestones',
      'Streak Milestones',
      description: 'Notifications for daily streak achievements',
      importance: Importance.low,
      playSound: true,
    );

    // Badge earned channel
    const badgeChannel = AndroidNotificationChannel(
      'badge_earned',
      'Badges Earned',
      description: 'Notifications for earned badges',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // General notifications channel
    const generalChannel = AndroidNotificationChannel(
      'general',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.low,
    );

    // Create all channels
    await androidPlugin.createNotificationChannel(partyChannel);
    await androidPlugin.createNotificationChannel(questChannel);
    await androidPlugin.createNotificationChannel(streakChannel);
    await androidPlugin.createNotificationChannel(badgeChannel);
    await androidPlugin.createNotificationChannel(generalChannel);

    print('[ENHANCED-NOTIFICATION] Notification channels created');
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('[ENHANCED-NOTIFICATION] FCM permission status: ${settings.authorizationStatus}');

    // Save FCM token to Firestore
    await _saveFCMToken();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message opens
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageOpen);
  }

  /// Save FCM token to Firestore
  Future<void> _saveFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      final user = _auth.currentUser;

      if (token != null && user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('[ENHANCED-NOTIFICATION] FCM token saved: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      print('[ENHANCED-NOTIFICATION] Error saving FCM token: $e');
    }
  }

  /// Handle FCM token refresh
  Future<void> _onTokenRefresh(String newToken) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': newToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('[ENHANCED-NOTIFICATION] FCM token refreshed and saved');
      }
    } catch (e) {
      print('[ENHANCED-NOTIFICATION] Error saving refreshed token: $e');
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// NOTIFICATION HANDLERS
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Handle foreground FCM messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('[ENHANCED-NOTIFICATION] Foreground message received: ${message.notification?.title}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification
      _showLocalNotification(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: jsonEncode(data),
        channelId: _getChannelId(data['type']),
      );
    }

    // Handle specific notification types
    _handleNotificationData(data['type'], data);
  }

  /// Handle background message tap
  void _handleBackgroundMessageOpen(RemoteMessage message) {
    print('[ENHANCED-NOTIFICATION] Background message opened: ${message.notification?.title}');
    
    if (_onNotificationTap != null) {
      _onNotificationTap!(message.data['type'] ?? 'general', message.data);
    }
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    print('[ENHANCED-NOTIFICATION] Local notification tapped: ${response.payload}');

    if (response.payload != null && _onNotificationTap != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _onNotificationTap!(data['type'] ?? 'general', data);
      } catch (e) {
        print('[ENHANCED-NOTIFICATION] Error parsing notification payload: $e');
      }
    }
  }

  /// Handle notification data based on type
  void _handleNotificationData(String? type, Map<String, dynamic> data) {
    switch (type) {
      case 'party_invitation':
        print('[ENHANCED-NOTIFICATION] Party invitation received');
        break;
      case 'quest_completed':
        print('[ENHANCED-NOTIFICATION] Quest completion notification');
        break;
      case 'badge_earned':
        print('[ENHANCED-NOTIFICATION] Badge earned notification');
        break;
      case 'streak_milestone':
        print('[ENHANCED-NOTIFICATION] Streak milestone notification');
        break;
      default:
        print('[ENHANCED-NOTIFICATION] General notification');
    }
  }

  /// Get appropriate channel ID for notification type
  String _getChannelId(String? type) {
    switch (type) {
      case 'party_invitation':
        return 'party_invitations';
      case 'quest_completed':
        return 'quest_completions';
      case 'streak_milestone':
        return 'streak_milestones';
      case 'badge_earned':
        return 'badge_earned';
      default:
        return 'general';
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// LOCAL NOTIFICATION DISPLAY
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
    required String channelId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'party_invitations':
        return 'Party Invitations';
      case 'quest_completions':
        return 'Quest Completions';
      case 'streak_milestones':
        return 'Streak Milestones';
      case 'badge_earned':
        return 'Badges Earned';
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'party_invitations':
        return 'Notifications for party invitations from friends';
      case 'quest_completions':
        return 'Notifications when you complete quests';
      case 'streak_milestones':
        return 'Notifications for daily streak achievements';
      case 'badge_earned':
        return 'Notifications when you earn new badges';
      default:
        return 'General app notifications';
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// PUBLIC NOTIFICATION METHODS
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Show party invitation notification
  Future<void> showPartyInvitationNotification({
    required String partyName,
    required String inviterName,
    required String partyId,
    required String invitationId,
  }) async {
    final data = {
      'type': 'party_invitation',
      'partyId': partyId,
      'partyName': partyName,
      'invitationId': invitationId,
      'inviterName': inviterName,
    };

    await _showLocalNotification(
      title: '👥 Party Invitation!',
      body: '$inviterName invited you to join "$partyName"',
      payload: jsonEncode(data),
      channelId: 'party_invitations',
    );
  }

  /// Show quest completion notification
  Future<void> showQuestCompletionNotification({
    required String questTitle,
    required int xpGained,
    required int coinsGained,
  }) async {
    final data = {
      'type': 'quest_completed',
      'questTitle': questTitle,
      'xpGained': xpGained,
      'coinsGained': coinsGained,
    };

    await _showLocalNotification(
      title: '🎉 Quest Completed!',
      body: '$questTitle\n+${xpGained} XP, +$coinsGained coins',
      payload: jsonEncode(data),
      channelId: 'quest_completions',
    );
  }

  /// Show badge earned notification
  Future<void> showBadgeEarnedNotification({
    required String badgeName,
    required String badgeIcon,
  }) async {
    final data = {
      'type': 'badge_earned',
      'badgeName': badgeName,
    };

    await _showLocalNotification(
      title: '🏆 New Badge Earned!',
      body: 'Congratulations! You earned the "$badgeName" badge!',
      payload: jsonEncode(data),
      channelId: 'badge_earned',
    );
  }

  /// Show streak milestone notification
  Future<void> showStreakMilestoneNotification({
    required int streak,
  }) async {
    final data = {
      'type': 'streak_milestone',
      'streak': streak,
    };

    await _showLocalNotification(
      title: '🔥 Streak Milestone!',
      body: 'Amazing! You\'ve maintained a $streak-day streak!',
      payload: jsonEncode(data),
      channelId: 'streak_milestones',
    );
  }

  /// Show level up notification
  Future<void> showLevelUpNotification({
    required int newLevel,
  }) async {
    final data = {
      'type': 'level_up',
      'level': newLevel,
    };

    await _showLocalNotification(
      title: '⬆️ Level Up!',
      body: 'Congratulations! You reached level $newLevel!',
      payload: jsonEncode(data),
      channelId: 'general',
    );
  }

  /// Show generic notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    final prefs = await NotificationPreferencesService().getForCurrentUser();
    if (!prefs.notificationsEnabled) return;

    final payloadData = {
      'type': type ?? 'general',
      ...?data,
    };

    await _showLocalNotification(
      title: title,
      body: body,
      payload: jsonEncode(payloadData),
      channelId: _getChannelId(type),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// PERMISSIONS & SETTINGS
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      return result ?? false;
    }

    return false;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('[ENHANCED-NOTIFICATION] Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('[ENHANCED-NOTIFICATION] Unsubscribed from topic: $topic');
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// FCM BACKGROUND HANDLER (TOP-LEVEL FUNCTION)
/// ═══════════════════════════════════════════════════════════════════════════════
/// 
/// This MUST be a top-level function (not inside a class) for FCM to work
/// in background/terminated states.

Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  print('[FCM-BACKGROUND] Handling background message: ${message.messageId}');
  print('[FCM-BACKGROUND] Title: ${message.notification?.title}');
  print('[FCM-BACKGROUND] Body: ${message.notification?.body}');
  print('[FCM-BACKGROUND] Data: ${message.data}');

  // Handle the background message
  // The actual notification display is handled by FCM automatically
  // This handler is for any additional processing you need

  final type = message.data['type'];
  
  switch (type) {
    case 'party_invitation':
      // Could pre-fetch party data, etc.
      print('[FCM-BACKGROUND] Party invitation received in background');
      break;
    case 'quest_completed':
      print('[FCM-BACKGROUND] Quest completion in background');
      break;
    default:
      print('[FCM-BACKGROUND] General notification in background');
  }
}
