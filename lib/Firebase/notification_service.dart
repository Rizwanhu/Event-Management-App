import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationType {
  eventCreated,
  eventUpdated,
  eventCancelled,
  newAttendee,
  attendeeCancelled,
  paymentReceived,
  verificationUpdate,
  systemAlert,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: _parseNotificationType(map['type']),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
    );
  }

  static NotificationType _parseNotificationType(dynamic type) {
    if (type == null) return NotificationType.systemAlert;
    
    switch (type.toString().toLowerCase()) {
      case 'eventcreated':
        return NotificationType.eventCreated;
      case 'eventupdated':
        return NotificationType.eventUpdated;
      case 'eventcancelled':
        return NotificationType.eventCancelled;
      case 'newattendee':
        return NotificationType.newAttendee;
      case 'attendeecancelled':
        return NotificationType.attendeeCancelled;
      case 'paymentreceived':
        return NotificationType.paymentReceived;
      case 'verificationupdate':
        return NotificationType.verificationUpdate;
      case 'systemalert':
      default:
        return NotificationType.systemAlert;
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _localNotifications = FlutterLocalNotificationsPlugin();
    await _localNotifications.initialize(initializationSettings);

    // Request notification permissions
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_channel',
      'Event Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Save notification to Firestore
    if (message.data.containsKey('userId')) {
      await sendNotification(
        userId: message.data['userId'],
        title: message.notification?.title ?? 'New Notification',
        message: message.notification?.body ?? '',
        type: NotificationType.systemAlert,
        data: message.data,
      );
    }
  }

  CollectionReference get _notificationsCollection => _firestore.collection('notifications');

  /// Get notifications for current user
  Stream<List<NotificationModel>> getNotifications() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _notificationsCollection
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Get unread notifications count
  Stream<int> getUnreadCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _notificationsCollection
        .where('userId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final batch = _firestore.batch();
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: type,
        data: data ?? {},
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _notificationsCollection.add(notification.toMap());
      print('Notification sent to user: $userId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Send notification to organizer when someone registers for their event
  Future<void> sendNewAttendeeNotification({
    required String organizerId,
    required String eventTitle,
    required String attendeeName,
    required String eventId,
  }) async {
    await sendNotification(
      userId: organizerId,
      title: 'New Registration!',
      message: '$attendeeName registered for "$eventTitle"',
      type: NotificationType.newAttendee,
      data: {
        'eventId': eventId,
        'eventTitle': eventTitle,
        'attendeeName': attendeeName,
      },
    );
  }

  /// Send verification status update notification
  Future<void> sendVerificationUpdateNotification({
    required String organizerId,
    required bool isApproved,
    String? notes,
  }) async {
    await sendNotification(
      userId: organizerId,
      title: isApproved ? 'Verification Approved!' : 'Verification Update',
      message: isApproved
          ? 'Congratulations! Your organizer account has been verified.'
          : 'Your verification request needs attention. ${notes ?? ''}',
      type: NotificationType.verificationUpdate,
      data: {
        'isApproved': isApproved,
        'notes': notes,
      },
    );
  }

  /// Send event cancellation notification to attendees
  Future<void> sendEventCancellationNotification({
    required String eventId,
    required String eventTitle,
    required List<String> attendeeIds,
    String? reason,
  }) async {
    final batch = _firestore.batch();
    
    for (String attendeeId in attendeeIds) {
      final docRef = _notificationsCollection.doc();
      final notification = NotificationModel(
        id: docRef.id,
        userId: attendeeId,
        title: 'Event Cancelled',
        message: '"$eventTitle" has been cancelled. ${reason ?? ''}',
        type: NotificationType.eventCancelled,
        data: {
          'eventId': eventId,
          'eventTitle': eventTitle,
          'reason': reason,
        },
        isRead: false,
        createdAt: DateTime.now(),
      );
      
      batch.set(docRef, notification.toMap());
    }
    
    try {
      await batch.commit();
      print('Event cancellation notifications sent to ${attendeeIds.length} attendees');
    } catch (e) {
      print('Error sending event cancellation notifications: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Delete all notifications for current user
  Future<void> deleteAllNotifications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final batch = _firestore.batch();
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  /// Clean up old notifications (call this periodically)
  Future<void> cleanupOldNotifications({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final snapshot = await _notificationsCollection
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Cleaned up ${snapshot.docs.length} old notifications');
    } catch (e) {
      print('Error cleaning up old notifications: $e');
    }
  }
}
