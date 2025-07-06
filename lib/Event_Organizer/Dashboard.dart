import 'package:flutter/material.dart';
import 'create_edit_event_screen.dart';
import 'organizer_settings_screen.dart';
import 'notifications_screen.dart';
import '../Firebase/event_management_service.dart';
import '../Firebase/notification_service.dart';
import '../Models/event_model.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedNavIndex = 0;
  final EventManagementService _eventService = EventManagementService();
  final NotificationService _notificationService = NotificationService();
  List<EventModel> events = [];
  Map<String, dynamic> _statistics = {};

  final ColorScheme _colorScheme = ColorScheme.light(
    primary: Colors.blue.shade700,
    primaryContainer: Colors.blue.shade200,
    secondary: Colors.blueAccent,
    secondaryContainer: Colors.blueAccent.shade100,
    surface: Colors.white,
    background: Colors.blue.shade50,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEvents();
    _loadStatistics();
  }

  Future<void> _loadEvents() async {
    try {
      // First check if user is authenticated
      if (!mounted) return;
      
      print('Starting to load events...');
      
      // Try to use the one-time fetch first as it's more reliable
      try {
        final eventList = await _eventService.getOrganizerEventsOnce();
        if (mounted) {
          print('Received ${eventList.length} events via one-time fetch');
          setState(() {
            events = eventList;
          });
        }
        
        // After successful one-time fetch, set up the stream for real-time updates
        _eventService.getOrganizerEvents()
          .timeout(const Duration(seconds: 10))
          .listen(
            (eventList) {
              if (mounted) {
                print('Stream update: ${eventList.length} events');
                setState(() {
                  events = eventList;
                });
              }
            },
            onError: (error) {
              print('Stream error (non-fatal): $error');
              // Don't show error for stream failures after initial load
            },
          );
      } catch (e) {
        print('One-time fetch failed, trying stream only: $e');
        
        // Fallback to stream only
        _eventService.getOrganizerEvents()
          .timeout(const Duration(seconds: 15))
          .listen(
            (eventList) {
              if (mounted) {
                print('Received ${eventList.length} events via stream');
                setState(() {
                  events = eventList;
                });
              }
            },
            onError: (error) {
              print('Error loading events: $error');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load events: $error')),
                );
              }
            },
          );
      }
    } catch (e) {
      print('Exception in _loadEvents: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _eventService.getEventStatistics();
      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Organizer Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: _colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
        actions: [
          StreamBuilder<int>(
            stream: _notificationService.getUnreadCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrganizerSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Tabs
          Container(
            color: _colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: _colorScheme.primary,
              unselectedLabelColor: _colorScheme.onSurface,
              indicatorColor: _colorScheme.primary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Events'),
                Tab(text: 'Analytics'),
                Tab(text: 'Insights'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildEventsTab(),
                _buildAnalyticsTab(),
                _buildInsightsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventDialog(),
        backgroundColor: _colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    int totalEvents = _statistics['totalEvents'] ?? events.length;
    int totalTicketsSold = _statistics['totalAttendees'] ?? 0;
    int upcomingEvents = events.where((e) => e.eventDate.isAfter(DateTime.now())).length;
    double totalRevenue = _statistics['totalRevenue'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colorScheme.primary, _colorScheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your events and track performance',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Grid - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              int crossAxisCount = screenWidth > 600 ? 4 : 2;
              double childAspectRatio = screenWidth > 600 ? 1.3 : 1.4;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildStatCard(
                    'Total Events',
                    '$totalEvents',
                    Icons.event,
                    _colorScheme.primary,
                  ),
                  _buildStatCard(
                    'Tickets Sold',
                    '$totalTicketsSold',
                    Icons.confirmation_number,
                    _colorScheme.secondary,
                  ),
                  _buildStatCard(
                    'Upcoming',
                    '$upcomingEvents',
                    Icons.schedule,
                    _colorScheme.surface,
                  ),
                  _buildStatCard(
                    'Revenue',
                    '\$${totalRevenue.toStringAsFixed(0)}',
                    Icons.attach_money,
                    _colorScheme.primary,
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Recent Events
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Events',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: const Text('View All'),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Recent Events List with proper constraints
          ...events.take(3).map((event) => _buildEventCard(event, isCompact: true)),
          
          // Add bottom padding to prevent overflow
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        // Filter Bar - Mobile responsive
        Container(
          padding: const EdgeInsets.all(16),
          color: _colorScheme.surface,
          child: Column(
            children: [
              // Search and Filter Row
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _colorScheme.onSurface.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: _colorScheme.onSurface.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.filter_list, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Events List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _buildEventCard(events[index]);
            },
          ),
        ),
      ],
    );
  }
  void _editEvent(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditEventScreen(event: event),
      ),
    ).then((result) {
      if (result != null) {
        // Refresh events list after edit
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
      }
    });
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Chart - Mobile responsive
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Overview',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Chart container with constraints
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: LineChartPainter(),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Legend - Mobile responsive
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  children: [
                    _buildChartLegend('This Month', _colorScheme.primary),
                    _buildChartLegend('Last Month', _colorScheme.onSurface),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Performance Metrics - Responsive Grid
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Conversion Rate',
                            '24.5%',
                            '+2.1%',
                            _colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            'Avg. Rating',
                            '4.2',
                            '+0.3',
                            _colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Total Views',
                            '12.4K',
                            '+15%',
                            _colorScheme.surface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            'Engagement',
                            '8.7%',
                            '+1.2%',
                            _colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildMetricCard('Conversion Rate', '24.5%', '+2.1%', _colorScheme.primary),
                    const SizedBox(height: 12),
                    _buildMetricCard('Avg. Rating', '4.2', '+0.3', _colorScheme.secondary),
                    const SizedBox(height: 12),
                    _buildMetricCard('Total Views', '12.4K', '+15%', _colorScheme.surface),
                    const SizedBox(height: 12),
                    _buildMetricCard('Engagement', '8.7%', '+1.2%', _colorScheme.primary),
                  ],
                );
              }
            },
          ),
          
          // Add bottom padding
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Performing Event
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colorScheme.primary, _colorScheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Top Performing Event',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Event details
                const Text(
                  'Summer Music Festival 2024',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '245 tickets sold • 4.2★ rating • \$18,750 revenue',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Recent Reviews
          const Text(
            'Recent Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Reviews with proper constraints
          ...List.generate(3, (index) => _buildReviewCard(index)),
          
          const SizedBox(height: 20),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Quick Actions Grid - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              int crossAxisCount = screenWidth > 600 ? 4 : 2;
              double childAspectRatio = screenWidth > 600 ? 1.6 : 1.8;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildActionCard(
                    'Boost Event',
                    Icons.trending_up,
                    _colorScheme.primary,
                    () => _showBoostEventDialog(),
                  ),
                  _buildActionCard(
                    'View Analytics',
                    Icons.analytics,
                    _colorScheme.primary,
                    () => _tabController.animateTo(2),
                  ),
                  _buildActionCard(
                    'Export Data',
                    Icons.download,
                    _colorScheme.primary,
                    () {},
                  ),
                  _buildActionCard(
                    'Settings',
                    Icons.settings,
                    _colorScheme.onSurface,
                    () {},
                  ),
                ],
              );
            },
          ),
          
          // Add bottom padding to prevent FAB overlap
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.trending_up, color: color, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: _colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event, {bool isCompact = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Event image thumbnail
              if (event.imageUrls.isNotEmpty)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _colorScheme.onSurface.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event.imageUrls.first,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: _colorScheme.surface,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(event.status),
            ],
          ),
          
          if (!isCompact) ...[
            const SizedBox(height: 12),
            
            // Event Stats - Mobile responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 300) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildEventStat(
                          'Attendees',
                          '${event.currentAttendees}/${event.maxAttendees ?? 'Unlimited'}',
                          event.maxAttendees != null ? event.currentAttendees / event.maxAttendees! : 0.0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEventStat(
                          'Revenue',
                          '\$${_calculateRevenue(event).toStringAsFixed(0)}',
                          null,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildEventStat(
                        'Attendees',
                        '${event.currentAttendees}/${event.maxAttendees ?? 'Unlimited'}',
                        event.maxAttendees != null ? event.currentAttendees / event.maxAttendees! : 0.0,
                      ),
                      const SizedBox(height: 12),
                      _buildEventStat(
                        'Revenue',
                        '\$${_calculateRevenue(event).toStringAsFixed(0)}',
                        null,
                      ),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // Event Info - Wrap for mobile
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _buildSocialStat(Icons.people, event.currentAttendees.toString(), _colorScheme.primary),
                _buildSocialStat(Icons.category, event.category, _colorScheme.secondary),
                _buildSocialStat(Icons.schedule, _formatEventTime(event), _colorScheme.surface),
                _buildSocialStat(Icons.location_on, event.location.split(',').first, _colorScheme.primary),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons - Responsive
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 300) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showBoostEventDialog(),
                          icon: const Icon(Icons.trending_up, size: 16),
                          label: const Text('Boost', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _colorScheme.primary,
                            side: BorderSide(color: _colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _editEvent(event),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showBoostEventDialog(),
                          icon: const Icon(Icons.trending_up, size: 16),
                          label: const Text('Boost'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _colorScheme.primary,
                            side: BorderSide(color: _colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _editEvent(event),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: _colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildReviewCard(int index) {
    final reviews = [
      {
        'name': 'Sarah Johnson',
        'rating': 5,
        'comment': 'Amazing event! Great organization and fantastic music.',
        'event': 'Summer Music Festival 2024',
      },
      {
        'name': 'Mike Chen',
        'rating': 4,
        'comment': 'Good event overall, would recommend to others.',
        'event': 'Tech Conference 2024',
      },
      {
        'name': 'Emma Davis',
        'rating': 5,
        'comment': 'Perfect venue and excellent sound quality.',
        'event': 'Summer Music Festival 2024',
      },
    ];

    final review = reviews[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorScheme.onSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _colorScheme.primary,
                child: Text(
                  review['name'].toString()[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        final int rating = review['rating'] as int;
                        return Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: _colorScheme.primary,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'].toString(),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            review['event'].toString(),
            style: TextStyle(
              fontSize: 12,
              color: _colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showCreateEventDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEditEventScreen(),
      ),
    ).then((result) {
      if (result != null) {
        // Refresh events list after creation
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
      }
    });
  }
  // void _showCreateEventDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Create New Event'),
  //       content: const Text('Event creation form will be implemented here.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Create'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEventStat(String title, String value, double? progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: _colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: _colorScheme.onSurface.withOpacity(0.2),
            color: _colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildSocialStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showBoostEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Boost Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select boost package:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Basic Boost'),
              subtitle: const Text('\$10 - 3 days featured'),
              leading: Radio(value: 1, groupValue: 1, onChanged: (v) {}),
            ),
            ListTile(
              title: const Text('Premium Boost'),
              subtitle: const Text('\$25 - 7 days featured + priority'),
              leading: Radio(value: 2, groupValue: 1, onChanged: (v) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event boosted successfully!')),
              );
            },
            child: const Text('Boost Now'),
          ),
        ],
      ),
    );
  }

  // Widget to display event status as a badge
  Widget _buildStatusBadge(EventStatus status) {
    String label;
    Color color;
    switch (status) {
      case EventStatus.pending:
        label = 'Pending';
        color = _colorScheme.surface;
        break;
      case EventStatus.approved:
        label = 'Approved';
        color = _colorScheme.primary;
        break;
      case EventStatus.live:
        label = 'Live';
        color = _colorScheme.primary;
        break;
      default:
        label = 'Unknown';
        color = _colorScheme.onSurface;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper methods for EventModel
  double _calculateRevenue(EventModel event) {
    if (event.ticketType == TicketType.paid && event.ticketPrice != null) {
      return event.currentAttendees * event.ticketPrice!;
    }
    return 0.0;
  }

  String _formatEventTime(EventModel event) {
    if (event.eventTime != null) {
      final hour = event.eventTime!.hour;
      final minute = event.eventTime!.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$formattedHour:${minute.toString().padLeft(2, '0')} $period';
    }
    return 'All Day';
  }
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Mock data points for revenue chart
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
