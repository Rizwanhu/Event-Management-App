import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create sample pending events for testing
  Future<void> createSamplePendingEvents() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('No user logged in - cannot create test events');
      return;
    }

    final batch = _firestore.batch();
    
    final sampleEvents = [
      {
        'title': 'Tech Conference 2025',
        'description': 'A comprehensive technology conference featuring the latest innovations in AI, blockchain, and cloud computing.',
        'organizerId': currentUser.uid,
        'organizerName': 'Test Organizer',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'eventTime': '09:00',
        'location': 'San Francisco Convention Center',
        'category': 'Technology',
        'tags': ['tech', 'AI', 'blockchain'],
        'imageUrls': ['https://via.placeholder.com/400x200/0066cc/ffffff?text=Tech+Conference'],
        'ticketType': 'paid',
        'ticketPrice': 299.99,
        'maxAttendees': 500,
        'currentAttendees': 0,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': false,
      },
      {
        'title': 'Music Festival Summer 2025',
        'description': 'Three days of amazing music featuring top artists from around the world.',
        'organizerId': currentUser.uid,
        'organizerName': 'Test Organizer',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
        'eventTime': '14:00',
        'location': 'Central Park, New York',
        'category': 'Music',
        'tags': ['music', 'festival', 'outdoor'],
        'imageUrls': ['https://via.placeholder.com/400x200/ff6600/ffffff?text=Music+Festival'],
        'ticketType': 'paid',
        'ticketPrice': 159.99,
        'maxAttendees': 2000,
        'currentAttendees': 0,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': false,
      },
      {
        'title': 'Community Food Drive',
        'description': 'Help us collect food for local families in need. Volunteers welcome!',
        'organizerId': currentUser.uid,
        'organizerName': 'Test Organizer',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
        'eventTime': '10:00',
        'location': 'Community Center',
        'category': 'Community',
        'tags': ['charity', 'food', 'volunteer'],
        'imageUrls': ['https://via.placeholder.com/400x200/00aa44/ffffff?text=Food+Drive'],
        'ticketType': 'free',
        'ticketPrice': null,
        'maxAttendees': 100,
        'currentAttendees': 0,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': false,
      },
      {
        'title': 'Business Networking Event',
        'description': 'Connect with local entrepreneurs and business professionals.',
        'organizerId': currentUser.uid,
        'organizerName': 'Test Organizer',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 21))),
        'eventTime': '18:00',
        'location': 'Downtown Business Center',
        'category': 'Business',
        'tags': ['networking', 'business', 'professional'],
        'imageUrls': ['https://via.placeholder.com/400x200/6600cc/ffffff?text=Networking+Event'],
        'ticketType': 'paid',
        'ticketPrice': 75.0,
        'maxAttendees': 150,
        'currentAttendees': 0,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': false,
      },
    ];

    try {
      for (int i = 0; i < sampleEvents.length; i++) {
        final eventRef = _firestore.collection('events').doc();
        batch.set(eventRef, sampleEvents[i]);
        
        // Also add to event_approvals collection for consistency
        final approvalRef = _firestore.collection('event_approvals').doc();
        batch.set(approvalRef, {
          ...sampleEvents[i],
          'eventId': eventRef.id,
          'submittedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('Successfully created ${sampleEvents.length} sample pending events');
    } catch (e) {
      print('Error creating sample events: $e');
      rethrow;
    }
  }

  /// Create some approved and rejected events for variety
  Future<void> createSampleVarietyEvents() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('No user logged in - cannot create test events');
      return;
    }

    final batch = _firestore.batch();
    
    final varietyEvents = [
      {
        'title': 'Approved Art Exhibition',
        'description': 'Beautiful art exhibition showcasing local artists.',
        'organizerId': currentUser.uid,
        'organizerName': 'Test Organizer',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 60))),
        'location': 'Art Gallery Downtown',
        'category': 'Art',
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': true,
      },
      {
        'title': 'Rejected Controversial Event',
        'description': 'This event was rejected for violating community guidelines.',
        'organizerId': currentUser.uid,
        'organizerName': 'Test Organizer',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 40))),
        'location': 'Various Locations',
        'category': 'Other',
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectionReason': 'Does not comply with community guidelines',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': false,
      },
    ];

    try {
      for (var event in varietyEvents) {
        final eventRef = _firestore.collection('events').doc();
        batch.set(eventRef, event);
      }

      await batch.commit();
      print('Successfully created ${varietyEvents.length} variety events');
    } catch (e) {
      print('Error creating variety events: $e');
      rethrow;
    }
  }

  /// Clean up all test events
  Future<void> cleanUpTestEvents() async {
    try {
      // Get all events for current user
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: _auth.currentUser?.uid)
          .get();

      final batch = _firestore.batch();
      
      for (var doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Also clean up approval records
      final approvalsSnapshot = await _firestore
          .collection('event_approvals')
          .where('organizerId', isEqualTo: _auth.currentUser?.uid)
          .get();

      for (var doc in approvalsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Successfully cleaned up test events');
    } catch (e) {
      print('Error cleaning up test events: $e');
      rethrow;
    }
  }
}
