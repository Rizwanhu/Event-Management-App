import 'package:flutter/material.dart';
import 'manage_event_screen.dart';
import 'user_profile_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['boostApproved'] == true)
              const Chip(label: Text("Boosted")),
            const SizedBox(height: 8),
            Text(
              event['title'] ?? 'No Title',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text("Date: ${event['date'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Text(
              event['description'] ?? 'No description',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text("Manage Event"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageEventScreen(eventTitle: event['title']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
