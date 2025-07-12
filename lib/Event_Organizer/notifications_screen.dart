import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              await _notificationService.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('All notifications marked as read')),
              );
            },
            child: const Text('Mark All Read',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(
                'OrganizerNotificationsScreen: Error loading notifications: \\${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          // DEBUG PRINT: Log all raw notification documents
          print(
              'OrganizerNotificationsScreen: Raw notifications from Firestore:');
          for (var doc in docs) {
            print('DocID: \\${doc.id}, Data: \\${doc.data()}');
          }
          final notifications = docs
              .map((doc) => NotificationModel.fromMap(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see updates about your events here',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () async {
          print(
              'Notification tapped: id=${notification.id}, type=${notification.type}, isRead=${notification.isRead}');
          if (!notification.isRead) {
            await _notificationService.markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.eventCreated:
        return Colors.green;
      case NotificationType.eventUpdated:
        return Colors.blue;
      case NotificationType.eventCancelled:
        return Colors.red;
      case NotificationType.newAttendee:
        return Colors.purple;
      case NotificationType.attendeeCancelled:
        return Colors.orange;
      case NotificationType.paymentReceived:
        return Colors.teal;
      case NotificationType.verificationUpdate:
        return Colors.indigo;
      case NotificationType.systemAlert:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.eventCreated:
        return Icons.event;
      case NotificationType.eventUpdated:
        return Icons.edit;
      case NotificationType.eventCancelled:
        return Icons.cancel;
      case NotificationType.newAttendee:
        return Icons.person_add;
      case NotificationType.attendeeCancelled:
        return Icons.person_remove;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.verificationUpdate:
        return Icons.verified;
      case NotificationType.systemAlert:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle different notification types
    switch (notification.type) {
      case NotificationType.eventCreated:
      case NotificationType.eventUpdated:
      case NotificationType.newAttendee:
      case NotificationType.attendeeCancelled:
        final eventId = notification.data['eventId'] as String?;
        if (eventId != null) {
          // Navigate to event details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to event: $eventId')),
          );
        }
        break;
      case NotificationType.verificationUpdate:
        // Navigate to settings/verification section
        Navigator.of(context).pop(); // Go back to dashboard
        // Then navigate to settings - this would be handled by the dashboard
        break;
      default:
        // For other types, just show the notification is read
        break;
    }
  }
}
