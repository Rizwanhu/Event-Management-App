import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/event_model.dart';

class EventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all approved events for public display
  Stream<List<Map<String, dynamic>>> getApprovedEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get events by category
  Stream<List<Map<String, dynamic>>> getEventsByCategory(String category) {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .where('category', isEqualTo: category)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Search events by title or description
  Stream<List<Map<String, dynamic>>> searchEvents(String query) {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      final allEvents = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter by query string
      return allEvents.where((event) {
        final title = event['title']?.toString().toLowerCase() ?? '';
        final description = event['description']?.toString().toLowerCase() ?? '';
        final location = event['location']?.toString().toLowerCase() ?? '';
        final category = event['category']?.toString().toLowerCase() ?? '';
        
        final searchQuery = query.toLowerCase();
        
        return title.contains(searchQuery) ||
               description.contains(searchQuery) ||
               location.contains(searchQuery) ||
               category.contains(searchQuery);
      }).toList();
    });
  }

  /// Get event details by ID
  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting event by ID: $e');
      return null;
    }
  }

  /// Get events for a specific organizer
  Stream<List<Map<String, dynamic>>> getOrganizerEvents(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
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

  /// Get upcoming events (public approved events happening in the future)
  Stream<List<Map<String, dynamic>>> getUpcomingEvents() {
    final now = Timestamp.fromDate(DateTime.now());
    
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .where('eventDate', isGreaterThan: now)
        .orderBy('eventDate', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get popular events (by attendee count)
  Stream<List<Map<String, dynamic>>> getPopularEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .orderBy('currentAttendees', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Register user for an event
  Future<bool> registerForEvent(String eventId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if user is already registered
      final registrationQuery = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (registrationQuery.docs.isNotEmpty) {
        throw Exception('Already registered for this event');
      }

      // Get event details
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final maxAttendees = eventData['maxAttendees'] as int?;
      final currentAttendees = eventData['currentAttendees'] as int? ?? 0;

      // Check if event is full
      if (maxAttendees != null && currentAttendees >= maxAttendees) {
        throw Exception('Event is full');
      }

      // Create registration
      await _firestore.collection('event_registrations').add({
        'eventId': eventId,
        'userId': currentUser.uid,
        'registeredAt': FieldValue.serverTimestamp(),
        'status': 'confirmed',
      });

      // Update attendee count
      await _firestore.collection('events').doc(eventId).update({
        'currentAttendees': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error registering for event: $e');
      return false;
    }
  }

  /// Cancel event registration
  Future<bool> cancelRegistration(String eventId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Find registration
      final registrationQuery = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (registrationQuery.docs.isEmpty) {
        throw Exception('No registration found');
      }

      // Delete registration
      await registrationQuery.docs.first.reference.delete();

      // Update attendee count
      await _firestore.collection('events').doc(eventId).update({
        'currentAttendees': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error cancelling registration: $e');
      return false;
    }
  }

  /// Check if user is registered for an event
  Future<bool> isUserRegistered(String eventId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final registrationQuery = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      return registrationQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking registration status: $e');
      return false;
    }
  }

  /// Get events user has registered for
  Stream<List<Map<String, dynamic>>> getUserRegisteredEvents() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('event_registrations')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> events = [];
      
      for (var doc in snapshot.docs) {
        final registrationData = doc.data();
        final eventId = registrationData['eventId'];
        
        final eventDoc = await _firestore.collection('events').doc(eventId).get();
        if (eventDoc.exists) {
          Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
          eventData['id'] = eventDoc.id;
          eventData['registrationId'] = doc.id;
          eventData['registeredAt'] = registrationData['registeredAt'];
          events.add(eventData);
        }
      }
      
      return events;
    });
  }

  /// Get event statistics
  Future<Map<String, int>> getEventStatistics() async {
    try {
      final totalSnapshot = await _firestore.collection('events').get();
      final approvedSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'approved')
          .get();
      final pendingSnapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'pending')
          .get();

      return {
        'total': totalSnapshot.docs.length,
        'approved': approvedSnapshot.docs.length,
        'pending': pendingSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting event statistics: $e');
      return {'total': 0, 'approved': 0, 'pending': 0};
    }
  }
}
