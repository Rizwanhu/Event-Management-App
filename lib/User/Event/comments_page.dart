import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const CommentsPage({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  Stream<QuerySnapshot> get _commentsStream => FirebaseFirestore.instance
      .collection('events')
      .doc(widget.eventId)
      .collection('comments')
      .orderBy('timestamp', descending: true)
      .snapshots();

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('comments')
        .add({
      'text': text,
      'userName': 'Anonymous', // Replace with actual user name if available
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments - ${widget.eventTitle}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _commentsStream,
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
                      leading:
                          const Icon(Icons.comment, color: Colors.deepPurple),
                      title: Text(data['userName'] ?? 'Anonymous'),
                      subtitle: Text(data['text'] ?? ''),
                      trailing: Text(
                        _formatTimestamp(data['timestamp']),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
