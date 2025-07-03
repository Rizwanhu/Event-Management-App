import 'package:flutter/material.dart';
import '../Firebase/onboarding_service.dart';
import '../Models/admin_model.dart';
import '../Models/onboarding_model.dart';
import '../Admin/dashboard_screen.dart';

class AdminOnboardingForm extends StatefulWidget {
  final AdminUser admin;

  const AdminOnboardingForm({super.key, required this.admin});

  @override
  State<AdminOnboardingForm> createState() => _AdminOnboardingFormState();
}

class _AdminOnboardingFormState extends State<AdminOnboardingForm> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  
  int _currentPage = 0;
  bool _isLoading = false;

  // Form data
  final List<String> _selectedInterests = [];
  String? _selectedLocation;
  String? _preferredLanguage;
  bool _receiveNotifications = true;
  bool _shareLocation = false;
  double _radiusPreference = 50.0;
  
  // Admin-specific data
  final List<String> _adminPreferences = [];
  final List<String> _managementAreas = [];
  String? _primaryResponsibility;
  String? _workSchedule;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Create admin-specific onboarding data
      final adminOnboardingData = AdminOnboardingData(
        adminPreferences: _adminPreferences,
        primaryResponsibility: _primaryResponsibility,
        managementAreas: _managementAreas,
        workSchedule: _workSchedule,
      );

      // Create main onboarding profile
      final onboardingProfile = OnboardingProfile(
        userId: widget.admin.uid,
        userRole: 'admin',
        interests: _selectedInterests,
        location: _selectedLocation,
        preferredLanguage: _preferredLanguage,
        receiveNotifications: _receiveNotifications,
        shareLocation: _shareLocation,
        radiusPreference: _radiusPreference,
        completedAt: DateTime.now(),
        roleSpecificData: adminOnboardingData.toMap(),
      );

      // Save to database
      final success = await _onboardingService.saveOnboardingProfile(onboardingProfile);
      if (success) {
        await _onboardingService.updateUserProfileWithOnboardingData(
          userId: widget.admin.uid,
          userRole: 'admin',
          onboardingProfile: onboardingProfile,
        );

        await _onboardingService.updateAdminOnboarding(
          userId: widget.admin.uid,
          adminData: adminOnboardingData,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else {
        throw Exception('Failed to save onboarding data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing onboarding: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

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
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step ${_currentPage + 1} of 3',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (_currentPage + 1) / 3,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildAdminRolePage(),
                    _buildManagementAreasPage(),
                    _buildPreferencesPage(),
                  ],
                ),
              ),

              // Navigation Buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.red)
                            : Text(_currentPage == 2 ? 'Complete' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminRolePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Role Setup',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Set up your administrative preferences and responsibilities.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Primary Responsibility
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Primary Responsibility',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _primaryResponsibility,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'What is your main administrative focus?',
                  ),
                  items: [
                    'Platform Administration',
                    'User Management',
                    'Content Moderation',
                    'Event Oversight',
                    'Customer Support',
                    'Technical Support',
                    'Analytics & Reporting',
                    'Security & Compliance',
                    'Marketing & Growth',
                    'Operations Management',
                  ].map((responsibility) {
                    return DropdownMenuItem(
                      value: responsibility,
                      child: Text(responsibility),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _primaryResponsibility = value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Work Schedule
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Work Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _workSchedule,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'When are you typically available?',
                  ),
                  items: [
                    'Business Hours (9 AM - 5 PM)',
                    'Extended Hours (8 AM - 8 PM)',
                    'Evening Shift (2 PM - 10 PM)',
                    'Night Shift (10 PM - 6 AM)',
                    'Weekend Focus',
                    'Flexible Schedule',
                    '24/7 On-Call',
                  ].map((schedule) {
                    return DropdownMenuItem(
                      value: schedule,
                      child: Text(schedule),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _workSchedule = value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Admin Preferences
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    'Real-time Alerts',
                    'Daily Reports',
                    'Weekly Summaries',
                    'Emergency Notifications',
                    'Performance Metrics',
                    'User Feedback',
                    'System Alerts',
                    'Security Notifications',
                  ].map((preference) {
                    final isSelected = _adminPreferences.contains(preference);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _adminPreferences.remove(preference);
                          } else {
                            _adminPreferences.add(preference);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          preference,
                          style: TextStyle(
                            color: isSelected ? Colors.red : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementAreasPage() {
    final managementAreas = _onboardingService.getManagementAreas();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Management Areas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Which areas would you like to manage or monitor?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Management Areas Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.2,
            ),
            itemCount: managementAreas.length,
            itemBuilder: (context, index) {
              final area = managementAreas[index];
              final isSelected = _managementAreas.contains(area);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _managementAreas.remove(area);
                    } else {
                      _managementAreas.add(area);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getManagementIcon(area),
                        size: 30,
                        color: isSelected ? Colors.red : Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        area,
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    final cities = _onboardingService.getPopularCities();
    final languages = _onboardingService.getSupportedLanguages();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Customize your admin dashboard and notification preferences.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Location
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Primary Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Select your location',
                  ),
                  items: cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedLocation = value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Language
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferred Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _preferredLanguage,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Select your language',
                  ),
                  items: languages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _preferredLanguage = value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Notification Preferences
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Receive Critical Alerts',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Get notified about urgent platform issues',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _receiveNotifications,
                  onChanged: (value) => setState(() => _receiveNotifications = value),
                  activeColor: Colors.white,
                ),
                SwitchListTile(
                  title: const Text(
                    'Location-based Monitoring',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Monitor events and users in your region',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _shareLocation,
                  onChanged: (value) => setState(() => _shareLocation = value),
                  activeColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getManagementIcon(String area) {
    switch (area) {
      case 'User Management':
        return Icons.people;
      case 'Event Moderation':
        return Icons.event_note;
      case 'Content Management':
        return Icons.content_paste;
      case 'System Administration':
        return Icons.settings;
      case 'Customer Support':
        return Icons.support_agent;
      case 'Analytics & Reporting':
        return Icons.analytics;
      case 'Security & Compliance':
        return Icons.security;
      case 'Platform Development':
        return Icons.code;
      case 'Quality Assurance':
        return Icons.verified;
      case 'Marketing & Growth':
        return Icons.trending_up;
      case 'Finance & Operations':
        return Icons.account_balance;
      case 'Legal & Compliance':
        return Icons.gavel;
      default:
        return Icons.admin_panel_settings;
    }
  }
}
