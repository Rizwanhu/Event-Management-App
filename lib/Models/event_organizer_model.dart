import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class EventOrganizer extends BaseUser {
  final String companyName;
  final String businessLicense;
  final String? website;
  final int yearsOfExperience;
  final List<String> createdEvents;
  final bool isVerified;
  final double rating;
  final int totalEventsOrganized;
  final bool onboardingCompleted;

  EventOrganizer({
    required super.uid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.createdAt,
    super.isActive = true,
    required this.companyName,
    required this.businessLicense,
    this.website,
    required this.yearsOfExperience,
    this.createdEvents = const [],
    this.isVerified = false,
    this.rating = 0.0,
    this.totalEventsOrganized = 0,
    this.onboardingCompleted = false,
  }) : super(role: 'organizer');

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'companyName': companyName,
      'businessLicense': businessLicense,
      'website': website,
      'yearsOfExperience': yearsOfExperience,
      'createdEvents': createdEvents,
      'isVerified': isVerified,
      'rating': rating,
      'totalEventsOrganized': totalEventsOrganized,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  static EventOrganizer fromMap(Map<String, dynamic> map, String uid) {
    return EventOrganizer(
      uid: uid,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      companyName: map['companyName'] ?? '',
      businessLicense: map['businessLicense'] ?? '',
      website: map['website'],
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      createdEvents: List<String>.from(map['createdEvents'] ?? []),
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalEventsOrganized: map['totalEventsOrganized'] ?? 0,
      onboardingCompleted: map['onboardingCompleted'] ?? false,
    );
  }

  EventOrganizer copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
    String? companyName,
    String? businessLicense,
    String? website,
    int? yearsOfExperience,
    List<String>? createdEvents,
    bool? isVerified,
    double? rating,
    int? totalEventsOrganized,
    bool? onboardingCompleted,
  }) {
    return EventOrganizer(
      uid: uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      companyName: companyName ?? this.companyName,
      businessLicense: businessLicense ?? this.businessLicense,
      website: website ?? this.website,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      createdEvents: createdEvents ?? this.createdEvents,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalEventsOrganized: totalEventsOrganized ?? this.totalEventsOrganized,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
