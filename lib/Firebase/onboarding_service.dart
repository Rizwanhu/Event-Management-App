import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Models/onboarding_model.dart';

class OnboardingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save onboarding profile
  Future<bool> saveOnboardingProfile(OnboardingProfile profile) async {
    try {
      await _firestore
          .collection('onboarding_profiles')
          .doc(profile.userId)
          .set(profile.toMap());
      return true;
    } catch (e) {
      debugPrint('Error saving onboarding profile: $e');
      return false;
    }
  }

  // Get onboarding profile
  Future<OnboardingProfile?> getOnboardingProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('onboarding_profiles')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return OnboardingProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting onboarding profile: $e');
      return null;
    }
  }

  // Update user profile with onboarding data
  Future<bool> updateUserProfileWithOnboardingData({
    required String userId,
    required String userRole,
    required OnboardingProfile onboardingProfile,
  }) async {
    try {
      String collection;
      switch (userRole) {
        case 'user':
          collection = 'users';
          break;
        case 'organizer':
          collection = 'event_organizers';
          break;
        case 'admin':
          collection = 'admins';
          break;
        default:
          throw ArgumentError('Invalid user role: $userRole');
      }

      // Update user's main profile with onboarding data
      await _firestore.collection(collection).doc(userId).update({
        'interests': onboardingProfile.interests,
        'location': onboardingProfile.location,
        'preferredLanguage': onboardingProfile.preferredLanguage,
        'receiveNotifications': onboardingProfile.receiveNotifications,
        'shareLocation': onboardingProfile.shareLocation,
        'radiusPreference': onboardingProfile.radiusPreference,
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
        'roleSpecificOnboardingData': onboardingProfile.roleSpecificData,
      });

      return true;
    } catch (e) {
      debugPrint('Error updating user profile with onboarding data: $e');
      return false;
    }
  }

  // Update regular user with specific onboarding data
  Future<bool> updateRegularUserOnboarding({
    required String userId,
    required UserOnboardingData userData,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'eventPreferences': userData.eventPreferences,
        'ageGroup': userData.ageGroup,
        'occupation': userData.occupation,
        'socialMediaLinks': userData.socialMediaLinks,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating regular user onboarding: $e');
      return false;
    }
  }

  // Update organizer with specific onboarding data
  Future<bool> updateOrganizerOnboarding({
    required String userId,
    required OrganizerOnboardingData organizerData,
  }) async {
    try {
      await _firestore.collection('event_organizers').doc(userId).update({
        'businessDescription': organizerData.businessDescription,
        'eventTypes': organizerData.eventTypes,
        'targetAudience': organizerData.targetAudience,
        'experienceLevel': organizerData.experienceLevel,
        'specializations': organizerData.specializations,
        'portfolioUrl': organizerData.portfolioUrl,
        'socialMediaLinks': organizerData.socialMediaLinks,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating organizer onboarding: $e');
      return false;
    }
  }

  // Update admin with specific onboarding data
  Future<bool> updateAdminOnboarding({
    required String userId,
    required AdminOnboardingData adminData,
  }) async {
    try {
      await _firestore.collection('admins').doc(userId).update({
        'adminPreferences': adminData.adminPreferences,
        'primaryResponsibility': adminData.primaryResponsibility,
        'managementAreas': adminData.managementAreas,
        'workSchedule': adminData.workSchedule,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating admin onboarding: $e');
      return false;
    }
  }

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final profile = await getOnboardingProfile(userId);
      return profile != null;
    } catch (e) {
      debugPrint('Error checking onboarding completion: $e');
      return false;
    }
  }

  // Delete onboarding profile (if needed)
  Future<bool> deleteOnboardingProfile(String userId) async {
    try {
      await _firestore
          .collection('onboarding_profiles')
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting onboarding profile: $e');
      return false;
    }
  }

  // Get default interests based on role
  List<Map<String, dynamic>> getDefaultInterests() {
    return [
      {'name': 'Music & Concerts', 'icon': 'music_note', 'color': 'purple'},
      {'name': 'Sports & Fitness', 'icon': 'sports_soccer', 'color': 'green'},
      {'name': 'Technology', 'icon': 'computer', 'color': 'blue'},
      {'name': 'Food & Dining', 'icon': 'restaurant', 'color': 'orange'},
      {'name': 'Art & Culture', 'icon': 'palette', 'color': 'pink'},
      {'name': 'Business', 'icon': 'business_center', 'color': 'indigo'},
      {'name': 'Health & Wellness', 'icon': 'favorite', 'color': 'red'},
      {'name': 'Education', 'icon': 'school', 'color': 'teal'},
      {'name': 'Travel', 'icon': 'travel_explore', 'color': 'amber'},
      {'name': 'Gaming', 'icon': 'games', 'color': 'deepPurple'},
      {'name': 'Photography', 'icon': 'camera_alt', 'color': 'cyan'},
      {'name': 'Fashion', 'icon': 'checkroom', 'color': 'pinkAccent'},
    ];
  }

  // Get popular cities
  List<String> getPopularCities() {
    return [
      'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
      'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
      'Austin', 'Jacksonville', 'San Francisco', 'Columbus', 'Fort Worth',
      'Charlotte', 'Seattle', 'Denver', 'El Paso', 'Detroit',
      'Boston', 'Memphis', 'Portland', 'Oklahoma City', 'Las Vegas'
    ];
  }

  // Get supported languages
  List<String> getSupportedLanguages() {
    return [
      'English', 'Spanish', 'French', 'German', 'Italian',
      'Portuguese', 'Russian', 'Chinese', 'Japanese', 'Arabic',
      'Hindi', 'Korean', 'Dutch', 'Swedish', 'Norwegian'
    ];
  }

  // Get event types for organizers
  List<String> getEventTypes() {
    return [
      'Conferences', 'Workshops', 'Seminars', 'Concerts', 'Festivals',
      'Networking Events', 'Trade Shows', 'Webinars', 'Sports Events',
      'Cultural Events', 'Corporate Events', 'Social Events',
      'Educational Events', 'Charity Events', 'Product Launches'
    ];
  }

  // Get specializations for organizers
  List<String> getSpecializations() {
    return [
      'Event Planning', 'Venue Management', 'Catering', 'Entertainment',
      'Marketing & Promotion', 'Logistics', 'Technology Integration',
      'Budget Management', 'Vendor Coordination', 'Guest Relations',
      'Audio/Visual Production', 'Security Management'
    ];
  }

  // Get management areas for admins
  List<String> getManagementAreas() {
    return [
      'User Management', 'Event Moderation', 'Content Management',
      'System Administration', 'Customer Support', 'Analytics & Reporting',
      'Security & Compliance', 'Platform Development', 'Quality Assurance',
      'Marketing & Growth', 'Finance & Operations', 'Legal & Compliance'
    ];
  }
}
