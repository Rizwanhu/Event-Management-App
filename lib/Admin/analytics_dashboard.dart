import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/event_model.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  void _updateEventStatus(String eventId, EventStatus status) {
    FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({'status': status.toString().split('.').last});
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.approved:
        return Colors.green;
      case EventStatus.rejected:
        return Colors.red;
      case EventStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Events')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading events'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs
              .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList()
              ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(event.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.status.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(event.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (event.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Image.network(
                              event.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${event.eventDate.toLocal().toString().split(' ')[0]} ${event.eventTime?.format(context)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _updateEventStatus(event.id, EventStatus.rejected),
                              child: const Text('Reject'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateEventStatus(event.id, EventStatus.approved),
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'event_details_screen.dart';

// class AnalyticsDashboard extends StatelessWidget {
//   const AnalyticsDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final stats = [
//       {'label': 'Total Events', 'value': '70', 'icon': Icons.event},
//       {'label': 'Boost Revenue', 'value': '\$3200', 'icon': Icons.monetization_on},
//       {'label': 'Active Users', 'value': '580', 'icon': Icons.people},
//       {'label': 'Reports', 'value': '12', 'icon': Icons.report},
//     ];

//     // Sample events data - replace with your actual data source
//     final events = [
//       {
//         'name': 'Tech Conference',
//         'location': 'Convention Center',
//         'time': '10:00 AM, June 30',
//         'image': 'https://example.com/tech-conf.jpg'
//       },
//       {
//         'name': 'Music Festival',
//         'location': 'Central Park',
//         'time': '6:00 PM, July 5',
//         'image': 'https://example.com/music-fest.jpg'
//       },
//       // Add more events as needed
//     ];

//     return Scaffold(
//       appBar: AppBar(title: const Text("Analytics Dashboard")),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(16),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 1.1,
//         ),
//         itemCount: stats.length,
//         itemBuilder: (context, index) {
//           final stat = stats[index];
//           Widget card = Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 7,
//             color: const Color.fromARGB(255, 115, 224, 224),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(stat['icon'] as IconData, size: 40, color: Theme.of(context).colorScheme.primary),
//                   const SizedBox(height: 10),
//                   Text(stat['label'].toString(), style: const TextStyle(fontSize: 16)),
//                   const SizedBox(height: 6),
//                   Text(stat['value'].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//           );
          
//           if (index == 0) {
//             card = InkWell(
//               borderRadius: BorderRadius.circular(16),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EventDetailsScreen(events: events),
//                   ),
//                 );
//               },
//               child: card,
//             );
//           }
          
//           return card;
//         },
//       ),
//     );
//   }
// }


