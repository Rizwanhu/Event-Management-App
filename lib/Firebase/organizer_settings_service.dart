import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../Models/organizer_model.dart';

class OrganizerSettingsService {
  static final OrganizerSettingsService _instance = OrganizerSettingsService._internal();
  factory OrganizerSettingsService() => _instance;
  OrganizerSettingsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _organizersCollection => _firestore.collection('organizers');

  /// Get current organizer profile
  Future<OrganizerModel?> getOrganizerProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        return null;
      }

      final doc = await _organizersCollection.doc(currentUser.uid).get();
      if (doc.exists) {
        return OrganizerModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      print('No organizer profile found for user: ${currentUser.uid}');
      return null;
    } catch (e) {
      print('Error getting organizer profile: $e');
      throw Exception('Failed to get organizer profile: $e');
    }
  }

  /// Update organizer profile
  Future<void> updateOrganizerProfile(OrganizerModel organizer) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _organizersCollection.doc(currentUser.uid).set(
        organizer.toMap(),
        SetOptions(merge: true),
      );
      
      print('Organizer profile updated successfully');
    } catch (e) {
      print('Error updating organizer profile: $e');
      throw Exception('Failed to update organizer profile: $e');
    }
  }

  /// Create new organizer profile
  Future<void> createOrganizerProfile(OrganizerModel organizer) async {
    try {
      await _organizersCollection.doc(organizer.uid).set(organizer.toMap());
      print('Organizer profile created successfully');
    } catch (e) {
      print('Error creating organizer profile: $e');
      throw Exception('Failed to create organizer profile: $e');
    }
  }

  /// Request verification
  Future<void> requestVerification() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update verification status to pending
      await _organizersCollection.doc(currentUser.uid).update({
        'verificationStatus': 'pending',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Create verification request document
      await _firestore.collection('verification_requests').add({
        'organizerId': currentUser.uid,
        'organizerEmail': currentUser.email,
        'requestedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'pending',
        'reviewedBy': null,
        'reviewedAt': null,
        'notes': '',
      });

      print('Verification request submitted successfully');
    } catch (e) {
      print('Error requesting verification: $e');
      throw Exception('Failed to request verification: $e');
    }
  }

  /// Get organizer statistics
  Future<Map<String, dynamic>> getOrganizerStatistics() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return _getDefaultStats();
      }

      // Get events count
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: currentUser.uid)
          .get();

      int totalEvents = eventsSnapshot.docs.length;
      int totalAttendees = 0;
      int liveEvents = 0;
      int completedEvents = 0;
      double totalRevenue = 0.0;

      for (var doc in eventsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        final attendees = data['currentAttendees'] as int? ?? 0;
        
        totalAttendees += attendees;
        
        if (status == 'live') liveEvents++;
        if (status == 'completed') completedEvents++;
        
        if (data['ticketType'] == 'paid') {
          final price = (data['ticketPrice'] as num?)?.toDouble() ?? 0.0;
          totalRevenue += attendees * price;
        }
      }

      // Update organizer profile with latest stats
      await _organizersCollection.doc(currentUser.uid).update({
        'totalEvents': totalEvents,
        'totalAttendees': totalAttendees,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return {
        'totalEvents': totalEvents,
        'totalAttendees': totalAttendees,
        'liveEvents': liveEvents,
        'completedEvents': completedEvents,
        'totalRevenue': totalRevenue,
        'averageAttendees': totalEvents > 0 ? (totalAttendees / totalEvents).round() : 0,
      };
    } catch (e) {
      print('Error getting organizer statistics: $e');
      return _getDefaultStats();
    }
  }

  Map<String, dynamic> _getDefaultStats() {
    return {
      'totalEvents': 0,
      'totalAttendees': 0,
      'liveEvents': 0,
      'completedEvents': 0,
      'totalRevenue': 0.0,
      'averageAttendees': 0,
    };
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences({
    required bool emailNotifications,
    required bool smsNotifications,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _organizersCollection.doc(currentUser.uid).update({
        'emailNotifications': emailNotifications,
        'smsNotifications': smsNotifications,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('Notification preferences updated successfully');
    } catch (e) {
      print('Error updating notification preferences: $e');
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  /// Update privacy settings
  Future<void> updatePrivacySettings({
    required bool publicProfile,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _organizersCollection.doc(currentUser.uid).update({
        'publicProfile': publicProfile,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('Privacy settings updated successfully');
    } catch (e) {
      print('Error updating privacy settings: $e');
      throw Exception('Failed to update privacy settings: $e');
    }
  }

  /// Delete organizer account and all related data
  Future<void> deleteAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();

      // Delete all events created by this organizer
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: currentUser.uid)
          .get();

      for (var doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete verification requests
      final verificationSnapshot = await _firestore
          .collection('verification_requests')
          .where('organizerId', isEqualTo: currentUser.uid)
          .get();

      for (var doc in verificationSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete organizer profile
      batch.delete(_organizersCollection.doc(currentUser.uid));

      // Execute batch delete
      await batch.commit();

      print('Account and all related data deleted successfully');
    } catch (e) {
      print('Error deleting account: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Check if user is a verified organizer
  Future<bool> isVerifiedOrganizer() async {
    try {
      final organizer = await getOrganizerProfile();
      return organizer?.isVerified ?? false;
    } catch (e) {
      print('Error checking verification status: $e');
      return false;
    }
  }

  /// Get public organizer profile (for attendees to view)
  Future<OrganizerModel?> getPublicOrganizerProfile(String organizerId) async {
    try {
      final doc = await _organizersCollection.doc(organizerId).get();
      if (doc.exists) {
        final organizer = OrganizerModel.fromMap(doc.data() as Map<String, dynamic>);
        // Only return if profile is public
        if (organizer.publicProfile) {
          return organizer;
        }
      }
      return null;
    } catch (e) {
      print('Error getting public organizer profile: $e');
      return null;
    }
  }

  /// Search verified organizers
  Future<List<OrganizerModel>> searchVerifiedOrganizers(String query) async {
    try {
      // Note: This is a simple implementation. For better search,
      // consider using Algolia or similar search service
      final snapshot = await _organizersCollection
          .where('verificationStatus', isEqualTo: 'verified')
          .where('publicProfile', isEqualTo: true)
          .limit(20)
          .get();

      final organizers = snapshot.docs
          .map((doc) => OrganizerModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((organizer) =>
              organizer.displayName.toLowerCase().contains(query.toLowerCase()) ||
              organizer.companyName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return organizers;
    } catch (e) {
      print('Error searching organizers: $e');
      return [];
    }
  }

  /// Get top organizers by rating or event count
  Future<List<OrganizerModel>> getTopOrganizers({int limit = 10}) async {
    try {
      final snapshot = await _organizersCollection
          .where('verificationStatus', isEqualTo: 'verified')
          .where('publicProfile', isEqualTo: true)
          .orderBy('totalEvents', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => OrganizerModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting top organizers: $e');
      return [];
    }
  }
}
