import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class AdminUser extends BaseUser {
  final DateTime? lastLoginAt;
  final bool onboardingCompleted;

  AdminUser({
    required super.uid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.createdAt,
    this.lastLoginAt,
    this.onboardingCompleted = false,
  }) : super(role: 'admin', isActive: true);

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  static AdminUser fromMap(Map<String, dynamic> map, String uid) {
    return AdminUser(
      uid: uid,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      onboardingCompleted: map['onboardingCompleted'] ?? false,
    );
  }

  AdminUser copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? onboardingCompleted,
  }) {
    return AdminUser(
      uid: uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
