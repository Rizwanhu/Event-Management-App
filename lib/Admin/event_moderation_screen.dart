import 'package:flutter/material.dart';

class EventModerationScreen extends StatelessWidget {
  const EventModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockEvents = [
      {
        'title': 'Spring Fest 2025',
        'location': 'City Hall',
        'date': 'May 10, 2025',
        'desc': 'A fun-filled musical evening with bands.',
        'image': 'https://via.placeholder.com/400x200.png?text=Spring+Fest'
      },
      {
        'title': 'Food Carnival',
        'location': 'Park Street',
        'date': 'June 5, 2025',
        'desc': 'Tasting events and chef competitions.',
        'image': 'https://via.placeholder.com/400x200.png?text=Food+Carnival'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Event Moderation")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockEvents.length,
        itemBuilder: (context, index) {
          final event = mockEvents[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event['image'] != null)
                  Image.network(
                    event['image']!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title']!, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text("📍 ${event['location']}  •  🗓️ ${event['date']}", style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(event['desc']!, style: const TextStyle(color: Colors.black87)),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Approve"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${event['title']} Approved")),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel),
                              label: const Text("Reject"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${event['title']} Rejected")),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
