import 'package:cloud_firestore/cloud_firestore.dart';

class UserEventsService {
  final FirebaseFirestore _firestore;

  UserEventsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all approved events for public display (user search screen)
  Stream<List<Map<String, dynamic>>> getApprovedEvents() {
    try {
      return _firestore.collection('events').snapshots().handleError((error) {
        print('Firestore Error: $error');
        return Stream.value([]);
      }).map((snapshot) {
        if (snapshot.docs.isEmpty) return [];

        final allEvents = snapshot.docs
            .map((doc) {
              try {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;

                // Map the Firebase structure to expected structure
                if (data['imageUrls'] != null &&
                    data['imageUrls'] is List &&
                    (data['imageUrls'] as List).isNotEmpty) {
                  data['imageUrl'] = (data['imageUrls'] as List).first;
                }
                return data;
              } catch (e) {
                print('Error parsing event data: $e');
                return null;
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList();

        // Filter for approved events only (ignore isPublished for search screen)
        final approvedEvents = allEvents.where((event) {
          bool isApproved =
              event['status']?.toString().toLowerCase() == 'approved';
          print(
              'Event: ${event['title']} - Status: ${event['status']} - Approved: $isApproved');
          return isApproved;
        }).toList();

        print(
            'UserEventsService: Found ${approvedEvents.length} approved events');

        // Sort by event date (earliest first)
        approvedEvents.sort((a, b) {
          final dateA = _parseEventDate(a['eventDate']) ?? DateTime.now();
          final dateB = _parseEventDate(b['eventDate']) ?? DateTime.now();
          return dateA.compareTo(dateB);
        });

        return approvedEvents;
      });
    } catch (e) {
      print('Service Error: $e');
      return Stream.value([]);
    }
  }

  DateTime? _parseEventDate(dynamic date) {
    try {
      if (date == null) return null;

      if (date is Timestamp) {
        return date.toDate();
      } else if (date is DateTime) {
        return date;
      } else if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error parsing event date: $e');
      return null;
    }
  }

  /// Get events by category (only approved ones)
  Stream<List<Map<String, dynamic>>> getEventsByCategory(String category) {
    try {
      return _firestore.collection('events').snapshots().handleError((error) {
        print('Firestore Error: $error');
        return Stream.value([]);
      }).map((snapshot) {
        if (snapshot.docs.isEmpty) return [];

        final events = snapshot.docs
            .map((doc) {
              try {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;
                return data;
              } catch (e) {
                print('Error parsing event data: $e');
                return null;
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList();

        // Filter by approved status and category
        final filteredEvents = events
            .where((event) =>
                event['status']?.toString().toLowerCase() == 'approved' &&
                event['category'] == category)
            .toList();

        print(
            'UserEventsService: Found ${filteredEvents.length} approved events in category $category');

        // Sort by event date
        filteredEvents.sort((a, b) {
          final dateA = _parseEventDate(a['eventDate']) ?? DateTime.now();
          final dateB = _parseEventDate(b['eventDate']) ?? DateTime.now();
          return dateA.compareTo(dateB);
        });

        return filteredEvents;
      });
    } catch (e) {
      print('Service Error: $e');
      return Stream.value([]);
    }
  }

  /// Search approved events by title, description, location, or category
  Stream<List<Map<String, dynamic>>> searchEvents(String query) {
    try {
      return _firestore.collection('events').snapshots().handleError((error) {
        print('Firestore Error: $error');
        return Stream.value([]);
      }).map((snapshot) {
        if (snapshot.docs.isEmpty) return [];

        final allEvents = snapshot.docs
            .map((doc) {
              try {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;

                // Map the Firebase structure to expected structure
                if (data['imageUrls'] != null &&
                    data['imageUrls'] is List &&
                    (data['imageUrls'] as List).isNotEmpty) {
                  data['imageUrl'] = (data['imageUrls'] as List).first;
                }
                return data;
              } catch (e) {
                print('Error parsing event data: $e');
                return null;
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList();

        print(
            'UserEventsService: Searching through ${allEvents.length} total events');

        // Filter by query string and approved status only
        final results = allEvents.where((event) {
          // Ensure event is approved
          if (event['status']?.toString().toLowerCase() != 'approved') {
            return false;
          }

          final title = event['title']?.toString().toLowerCase() ?? '';
          final description =
              event['description']?.toString().toLowerCase() ?? '';
          final location = event['location']?.toString().toLowerCase() ?? '';
          final category = event['category']?.toString().toLowerCase() ?? '';
          final organizerName =
              event['organizerName']?.toString().toLowerCase() ?? '';

          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) ||
              description.contains(searchQuery) ||
              location.contains(searchQuery) ||
              category.contains(searchQuery) ||
              organizerName.contains(searchQuery);
        }).toList();

        print(
            'UserEventsService: Found ${results.length} events matching search query');

        // Sort by relevance (title matches first, then others)
        results.sort((a, b) {
          final titleA = a['title']?.toString().toLowerCase() ?? '';
          final titleB = b['title']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          final aTitleMatch = titleA.contains(searchQuery);
          final bTitleMatch = titleB.contains(searchQuery);

          if (aTitleMatch && !bTitleMatch) return -1;
          if (!aTitleMatch && bTitleMatch) return 1;

          // If both or neither match title, sort by date
          final dateA = _parseEventDate(a['eventDate']) ?? DateTime.now();
          final dateB = _parseEventDate(b['eventDate']) ?? DateTime.now();
          return dateA.compareTo(dateB);
        });

        return results;
      });
    } catch (e) {
      print('Service Error: $e');
      return Stream.value([]);
    }
  }

  /// Get event by ID
  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        } catch (e) {
          print('Error parsing event data: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Service Error: $e');
      return null;
    }
  }

  /// Create multiple test approved events (for debugging)
  Future<void> createMultipleTestApprovedEvents() async {
    try {
      final testEvents = [
        {
          'title': 'Test Event 1',
          'status': 'approved',
          'eventDate': Timestamp.now(),
          'description': 'Test event description',
          'location': 'Test location',
          'category': 'test',
          'organizerName': 'Test Organizer'
        },
        {
          'title': 'Test Event 2',
          'status': 'approved',
          'eventDate': Timestamp.now(),
          'description': 'Test event description 2',
          'location': 'Test location 2',
          'category': 'test',
          'organizerName': 'Test Organizer'
        }
      ];

      final batch = _firestore.batch();
      for (var event in testEvents) {
        final docRef = _firestore.collection('events').doc();
        batch.set(docRef, event);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      // Use print instead of debugPrint for compatibility
      print('Firebase Error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Unexpected Error: $e');
      rethrow;
    }
  }

  /// Create multiple test approved events (for debugging)
  Future<void> createTestApprovedEvents() async {
    // Stub: Implement as needed
    print('createTestApprovedEvents called (stub)');
  }

  /// Create multiple test pending events (for debugging)
  Future<void> createTestPendingEvents() async {
    // Stub: Implement as needed
    print('createTestPendingEvents called (stub)');
  }

  /// Check Firebase status (for debugging)
  Future<void> checkFirebaseStatus() async {
    // Stub: Implement as needed
    print('checkFirebaseStatus called (stub)');
  }

  /// Delete all test events (for debugging)
  Future<void> deleteAllTestEvents() async {
    // Stub: Implement as needed
    print('deleteAllTestEvents called (stub)');
  }

  /// Debug event statuses (for debugging)
  Future<void> debugEventStatuses() async {
    // Stub: Implement as needed
    print('debugEventStatuses called (stub)');
  }

  /// Create a single test approved event (for debugging)
  Future<void> createTestApprovedEvent() async {
    // Stub: Implement as needed
    print('createTestApprovedEvent called (stub)');
  }
}
