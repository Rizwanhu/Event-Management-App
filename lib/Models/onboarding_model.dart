import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingProfile {
  final String userId;
  final String userRole;
  final List<String> interests;
  final String? location;
  final String? preferredLanguage;
  final bool receiveNotifications;
  final bool shareLocation;
  final double radiusPreference;
  final DateTime completedAt;
  final Map<String, dynamic> roleSpecificData;

  OnboardingProfile({
    required this.userId,
    required this.userRole,
    required this.interests,
    this.location,
    this.preferredLanguage,
    this.receiveNotifications = true,
    this.shareLocation = false,
    this.radiusPreference = 50.0,
    required this.completedAt,
    this.roleSpecificData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userRole': userRole,
      'interests': interests,
      'location': location,
      'preferredLanguage': preferredLanguage,
      'receiveNotifications': receiveNotifications,
      'shareLocation': shareLocation,
      'radiusPreference': radiusPreference,
      'completedAt': Timestamp.fromDate(completedAt),
      'roleSpecificData': roleSpecificData,
    };
  }

  static OnboardingProfile fromMap(Map<String, dynamic> map) {
    return OnboardingProfile(
      userId: map['userId'] ?? '',
      userRole: map['userRole'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      location: map['location'],
      preferredLanguage: map['preferredLanguage'],
      receiveNotifications: map['receiveNotifications'] ?? true,
      shareLocation: map['shareLocation'] ?? false,
      radiusPreference: (map['radiusPreference'] ?? 50.0).toDouble(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      roleSpecificData: Map<String, dynamic>.from(map['roleSpecificData'] ?? {}),
    );
  }

  OnboardingProfile copyWith({
    String? userId,
    String? userRole,
    List<String>? interests,
    String? location,
    String? preferredLanguage,
    bool? receiveNotifications,
    bool? shareLocation,
    double? radiusPreference,
    DateTime? completedAt,
    Map<String, dynamic>? roleSpecificData,
  }) {
    return OnboardingProfile(
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      shareLocation: shareLocation ?? this.shareLocation,
      radiusPreference: radiusPreference ?? this.radiusPreference,
      completedAt: completedAt ?? this.completedAt,
      roleSpecificData: roleSpecificData ?? this.roleSpecificData,
    );
  }
}

class UserOnboardingData {
  final List<String> eventPreferences;
  final String? ageGroup;
  final String? occupation;
  final List<String> socialMediaLinks;

  UserOnboardingData({
    this.eventPreferences = const [],
    this.ageGroup,
    this.occupation,
    this.socialMediaLinks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'eventPreferences': eventPreferences,
      'ageGroup': ageGroup,
      'occupation': occupation,
      'socialMediaLinks': socialMediaLinks,
    };
  }

  static UserOnboardingData fromMap(Map<String, dynamic> map) {
    return UserOnboardingData(
      eventPreferences: List<String>.from(map['eventPreferences'] ?? []),
      ageGroup: map['ageGroup'],
      occupation: map['occupation'],
      socialMediaLinks: List<String>.from(map['socialMediaLinks'] ?? []),
    );
  }
}

class OrganizerOnboardingData {
  final String? businessDescription;
  final List<String> eventTypes;
  final String? targetAudience;
  final String? experienceLevel;
  final List<String> specializations;
  final String? portfolioUrl;
  final List<String> socialMediaLinks;

  OrganizerOnboardingData({
    this.businessDescription,
    this.eventTypes = const [],
    this.targetAudience,
    this.experienceLevel,
    this.specializations = const [],
    this.portfolioUrl,
    this.socialMediaLinks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'businessDescription': businessDescription,
      'eventTypes': eventTypes,
      'targetAudience': targetAudience,
      'experienceLevel': experienceLevel,
      'specializations': specializations,
      'portfolioUrl': portfolioUrl,
      'socialMediaLinks': socialMediaLinks,
    };
  }

  static OrganizerOnboardingData fromMap(Map<String, dynamic> map) {
    return OrganizerOnboardingData(
      businessDescription: map['businessDescription'],
      eventTypes: List<String>.from(map['eventTypes'] ?? []),
      targetAudience: map['targetAudience'],
      experienceLevel: map['experienceLevel'],
      specializations: List<String>.from(map['specializations'] ?? []),
      portfolioUrl: map['portfolioUrl'],
      socialMediaLinks: List<String>.from(map['socialMediaLinks'] ?? []),
    );
  }
}

class AdminOnboardingData {
  final List<String> adminPreferences;
  final String? primaryResponsibility;
  final List<String> managementAreas;
  final String? workSchedule;

  AdminOnboardingData({
    this.adminPreferences = const [],
    this.primaryResponsibility,
    this.managementAreas = const [],
    this.workSchedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'adminPreferences': adminPreferences,
      'primaryResponsibility': primaryResponsibility,
      'managementAreas': managementAreas,
      'workSchedule': workSchedule,
    };
  }

  static AdminOnboardingData fromMap(Map<String, dynamic> map) {
    return AdminOnboardingData(
      adminPreferences: List<String>.from(map['adminPreferences'] ?? []),
      primaryResponsibility: map['primaryResponsibility'],
      managementAreas: List<String>.from(map['managementAreas'] ?? []),
      workSchedule: map['workSchedule'],
    );
  }
}
