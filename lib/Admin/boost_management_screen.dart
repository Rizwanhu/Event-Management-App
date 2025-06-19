import 'package:flutter/material.dart';

class BoostManagementScreen extends StatelessWidget {
  const BoostManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockBoosts = [
      {
        'title': 'TechFest 2025',
        'tier': 'Gold',
        'amount': 500,
        'daysLeft': 12,
        'image': 'https://via.placeholder.com/400x200.png?text=TechFest+2025'
      },
      {
        'title': 'Startup Meetup',
        'tier': 'Silver',
        'amount': 300,
        'daysLeft': 5,
        'image': 'https://via.placeholder.com/400x200.png?text=Startup+Meetup'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Boost Revenue Management")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockBoosts.length,
        itemBuilder: (context, index) {
          final event = mockBoosts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event['image'] != null)
                  Image.network(
  event['image'] as String,
  width: double.infinity,
  height: 180,
  fit: BoxFit.cover,
),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                           event['title'] as String,
                           style: Theme.of(context).textTheme.titleLarge,
                          ),

                          const Chip(
                            label: Text("Boosted", style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("💎 Tier: ${event['tier']}"),
                      Text("💰 Revenue: \$${event['amount']}"),
                      Text("⏳ Days Remaining: ${event['daysLeft']}"),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.info_outline),
                              label: const Text("Details"),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Details of ${event['title']}")),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel),
                              label: const Text("Remove Boost"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Boost removed for ${event['title']}")),
                                );
                              },
                            ),
                          ),
                        ],
                      )
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
