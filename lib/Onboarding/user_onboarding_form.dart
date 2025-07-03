import 'package:flutter/material.dart';
import '../Firebase/onboarding_service.dart';
import '../Models/user_model.dart';
import '../Models/onboarding_model.dart';
import '../User/search_screen.dart';

class UserOnboardingForm extends StatefulWidget {
  final RegularUser user;

  const UserOnboardingForm({super.key, required this.user});

  @override
  State<UserOnboardingForm> createState() => _UserOnboardingFormState();
}

class _UserOnboardingFormState extends State<UserOnboardingForm> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  
  int _currentPage = 0;
  bool _isLoading = false;

  // Form data
  final List<String> _selectedInterests = [];
  String? _selectedLocation;
  String? _preferredLanguage;
  String? _ageGroup;
  String? _occupation;
  bool _receiveNotifications = true;
  bool _shareLocation = false;
  double _radiusPreference = 50.0;
  final List<String> _eventPreferences = [];
  final List<String> _socialMediaLinks = [];

  // Controllers
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _socialMediaController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _occupationController.dispose();
    _socialMediaController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Create user-specific onboarding data
      final userOnboardingData = UserOnboardingData(
        eventPreferences: _eventPreferences,
        ageGroup: _ageGroup,
        occupation: _occupationController.text.trim().isNotEmpty 
            ? _occupationController.text.trim() 
            : null,
        socialMediaLinks: _socialMediaLinks,
      );

      // Create main onboarding profile
      final onboardingProfile = OnboardingProfile(
        userId: widget.user.uid,
        userRole: 'user',
        interests: _selectedInterests,
        location: _selectedLocation,
        preferredLanguage: _preferredLanguage,
        receiveNotifications: _receiveNotifications,
        shareLocation: _shareLocation,
        radiusPreference: _radiusPreference,
        completedAt: DateTime.now(),
        roleSpecificData: userOnboardingData.toMap(),
      );

      // Save to database
      final success = await _onboardingService.saveOnboardingProfile(onboardingProfile);
      if (success) {
        await _onboardingService.updateUserProfileWithOnboardingData(
          userId: widget.user.uid,
          userRole: 'user',
          onboardingProfile: onboardingProfile,
        );

        await _onboardingService.updateRegularUserOnboarding(
          userId: widget.user.uid,
          userData: userOnboardingData,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
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
            colors: [Colors.blue, Colors.blueAccent],
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
                    _buildInterestsPage(),
                    _buildLocationPage(),
                    _buildPreferencesPage(),
                    _buildPersonalInfoPage(),
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
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.blue)
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

  Widget _buildInterestsPage() {
    final interests = _onboardingService.getDefaultInterests();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What interests you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Select your interests to help us recommend events you\'ll love.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: interests.length,
            itemBuilder: (context, index) {
              final interest = interests[index];
              final isSelected = _selectedInterests.contains(interest['name']);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest['name']);
                    } else {
                      _selectedInterests.add(interest['name']);
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
                        _getIconData(interest['icon']),
                        size: 30,
                        color: isSelected ? Colors.blue : Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        interest['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.white,
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

  Widget _buildLocationPage() {
    final cities = _onboardingService.getPopularCities();
    final languages = _onboardingService.getSupportedLanguages();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location & Language',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Help us show you events in your area and preferred language.',
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
                  'Select your city',
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
                    hintText: 'Choose your city',
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
                  'Preferred language',
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
                    hintText: 'Choose your language',
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
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Customize your event discovery experience.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Event Preferences
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
                  'Event Types You Prefer',
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
                    'Free Events',
                    'Paid Events',
                    'Virtual Events',
                    'In-Person Events',
                    'Weekend Events',
                    'Evening Events',
                  ].map((preference) {
                    final isSelected = _eventPreferences.contains(preference);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _eventPreferences.remove(preference);
                          } else {
                            _eventPreferences.add(preference);
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
                            color: isSelected ? Colors.blue : Colors.white,
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
          
          // Notifications
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
                    'Get notified about new events and updates',
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
                    'Help us show nearby events',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _shareLocation,
                  onChanged: (value) => setState(() => _shareLocation = value),
                  activeColor: Colors.white,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Radius Preference
          if (_shareLocation)
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
                    'Search Radius: ${_radiusPreference.round()} km',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: _radiusPreference,
                    min: 5,
                    max: 100,
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

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tell us a bit more about yourself (optional).',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          
          // Age Group
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
                  'Age Group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _ageGroup,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Select your age group',
                  ),
                  items: [
                    '18-24',
                    '25-34',
                    '35-44',
                    '45-54',
                    '55-64',
                    '65+',
                  ].map((age) {
                    return DropdownMenuItem(
                      value: age,
                      child: Text(age),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _ageGroup = value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Occupation
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
                  'Occupation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _occupationController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'e.g., Software Engineer, Teacher, Student',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Social Media
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
                  'Social Media (Optional)',
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
                          hintText: 'Profile URL',
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
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (_socialMediaLinks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 5,
                    children: _socialMediaLinks.map((link) {
                      return Chip(
                        label: Text(link),
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
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'music_note':
        return Icons.music_note;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'computer':
        return Icons.computer;
      case 'restaurant':
        return Icons.restaurant;
      case 'palette':
        return Icons.palette;
      case 'business_center':
        return Icons.business_center;
      case 'favorite':
        return Icons.favorite;
      case 'school':
        return Icons.school;
      case 'travel_explore':
        return Icons.travel_explore;
      case 'games':
        return Icons.games;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'checkroom':
        return Icons.checkroom;
      default:
        return Icons.star;
    }
  }
}
