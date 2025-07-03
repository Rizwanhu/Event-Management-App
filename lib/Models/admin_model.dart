import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class AdminUser extends BaseUser {
  final String employeeId;
  final String department;
  final String accessLevel;
  final List<String> permissions;
  final bool isSuperAdmin;
  final DateTime? lastLoginAt;
  final bool onboardingCompleted;

  AdminUser({
    required super.uid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.createdAt,
    super.isActive = true,
    required this.employeeId,
    required this.department,
    required this.accessLevel,
    this.permissions = const [],
    this.isSuperAdmin = false,
    this.lastLoginAt,
    this.onboardingCompleted = false,
  }) : super(role: 'admin');

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
      'employeeId': employeeId,
      'department': department,
      'accessLevel': accessLevel,
      'permissions': permissions,
      'isSuperAdmin': isSuperAdmin,
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
      isActive: map['isActive'] ?? true,
      employeeId: map['employeeId'] ?? '',
      department: map['department'] ?? '',
      accessLevel: map['accessLevel'] ?? '',
      permissions: List<String>.from(map['permissions'] ?? []),
      isSuperAdmin: map['isSuperAdmin'] ?? false,
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
    bool? isActive,
    String? employeeId,
    String? department,
    String? accessLevel,
    List<String>? permissions,
    bool? isSuperAdmin,
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
      isActive: isActive ?? this.isActive,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      accessLevel: accessLevel ?? this.accessLevel,
      permissions: permissions ?? this.permissions,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
