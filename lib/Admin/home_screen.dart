import 'package:flutter/material.dart';
import 'event_tile.dart';
import 'event_detail_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  final List<String> tabs = const ['All', 'Boosted', 'Following'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Event Manager"),
          bottom: TabBar(
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) => _buildTabView(context, tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildTabView(BuildContext context, String tab) {
    final mockEvents = List.generate(4, (index) => {
      'title': '$tab Event ${index + 1}',
      'price': (10 + index * 10).toDouble(),
      'boostApproved': tab == 'Boosted',
      'date': '2025-07-1${index}',
      'description': 'Description for $tab event ${index + 1}',
    });

    return ListView.builder(
      itemCount: mockEvents.length,
      itemBuilder: (context, index) {
        final data = mockEvents[index];
       return EventTile(
  title: data['title']?.toString() ?? 'Untitled Event',
  price: (data['price'] is num) ? data['price'] as num : 0,
  boosted: data['boostApproved'] == true,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EventDetailScreen(event: data),
    ),
  ),
);

      },
    );
  }
}
