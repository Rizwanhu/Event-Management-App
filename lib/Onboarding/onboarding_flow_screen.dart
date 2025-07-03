import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/auth_service.dart';
import '../Firebase/onboarding_service.dart';
import '../Models/user_model.dart';
import '../Models/event_organizer_model.dart';
import '../Models/admin_model.dart';
import '../User/search_screen.dart';
import '../Event_Organizer/Dashboard.dart';
import '../Admin/dashboard_screen.dart';
import 'user_onboarding_form.dart';
import 'organizer_onboarding_form.dart';
import 'admin_onboarding_form.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final OnboardingService _onboardingService = OnboardingService();
  
  BaseUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _authService.getUserData(currentUser.uid);
        if (userData != null) {
          // Check if user has already completed onboarding
          final hasCompleted = await _onboardingService.hasCompletedOnboarding(currentUser.uid);
          if (hasCompleted) {
            _navigateToRoleDashboard(userData);
            return;
          }
          
          setState(() {
            _currentUser = userData;
            _isLoading = false;
          });
        } else {
          _navigateToLogin();
        }
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToRoleDashboard(BaseUser user) {
    Widget destination;
    
    if (user is RegularUser) {
      destination = const SearchScreen();
    } else if (user is EventOrganizer) {
      destination = const OrganizerDashboard();
    } else if (user is AdminUser) {
      destination = const AdminDashboardScreen();
    } else {
      destination = const SearchScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  void _navigateToRoleOnboarding() {
    if (_currentUser == null) return;

    Widget onboardingForm;
    
    if (_currentUser is RegularUser) {
      onboardingForm = UserOnboardingForm(user: _currentUser as RegularUser);
    } else if (_currentUser is EventOrganizer) {
      onboardingForm = OrganizerOnboardingForm(organizer: _currentUser as EventOrganizer);
    } else if (_currentUser is AdminUser) {
      onboardingForm = AdminOnboardingForm(admin: _currentUser as AdminUser);
    } else {
      onboardingForm = UserOnboardingForm(user: _currentUser as RegularUser);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => onboardingForm,
      ),
    ).then((completed) {
      if (completed == true) {
        _navigateToRoleDashboard(_currentUser!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Header
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getRoleIcon(),
                    size: 60,
                    color: Colors.deepPurple,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Text(
                  'Welcome, ${_currentUser?.firstName ?? 'User'}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 15),
                
                Text(
                  'Let\'s set up your ${_getRoleDisplayName()} profile',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Role-specific welcome message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getRoleIcon(),
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _getRoleWelcomeMessage(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Start Onboarding Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _navigateToRoleOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Skip for now button
                TextButton(
                  onPressed: () => _navigateToRoleDashboard(_currentUser!),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon() {
    if (_currentUser is RegularUser) {
      return Icons.person;
    } else if (_currentUser is EventOrganizer) {
      return Icons.event_available;
    } else if (_currentUser is AdminUser) {
      return Icons.admin_panel_settings;
    }
    return Icons.person;
  }

  String _getRoleDisplayName() {
    if (_currentUser is RegularUser) {
      return 'User';
    } else if (_currentUser is EventOrganizer) {
      return 'Event Organizer';
    } else if (_currentUser is AdminUser) {
      return 'Admin';
    }
    return 'User';
  }

  String _getRoleWelcomeMessage() {
    if (_currentUser is RegularUser) {
      return 'Discover amazing events, connect with like-minded people, and never miss out on experiences that matter to you. Let\'s personalize your event discovery journey!';
    } else if (_currentUser is EventOrganizer) {
      return 'Create unforgettable experiences and reach the right audience. We\'ll help you set up your organizer profile to showcase your expertise and attract attendees.';
    } else if (_currentUser is AdminUser) {
      return 'Manage the platform effectively and ensure a great experience for all users. Set up your admin preferences to streamline your management workflow.';
    }
    return 'Welcome to the Event Management platform! Let\'s get you started.';
  }
}
