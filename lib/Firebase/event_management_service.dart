import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Models/event_model.dart';

class EventManagementService {
  static final EventManagementService _instance = EventManagementService._internal();
  factory EventManagementService() => _instance;
  EventManagementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference get _eventsCollection => _firestore.collection('events');

  /// Create a new event
  Future<String> createEvent(EventModel event) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create event document
      final docRef = await _eventsCollection.add(event.toMap());
      
      print('Event created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating event: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  /// Create event without image upload (fallback method)
  Future<String> createEventWithoutImages(EventModel event) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create event document without images
      final eventWithoutImages = event.copyWith(imageUrls: []);
      final docRef = await _eventsCollection.add(eventWithoutImages.toMap());
      
      print('Event created successfully without images with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating event without images: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  /// Update an existing event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Verify user owns this event
      final eventDoc = await _eventsCollection.doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != currentUser.uid) {
        throw Exception('You do not have permission to update this event');
      }

      // Update event with new timestamp
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());
      await _eventsCollection.doc(eventId).update(updatedEvent.toMap());
      
      print('Event updated successfully');
    } catch (e) {
      print('Error updating event: $e');
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Verify user owns this event
      final eventDoc = await _eventsCollection.doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData['organizerId'] != currentUser.uid) {
        throw Exception('You do not have permission to delete this event');
      }

      await _eventsCollection.doc(eventId).delete();
      print('Event deleted successfully');
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Get events for current organizer
  Stream<List<EventModel>> getOrganizerEvents() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('No authenticated user found');
      return Stream.value([]);
    }

    print('Getting events for user: ${currentUser.uid}');
    
    try {
      return _eventsCollection
          .where('organizerId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            print('Firestore stream error: $error');
            return <QuerySnapshot>[];
          })
          .map((snapshot) {
            print('Stream snapshot received with ${snapshot.docs.length} documents');
            return snapshot.docs.map((doc) {
              try {
                return EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              } catch (e) {
                print('Error parsing event document ${doc.id}: $e');
                return null;
              }
            }).where((event) => event != null).cast<EventModel>().toList();
          });
    } catch (e) {
      print('Error setting up events stream: $e');
      return Stream.value([]);
    }
  }

  /// Get events for current organizer (non-stream version)
  Future<List<EventModel>> getOrganizerEventsOnce() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      print('Fetching events for user: ${currentUser.uid}');
      
      final snapshot = await _eventsCollection
          .where('organizerId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      print('Found ${snapshot.docs.length} event documents');
      
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Get single event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  /// Upload event images to Firebase Storage
  Future<List<String>> uploadEventImages(List<XFile> images, String eventId) async {
    List<String> downloadUrls = [];
    
    try {
      if (images.isEmpty) return [];

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      for (int i = 0; i < images.length; i++) {
        try {
          final file = images[i];
          final fileName = 'event_${eventId}_image_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = _storage.ref().child('event_images').child(eventId).child(fileName);

          print('Uploading image $i: $fileName');
          
          // Upload file - handle both web and mobile with better error handling
          UploadTask uploadTask;
          if (kIsWeb) {
            // For web, read as bytes with better error handling
            try {
              final bytes = await file.readAsBytes().timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw Exception('Timeout reading image bytes'),
              );
              
              // Create metadata with proper content type
              final metadata = SettableMetadata(
                contentType: 'image/jpeg',
                customMetadata: {
                  'uploadedBy': currentUser.uid,
                  'eventId': eventId,
                  'uploadedAt': DateTime.now().toIso8601String(),
                },
              );
              
              uploadTask = ref.putData(bytes, metadata);
            } catch (e) {
              print('Error reading bytes for image $i: $e');
              continue; // Skip this image and continue with others
            }
          } else {
            // For mobile, use file path
            final metadata = SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'uploadedBy': currentUser.uid,
                'eventId': eventId,
                'uploadedAt': DateTime.now().toIso8601String(),
              },
            );
            
            uploadTask = ref.putFile(File(file.path), metadata);
          }
          
          // Upload with progress tracking and timeout
          final snapshot = await uploadTask.timeout(
            const Duration(minutes: 2),
            onTimeout: () => throw Exception('Upload timeout for image $i'),
          );
          
          // Get download URL with retry logic
          String? downloadUrl;
          for (int retry = 0; retry < 3; retry++) {
            try {
              downloadUrl = await snapshot.ref.getDownloadURL();
              break;
            } catch (e) {
              if (retry == 2) {
                throw Exception('Failed to get download URL after 3 retries: $e');
              }
              await Future.delayed(Duration(seconds: retry + 1));
            }
          }
          
          if (downloadUrl != null) {
            downloadUrls.add(downloadUrl);
            print('Image $i uploaded successfully');
          }
          
        } catch (e) {
          print('Failed to upload image $i: $e');
          // Continue with other images instead of failing completely
          continue;
        }
      }

      print('Successfully uploaded ${downloadUrls.length} out of ${images.length} images for event $eventId');
      return downloadUrls;
      
    } catch (e) {
      print('Error uploading images: $e');
      // Return any successfully uploaded URLs instead of failing completely
      return downloadUrls;
    }
  }

  /// Submit event for approval (if moderation is required)
  Future<void> submitEventForApproval(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': EventStatus.pending.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      print('Event submitted for approval');
    } catch (e) {
      print('Error submitting event for approval: $e');
      throw Exception('Failed to submit event for approval: $e');
    }
  }

  /// Publish event (make it live)
  Future<void> publishEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': EventStatus.live.toString().split('.').last,
        'isPublished': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      print('Event published successfully');
    } catch (e) {
      print('Error publishing event: $e');
      throw Exception('Failed to publish event: $e');
    }
  }

  /// Cancel event
  Future<void> cancelEvent(String eventId, String reason) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': EventStatus.cancelled.toString().split('.').last,
        'rejectionReason': reason,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      print('Event cancelled successfully');
    } catch (e) {
      print('Error cancelling event: $e');
      throw Exception('Failed to cancel event: $e');
    }
  }

  /// Get event statistics for organizer dashboard
  Future<Map<String, dynamic>> getEventStatistics() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'totalEvents': 0,
          'liveEvents': 0,
          'completedEvents': 0,
          'totalAttendees': 0,
          'totalRevenue': 0.0,
        };
      }

      final snapshot = await _eventsCollection
          .where('organizerId', isEqualTo: currentUser.uid)
          .get();

      int totalEvents = snapshot.docs.length;
      int liveEvents = 0;
      int completedEvents = 0;
      int totalAttendees = 0;
      double totalRevenue = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        
        if (status == 'live') liveEvents++;
        if (status == 'completed') completedEvents++;
        
        totalAttendees += (data['currentAttendees'] as int?) ?? 0;
        
        if (data['ticketType'] == 'paid') {
          final attendees = (data['currentAttendees'] as int?) ?? 0;
          final price = (data['ticketPrice'] as num?)?.toDouble() ?? 0.0;
          totalRevenue += attendees * price;
        }
      }

      return {
        'totalEvents': totalEvents,
        'liveEvents': liveEvents,
        'completedEvents': completedEvents,
        'totalAttendees': totalAttendees,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('Error getting event statistics: $e');
      return {
        'totalEvents': 0,
        'liveEvents': 0,
        'completedEvents': 0,
        'totalAttendees': 0,
        'totalRevenue': 0.0,
      };
    }
  }

  /// Get events by status
  Stream<List<EventModel>> getEventsByStatus(EventStatus status) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _eventsCollection
        .where('organizerId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Search events for organizer
  Future<List<EventModel>> searchOrganizerEvents(String query) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final snapshot = await _eventsCollection
          .where('organizerId', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((event) =>
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              event.description.toLowerCase().contains(query.toLowerCase()) ||
              event.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  /// Duplicate an event
  Future<String> duplicateEvent(String eventId) async {
    try {
      final originalEvent = await getEventById(eventId);
      if (originalEvent == null) {
        throw Exception('Original event not found');
      }

      final duplicatedEvent = originalEvent.copyWith(
        title: '${originalEvent.title} (Copy)',
        status: EventStatus.draft,
        updatedAt: DateTime.now(),
        currentAttendees: 0,
        isPublished: false,
      );

      return await createEvent(duplicatedEvent);
    } catch (e) {
      print('Error duplicating event: $e');
      throw Exception('Failed to duplicate event: $e');
    }
  }

  /// Test Firebase connectivity
  Future<bool> testFirebaseConnection() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user for connectivity test');
        return false;
      }

      print('Testing Firebase connection...');
      
      // Try to read from Firestore with a simple query
      final testQuery = await _firestore
          .collection('events')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      
      print('Firebase connection test successful. Found ${testQuery.docs.length} documents');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
}
