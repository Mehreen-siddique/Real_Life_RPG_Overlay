import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_life_rpg/Services/Notifications/notification_center_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════════
/// IN-APP NOTIFICATION SYSTEM
/// ═══════════════════════════════════════════════════════════════════════════════
/// 
/// Displays pending party invitations and notifications when user opens the app
/// Shows as an overlay that can be dismissed or clicked to view details

class InAppNotificationManager extends StatefulWidget {
  final Widget child;

  const InAppNotificationManager({
    super.key,
    required this.child,
  });

  @override
  State<InAppNotificationManager> createState() => _InAppNotificationManagerState();
}

class _InAppNotificationManagerState extends State<InAppNotificationManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationCenterService _notificationCenter = NotificationCenterService();
  
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;
  List<Map<String, dynamic>> _pendingNotifications = [];
  bool _showingNotification = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Listen for unread notifications
    _notificationsSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final notifications = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          if (notifications.isNotEmpty && !_showingNotification) {
            setState(() {
              _pendingNotifications = notifications;
            });
            _showNextNotification();
          }
        });
  }

  void _showNextNotification() {
    if (_pendingNotifications.isEmpty || _showingNotification) return;

    setState(() {
      _showingNotification = true;
    });
  }

  void _dismissNotification(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Mark as read
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});

    setState(() {
      _pendingNotifications.removeWhere((n) => n['id'] == notificationId);
      _showingNotification = false;
    });

    // Show next notification if available
    if (_pendingNotifications.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), _showNextNotification);
    }
  }

  void _acceptPartyInvitation(Map<String, dynamic> notification) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final notifId = notification['id'] as String?;
    if (notifId == null) return;

    // Delegate to central notification center which already handles
    // accepting party invitations and updating user/party docs.
    final appNotification = AppNotification.fromFirestore(notifId, {
      'type': notification['type'],
      'title': notification['title'],
      'message': notification['message'],
      'invitationId': notification['invitationId'],
      'partyId': notification['partyId'],
      'read': notification['read'] ?? false,
      'createdAt': notification['createdAt'],
    });

    final success = await _notificationCenter.acceptPartyInvitation(appNotification);

    // Mark as read and close UI
    _dismissNotification(notifId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'You joined the party!' : 'Failed to join party'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showingNotification && _pendingNotifications.isNotEmpty)
          _buildNotificationOverlay(_pendingNotifications.first),
      ],
    );
  }

  Widget _buildNotificationOverlay(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'general';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: type == 'party_invitation' 
                  ? const Color(0xFF7B2CBF) 
                  : Colors.grey.shade300,
              width: type == 'party_invitation' ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    type == 'party_invitation' 
                        ? Icons.group_add 
                        : Icons.notifications,
                    color: type == 'party_invitation' 
                        ? const Color(0xFF7B2CBF) 
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _dismissNotification(notification['id']),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              if (type == 'party_invitation') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _dismissNotification(notification['id']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptPartyInvitation(notification),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B2CBF),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Join Party'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
