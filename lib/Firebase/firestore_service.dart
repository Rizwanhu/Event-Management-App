import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/user_model.dart';
import '../Models/event_organizer_model.dart';
import '../Models/admin_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String organizersCollection = 'event_organizers';
  static const String adminsCollection = 'admins';
  static const String eventsCollection = 'events';

  // User CRUD operations
  Future<void> createUser(RegularUser user) async {
    await _firestore.collection(usersCollection).doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(RegularUser user) async {
    await _firestore.collection(usersCollection).doc(user.uid).update(user.toMap());
  }

  Future<RegularUser?> getUser(String uid) async {
    final doc = await _firestore.collection(usersCollection).doc(uid).get();
    if (doc.exists) {
      return RegularUser.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection(usersCollection).doc(uid).delete();
  }

  // Event Organizer CRUD operations
  Future<void> createOrganizer(EventOrganizer organizer) async {
    await _firestore.collection(organizersCollection).doc(organizer.uid).set(organizer.toMap());
  }

  Future<void> updateOrganizer(EventOrganizer organizer) async {
    await _firestore.collection(organizersCollection).doc(organizer.uid).update(organizer.toMap());
  }

  Future<EventOrganizer?> getOrganizer(String uid) async {
    final doc = await _firestore.collection(organizersCollection).doc(uid).get();
    if (doc.exists) {
      return EventOrganizer.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> deleteOrganizer(String uid) async {
    await _firestore.collection(organizersCollection).doc(uid).delete();
  }

  // Admin CRUD operations
  Future<void> createAdmin(AdminUser admin) async {
    await _firestore.collection(adminsCollection).doc(admin.uid).set(admin.toMap());
  }

  Future<void> updateAdmin(AdminUser admin) async {
    await _firestore.collection(adminsCollection).doc(admin.uid).update(admin.toMap());
  }

  Future<AdminUser?> getAdmin(String uid) async {
    final doc = await _firestore.collection(adminsCollection).doc(uid).get();
    if (doc.exists) {
      return AdminUser.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> deleteAdmin(String uid) async {
    await _firestore.collection(adminsCollection).doc(uid).delete();
  }

  // Get all users (for admin purposes)
  Future<List<RegularUser>> getAllUsers() async {
    final querySnapshot = await _firestore.collection(usersCollection).get();
    return querySnapshot.docs
        .map((doc) => RegularUser.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get all organizers (for admin purposes)
  Future<List<EventOrganizer>> getAllOrganizers() async {
    final querySnapshot = await _firestore.collection(organizersCollection).get();
    return querySnapshot.docs
        .map((doc) => EventOrganizer.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get all admins
  Future<List<AdminUser>> getAllAdmins() async {
    final querySnapshot = await _firestore.collection(adminsCollection).get();
    return querySnapshot.docs
        .map((doc) => AdminUser.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get pending organizers
  Future<List<EventOrganizer>> getPendingOrganizers() async {
    final querySnapshot = await _firestore
        .collection(organizersCollection)
        .where('isVerified', isEqualTo: false)
        .get();
    return querySnapshot.docs
        .map((doc) => EventOrganizer.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Note: getInactiveAdmins method removed since admins don't have isActive status anymore

  // Approve organizer
  Future<void> approveOrganizer(String organizerId) async {
    await _firestore.collection(organizersCollection).doc(organizerId).update({
      'isVerified': true,
      'isActive': true,
    });
  }

  // Note: approveAdmin method removed since admins don't need approval anymore

  // Reject organizer
  Future<void> rejectOrganizer(String organizerId) async {
    await _firestore.collection(organizersCollection).doc(organizerId).update({
      'isActive': false,
    });
  }

  // Reject admin
  Future<void> rejectAdmin(String adminId) async {
    await _firestore.collection(adminsCollection).doc(adminId).delete();
  }

  // Deactivate user
  Future<void> deactivateUser(String uid, String userType) async {
    String collection;
    switch (userType) {
      case 'user':
        collection = usersCollection;
        break;
      case 'organizer':
        collection = organizersCollection;
        break;
      case 'admin':
        collection = adminsCollection;
        break;
      default:
        throw ArgumentError('Invalid user type: $userType');
    }

    await _firestore.collection(collection).doc(uid).update({
      'isActive': false,
    });
  }

  // Reactivate user
  Future<void> reactivateUser(String uid, String userType) async {
    String collection;
    switch (userType) {
      case 'user':
        collection = usersCollection;
        break;
      case 'organizer':
        collection = organizersCollection;
        break;
      case 'admin':
        collection = adminsCollection;
        break;
      default:
        throw ArgumentError('Invalid user type: $userType');
    }

    await _firestore.collection(collection).doc(uid).update({
      'isActive': true,
    });
  }

  // Search users by name or email
  Future<List<BaseUser>> searchUsers(String query) async {
    List<BaseUser> allUsers = [];
    
    // Search in users collection
    final usersQuery = await _firestore
        .collection(usersCollection)
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    
    allUsers.addAll(usersQuery.docs
        .map((doc) => RegularUser.fromMap(doc.data(), doc.id)));

    // Search in organizers collection
    final organizersQuery = await _firestore
        .collection(organizersCollection)
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    
    allUsers.addAll(organizersQuery.docs
        .map((doc) => EventOrganizer.fromMap(doc.data(), doc.id)));

    // Search in admins collection
    final adminsQuery = await _firestore
        .collection(adminsCollection)
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    
    allUsers.addAll(adminsQuery.docs
        .map((doc) => AdminUser.fromMap(doc.data(), doc.id)));

    return allUsers;
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    final usersCount = await _firestore.collection(usersCollection).get();
    final organizersCount = await _firestore.collection(organizersCollection).get();
    final adminsCount = await _firestore.collection(adminsCollection).get();
    
    final activeUsersCount = await _firestore
        .collection(usersCollection)
        .where('isActive', isEqualTo: true)
        .get();
    
    final verifiedOrganizersCount = await _firestore
        .collection(organizersCollection)
        .where('isVerified', isEqualTo: true)
        .get();

    return {
      'totalUsers': usersCount.docs.length,
      'totalOrganizers': organizersCount.docs.length,
      'totalAdmins': adminsCount.docs.length,
      'activeUsers': activeUsersCount.docs.length,
      'verifiedOrganizers': verifiedOrganizersCount.docs.length,
    };
  }
}
