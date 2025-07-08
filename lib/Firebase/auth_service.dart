import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Models/user_model.dart';
import '../Models/event_organizer_model.dart';
import '../Models/admin_model.dart';

class AuthResult {
  final bool success;
  final String message;
  final BaseUser? user;

  AuthResult({required this.success, required this.message, this.user});
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up regular user
  Future<AuthResult> signUpRegularUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    DateTime? dateOfBirth,
  }) async {
    try {
      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      RegularUser user = RegularUser(
        uid: credential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        createdAt: DateTime.now(),
        dateOfBirth: dateOfBirth,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap())
          .timeout(const Duration(seconds: 10));

      // Update display name
      await credential.user!.updateDisplayName(user.fullName);

      return AuthResult(
        success: true,
        message: 'User account created successfully!',
        user: user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Sign up event organizer
  Future<AuthResult> signUpEventOrganizer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String companyName,
    required String businessLicense,
    String? website,
    required int yearsOfExperience,
  }) async {
    try {
      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create organizer model
      EventOrganizer organizer = EventOrganizer(
        uid: credential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        createdAt: DateTime.now(),
        companyName: companyName,
        businessLicense: businessLicense,
        website: website,
        yearsOfExperience: yearsOfExperience,
      );

      // Save to Firestore
      await _firestore
          .collection('event_organizers')
          .doc(credential.user!.uid)
          .set(organizer.toMap())
          .timeout(const Duration(seconds: 10));

      // Update display name
      await credential.user!.updateDisplayName(organizer.fullName);

      return AuthResult(
        success: true,
        message: 'Event organizer account created successfully! Pending verification.',
        user: organizer,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Sign up admin
  Future<AuthResult> signUpAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin model
      AdminUser admin = AdminUser(
        uid: credential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('admins')
          .doc(credential.user!.uid)
          .set(admin.toMap())
          .timeout(const Duration(seconds: 10));

      // Update display name
      await credential.user!.updateDisplayName(admin.fullName);

      return AuthResult(
        success: true,
        message: 'Admin account created successfully! You can now login.',
        user: admin,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Sign in
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      BaseUser? user = await getUserData(credential.user!.uid);

      if (user == null) {
        await _auth.signOut();
        return AuthResult(
          success: false,
          message: 'User data not found. Please contact support.',
        );
      }

      // Check if user is active (skip for admin users)
      if (user.role != 'admin' && !user.isActive) {
        await _auth.signOut();
        return AuthResult(
          success: false,
          message: 'Account is inactive. Please contact support.',
        );
      }

      // Update last login for admin users (non-blocking)
      if (user is AdminUser) {
        try {
          await _firestore
              .collection('admins')
              .doc(user.uid)
              .update({'lastLoginAt': FieldValue.serverTimestamp()})
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          // debugPrint('Warning: Failed to update admin last login time: $e');
          // Don't fail the login process if this update fails
        }
      }

      return AuthResult(
        success: true,
        message: 'Signed in successfully!',
        user: user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Get user data from Firestore
  Future<BaseUser?> getUserData(String uid) async {
    try {
      debugPrint('Starting getUserData for UID: $uid');
      
      // Add timeout to prevent hanging
      const timeoutDuration = Duration(seconds: 10);
      
      // Check in users collection first
      debugPrint('Checking users collection...');
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(timeoutDuration);
      
      debugPrint('Users collection check completed. Exists: ${userDoc.exists}');
      if (userDoc.exists) {
        debugPrint('Found user in users collection');
        final userData = userDoc.data() as Map<String, dynamic>;
        debugPrint('User data: $userData');
        return RegularUser.fromMap(userData, uid);
      }

      // Check in event_organizers collection
      // debugPrint('Checking event_organizers collection...');
      DocumentSnapshot organizerDoc = await _firestore
          .collection('event_organizers')
          .doc(uid)
          .get()
          .timeout(timeoutDuration);
      
      debugPrint('Event organizers collection check completed. Exists: ${organizerDoc.exists}');
      if (organizerDoc.exists) {
        debugPrint('Found user in event_organizers collection');
        final organizerData = organizerDoc.data() as Map<String, dynamic>;
        debugPrint('Organizer data: $organizerData');
        return EventOrganizer.fromMap(organizerData, uid);
      }

      // Check in admins collection
      debugPrint('Checking admins collection...');
      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .get()
          .timeout(timeoutDuration);
      
      debugPrint('Admins collection check completed. Exists: ${adminDoc.exists}');
      if (adminDoc.exists) {
        debugPrint('Found user in admins collection');
        final adminData = adminDoc.data() as Map<String, dynamic>;
        debugPrint('Admin data: $adminData');
        return AdminUser.fromMap(adminData, uid);
      }

      debugPrint('User not found in any collection');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('Timeout error getting user data: $e');
      debugPrint('Firestore operation timed out after 10 seconds');
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      debugPrint('Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        message: 'Password reset email sent! Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'No user signed in',
        );
      }

      // Get user data to determine collection
      BaseUser? userData = await getUserData(user.uid);
      if (userData != null) {
        String collection = userData.role == 'user' 
            ? 'users' 
            : userData.role == 'organizer' 
              ? 'event_organizers' 
              : 'admins';
        
        // Delete user data from Firestore
        await _firestore
            .collection(collection)
            .doc(user.uid)
            .delete()
            .timeout(const Duration(seconds: 10));
      }

      // Delete auth user
      await user.delete();

      return AuthResult(
        success: true,
        message: 'Account deleted successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getAuthErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Get auth error message
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
