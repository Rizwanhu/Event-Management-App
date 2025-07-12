// Delete a notification by document ID
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteNotification(String notificationId) async {
  try {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  } catch (e) {
    debugPrint('Error deleting notification: $e');
    rethrow;
  }
}

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<User?> signUp(
    String email,
    String password,
    String name,
    String role, // 'user', 'organizer', or 'admin'
    BuildContext context,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Map role to collection name
      String collectionName;
      switch (role) {
        case 'admin':
          collectionName = 'Admin';
          break;
        case 'organizer':
          collectionName = 'Event-managers';
          break;
        default:
          collectionName = 'Users';
      }

      // Add 'approved: false' for organizers
      final userData = {
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (role == 'organizer') {
        userData['approved'] = false;
      }

      await _firestore
          .collection(collectionName)
          .doc(credential.user!.uid)
          .set(userData);

      return credential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? 'Sign up failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Event Moderation Functions

  /// Get all pending events for admin moderation from approval collection
  Stream<List<Map<String, dynamic>>> getPendingEvents() {
    return _firestore
        .collection('event_approvals')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Approve event and make it visible to users
  Future<void> approveEvent(String approvalId) async {
    try {
      // Get approval document
      DocumentSnapshot approvalDoc =
          await _firestore.collection('event_approvals').doc(approvalId).get();
      if (!approvalDoc.exists) {
        throw Exception('Approval record not found');
      }

      Map<String, dynamic> approvalData =
          approvalDoc.data() as Map<String, dynamic>;
      String eventId = approvalData['eventId'];

      // Update event status to approved
      await _firestore.collection('events').doc(eventId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': _auth.currentUser?.uid,
      });

      // Update approval record
      await _firestore.collection('event_approvals').doc(approvalId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': _auth.currentUser?.uid,
      });

      // Send notification to organizer
      await _sendNotificationToOrganizer(
        approvalData['organizerId'],
        'Event Approved!',
        'Your event "${approvalData['title']}" has been approved and is now live.',
        'event_approved',
        {'eventId': eventId, 'eventTitle': approvalData['title']},
      );
    } catch (e) {
      throw Exception('Failed to approve event: $e');
    }
  }

  /// Reject event with reason
  Future<void> rejectEvent(String approvalId, String reason) async {
    try {
      // Get approval document
      DocumentSnapshot approvalDoc =
          await _firestore.collection('event_approvals').doc(approvalId).get();
      if (!approvalDoc.exists) {
        throw Exception('Approval record not found');
      }

      Map<String, dynamic> approvalData =
          approvalDoc.data() as Map<String, dynamic>;
      String eventId = approvalData['eventId'];

      // Update event status to rejected
      await _firestore.collection('events').doc(eventId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': _auth.currentUser?.uid,
        'rejectionReason': reason,
      });

      // Update approval record
      await _firestore.collection('event_approvals').doc(approvalId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': _auth.currentUser?.uid,
        'rejectionReason': reason,
      });

      // Send notification to organizer
      await _sendNotificationToOrganizer(
        approvalData['organizerId'],
        'Event Rejected',
        'Your event "${approvalData['title']}" was rejected. Reason: $reason',
        'event_rejected',
        {
          'eventId': eventId,
          'eventTitle': approvalData['title'],
          'reason': reason
        },
      );
    } catch (e) {
      throw Exception('Failed to reject event: $e');
    }
  }

  /// Get approved events for search screen
  Stream<List<Map<String, dynamic>>> getApprovedEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Send notification to admin when new event is submitted
  Future<void> notifyAdminOfNewEvent(
      String eventId, String eventTitle, String organizerName) async {
    try {
      // Get all admin users (remove isActive filter for now)
      QuerySnapshot adminSnapshot = await _firestore.collection('admins').get();

      // Send notification to each admin
      for (DocumentSnapshot adminDoc in adminSnapshot.docs) {
        await _sendNotificationToUser(
          adminDoc.id,
          'New Event Pending Approval',
          'A new event "$eventTitle" by $organizerName is waiting for your review.',
          'event_pending_review',
          {
            'eventId': eventId,
            'eventTitle': eventTitle,
            'organizerName': organizerName
          },
        );
      }
    } catch (e) {
      print('Error notifying admins: $e');
    }
  }

  /// Send notification to organizer
  Future<void> _sendNotificationToOrganizer(
    String organizerId,
    String title,
    String message,
    String type,
    Map<String, dynamic> data,
  ) async {
    await _sendNotificationToUser(organizerId, title, message, type, data);
  }

  /// Generic notification sender
  Future<void> _sendNotificationToUser(
    String userId,
    String title,
    String message,
    String type,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Get notifications for current user
  Stream<List<Map<String, dynamic>>> getNotifications() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    // Try to get user role from Firestore (admins, event_organizers, users)
    Future<String?> getUserRole(String uid) async {
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) return 'admin';
      final orgDoc =
          await _firestore.collection('event_organizers').doc(uid).get();
      if (orgDoc.exists) return 'organizer';
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) return 'user';
      return null;
    }

    // Use a stream that depends on the user's role
    return Stream.fromFuture(getUserRole(currentUser.uid)).asyncExpand((role) {
      if (role == 'admin') {
        // Admin: show notifications for all admins (targetRole) and personal
        final adminQuery = _firestore
            .collection('notifications')
            .where('targetRole', isEqualTo: 'admin')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots();
        final userQuery = _firestore
            .collection('notifications')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots();
        return adminQuery.asyncMap((adminSnap) async {
          final userSnap = await userQuery.first;
          final allDocs = <String, Map<String, dynamic>>{};
          for (var doc in adminSnap.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            allDocs[doc.id] = data;
          }
          for (var doc in userSnap.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            allDocs[doc.id] = data;
          }
          final docsList = allDocs.values.toList();
          docsList.sort((a, b) {
            final aTime = a['createdAt'] is Timestamp
                ? a['createdAt'].millisecondsSinceEpoch
                : 0;
            final bTime = b['createdAt'] is Timestamp
                ? b['createdAt'].millisecondsSinceEpoch
                : 0;
            return bTime.compareTo(aTime);
          });
          return docsList;
        });
      } else if (role == 'organizer') {
        // Organizer: only personal notifications
        return _firestore
            .collection('notifications')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
      } else {
        // Regular user: only personal notifications
        return _firestore
            .collection('notifications')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
      }
    });
  }

  /// Get unread notifications count
  Stream<int> getUnreadNotificationsCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Approve an organizer (admin action)
  Future<void> approveOrganizer(String organizerId) async {
    try {
      await _firestore.collection('Event-managers').doc(organizerId).update({
        'approved': true,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': _auth.currentUser?.uid,
      });
      // Optionally notify organizer
      await _sendNotificationToOrganizer(
        organizerId,
        'Organizer Approved',
        'Your account has been approved by the admin. You can now create events.',
        'organizer_approved',
        {},
      );
    } catch (e) {
      print('Error approving organizer: $e');
      throw Exception('Failed to approve organizer');
    }
  }

  /// Check if current organizer is approved
  Future<bool> isCurrentOrganizerApproved() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc =
        await _firestore.collection('Event-managers').doc(user.uid).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    return data['approved'] == true;
  }
}
