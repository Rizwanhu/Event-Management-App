import 'package:flutter/material.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedNavIndex = 0;

  // Mock data
  final List<Event> events = [
    Event(
      id: '1',
      title: 'Summer Music Festival 2024',
      date: DateTime(2024, 7, 15),
      status: EventStatus.live,
      ticketsSold: 245,
      totalTickets: 500,
      revenue: 18750.0,
      likes: 156,
      comments: 42,
      shares: 28,
      rating: 4.2,
      reviews: 87,
    ),
    Event(
      id: '2',
      title: 'Tech Conference 2024',
      date: DateTime(2024, 8, 20),
      status: EventStatus.approved,
      ticketsSold: 89,
      totalTickets: 200,
      revenue: 8900.0,
      likes: 78,
      comments: 15,
      shares: 12,
      rating: 0.0,
      reviews: 0,
    ),
    Event(
      id: '3',
      title: 'Food & Wine Festival',
      date: DateTime(2024, 6, 10),
      status: EventStatus.pending,
      ticketsSold: 0,
      totalTickets: 300,
      revenue: 0.0,
      likes: 23,
      comments: 5,
      shares: 3,
      rating: 0.0,
      reviews: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Organizer Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
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
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    int totalEvents = events.length;
    int totalTicketsSold = events.fold(0, (sum, event) => sum + event.ticketsSold);
    int upcomingEvents = events.where((e) => e.date.isAfter(DateTime.now())).length;
    double totalRevenue = events.fold(0.0, (sum, event) => sum + event.revenue);

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
                colors: [Colors.deepPurple.shade400, Colors.purple.shade500],
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
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your events and track performance',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
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
                        Icons.event_available,
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
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Tickets Sold',
                    '$totalTicketsSold',
                    Icons.confirmation_number,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Upcoming',
                    '$upcomingEvents',
                    Icons.schedule,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Revenue',
                    '\$${totalRevenue.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.purple,
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
              const Expanded(
                child: Text(
                  'Recent Events',
                  style: TextStyle(
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
          color: Colors.white,
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
                          borderSide: BorderSide(color: Colors.grey.shade300),
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
                        border: Border.all(color: Colors.grey.shade300),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revenue Overview',
                  style: TextStyle(
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
                    _buildChartLegend('This Month', Colors.deepPurple),
                    _buildChartLegend('Last Month', Colors.grey),
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
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            'Avg. Rating',
                            '4.2',
                            '+0.3',
                            Colors.amber,
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
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            'Engagement',
                            '8.7%',
                            '+1.2%',
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildMetricCard('Conversion Rate', '24.5%', '+2.1%', Colors.green),
                    const SizedBox(height: 12),
                    _buildMetricCard('Avg. Rating', '4.2', '+0.3', Colors.amber),
                    const SizedBox(height: 12),
                    _buildMetricCard('Total Views', '12.4K', '+15%', Colors.blue),
                    const SizedBox(height: 12),
                    _buildMetricCard('Engagement', '8.7%', '+1.2%', Colors.purple),
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
                colors: [Colors.amber.shade400, Colors.orange.shade500],
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
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Summer Music Festival 2024',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '245 tickets sold • 4.2★ rating • \$18,750 revenue',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
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
                    Colors.green,
                    () => _showBoostEventDialog(),
                  ),
                  _buildActionCard(
                    'View Analytics',
                    Icons.analytics,
                    Colors.blue,
                    () => _tabController.animateTo(2),
                  ),
                  _buildActionCard(
                    'Export Data',
                    Icons.download,
                    Colors.purple,
                    () {},
                  ),
                  _buildActionCard(
                    'Settings',
                    Icons.settings,
                    Colors.grey,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, {bool isCompact = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      '${event.date.day}/${event.date.month}/${event.date.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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
                          'Tickets Sold',
                          '${event.ticketsSold}/${event.totalTickets}',
                          event.ticketsSold / event.totalTickets,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEventStat(
                          'Revenue',
                          '\$${event.revenue.toStringAsFixed(0)}',
                          null,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildEventStat(
                        'Tickets Sold',
                        '${event.ticketsSold}/${event.totalTickets}',
                        event.ticketsSold / event.totalTickets,
                      ),
                      const SizedBox(height: 12),
                      _buildEventStat(
                        'Revenue',
                        '\$${event.revenue.toStringAsFixed(0)}',
                        null,
                      ),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // Social Stats - Wrap for mobile
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _buildSocialStat(Icons.favorite, event.likes.toString(), Colors.red),
                _buildSocialStat(Icons.comment, event.comments.toString(), Colors.blue),
                _buildSocialStat(Icons.share, event.shares.toString(), Colors.green),
                if (event.rating > 0)
                  _buildSocialStat(Icons.star, event.rating.toStringAsFixed(1), Colors.amber),
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
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
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
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: Colors.grey.shade600,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.deepPurple,
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
                          color: Colors.amber,
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
              color: Colors.grey.shade600,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Event'),
        content: const Text('Event creation form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventStat(String title, String value, double? progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
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
            backgroundColor: Colors.grey.shade200,
            color: Colors.deepPurple,
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
        color = Colors.orange;
        break;
      case EventStatus.approved:
        label = 'Approved';
        color = Colors.blue;
        break;
      case EventStatus.live:
        label = 'Live';
        color = Colors.green;
        break;
      default:
        label = 'Unknown';
        color = Colors.grey;
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

  // Navigation to Boost Event page or dialog
  void _navigateToBoostEvent() {
    Navigator.pop(context); // Close drawer if open
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BoostEventPage()),
    );
  }

  // Handle popup menu selection
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'boost':
        _navigateToBoostEvent();
        break;
      case 'analytics':
        _navigateToAnalytics();
        break;
      case 'management':
        _navigateToManagement();
        break;
      case 'report':
        _navigateToReport();
        break;
      case 'managers':
        _navigateToManagers();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
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
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Data models
class Event {
  final String id;
  final String title;
  final DateTime date;
  final EventStatus status;
  final int ticketsSold;
  final int totalTickets;
  final double revenue;
  final int likes;
  final int comments;
  final int shares;
  final double rating;
  final int reviews;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.ticketsSold,
    required this.totalTickets,
    required this.revenue,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.rating,
    required this.reviews,
  });
}

enum EventStatus { pending, approved, live }
