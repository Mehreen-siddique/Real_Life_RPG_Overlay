import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../Achievements/achievement_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════════
/// NOTIFICATION CENTER SERVICE - Central In-App Notification Management
/// ═══════════════════════════════════════════════════════════════════════════════
/// 
/// Manages:
/// • All in-app notifications (party invites, quest completions, badges, streaks)
/// • Real-time notification streams
/// • Notification read/unread status
/// • Notification actions (accept/decline invitations)
/// • Notification history and persistence
///
/// Author: Final Year Project Student
/// Course: CS/SE Final Year Project 2024-2025

class NotificationCenterService extends ChangeNotifier {
  /// Singleton pattern
  static final NotificationCenterService _instance = NotificationCenterService._internal();
  factory NotificationCenterService() => _instance;
  NotificationCenterService._internal();

  /// Firestore instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream subscriptions
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  /// Tracks which user the current stream is attached to.
  /// This is important because the service is a singleton and the logged-in user can change.
  String? _activeStreamUserId;

  /// ═══════════════════════════════════════════════════════════════════════════
  /// STATE VARIABLES
  /// ═══════════════════════════════════════════════════════════════════════════

  /// All notifications for current user
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  /// Unread notifications only
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();

  /// Read notifications only
  List<AppNotification> get readNotifications => 
      _notifications.where((n) => n.isRead).toList();

  /// Count of unread notifications
  int get unreadCount => unreadNotifications.length;

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  /// ═══════════════════════════════════════════════════════════════════════════
  /// INITIALIZATION
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Initialize the notification center service
  Future<void> initialize() async {
    if (!isAuthenticated) {
      print('[NOTIFICATION-CENTER] Cannot initialize - user not authenticated');
      return;
    }

    final uid = currentUserId;
    if (uid == null) return;

    // If we already stream the same user, don't restart.
    if (_activeStreamUserId == uid && _notificationsSubscription != null) return;

    print('[NOTIFICATION-CENTER] Initializing for user: $uid');

    _activeStreamUserId = uid;
    _isLoading = true;
    _errorMessage = null;
    _notifications = [];
    notifyListeners();

    _startNotificationsStream();
  }

  /// Start real-time notifications stream
  void _startNotificationsStream() {
    if (currentUserId == null) return;

    _notificationsSubscription?.cancel();
    _notificationsSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _notifications = snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc.id, doc.data()))
            .toList();
        _isLoading = false;
        print('[NOTIFICATION-CENTER] Received ${_notifications.length} notifications');
        notifyListeners();
      },
      onError: (error) {
        print('[NOTIFICATION-CENTER] Error in notifications stream: $error');
        _errorMessage = 'Failed to load notifications: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Dispose the service
  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// NOTIFICATION ACTIONS
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      // Update unread count on user document
      await _updateUnreadCount();
      
      print('[NOTIFICATION-CENTER] Marked notification $notificationId as read');
    } catch (e) {
      print('[NOTIFICATION-CENTER] Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final unreadNotifications = _notifications.where((n) => !n.isRead);

      for (final notification in unreadNotifications) {
        final ref = _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('notifications')
            .doc(notification.id);
        batch.update(ref, {'read': true});
      }

      await batch.commit();
      
      // Reset unread count
      await _firestore.collection('users').doc(currentUserId).update({
        'hasUnreadNotifications': false,
        'unreadNotificationsCount': 0,
      });

      print('[NOTIFICATION-CENTER] Marked all notifications as read');
    } catch (e) {
      print('[NOTIFICATION-CENTER] Error marking all as read: $e');
      _errorMessage = 'Failed to mark all as read: $e';
      notifyListeners();
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      await _updateUnreadCount();
      
      print('[NOTIFICATION-CENTER] Deleted notification $notificationId');
    } catch (e) {
      print('[NOTIFICATION-CENTER] Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    if (currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      
      for (final notification in _notifications) {
        final ref = _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('notifications')
            .doc(notification.id);
        batch.delete(ref);
      }

      await batch.commit();

      // Reset unread count
      await _firestore.collection('users').doc(currentUserId).update({
        'hasUnreadNotifications': false,
        'unreadNotificationsCount': 0,
      });

      print('[NOTIFICATION-CENTER] Cleared all notifications');
    } catch (e) {
      print('[NOTIFICATION-CENTER] Error clearing notifications: $e');
      _errorMessage = 'Failed to clear notifications: $e';
      notifyListeners();
    }
  }

  /// Accept a party invitation from notification
  Future<bool> acceptPartyInvitation(AppNotification notification) async {
    if (currentUserId == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final partyId = notification.partyId;
      final invitationId = notification.invitationId;

      if (partyId == null || invitationId == null) {
        throw Exception('Missing party or invitation ID');
      }

      // Add user to party
      await _firestore.collection('parties').doc(partyId).update({
        'memberIds': FieldValue.arrayUnion([currentUserId!]),
        'lastActive': Timestamp.now(),
      });

      // Get party name
      final partyDoc = await _firestore.collection('parties').doc(partyId).get();
      final partyName = partyDoc.data()?['name'] ?? 'Unknown Party';

      // Update user's party reference
      await _firestore.collection('users').doc(currentUserId).update({
        'partyId': partyId,
        'partyName': partyName,
      });

      // Achievements integration: party join milestone (guard against null uid).
      final uid = currentUserId;
      if (uid != null) {
        await AchievementService().updateAchievementProgress(uid);
      }

      // Update invitation status
      await _firestore.collection('partyInvitations').doc(invitationId).update({
        'status': 'accepted',
      });

      // Mark notification as read
      await markAsRead(notification.id);

      print('[NOTIFICATION-CENTER] Accepted party invitation: $partyId');
      return true;
    } catch (e) {
      print('[NOTIFICATION-CENTER] Error accepting invitation: $e');
      _errorMessage = 'Failed to accept invitation: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Decline a party invitation from notification
  Future<bool> declinePartyInvitation(AppNotification notification) async {
    if (currentUserId == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final invitationId = notification.invitationId;
      if (invitationId == null) {
        throw Exception('Missing invitation ID');
      }

      // Update invitation status
      await _firestore.collection('partyInvitations').doc(invitationId).update({
        'status': 'declined',
      });

      // Mark notification as read
      await markAsRead(notification.id);

      print('[NOTIFICATION-CENTER] Declined party invitation: $invitationId');
      return true;
    } catch (e) {
      print('[NOTIFICATION-CENTER] Error declining invitation: $e');
      _errorMessage = 'Failed to decline invitation: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// HELPER METHODS
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Update unread notification count on user document
  Future<void> _updateUnreadCount() async {
    if (currentUserId == null) return;

    try {
      final unreadSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .count()
          .get();

      final count = unreadSnapshot.count ?? 0;

      await _firestore.collection('users').doc(currentUserId).update({
        'hasUnreadNotifications': count > 0,
        'unreadNotificationsCount': count,
      });
    } catch (e) {
      print('[NOTIFICATION-CENTER] Error updating unread count: $e');
    }
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    _startNotificationsStream();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// NOTIFICATION MODEL
/// ═══════════════════════════════════════════════════════════════════════════════

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  
  // Party invitation fields
  final String? partyId;
  final String? partyName;
  final String? invitationId;
  final String? inviterId;
  final String? inviterName;
  
  // Badge fields
  final String? badgeType;
  final String? badgeName;
  final String? badgeIcon;
  final String? badgeColor;
  
  // Quest completion fields
  final String? questId;
  final String? questTitle;
  final int? xpGained;
  final int? coinsGained;
  
  // Challenge fields
  final String? challengeId;
  final String? challengeTitle;
  
  // Generic action data
  final Map<String, dynamic>? actionData;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.partyId,
    this.partyName,
    this.invitationId,
    this.inviterId,
    this.inviterName,
    this.badgeType,
    this.badgeName,
    this.badgeIcon,
    this.badgeColor,
    this.questId,
    this.questTitle,
    this.xpGained,
    this.coinsGained,
    this.challengeId,
    this.challengeTitle,
    this.actionData,
  });

  factory AppNotification.fromFirestore(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      type: _parseNotificationType(data['type'] ?? 'general'),
      title: data['title'] ?? 'Notification',
      message: data['message'] ?? '',
      isRead: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      partyId: data['partyId'],
      partyName: data['partyName'],
      invitationId: data['invitationId'],
      inviterId: data['inviterId'] ?? data['fromUserId'],
      inviterName: data['inviterName'] ?? data['fromUsername'],
      badgeType: data['badgeType'],
      badgeName: data['badgeName'],
      badgeIcon: data['badgeIcon'],
      badgeColor: data['badgeColor'],
      questId: data['questId'],
      questTitle: data['questTitle'],
      xpGained: data['xpGained']?.toInt(),
      coinsGained: data['coinsGained']?.toInt(),
      challengeId: data['challengeId'],
      challengeTitle: data['challengeTitle'],
      actionData: data['actionData'] as Map<String, dynamic>?,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'party_invitation':
        return NotificationType.partyInvitation;
      case 'challenge_invitation':
        return NotificationType.challengeInvitation;
      case 'badge_earned':
        return NotificationType.badgeEarned;
      case 'quest_completed':
        return NotificationType.questCompleted;
      case 'streak_milestone':
        return NotificationType.streakMilestone;
      case 'level_up':
        return NotificationType.levelUp;
      case 'gift_received':
        return NotificationType.giftReceived;
      case 'leadership_transferred':
        return NotificationType.leadershipTransferred;
      case 'party_message':
        return NotificationType.partyMessage;
      default:
        return NotificationType.general;
    }
  }

  /// Get icon based on notification type
  String get icon {
    switch (type) {
      case NotificationType.partyInvitation:
        return '👥';
      case NotificationType.challengeInvitation:
        return '🏆';
      case NotificationType.badgeEarned:
        return badgeIcon ?? '🏅';
      case NotificationType.questCompleted:
        return '✅';
      case NotificationType.streakMilestone:
        return '🔥';
      case NotificationType.levelUp:
        return '⬆️';
      case NotificationType.giftReceived:
        return '🎁';
      case NotificationType.leadershipTransferred:
        return '👑';
      case NotificationType.partyMessage:
        return '💬';
      case NotificationType.general:
        return '📢';
    }
  }

  /// Get color based on notification type
  String get color {
    switch (type) {
      case NotificationType.partyInvitation:
        return '#7B2CBF';
      case NotificationType.challengeInvitation:
        return '#FF9800';
      case NotificationType.badgeEarned:
        return badgeColor ?? '#FFD700';
      case NotificationType.questCompleted:
        return '#4CAF50';
      case NotificationType.streakMilestone:
        return '#FF5722';
      case NotificationType.levelUp:
        return '#9C27B0';
      case NotificationType.giftReceived:
        return '#E91E63';
      case NotificationType.leadershipTransferred:
        return '#FFC107';
      case NotificationType.partyMessage:
        return '#2196F3';
      case NotificationType.general:
        return '#757575';
    }
  }

  /// Check if this notification requires action
  bool get requiresAction {
    return type == NotificationType.partyInvitation ||
           type == NotificationType.challengeInvitation;
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

/// Notification Types
enum NotificationType {
  partyInvitation,
  challengeInvitation,
  badgeEarned,
  questCompleted,
  streakMilestone,
  levelUp,
  giftReceived,
  leadershipTransferred,
  partyMessage,
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.partyInvitation:
        return 'Party Invitation';
      case NotificationType.challengeInvitation:
        return 'Challenge Invitation';
      case NotificationType.badgeEarned:
        return 'Badge Earned';
      case NotificationType.questCompleted:
        return 'Quest Completed';
      case NotificationType.streakMilestone:
        return 'Streak Milestone';
      case NotificationType.levelUp:
        return 'Level Up';
      case NotificationType.giftReceived:
        return 'Gift Received';
      case NotificationType.leadershipTransferred:
        return 'Leadership Transferred';
      case NotificationType.partyMessage:
        return 'Party Message';
      case NotificationType.general:
        return 'General';
    }
  }
}
