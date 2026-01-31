import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Services/Notifications/notification_center_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════════
/// NOTIFICATION CENTER SCREEN - Central Hub for All Notifications
/// ═══════════════════════════════════════════════════════════════════════════════
/// 
/// Displays all user notifications with:
/// • Unread/Read filtering
/// • Notification type icons and colors
/// • Accept/Decline actions for invitations
/// • Swipe to delete
/// • Mark all as read
///
/// Author: Final Year Project Student
/// Course: CS/SE Final Year Project 2024-2025

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({Key? key}) : super(key: key);

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize notification service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCenterService>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use existing provider from main.dart - don't create new instance
    final service = context.watch<NotificationCenterService>();
    
    // Initialize if not already initialized
    if (!service.isLoading && service.notifications.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        service.initialize();
      });
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NotificationsListView(showUnreadOnly: true),
          _NotificationsListView(showUnreadOnly: false),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF7B2CBF),
      elevation: 0,
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Mark all as read button
        Consumer<NotificationCenterService>(
          builder: (context, service, _) {
            if (service.unreadCount == 0) return const SizedBox.shrink();
            
            return TextButton(
              onPressed: () => _showMarkAllReadConfirmation(context, service),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Consumer<NotificationCenterService>(
            builder: (context, service, _) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unread'),
                    if (service.unreadCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${service.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const Tab(text: 'All'),
        ],
      ),
    );
  }

  void _showMarkAllReadConfirmation(BuildContext context, NotificationCenterService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark all as read?'),
        content: Text('Mark all ${service.unreadCount} unread notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              service.markAllAsRead();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2CBF),
            ),
            child: const Text('Mark Read'),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// NOTIFICATIONS LIST VIEW
/// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationsListView extends StatelessWidget {
  final bool showUnreadOnly;

  const _NotificationsListView({required this.showUnreadOnly});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationCenterService>(
      builder: (context, service, _) {
        if (service.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B2CBF)),
            ),
          );
        }

        final notifications = showUnreadOnly 
            ? service.unreadNotifications 
            : service.notifications;

        if (notifications.isEmpty) {
          return _buildEmptyState(showUnreadOnly);
        }

        return RefreshIndicator(
          onRefresh: () => service.refresh(),
          color: const Color(0xFF7B2CBF),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationCard(
                notification: notification,
                onDismiss: () => service.deleteNotification(notification.id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isUnreadTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnreadTab ? Icons.mark_email_read : Icons.notifications_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isUnreadTab ? 'No unread notifications' : 'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUnreadTab 
                ? 'You\'re all caught up!' 
                : 'Notifications will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// NOTIFICATION CARD
/// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        onDismiss();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.isRead ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead 
                ? Colors.grey.shade200 
                : _hexToColor(notification.color).withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and time
                Row(
                  children: [
                    // Icon container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _hexToColor(notification.color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          notification.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Title and time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: notification.isRead ? Colors.grey.shade700 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Unread indicator
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _hexToColor(notification.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                // Action buttons for invitations
                if (notification.requiresAction) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleDecline(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleAccept(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2CBF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Accept'),
          ),
        ),
      ],
    );
  }

  void _handleNotificationTap(BuildContext context) async {
    final service = context.read<NotificationCenterService>();

    // Mark as read
    if (!notification.isRead) {
      await service.markAsRead(notification.id);
    }

    // Handle specific notification types
    switch (notification.type) {
      case NotificationType.partyInvitation:
        // Show accept/decline dialog
        _showInvitationDialog(context);
        break;
      case NotificationType.badgeEarned:
        // Navigate to badges/profile screen
        _showBadgeDetails(context);
        break;
      case NotificationType.questCompleted:
        // Navigate to quest details
        break;
      case NotificationType.streakMilestone:
        // Show streak celebration
        _showStreakCelebration(context);
        break;
      default:
        break;
    }
  }

  void _handleAccept(BuildContext context) async {
    final service = context.read<NotificationCenterService>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await service.acceptPartyInvitation(notification);
    Navigator.pop(context); // Close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You joined the party!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(service.errorMessage ?? 'Failed to join party'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleDecline(BuildContext context) async {
    final service = context.read<NotificationCenterService>();
    
    final success = await service.declinePartyInvitation(notification);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation declined'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  void _showInvitationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(notification.icon),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Text(
          '${notification.message}\n\nWould you like to join this party?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDecline(context);
            },
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAccept(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2CBF),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(notification.badgeIcon ?? '🏅'),
            const SizedBox(width: 8),
            const Text('Badge Earned!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notification.badgeName ?? 'Unknown Badge',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hexToColor(notification.badgeColor ?? '#FFD700'),
            ),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _showStreakCelebration(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.orange.shade50,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔥', style: TextStyle(fontSize: 40)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Keep it up!'),
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
