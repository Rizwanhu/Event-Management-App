import 'package:flutter/material.dart';
import 'main.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // User preferences
  final List<String> _selectedInterests = [];
  String? _selectedLocation;
  String? _preferredLanguage;
  bool _receiveNotifications = true;
  bool _shareLocation = false;
  double _radiusPreference = 50.0; // km
  
  // Interest categories
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Music & Concerts', 'icon': Icons.music_note, 'color': Colors.purple},
    {'name': 'Sports & Fitness', 'icon': Icons.sports_soccer, 'color': Colors.green},
    {'name': 'Technology', 'icon': Icons.computer, 'color': Colors.blue},
    {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Art & Culture', 'icon': Icons.palette, 'color': Colors.pink},
    {'name': 'Business', 'icon': Icons.business_center, 'color': Colors.indigo},
    {'name': 'Health & Wellness', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.teal},
    {'name': 'Travel', 'icon': Icons.travel_explore, 'color': Colors.amber},
    {'name': 'Gaming', 'icon': Icons.games, 'color': Colors.deepPurple},
    {'name': 'Photography', 'icon': Icons.camera_alt, 'color': Colors.cyan},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pinkAccent},
  ];
  
  // Popular cities
  final List<String> _cities = [
    'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
    'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
    'Austin', 'Jacksonville', 'San Francisco', 'Columbus', 'Fort Worth'
  ];
  
  // Languages
  final List<String> _languages = [
    'English', 'Spanish', 'French', 'German', 'Italian',
    'Portuguese', 'Russian', 'Chinese', 'Japanese', 'Arabic'
  ];

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

  void _completeOnboarding() {
    // Save user preferences (in real app, save to database/shared preferences)
    final userProfile = {
      'interests': _selectedInterests,
      'location': _selectedLocation,
      'language': _preferredLanguage,
      'notifications': _receiveNotifications,
      'shareLocation': _shareLocation,
      'radius': _radiusPreference,
    };
    
    print('User Profile Saved: $userProfile');
    
    // Navigate to main app
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Event Management'),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.waving_hand,
              size: 60,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Welcome to Event Management!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'Let\'s personalize your experience by setting up your preferences. This will help us recommend events you\'ll love!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This will only take a few minutes and you can always change these settings later.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What interests you?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select at least 3 categories to get better recommendations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          // Fixed height grid without scroll
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _interests.length,
              itemBuilder: (context, index) {
                final interest = _interests[index];
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? interest['color'] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? interest['color'] : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: interest['color'].withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          interest['icon'],
                          size: 24,
                          color: isSelected ? Colors.white : interest['color'],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            interest['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Improved minimum selection indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _selectedInterests.length >= 3 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedInterests.length >= 3 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedInterests.length >= 3 ? Icons.check_circle : Icons.info_outline,
                  color: _selectedInterests.length >= 3 ? Colors.green : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedInterests.length}/3 minimum selected',
                  style: TextStyle(
                    color: _selectedInterests.length >= 3 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (_selectedInterests.length >= 3) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Ready!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Preferences',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us find events near you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Location Selection
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select your city',
                prefixIcon: Icon(Icons.location_city),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              value: _selectedLocation,
              items: _cities.map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              )).toList(),
              onChanged: (value) => setState(() => _selectedLocation = value),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Share Location Toggle
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share precise location',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        'Get more accurate event recommendations',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _shareLocation,
                  onChanged: (value) => setState(() => _shareLocation = value),
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Radius Preference
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search radius',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_radiusPreference.round()} km',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: _radiusPreference,
                  min: 5,
                  max: 100,
                  divisions: 19,
                  activeColor: Colors.deepPurple,
                  onChanged: (value) => setState(() => _radiusPreference = value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('5 km', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    Text('100 km', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Language Selection
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Preferred language',
                prefixIcon: Icon(Icons.language),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              value: _preferredLanguage,
              items: _languages.map((language) => DropdownMenuItem(
                value: language,
                child: Text(language),
              )).toList(),
              onChanged: (value) => setState(() => _preferredLanguage = value),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Notifications Toggle
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event notifications',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        'Get notified about new events and updates',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _receiveNotifications,
                  onChanged: (value) => setState(() => _receiveNotifications = value),
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Summary
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _selectedInterests.isNotEmpty 
                      ? Colors.white.withOpacity(0.2) 
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Selected: ${_selectedInterests.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: _selectedInterests.isNotEmpty 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  'Search Radius: ${_radiusPreference.round()}km',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Notifications: ${_receiveNotifications ? 'ON' : 'OFF'}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentPage ? Colors.white : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildWelcomePage(),
                    _buildInterestsPage(),
                    _buildLocationPage(),
                    _buildPreferencesPage(),
                  ],
                ),
              ),
              
              // Navigation Button
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_currentPage == 1 && _selectedInterests.length < 3) ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.white.withOpacity(0.3),
                    ),
                    child: Text(
                      _currentPage == 3 ? 'Get Started' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
