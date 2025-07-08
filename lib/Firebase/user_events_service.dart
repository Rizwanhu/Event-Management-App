import 'package:cloud_firestore/cloud_firestore.dart';

class UserEventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all approved events for public display (user search screen)
  Stream<List<Map<String, dynamic>>> getApprovedEvents() {
    print('UserEventsService: Fetching approved events...');
    
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      print('UserEventsService: Found ${snapshot.docs.length} total events');
      
      final allEvents = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        
        // Map the Firebase structure to expected structure
        if (data['imageUrls'] != null && data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty) {
          data['imageUrl'] = (data['imageUrls'] as List).first;
        }
        
        return data;
      }).toList();
      
      // Filter for approved events only (ignore isPublished for search screen)
      final approvedEvents = allEvents.where((event) {
        bool isApproved = event['status']?.toString().toLowerCase() == 'approved';
        print('Event: ${event['title']} - Status: ${event['status']} - Approved: $isApproved');
        return isApproved;
      }).toList();
      
      print('UserEventsService: Found ${approvedEvents.length} approved events');
      
      // Sort by event date (earliest first)
      approvedEvents.sort((a, b) {
        final dateA = _parseEventDate(a['eventDate']) ?? DateTime.now();
        final dateB = _parseEventDate(b['eventDate']) ?? DateTime.now();
        return dateA.compareTo(dateB);
      });
      
      return approvedEvents;
    });
  }
  
  DateTime? _parseEventDate(dynamic date) {
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
  }

  /// Get events by category (only approved ones)
  Stream<List<Map<String, dynamic>>> getEventsByCategory(String category) {
    print('UserEventsService: Fetching events for category: $category');
    
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Filter by approved status and category
      final filteredEvents = events.where((event) => 
        event['status']?.toString().toLowerCase() == 'approved' && 
        event['category'] == category
      ).toList();
      
      print('UserEventsService: Found ${filteredEvents.length} approved events in category $category');
      
      // Sort by event date
      filteredEvents.sort((a, b) {
        final dateA = _parseEventDate(a['eventDate']) ?? DateTime.now();
        final dateB = _parseEventDate(b['eventDate']) ?? DateTime.now();
        return dateA.compareTo(dateB);
      });
      
      return filteredEvents;
    });
  }

  /// Search approved events by title, description, location, or category
  Stream<List<Map<String, dynamic>>> searchEvents(String query) {
    print('UserEventsService: Searching events with query: $query');
    
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      final allEvents = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        
        // Map the Firebase structure to expected structure
        if (data['imageUrls'] != null && data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty) {
          data['imageUrl'] = (data['imageUrls'] as List).first;
        }
        
        return data;
      }).toList();

      print('UserEventsService: Searching through ${allEvents.length} total events');

      // Filter by query string and approved status only
      final results = allEvents.where((event) {
        // Ensure event is approved
        if (event['status']?.toString().toLowerCase() != 'approved') {
          return false;
        }
        
        final title = event['title']?.toString().toLowerCase() ?? '';
        final description = event['description']?.toString().toLowerCase() ?? '';
        final location = event['location']?.toString().toLowerCase() ?? '';
        final category = event['category']?.toString().toLowerCase() ?? '';
        final organizerName = event['organizerName']?.toString().toLowerCase() ?? '';
        
        final searchQuery = query.toLowerCase();
        
        return title.contains(searchQuery) ||
               description.contains(searchQuery) ||
               location.contains(searchQuery) ||
               category.contains(searchQuery) ||
               organizerName.contains(searchQuery);
      }).toList();

      print('UserEventsService: Found ${results.length} events matching search query');
      
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
  }

  /// Get event by ID
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
      return null;
    }
  }
}
