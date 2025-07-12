
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/auth_service.dart';
import '../Models/user_model.dart';
import '../Models/event_organizer_model.dart';
import '../Models/admin_model.dart';
import '../Login.dart';
import '../User/search_screen.dart';
import '../Event_Organizer/Dashboard.dart';
import '../Admin/dashboard_screen.dart';
import '../Onboarding/onboarding_flow_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          debugPrint('AuthWrapper: User authenticated, UID: ${snapshot.data!.uid}');
          return FutureBuilder<BaseUser?>(
            future: FirebaseAuthService().getUserData(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              debugPrint('AuthWrapper: FutureBuilder state: ${userSnapshot.connectionState}');
              
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading user data...'),
                      ],
                    ),
                  ),
                );
              }

              if (userSnapshot.hasError) {
                debugPrint('AuthWrapper: Error loading user data: ${userSnapshot.error}');
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text('Error loading user data'),
                        const SizedBox(height: 8),
                        Text('${userSnapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (userSnapshot.hasData) {
                final user = userSnapshot.data!;
                debugPrint('AuthWrapper: User data loaded: ${user.runtimeType}');
                
                // Check if user is active (skip for admin users)
                if (user.role != 'admin' && !user.isActive) {
                  debugPrint('AuthWrapper: User is inactive');
                  return const _InactiveUserScreen();
                }

                // Navigate based on user type
                if (user is RegularUser) {
                  debugPrint('AuthWrapper: RegularUser detected');
                  if (user.onboardingCompleted) {
                    debugPrint('AuthWrapper: Onboarding completed, navigating to SearchScreen');
                    return const SearchScreen();
                  } else {
                    debugPrint('AuthWrapper: Onboarding not completed, navigating to OnboardingFlowScreen');
                    return const OnboardingFlowScreen();
                  }
                } else if (user is EventOrganizer) {
                  if (user.isVerified) {
                    if (user.onboardingCompleted) {
                      debugPrint('AuthWrapper: Navigating to OrganizerDashboard');
                      return const OrganizerDashboard();
                    } else {
                      debugPrint('AuthWrapper: Organizer onboarding not completed, navigating to OnboardingFlowScreen');
                      return const OnboardingFlowScreen();
                    }
                  } else {
                    debugPrint('AuthWrapper: Organizer not verified, showing pending screen');
                    return const _PendingVerificationScreen();
                  }
                } else if (user is AdminUser) {
                  if (user.onboardingCompleted) {
                    debugPrint('AuthWrapper: Navigating to AdminDashboardScreen');
                    return const AdminDashboardScreen();
                  } else {
                    debugPrint('AuthWrapper: Admin onboarding not completed, navigating to OnboardingFlowScreen');
                    return const OnboardingFlowScreen();
                  }
                }
              }

              // If no user data found, sign out and go to login
              debugPrint('AuthWrapper: No user data found, signing out');
              FirebaseAuth.instance.signOut();
              return const LoginPage();
            },
          );
        }

        // User not signed in
        return const LoginPage();
      },
    );
  }
}

class _InactiveUserScreen extends StatelessWidget {
  const _InactiveUserScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Inactive',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your account has been deactivated. Please contact support for assistance.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                  child: Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingVerificationScreen extends StatelessWidget {
  const _PendingVerificationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pending,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  'Verification Pending',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your organizer account is pending verification. You will be notified once approved.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                  ),
                  child: Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
