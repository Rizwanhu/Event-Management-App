import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerEventCommentsScreen extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerEventCommentsScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  Stream<QuerySnapshot> getCommentsStream() {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments - $eventTitle'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCommentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final comments = snapshot.data?.docs ?? [];
          if (comments.isEmpty) {
            return const Center(child: Text('No comments yet.'));
          }
          return ListView.builder(
            reverse: true,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final data = comments[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.comment, color: Colors.deepPurple),
                title: Text(data['userName'] ?? 'Anonymous'),
                subtitle: Text(data['text'] ?? ''),
                trailing: Text(
                  _formatTimestamp(data['timestamp']),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
