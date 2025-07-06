import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Login.dart';
import '../Firebase/user_data_service.dart';
import '../Models/user_model.dart';
import '../Onboarding/user_onboarding_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserDataService _userDataService = UserDataService();
  RegularUser? _currentUser;
  bool _isLoading = false; // Start with false since we'll show cached data first
  String? _error;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataImmediately();
  }

  void _loadUserDataImmediately() {
    // First, try to get cached data for immediate display
    final cachedData = _userDataService.getCachedUserData();
    if (cachedData != null) {
      setState(() {
        _currentUser = cachedData;
        _hasInitialized = true;
        _isLoading = false;
        _error = null;
      });
    } else {
      // No cached data, show loading
      setState(() {
        _isLoading = true;
        _hasInitialized = false;
        _error = null;
      });
    }

    // Then load fresh data
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _userDataService.getUserData();
        if (userData != null) {
          setState(() {
            _currentUser = userData;
            _isLoading = false;
            _error = null;
            _hasInitialized = true;
          });
        } else {
          setState(() {
            _error = 'Failed to load user data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'No user logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading user data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> get _userProfile {
    return _userDataService.getFormattedUserProfile();
  }

  List<Map<String, dynamic>> _getAchievements() {
    final achievements = <Map<String, dynamic>>[];
    
    if (_currentUser != null) {
      if (_currentUser!.attendedEvents.length >= 1) {
        achievements.add({
          'title': 'First Event',
          'description': 'Attended your first event',
          'icon': Icons.celebration
        });
      }
      if (_currentUser!.attendedEvents.length >= 5) {
        achievements.add({
          'title': 'Event Explorer',
          'description': 'Attended 5+ events',
          'icon': Icons.explore
        });
      }
      if (_currentUser!.interests.length >= 3) {
        achievements.add({
          'title': 'Diverse Interests',
          'description': 'Selected 3+ interests',
          'icon': Icons.star
        });
      }
    }
    
    return achievements;
  }

  List<Map<String, dynamic>> _getRecentActivity() {
    // TODO: Implement real activity tracking
    return [
      {'action': 'Joined', 'event': 'Event Management App', 'date': _formatDate(_currentUser?.createdAt ?? DateTime.now())},
    ];
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

  @override
  Widget build(BuildContext context) {
    // Show loading only if we have no data at all
    if (_isLoading && !_hasInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null && !_hasInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserDataImmediately,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.teal,
            automaticallyImplyLeading: false, // This removes the back button
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.teal, Colors.teal.shade300],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 47,
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            _currentUser?.firstName.isNotEmpty == true 
                                ? _currentUser!.firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userProfile['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _userProfile['role'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (_isLoading && _hasInitialized)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadUserDataImmediately,
              ),
            ],
          ),
          
          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  
                  // Bio Section
                  _buildBioSection(),
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  
                  // Interests
                  _buildInterestsSection(),
                  const SizedBox(height: 20),
                  
                  // Achievements
                  _buildAchievementsSection(context),
                  const SizedBox(height: 20),
                  
                  // Recent Activity
                  _buildRecentActivitySection(context),
                  const SizedBox(height: 30),
                  
                  // Edit Profile Button
                  _buildEditProfileButton(context),
                  const SizedBox(height: 15),
                  
                  // Logout Button
                  _buildLogoutButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = _userDataService.getUserStats();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Events\nAttended', stats['eventsAttended'].toString()),
          _buildVerticalDivider(),
          _buildStatItem('Events\nCreated', stats['eventsCreated'].toString()),
          _buildVerticalDivider(),
          _buildStatItem('Followers', stats['followers'].toString()),
          _buildVerticalDivider(),
          _buildStatItem('Following', stats['following'].toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.teal.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.teal.shade300,
    );
  }

  Widget _buildBioSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userProfile['bio'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.teal.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.teal.shade600),
              const SizedBox(width: 4),
              Text(_userProfile['location'], style: TextStyle(color: Colors.teal.shade600)),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: Colors.teal.shade600),
              const SizedBox(width: 4),
              Text('Joined ${_userProfile['joinDate']}', style: TextStyle(color: Colors.teal.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                'Edit Profile',
                Icons.edit,
                Colors.teal,
                () => _navigateToEditProfile(context),
              ),
              _buildActionButton(
                'My Events',
                Icons.event,
                Colors.teal.shade600,
                () => _navigateToMyEvents(context),
              ),
              _buildActionButton(
                'Bookmarks',
                Icons.bookmark,
                Colors.teal.shade700,
                () => _navigateToBookmarks(context),
              ),
              _buildActionButton(
                'Analytics',
                Icons.analytics,
                Colors.teal.shade800,
                () => _navigateToAnalytics(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    final interests = _userProfile['interests'] as List<String>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 12),
          if (interests.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.teal.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No interests selected yet. Edit your profile to add interests!',
                      style: TextStyle(color: Colors.teal.shade600),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToAchievements(context),
                child: Text(
                  'View All',
                  style: TextStyle(color: Colors.teal.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_getAchievements()).map((achievement) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(achievement['icon'], color: Colors.teal, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        Text(
                          achievement['description'],
                          style: TextStyle(
                            color: Colors.teal.shade600, 
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToActivity(context),
                child: Text(
                  'View All',
                  style: TextStyle(color: Colors.teal.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_getRecentActivity()).map((activity) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.teal,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activity['action']} ${activity['event']}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500, 
                            fontSize: 14,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        Text(
                          activity['date'],
                          style: TextStyle(
                            color: Colors.teal.shade600, 
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _navigateToEditProfile(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 8),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        onLongPress: () => _forceLogout(context), // Long press for immediate logout
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Column(
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 20),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'Long press for immediate logout',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceLogout(context);
              },
              child: const Text(
                'Force Logout',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Clear user data cache
      _userDataService.clearCache();

      // Sign out from Firebase with timeout
      await FirebaseAuth.instance.signOut().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Logout timed out');
        },
      );

      // Close loading dialog if still mounted
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login page and clear all previous routes
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open and mounted
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Force logout even if Firebase signout fails
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        
        // Show info message about forced logout
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out (session cleared)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _forceLogout(BuildContext context) {
    // Clear user data cache
    _userDataService.clearCache();
    
    // Force logout without waiting for Firebase Auth
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );

    // Show info message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forced logout - session cleared'),
        backgroundColor: Colors.orange,
      ),
    );

    // Try to sign out from Firebase in the background (don't wait for it)
    FirebaseAuth.instance.signOut().catchError((error) {
      // Ignore any errors since we've already logged out the user
      debugPrint('Background Firebase signout error: $error');
    });
  }

  // Navigation methods
  void _navigateToEditProfile(BuildContext context) {
    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserOnboardingForm(user: _currentUser!),
        ),
      ).then((_) {
        // Refresh user data when returning from onboarding
        _loadUserDataImmediately();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to edit profile. Please try refreshing.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToMyEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyEventsPage()),
    );
  }

  void _navigateToBookmarks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookmarksPage()),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsPage()),
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AchievementsPage()),
    );
  }

  void _navigateToActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActivityPage()),
    );
  }
}

// Placeholder pages for navigation
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page')),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile Page')),
    );
  }
}

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: const Center(child: Text('My Events Page')),
    );
  }
}

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: const Center(child: Text('Bookmarks Page')),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics Page')),
    );
  }
}

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: const Center(child: Text('Achievements Page')),
    );
  }
}

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: const Center(child: Text('Activity History Page')),
    );
  }
}
