import 'package:flutter/material.dart';
import '../Firebase/onboarding_service.dart';
import '../Models/event_organizer_model.dart';
import '../Models/onboarding_model.dart';
import '../Event_Organizer/Dashboard.dart';

class OrganizerOnboardingForm extends StatefulWidget {
  final EventOrganizer organizer;

  const OrganizerOnboardingForm({super.key, required this.organizer});

  @override
  State<OrganizerOnboardingForm> createState() => _OrganizerOnboardingFormState();
}

class _OrganizerOnboardingFormState extends State<OrganizerOnboardingForm> {
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
  
  // Organizer-specific data
  final List<String> _eventTypes = [];
  final List<String> _specializations = [];
  String? _targetAudience;
  String? _experienceLevel;
  final List<String> _socialMediaLinks = [];

  // Controllers
  final TextEditingController _businessDescriptionController = TextEditingController();
  final TextEditingController _portfolioUrlController = TextEditingController();
  final TextEditingController _socialMediaController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _businessDescriptionController.dispose();
    _portfolioUrlController.dispose();
    _socialMediaController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Create organizer-specific onboarding data
      final organizerOnboardingData = OrganizerOnboardingData(
        businessDescription: _businessDescriptionController.text.trim().isNotEmpty 
            ? _businessDescriptionController.text.trim() 
            : null,
        eventTypes: _eventTypes,
        targetAudience: _targetAudience,
        experienceLevel: _experienceLevel,
        specializations: _specializations,
        portfolioUrl: _portfolioUrlController.text.trim().isNotEmpty 
            ? _portfolioUrlController.text.trim() 
            : null,
        socialMediaLinks: _socialMediaLinks,
      );

      // Create main onboarding profile
      final onboardingProfile = OnboardingProfile(
        userId: widget.organizer.uid,
        userRole: 'organizer',
        interests: _selectedInterests,
        location: _selectedLocation,
        preferredLanguage: _preferredLanguage,
        receiveNotifications: _receiveNotifications,
        shareLocation: _shareLocation,
        radiusPreference: _radiusPreference,
        completedAt: DateTime.now(),
        roleSpecificData: organizerOnboardingData.toMap(),
      );

      // Save to database
      final success = await _onboardingService.saveOnboardingProfile(onboardingProfile);
      if (success) {
        await _onboardingService.updateUserProfileWithOnboardingData(
          userId: widget.organizer.uid,
          userRole: 'organizer',
          onboardingProfile: onboardingProfile,
        );

        await _onboardingService.updateOrganizerOnboarding(
          userId: widget.organizer.uid,
          organizerData: organizerOnboardingData,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrganizerDashboard()),
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
    if (_currentPage < 3) {
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
            colors: [Colors.green, Colors.greenAccent],
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
                          'Step ${_currentPage + 1} of 4',
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
                      value: (_currentPage + 1) / 4,
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
                    _buildBusinessProfilePage(),
                    _buildEventTypesPage(),
                    _buildLocationPage(),
                    _buildMarketingPage(),
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
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.green)
                            : Text(_currentPage == 3 ? 'Complete' : 'Next'),
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

  Widget _buildBusinessProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tell us about your business and expertise.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Business Description
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
                  'Business Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _businessDescriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Describe your business, services, and what makes you unique...',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Experience Level
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
                  'Experience Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _experienceLevel,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Select your experience level',
                  ),
                  items: [
                    'Beginner (0-2 years)',
                    'Intermediate (2-5 years)',
                    'Experienced (5-10 years)',
                    'Expert (10+ years)',
                  ].map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _experienceLevel = value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Target Audience
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
                  'Target Audience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _targetAudience,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Who do you primarily organize events for?',
                  ),
                  items: [
                    'General Public',
                    'Corporate Clients',
                    'Young Adults (18-35)',
                    'Families',
                    'Professionals',
                    'Students',
                    'Seniors (55+)',
                    'Special Interest Groups',
                  ].map((audience) {
                    return DropdownMenuItem(
                      value: audience,
                      child: Text(audience),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _targetAudience = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypesPage() {
    final eventTypes = _onboardingService.getEventTypes();
    final specializations = _onboardingService.getSpecializations();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Expertise',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'What types of events do you specialize in?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Event Types
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
                  'Event Types',
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
                  children: eventTypes.map((type) {
                    final isSelected = _eventTypes.contains(type);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _eventTypes.remove(type);
                          } else {
                            _eventTypes.add(type);
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
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.green : Colors.white,
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
          
          const SizedBox(height: 20),
          
          // Specializations
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
                  'Specializations',
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
                  children: specializations.map((specialization) {
                    final isSelected = _specializations.contains(specialization);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _specializations.remove(specialization);
                          } else {
                            _specializations.add(specialization);
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
                          specialization,
                          style: TextStyle(
                            color: isSelected ? Colors.green : Colors.white,
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

  Widget _buildLocationPage() {
    final cities = _onboardingService.getPopularCities();
    final languages = _onboardingService.getSupportedLanguages();
    final interests = _onboardingService.getDefaultInterests();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location & Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Where do you primarily organize events?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Location Selection
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
                    hintText: 'Select your primary city',
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
          
          // Language Selection
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
          
          // Operating Radius
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operating Radius: ${_radiusPreference.round()} km',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'How far are you willing to travel for events?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _radiusPreference,
                  min: 10,
                  max: 200,
                  divisions: 19,
                  label: '${_radiusPreference.round()} km',
                  onChanged: (value) => setState(() => _radiusPreference = value),
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Marketing & Portfolio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Help attendees discover your events and build trust.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Portfolio URL
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
                  'Portfolio/Website URL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _portfolioUrlController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'https://yourwebsite.com',
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Social Media Links
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
                  'Social Media Links',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _socialMediaController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Social media profile URL',
                          prefixIcon: const Icon(Icons.share),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_socialMediaController.text.trim().isNotEmpty) {
                          setState(() {
                            _socialMediaLinks.add(_socialMediaController.text.trim());
                            _socialMediaController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (_socialMediaLinks.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 5,
                    children: _socialMediaLinks.map((link) {
                      return Chip(
                        label: Text(
                          link.length > 30 ? '${link.substring(0, 30)}...' : link,
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() => _socialMediaLinks.remove(link));
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Notifications Preferences
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
                    'Receive Notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Get notified about platform updates and opportunities',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _receiveNotifications,
                  onChanged: (value) => setState(() => _receiveNotifications = value),
                  activeColor: Colors.white,
                ),
                SwitchListTile(
                  title: const Text(
                    'Share Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Help users find your events based on location',
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
}
