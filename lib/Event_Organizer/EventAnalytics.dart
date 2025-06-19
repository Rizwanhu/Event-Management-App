import 'package:flutter/material.dart';

class EventAnalyticsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const EventAnalyticsScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  State<EventAnalyticsScreen> createState() => _EventAnalyticsScreenState();
}

class _EventAnalyticsScreenState extends State<EventAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;

  // Sample data - replace with actual API calls
  final Map<String, dynamic> analyticsData = {
    'ticketSales': {
      'totalSold': 245,
      'totalCapacity': 300,
      'revenue': 12250.00,
      'salesByType': {
        'Early Bird': {'sold': 100, 'price': 35.00},
        'Regular': {'sold': 120, 'price': 50.00},
        'VIP': {'sold': 25, 'price': 100.00},
      },
      'salesTrend': [15, 25, 40, 65, 85, 120, 160, 200, 230, 245],
    },
    'attendees': {
      'checked_in': 198,
      'no_show': 47,
      'ageGroups': {
        '18-25': 85,
        '26-35': 95,
        '36-45': 45,
        '46+': 20,
      },
      'genderDistribution': {
        'Male': 52,
        'Female': 45,
        'Other': 3,
      },
      'locations': {
        'Local': 70,
        'Regional': 25,
        'International': 5,
      }
    },
    'reviews': {
      'averageRating': 4.3,
      'totalReviews': 156,
      'ratingDistribution': {
        5: 78,
        4: 45,
        3: 22,
        2: 8,
        1: 3,
      },
      'recentReviews': [
        {
          'rating': 5,
          'comment': 'Amazing event! Well organized and great speakers.',
          'author': 'John D.',
          'date': '2024-01-15'
        },
        {
          'rating': 4,
          'comment': 'Good content but venue was a bit crowded.',
          'author': 'Sarah M.',
          'date': '2024-01-14'
        },
        {
          'rating': 5,
          'comment': 'Exceeded expectations. Will attend again!',
          'author': 'Mike R.',
          'date': '2024-01-14'
        },
      ]
    },
    'feedback': {
      'responseRate': 65,
      'overallSatisfaction': 4.2,
      'categories': {
        'Content Quality': 4.5,
        'Organization': 4.3,
        'Venue': 3.8,
        'Networking': 4.1,
        'Value for Money': 4.0,
      },
      'improvements': [
        {'suggestion': 'Better venue ventilation', 'votes': 45},
        {'suggestion': 'More networking breaks', 'votes': 38},
        {'suggestion': 'Improved catering options', 'votes': 32},
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics - ${widget.eventTitle}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.monetization_on), text: 'Sales'),
            Tab(icon: Icon(Icons.people), text: 'Attendees'),
            Tab(icon: Icon(Icons.star), text: 'Reviews'),
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTicketSalesTab(),
          _buildAttendeesTab(),
          _buildReviewsTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }

  Widget _buildTicketSalesTab() {
    final salesData = analyticsData['ticketSales'];
    final salesByType = salesData['salesByType'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSalesOverview(salesData),
          const SizedBox(height: 24),
          _buildSalesByType(salesByType),
          const SizedBox(height: 24),
          _buildSalesTrend(salesData['salesTrend']),
        ],
      ),
    );
  }

  Widget _buildSalesOverview(Map<String, dynamic> salesData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Tickets Sold',
                    '${salesData['totalSold']}/${salesData['totalCapacity']}',
                    Icons.confirmation_number,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Total Revenue',
                    '\$${salesData['revenue'].toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: salesData['totalSold'] / salesData['totalCapacity'],
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '${((salesData['totalSold'] / salesData['totalCapacity']) * 100).toStringAsFixed(1)}% capacity filled',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesByType(Map<String, dynamic> salesByType) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Ticket Type',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...salesByType.entries.map((entry) => _buildTicketTypeRow(
              entry.key,
              entry.value['sold'],
              entry.value['price'],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTypeRow(String type, int sold, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text('$sold sold'),
          ),
          Expanded(
            child: Text('\$${price.toStringAsFixed(2)}'),
          ),
          Expanded(
            child: Text(
              '\$${(sold * price).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTrend(List<int> salesTrend) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: salesTrend.asMap().entries.map((entry) {
                  final value = entry.value;
                  final maxValue = salesTrend.reduce((a, b) => a > b ? a : b);
                  final height = (value / maxValue) * 160;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 20,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'D${entry.key + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesTab() {
    final attendeeData = analyticsData['attendees'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttendanceOverview(attendeeData),
          const SizedBox(height: 24),
          _buildDemographics(attendeeData),
        ],
      ),
    );
  }

  Widget _buildAttendanceOverview(Map<String, dynamic> attendeeData) {
    final checkedIn = attendeeData['checked_in'];
    final noShow = attendeeData['no_show'];
    final total = checkedIn + noShow;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Checked In',
                    '$checkedIn',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'No Show',
                    '$noShow',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Attendance Rate: ${((checkedIn / total) * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographics(Map<String, dynamic> attendeeData) {
    return Column(
      children: [
        _buildDemographicChart('Age Groups', attendeeData['ageGroups']),
        const SizedBox(height: 16),
        _buildDemographicChart('Gender Distribution', attendeeData['genderDistribution']),
        const SizedBox(height: 16),
        _buildDemographicChart('Location', attendeeData['locations']),
      ],
    );
  }

  Widget _buildDemographicChart(String title, Map<String, int> data) {
    final total = data.values.reduce((a, b) => a + b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...data.entries.map((entry) {
              final percentage = (entry.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: entry.value / total,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${percentage.toStringAsFixed(1)}%'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviewsData = analyticsData['reviews'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewsOverview(reviewsData),
          const SizedBox(height: 24),
          _buildRatingDistribution(reviewsData['ratingDistribution']),
          const SizedBox(height: 24),
          _buildRecentReviews(reviewsData['recentReviews']),
        ],
      ),
    );
  }

  Widget _buildReviewsOverview(Map<String, dynamic> reviewsData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${reviewsData['averageRating']}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => Icon(
                          index < reviewsData['averageRating'].floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        )),
                      ),
                      Text('Average Rating'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${reviewsData['totalReviews']}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Total Reviews'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(Map<int, int> ratingDistribution) {
    final total = ratingDistribution.values.reduce((a, b) => a + b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...ratingDistribution.entries.map((entry) {
              final percentage = (entry.value / total);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Text('${entry.key}'),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.value}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReviews(List<Map<String, dynamic>> recentReviews) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Reviews',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recentReviews.map((review) => _buildReviewCard(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (index) => Icon(
                  index < review['rating']
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                )),
              ),
              const Spacer(),
              Text(
                review['date'],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review['comment']),
          const SizedBox(height: 8),
          Text(
            '- ${review['author']}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    final feedbackData = analyticsData['feedback'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeedbackOverview(feedbackData),
          const SizedBox(height: 24),
          _buildCategoryRatings(feedbackData['categories']),
          const SizedBox(height: 24),
          _buildImprovementSuggestions(feedbackData['improvements']),
        ],
      ),
    );
  }

  Widget _buildFeedbackOverview(Map<String, dynamic> feedbackData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post-Event Feedback',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Response Rate',
                    '${feedbackData['responseRate']}%',
                    Icons.rate_review,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Overall Satisfaction',
                    '${feedbackData['overallSatisfaction']}/5',
                    Icons.sentiment_satisfied,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRatings(Map<String, double> categories) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Ratings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(entry.key),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: entry.value / 5,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.value >= 4 ? Colors.green : 
                        entry.value >= 3 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value}/5'),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementSuggestions(List<Map<String, dynamic>> improvements) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Improvement Suggestions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...improvements.map((improvement) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  '${improvement['votes']}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text(improvement['suggestion']),
              subtitle: Text('${improvement['votes']} votes'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
