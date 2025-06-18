import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedEventType = 'Event';
  String selectedDate = 'Date';
  String selectedLocation = 'Location';

  final List<String> eventTypes = ['Event', 'Concert', 'Conference', 'Workshop', 'Sports', 'Party'];
  final List<String> dates = ['Date', 'Today', 'Tomorrow', 'This Week', 'This Month'];
  final List<String> locations = ['Location', 'New York', 'Los Angeles', 'Chicago', 'Miami', 'Seattle'];

  // Dummy event data
  final List<Map<String, dynamic>> events = [
    {
      'title': 'Music Concert',
      'location': 'Madison Square Garden',
      'date': 'Dec 25, 2024',
      'image': 'assets/images/concert.jpg',
      'isBoosted': true,
      'boostLevel': 'Boosted',
    },
    {
      'title': 'Tech Conference',
      'location': 'Convention Center',
      'date': 'Jan 15, 2025',
      'image': 'assets/images/tech.jpg',
      'isBoosted': false,
      'boostLevel': '',
    },
    {
      'title': 'Food Festival',
      'location': 'Central Park',
      'date': 'Feb 5, 2025',
      'image': 'assets/images/food.jpg',
      'isBoosted': true,
      'boostLevel': 'Boosted',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Events'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterDropdown(eventTypes, selectedEventType, (value) {
                  setState(() {
                    selectedEventType = value!;
                  });
                }),
                _buildFilterDropdown(dates, selectedDate, (value) {
                  setState(() {
                    selectedDate = value!;
                  });
                }),
                _buildFilterDropdown(locations, selectedLocation, (value) {
                  setState(() {
                    selectedLocation = value!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 24),
            
            // Event List
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(event);
                },
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavIcon(Icons.search, true),
            _buildBottomNavIcon(Icons.favorite_border, false),
            _buildBottomNavIcon(Icons.add_circle_outline, false),
            _buildBottomNavIcon(Icons.person_outline, false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(List<String> items, String selectedValue, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        underline: const SizedBox(),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
                if (event['isBoosted'])
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event['boostLevel'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event['location'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event['date'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.deepPurple : Colors.grey,
        size: 24,
      ),
    );
  }
}