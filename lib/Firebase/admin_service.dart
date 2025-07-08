import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get admin dashboard statistics
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, now.day);

      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      // Get total organizers
      final organizersSnapshot = await _firestore.collection('event_organizers').get();
      final totalOrganizers = organizersSnapshot.docs.length;

      // Get total events
      final eventsSnapshot = await _firestore.collection('events').get();
      final totalEvents = eventsSnapshot.docs.length;

      // Get events by status
      final pendingEventsSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingEvents = pendingEventsSnapshot.docs.length;

      final approvedEventsSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'approved')
          .get();
      final approvedEvents = approvedEventsSnapshot.docs.length;

      final rejectedEventsSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'rejected')
          .get();
      final rejectedEvents = rejectedEventsSnapshot.docs.length;

      // Get recent registrations (last month)
      final recentUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastMonth))
          .get();
      final recentUsers = recentUsersSnapshot.docs.length;

      final recentOrganizersSnapshot = await _firestore
          .collection('event_organizers')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastMonth))
          .get();
      final recentOrganizers = recentOrganizersSnapshot.docs.length;

      return {
        'totalUsers': totalUsers,
        'totalOrganizers': totalOrganizers,
        'totalEvents': totalEvents,
        'pendingEvents': pendingEvents,
        'approvedEvents': approvedEvents,
        'rejectedEvents': rejectedEvents,
        'recentUsers': recentUsers,
        'recentOrganizers': recentOrganizers,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting dashboard statistics: $e');
      return {
        'totalUsers': 0,
        'totalOrganizers': 0,
        'totalEvents': 0,
        'pendingEvents': 0,
        'approvedEvents': 0,
        'rejectedEvents': 0,
        'recentUsers': 0,
        'recentOrganizers': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get all users for user management
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        data['role'] = 'user';
        return data;
      }).toList();
    });
  }

  /// Get all organizers for user management
  Stream<List<Map<String, dynamic>>> getAllOrganizers() {
    return _firestore
        .collection('event_organizers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        data['role'] = 'organizer';
        return data;
      }).toList();
    });
  }

  /// Block/unblock a user
  Future<void> toggleUserStatus(String userId, String role, bool isActive) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Admin not authenticated');
      }

      String collection = role == 'user' ? 'users' : 'event_organizers';
      
      await _firestore.collection(collection).doc(userId).update({
        'isActive': isActive,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        'statusUpdatedBy': currentUser.uid,
      });

      print('User $userId status updated to ${isActive ? "active" : "blocked"}');
    } catch (e) {
      print('Error updating user status: $e');
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Delete a user account
  Future<void> deleteUser(String userId, String role) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Admin not authenticated');
      }

      String collection = role == 'user' ? 'users' : 'event_organizers';
      
      // Get user data before deletion
      DocumentSnapshot userDoc = await _firestore.collection(collection).doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      // Mark as deleted instead of actually deleting to preserve data integrity
      await _firestore.collection(collection).doc(userId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': currentUser.uid,
        'isActive': false,
      });

      // If it's an organizer, also deactivate their events
      if (role == 'organizer') {
        final eventsSnapshot = await _firestore
            .collection('events')
            .where('organizerId', isEqualTo: userId)
            .get();

        final batch = _firestore.batch();
        for (var doc in eventsSnapshot.docs) {
          batch.update(doc.reference, {
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
            'cancelledReason': 'Organizer account deleted by admin',
          });
        }
        await batch.commit();
      }

      print('User $userId marked as deleted');
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get system reports and analytics
  Future<Map<String, dynamic>> getSystemReports() async {
    try {
      final now = DateTime.now();
      final lastWeek = DateTime(now.year, now.month, now.day - 7);
      final lastMonth = DateTime(now.year, now.month - 1, now.day);

      // Events created this week
      final eventsThisWeekSnapshot = await _firestore
          .collection('events')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastWeek))
          .get();

      // Events created this month
      final eventsThisMonthSnapshot = await _firestore
          .collection('events')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastMonth))
          .get();

      // User registrations this week
      final usersThisWeekSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastWeek))
          .get();

      // Organizer registrations this week
      final organizersThisWeekSnapshot = await _firestore
          .collection('event_organizers')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastWeek))
          .get();

      // Most active organizers (by event count)
      final organizersSnapshot = await _firestore.collection('event_organizers').get();
      List<Map<String, dynamic>> organizerActivity = [];

      for (var orgDoc in organizersSnapshot.docs) {
        final eventsSnapshot = await _firestore
            .collection('events')
            .where('organizerId', isEqualTo: orgDoc.id)
            .get();
        
        organizerActivity.add({
          'organizerId': orgDoc.id,
          'organizerName': orgDoc.data()['firstName'] + ' ' + orgDoc.data()['lastName'],
          'eventCount': eventsSnapshot.docs.length,
        });
      }

      // Sort by event count
      organizerActivity.sort((a, b) => b['eventCount'].compareTo(a['eventCount']));

      return {
        'eventsThisWeek': eventsThisWeekSnapshot.docs.length,
        'eventsThisMonth': eventsThisMonthSnapshot.docs.length,
        'usersThisWeek': usersThisWeekSnapshot.docs.length,
        'organizersThisWeek': organizersThisWeekSnapshot.docs.length,
        'topOrganizers': organizerActivity.take(5).toList(),
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error generating system reports: $e');
      return {
        'eventsThisWeek': 0,
        'eventsThisMonth': 0,
        'usersThisWeek': 0,
        'organizersThisWeek': 0,
        'topOrganizers': [],
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Verify an organizer account
  Future<void> verifyOrganizer(String organizerId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Admin not authenticated');
      }

      await _firestore.collection('event_organizers').doc(organizerId).update({
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': currentUser.uid,
      });

      print('Organizer $organizerId verified successfully');
    } catch (e) {
      print('Error verifying organizer: $e');
      throw Exception('Failed to verify organizer: $e');
    }
  }

  /// Send system-wide announcement
  Future<void> sendSystemAnnouncement(String title, String message, List<String> targetRoles) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Admin not authenticated');
      }

      final batch = _firestore.batch();
      
      // Send to regular users if included
      if (targetRoles.contains('users')) {
        final usersSnapshot = await _firestore.collection('users').get();
        for (var userDoc in usersSnapshot.docs) {
          final notificationRef = _firestore.collection('notifications').doc();
          batch.set(notificationRef, {
            'userId': userDoc.id,
            'title': title,
            'message': message,
            'type': 'system_announcement',
            'data': {'announcementId': notificationRef.id},
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
            'sentBy': currentUser.uid,
          });
        }
      }

      // Send to organizers if included
      if (targetRoles.contains('organizers')) {
        final organizersSnapshot = await _firestore.collection('event_organizers').get();
        for (var orgDoc in organizersSnapshot.docs) {
          final notificationRef = _firestore.collection('notifications').doc();
          batch.set(notificationRef, {
            'userId': orgDoc.id,
            'title': title,
            'message': message,
            'type': 'system_announcement',
            'data': {'announcementId': notificationRef.id},
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
            'sentBy': currentUser.uid,
          });
        }
      }

      await batch.commit();
      print('System announcement sent to ${targetRoles.join(", ")}');
    } catch (e) {
      print('Error sending system announcement: $e');
      throw Exception('Failed to send system announcement: $e');
    }
  }
}
