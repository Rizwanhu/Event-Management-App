import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus {
  pending,
  verified,
  rejected,
}

class OrganizerModel {
  final String uid;
  final String email;
  final String displayName;
  final String companyName;
  final String bio;
  final String phone;
  final String website;
  final String location;
  final String profileImageUrl;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool publicProfile;
  final VerificationStatus verificationStatus;
  final String? verificationNotes;
  final int totalEvents;
  final int totalAttendees;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrganizerModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.companyName,
    required this.bio,
    required this.phone,
    required this.website,
    required this.location,
    required this.profileImageUrl,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.publicProfile,
    required this.verificationStatus,
    this.verificationNotes,
    this.totalEvents = 0,
    this.totalAttendees = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  OrganizerModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? companyName,
    String? bio,
    String? phone,
    String? website,
    String? location,
    String? profileImageUrl,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? publicProfile,
    VerificationStatus? verificationStatus,
    String? verificationNotes,
    int? totalEvents,
    int? totalAttendees,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrganizerModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      companyName: companyName ?? this.companyName,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      publicProfile: publicProfile ?? this.publicProfile,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      totalEvents: totalEvents ?? this.totalEvents,
      totalAttendees: totalAttendees ?? this.totalAttendees,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'companyName': companyName,
      'bio': bio,
      'phone': phone,
      'website': website,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'publicProfile': publicProfile,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'verificationNotes': verificationNotes,
      'totalEvents': totalEvents,
      'totalAttendees': totalAttendees,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory OrganizerModel.fromMap(Map<String, dynamic> map) {
    return OrganizerModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      companyName: map['companyName'] ?? '',
      bio: map['bio'] ?? '',
      phone: map['phone'] ?? '',
      website: map['website'] ?? '',
      location: map['location'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      publicProfile: map['publicProfile'] ?? true,
      verificationStatus: _parseVerificationStatus(map['verificationStatus']),
      verificationNotes: map['verificationNotes'],
      totalEvents: map['totalEvents'] ?? 0,
      totalAttendees: map['totalAttendees'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static VerificationStatus _parseVerificationStatus(dynamic status) {
    if (status == null) return VerificationStatus.pending;
    
    switch (status.toString().toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }

  @override
  String toString() {
    return 'OrganizerModel(uid: $uid, displayName: $displayName, email: $email, verificationStatus: $verificationStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OrganizerModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode ^ displayName.hashCode;
  }

  // Computed properties
  String get verificationStatusDisplay {
    switch (verificationStatus) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isVerified => verificationStatus == VerificationStatus.verified;
  
  String get initials {
    if (displayName.isEmpty) return 'EO';
    final parts = displayName.split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
