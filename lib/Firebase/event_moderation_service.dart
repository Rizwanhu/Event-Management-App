import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class EventModerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  /// Get all pending events for admin moderation
  Stream<List<Map<String, dynamic>>> getPendingEvents() {
    print('Getting pending events stream...');
    
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      print('Received ${snapshot.docs.length} pending events');
      
      final events = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Sort by creation date (newest first)
      events.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      
      return events;
    }).handleError((error) {
      print('Error in getPendingEvents stream: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Get event statistics for admin dashboard
  Future<Map<String, int>> getEventStatistics() async {
    try {
      final pendingSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'pending')
          .get();

      final approvedSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'approved')
          .get();

      final rejectedSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'rejected')
          .get();

      final totalSnapshot = await _firestore
          .collection('events')
          .get();

      return {
        'pending': pendingSnapshot.docs.length,
        'approved': approvedSnapshot.docs.length,
        'rejected': rejectedSnapshot.docs.length,
        'total': totalSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting event statistics: $e');
      return {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'total': 0,
      };
    }
  }

  /// Approve event and make it visible to users
  Future<void> approveEvent(String eventId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Admin not authenticated');
      }

      // Get event document first
      DocumentSnapshot eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

      // Update event status to approved in main events collection
      await _firestore.collection('events').doc(eventId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUser.uid,
      });

      // Update approval record if it exists
      final approvalQuery = await _firestore
          .collection('event_approvals')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in approvalQuery.docs) {
        await doc.reference.update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': currentUser.uid,
        });
      }

      // Send notification to organizer
      await _notificationService.sendNotification(
        userId: eventData['organizerId'],
        title: 'Event Approved!',
        message: 'Your event "${eventData['title']}" has been approved and is now live.',
        type: NotificationType.eventCreated, // Use appropriate type
        data: {'eventId': eventId, 'eventTitle': eventData['title']},
      );

      print('Event $eventId approved successfully');
    } catch (e) {
      print('Error approving event: $e');
      throw Exception('Failed to approve event: $e');
    }
  }

  /// Reject event with reason
  Future<void> rejectEvent(String eventId, String reason) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Admin not authenticated');
      }

      // Get event document first
      DocumentSnapshot eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

      // Update event status to rejected in main events collection
      await _firestore.collection('events').doc(eventId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': currentUser.uid,
        'rejectionReason': reason,
      });

      // Update approval record if it exists
      final approvalQuery = await _firestore
          .collection('event_approvals')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in approvalQuery.docs) {
        await doc.reference.update({
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
          'rejectedBy': currentUser.uid,
          'rejectionReason': reason,
        });
      }

      // Send notification to organizer
      await _notificationService.sendNotification(
        userId: eventData['organizerId'],
        title: 'Event Rejected',
        message: 'Your event "${eventData['title']}" was rejected. Reason: $reason',
        type: NotificationType.systemAlert, // Use appropriate type
        data: {'eventId': eventId, 'eventTitle': eventData['title'], 'reason': reason},
      );

      print('Event $eventId rejected successfully');
    } catch (e) {
      print('Error rejecting event: $e');
      throw Exception('Failed to reject event: $e');
    }
  }

  /// Get event details by ID
  Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    try {
      DocumentSnapshot eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (eventDoc.exists) {
        Map<String, dynamic> data = eventDoc.data() as Map<String, dynamic>;
        data['id'] = eventDoc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting event details: $e');
      return null;
    }
  }

  /// Bulk approve events
  Future<void> bulkApproveEvents(List<String> eventIds) async {
    final batch = _firestore.batch();
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      throw Exception('Admin not authenticated');
    }

    try {
      for (String eventId in eventIds) {
        final eventRef = _firestore.collection('events').doc(eventId);
        batch.update(eventRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': currentUser.uid,
        });
      }

      await batch.commit();
      print('Bulk approved ${eventIds.length} events');
    } catch (e) {
      print('Error in bulk approve: $e');
      throw Exception('Failed to bulk approve events: $e');
    }
  }

  /// Bulk reject events
  Future<void> bulkRejectEvents(List<String> eventIds, String reason) async {
    final batch = _firestore.batch();
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      throw Exception('Admin not authenticated');
    }

    try {
      for (String eventId in eventIds) {
        final eventRef = _firestore.collection('events').doc(eventId);
        batch.update(eventRef, {
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
          'rejectedBy': currentUser.uid,
          'rejectionReason': reason,
        });
      }

      await batch.commit();
      print('Bulk rejected ${eventIds.length} events');
    } catch (e) {
      print('Error in bulk reject: $e');
      throw Exception('Failed to bulk reject events: $e');
    }
  }

  /// Get all events for debugging (fallback method)
  Stream<List<Map<String, dynamic>>> getAllEvents() {
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get all pending events using alternative method
  Stream<List<Map<String, dynamic>>> getPendingEventsAlternative() {
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      final allEvents = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Filter pending events manually
      final pendingEvents = allEvents.where((event) {
        final status = event['status'];
        return status == 'pending' || status == null; // Include null status as pending
      }).toList();
      
      // Sort by createdAt manually
      pendingEvents.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
      
      return pendingEvents;
    });
  }
}
