import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_preferences_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    print(' NotificationService: Initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Show quest completion notification
  Future<void> showQuestCompletedNotification(String questTitle, int xpGained, int coinsGained) async {
    final prefs = await NotificationPreferencesService().getForCurrentUser();
    if (!prefs.questReminders) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'quest_completion_channel',
      'Quest Completions',
      channelDescription: 'Notifications for completed quests',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF9458F7),
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '🎉 Quest Completed!',
      '$questTitle\n+${xpGained}XP, +${coinsGained} coins',
      notificationDetails,
      payload: 'quest_completed',
    );

    print(' Quest completion notification sent: $questTitle');
  }

  // Show level up notification
  Future<void> showLevelUpNotification(int newLevel) async {
    final prefs = await NotificationPreferencesService().getForCurrentUser();
    if (!prefs.notificationsEnabled) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'level_up_channel',
      'Level Ups',
      channelDescription: 'Notifications for level progression',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFC107),
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000) + 1,
      ' Level Up!',
      'Congratulations! You reached level $newLevel!',
      notificationDetails,
      payload: 'level_up',
    );

    print(' Level up notification sent: Level $newLevel');
  }

  // Show daily streak notification
  Future<void> showStreakNotification(int streak) async {
    final prefs = await NotificationPreferencesService().getForCurrentUser();
    if (!prefs.notificationsEnabled) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'streak_channel',
      'Daily Streaks',
      channelDescription: 'Notifications for daily quest streaks',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF34D399),
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000) + 2,
      ' Streak Maintained!',
      'You\'ve completed quests for $streak days in a row!',
      notificationDetails,
      payload: 'streak',
    );

    print(' Streak notification sent: $streak days');
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      print(' Notification permissions granted: $result');
      return result ?? false;
    }
    
    return false;
  }
}
