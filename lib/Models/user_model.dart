import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_organizer_model.dart';
import 'admin_model.dart';

abstract class BaseUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final DateTime createdAt;
  final bool isActive;

  BaseUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap();
  
  static BaseUser fromMap(Map<String, dynamic> map, String uid) {
    String role = map['role'] ?? 'user';
    switch (role) {
      case 'organizer':
        return EventOrganizer.fromMap(map, uid);
      case 'admin':
        return AdminUser.fromMap(map, uid);
      default:
        return RegularUser.fromMap(map, uid);
    }
  }
}

class RegularUser extends BaseUser {
  final DateTime? dateOfBirth;
  final List<String> interests;
  final List<String> attendedEvents;
  final bool onboardingCompleted;

  RegularUser({
    required super.uid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.createdAt,
    super.isActive = true,
    this.dateOfBirth,
    this.interests = const [],
    this.attendedEvents = const [],
    this.onboardingCompleted = false,
  }) : super(role: 'user');

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
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'interests': interests,
      'attendedEvents': attendedEvents,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  static RegularUser fromMap(Map<String, dynamic> map, String uid) {
    return RegularUser(
      uid: uid,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      interests: List<String>.from(map['interests'] ?? []),
      attendedEvents: List<String>.from(map['attendedEvents'] ?? []),
      onboardingCompleted: map['onboardingCompleted'] ?? false,
    );
  }

  RegularUser copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
    DateTime? dateOfBirth,
    List<String>? interests,
    List<String>? attendedEvents,
    bool? onboardingCompleted,
  }) {
    return RegularUser(
      uid: uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      interests: interests ?? this.interests,
      attendedEvents: attendedEvents ?? this.attendedEvents,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
