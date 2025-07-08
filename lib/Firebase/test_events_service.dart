import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestEventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create test approved events for debugging
  Future<void> createTestApprovedEvents() async {
    try {
      print('TestEventsService: Creating test approved events...');

      final testEvents = [
        {
          'title': 'Tech Conference 2025',
          'description': 'Latest trends in technology and innovation. Join us for keynotes, workshops, and networking.',
          'category': 'Technology',
          'location': 'San Francisco, CA',
          'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
          'price': 299.0,
          'maxAttendees': 500,
          'organizerId': _auth.currentUser?.uid ?? 'test-organizer-1',
          'organizerName': 'TechCorp Events',
          'organizerEmail': 'events@techcorp.com',
          'status': 'approved',
          'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
          'createdAt': FieldValue.serverTimestamp(),
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': _auth.currentUser?.uid ?? 'admin-user',
        },
        {
          'title': 'Jazz Night at Blue Note',
          'description': 'An evening of smooth jazz with renowned artists. Intimate setting with great acoustics.',
          'category': 'Music & Concerts',
          'location': 'New York, NY',
          'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 8))),
          'price': 75.0,
          'maxAttendees': 120,
          'organizerId': _auth.currentUser?.uid ?? 'test-organizer-2',
          'organizerName': 'Blue Note Club',
          'organizerEmail': 'bookings@bluenote.com',
          'status': 'approved',
          'imageUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
          'createdAt': FieldValue.serverTimestamp(),
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': _auth.currentUser?.uid ?? 'admin-user',
        },
        {
          'title': 'Food Festival Downtown',
          'description': 'Taste the best food from local restaurants. Street food, gourmet dishes, and live cooking demos.',
          'category': 'Food & Dining',
          'location': 'Chicago, IL',
          'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 12))),
          'price': 45.0,
          'maxAttendees': 300,
          'organizerId': _auth.currentUser?.uid ?? 'test-organizer-3',
          'organizerName': 'Downtown Association',
          'organizerEmail': 'events@downtown-chicago.org',
          'status': 'approved',
          'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
          'createdAt': FieldValue.serverTimestamp(),
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': _auth.currentUser?.uid ?? 'admin-user',
        },
        {
          'title': 'Art Gallery Opening',
          'description': 'Contemporary art exhibition featuring local and international artists. Wine and cheese reception.',
          'category': 'Art & Culture',
          'location': 'Los Angeles, CA',
          'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
          'price': 25.0,
          'maxAttendees': 80,
          'organizerId': _auth.currentUser?.uid ?? 'test-organizer-4',
          'organizerName': 'Modern Art Gallery',
          'organizerEmail': 'info@modernartgallery.com',
          'status': 'approved',
          'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
          'createdAt': FieldValue.serverTimestamp(),
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': _auth.currentUser?.uid ?? 'admin-user',
        },
        {
          'title': 'Fitness Bootcamp',
          'description': 'High-intensity outdoor workout session. All fitness levels welcome. Bring water and a towel.',
          'category': 'Sports & Fitness',
          'location': 'Austin, TX',
          'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
          'price': 0.0, // Free event
          'maxAttendees': 50,
          'organizerId': _auth.currentUser?.uid ?? 'test-organizer-5',
          'organizerName': 'Austin Fitness Club',
          'organizerEmail': 'trainers@austinfit.com',
          'status': 'approved',
          'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
          'createdAt': FieldValue.serverTimestamp(),
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': _auth.currentUser?.uid ?? 'admin-user',
        },
      ];

      for (int i = 0; i < testEvents.length; i++) {
        final event = testEvents[i];
        await _firestore.collection('events').add(event);
        print('TestEventsService: Created test event ${i + 1}: ${event['title']}');
      }

      print('TestEventsService: Successfully created ${testEvents.length} test approved events');
    } catch (e) {
      print('TestEventsService Error creating test events: $e');
    }
  }

  /// Create test pending events (for approval workflow testing)
  Future<void> createTestPendingEvents() async {
    try {
      print('TestEventsService: Creating test pending events...');

      final testPendingEvents = [
        {
          'title': 'Startup Pitch Competition',
          'description': 'Young entrepreneurs present their business ideas to investors and judges.',
          'category': 'Business',
          'location': 'Seattle, WA',
          'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 20))),
          'price': 50.0,
          'maxAttendees': 200,
          'organizerId': _auth.currentUser?.uid ?? 'test-organizer-6',
          'organizerName': 'Startup Hub Seattle',
          'organizerEmail': 'events@startuphub.com',
          'status': 'pending',
          'imageUrl': 'https://images.unsplash.com/photo-1556761175-4b46a572b786?w=400',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Community Book Club',
          'description': 'Monthly book discussion group. This month: contemporary fiction.',
          'category': 'Education',
          'location': 'Portland, OR',
          'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 18))),
          'price': 0.0,
          'maxAttendees': 25,
          'organizerId': _auth.currentUser?.uid ?? 'test-organizer-7',
          'organizerName': 'Portland Public Library',
          'organizerEmail': 'programs@portlandlibrary.org',
          'status': 'pending',
          'imageUrl': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (int i = 0; i < testPendingEvents.length; i++) {
        final event = testPendingEvents[i];
        await _firestore.collection('events').add(event);
        print('TestEventsService: Created test pending event ${i + 1}: ${event['title']}');
      }

      print('TestEventsService: Successfully created ${testPendingEvents.length} test pending events');
    } catch (e) {
      print('TestEventsService Error creating test pending events: $e');
    }
  }

  /// Delete all test events (cleanup)
  Future<void> deleteAllTestEvents() async {
    try {
      print('TestEventsService: Deleting all test events...');

      // Delete from events collection
      QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();
      for (QueryDocumentSnapshot doc in eventsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete from event_approvals collection
      QuerySnapshot approvalsSnapshot = await _firestore.collection('event_approvals').get();
      for (QueryDocumentSnapshot doc in approvalsSnapshot.docs) {
        await doc.reference.delete();
      }

      print('TestEventsService: Successfully deleted all test events');
    } catch (e) {
      print('TestEventsService Error deleting test events: $e');
    }
  }

  /// Check Firebase collections and print summary
  Future<void> checkFirebaseStatus() async {
    try {
      print('TestEventsService: Checking Firebase collections status...');

      // Check events collection
      QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();
      print('Events collection: ${eventsSnapshot.docs.length} documents');
      
      // Group by status
      Map<String, int> statusCounts = {};
      for (QueryDocumentSnapshot doc in eventsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      print('Events by status: $statusCounts');

      // Check event_approvals collection
      QuerySnapshot approvalsSnapshot = await _firestore.collection('event_approvals').get();
      print('Event_approvals collection: ${approvalsSnapshot.docs.length} documents');

      // Group by status
      Map<String, int> approvalCounts = {};
      for (QueryDocumentSnapshot doc in approvalsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'unknown';
        approvalCounts[status] = (approvalCounts[status] ?? 0) + 1;
      }
      print('Approvals by status: $approvalCounts');

    } catch (e) {
      print('TestEventsService Error checking Firebase status: $e');
    }
  }
}
