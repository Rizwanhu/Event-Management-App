import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../Models/user_model.dart';

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cache for user data
  RegularUser? _cachedUserData;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Stream controller for real-time updates
  Stream<RegularUser?>? _userDataStream;

  /// Get user data with caching and immediate return of cached data
  Future<RegularUser?> getUserData({bool forceRefresh = false}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    // Return cached data immediately if available and valid
    if (!forceRefresh && _cachedUserData != null && _isCacheValid()) {
      // Start background refresh if cache is getting old (but still valid)
      if (_getCacheAge().inMinutes > 2) {
        _refreshUserDataInBackground(currentUser.uid);
      }
      return _cachedUserData;
    }

    try {
      final userData = await _fetchUserFromFirestore(currentUser.uid);
      if (userData != null) {
        _updateCache(userData);
      }
      return userData;
    } catch (e) {
      // Return cached data if available, even if fetch fails
      if (_cachedUserData != null) {
        return _cachedUserData;
      }
      throw e;
    }
  }

  /// Get cached user data immediately (synchronous)
  RegularUser? getCachedUserData() {
    return _cachedUserData;
  }

  /// Check if we have valid cached data
  bool hasCachedData() {
    return _cachedUserData != null;
  }

  /// Get real-time stream of user data
  Stream<RegularUser?> getUserDataStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    _userDataStream ??= _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final userData = RegularUser.fromMap(snapshot.data()!, currentUser.uid);
        _updateCache(userData);
        return userData;
      }
      return null;
    }).handleError((error) {
      debugPrint('Error in user data stream: $error');
      return _cachedUserData;
    });

    return _userDataStream!;
  }

  /// Update user data in Firestore and cache
  Future<void> updateUserData(RegularUser userData) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No authenticated user');

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(userData.toMap(), SetOptions(merge: true));
      
      _updateCache(userData);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  /// Preload user data (call this early in app lifecycle)
  Future<void> preloadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && !hasCachedData()) {
      try {
        await getUserData();
      } catch (e) {
        debugPrint('Failed to preload user data: $e');
      }
    }
  }

  /// Clear cache (useful for logout)
  void clearCache() {
    _cachedUserData = null;
    _lastCacheUpdate = null;
    _userDataStream = null;
  }

  /// Private methods
  Future<RegularUser?> _fetchUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return RegularUser.fromMap(doc.data()!, uid);
    }
    return null;
  }

  void _updateCache(RegularUser userData) {
    _cachedUserData = userData;
    _lastCacheUpdate = DateTime.now();
  }

  bool _isCacheValid() {
    return _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  Duration _getCacheAge() {
    return _lastCacheUpdate != null 
        ? DateTime.now().difference(_lastCacheUpdate!)
        : Duration.zero;
  }

  void _refreshUserDataInBackground(String uid) {
    _fetchUserFromFirestore(uid).then((userData) {
      if (userData != null) {
        _updateCache(userData);
      }
    }).catchError((error) {
      debugPrint('Background refresh failed: $error');
    });
  }

  /// Get user stats for quick display
  Map<String, int> getUserStats() {
    if (_cachedUserData == null) {
      return {
        'eventsAttended': 0,
        'eventsCreated': 0,
        'followers': 0,
        'following': 0,
      };
    }

    return {
      'eventsAttended': _cachedUserData!.attendedEvents.length,
      'eventsCreated': 0, // Regular users don't create events
      'followers': 0, // TODO: Implement social features
      'following': 0, // TODO: Implement social features
    };
  }

  /// Get formatted user profile data
  Map<String, dynamic> getFormattedUserProfile() {
    if (_cachedUserData == null) {
      return {
        'name': 'User',
        'email': 'user@email.com',
        'phone': 'No phone provided',
        'location': 'Location not set',
        'joinDate': 'Recently',
        'role': 'Event Enthusiast',
        'bio': 'Welcome to the event management app!',
        'interests': <String>[],
      };
    }

    return {
      'name': _cachedUserData!.fullName,
      'email': _cachedUserData!.email,
      'phone': _cachedUserData!.phone,
      'location': 'Location not set', // TODO: Add location to user model
      'joinDate': _formatDate(_cachedUserData!.createdAt),
      'role': 'Event Enthusiast',
      'bio': 'Passionate about discovering new events!',
      'interests': _cachedUserData!.interests,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }
}
