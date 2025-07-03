import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/auth_service.dart';
import '../Firebase/onboarding_service.dart';
import '../Models/onboarding_model.dart';
import '../Models/user_model.dart';

class OnboardingTestScreen extends StatefulWidget {
  const OnboardingTestScreen({super.key});

  @override
  State<OnboardingTestScreen> createState() => _OnboardingTestScreenState();
}

class _OnboardingTestScreenState extends State<OnboardingTestScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final OnboardingService _onboardingService = OnboardingService();
  
  BaseUser? _currentUser;
  OnboardingProfile? _onboardingProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _authService.getUserData(currentUser.uid);
        final onboardingData = await _onboardingService.getOnboardingProfile(currentUser.uid);
        
        setState(() {
          _currentUser = userData;
          _onboardingProfile = onboardingData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
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
      appBar: AppBar(
        title: const Text('Onboarding Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_currentUser != null) ...[
                      _buildInfoRow('Name', _currentUser!.fullName),
                      _buildInfoRow('Email', _currentUser!.email),
                      _buildInfoRow('Role', _currentUser!.role),
                      _buildInfoRow('Phone', _currentUser!.phone),
                      _buildInfoRow('Created At', _currentUser!.createdAt.toString()),
                      _buildInfoRow('Active', _currentUser!.isActive.toString()),
                    ] else
                      const Text('No user data available'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Onboarding Profile Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Onboarding Profile',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_onboardingProfile != null) ...[
                      _buildInfoRow('User ID', _onboardingProfile!.userId),
                      _buildInfoRow('User Role', _onboardingProfile!.userRole),
                      _buildInfoRow('Location', _onboardingProfile!.location ?? 'Not set'),
                      _buildInfoRow('Language', _onboardingProfile!.preferredLanguage ?? 'Not set'),
                      _buildInfoRow('Notifications', _onboardingProfile!.receiveNotifications.toString()),
                      _buildInfoRow('Share Location', _onboardingProfile!.shareLocation.toString()),
                      _buildInfoRow('Radius', '${_onboardingProfile!.radiusPreference.round()} km'),
                      _buildInfoRow('Completed At', _onboardingProfile!.completedAt.toString()),
                      
                      const SizedBox(height: 16),
                      Text(
                        'Interests',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_onboardingProfile!.interests.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: _onboardingProfile!.interests.map((interest) {
                            return Chip(
                              label: Text(interest),
                              backgroundColor: Colors.deepPurple.withOpacity(0.1),
                            );
                          }).toList(),
                        )
                      else
                        const Text('No interests selected'),

                      const SizedBox(height: 16),
                      Text(
                        'Role-Specific Data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _onboardingProfile!.roleSpecificData.toString(),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ] else
                      const Text('No onboarding data available'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Refresh Data'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go to Dashboard'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
