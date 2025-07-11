import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganizerEventChatScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerEventChatScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  State<OrganizerEventChatScreen> createState() =>
      _OrganizerEventChatScreenState();
}

class _OrganizerEventChatScreenState extends State<OrganizerEventChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> get _chatStream => FirebaseFirestore.instance
      .collection('events')
      .doc(widget.eventId)
      .collection('chat_messages')
      .orderBy('timestamp', descending: false)
      .snapshots();

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || user == null) return;
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('chat_messages')
        .add({
      'userName': user?.displayName ?? user?.email ?? 'Organizer',
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isOrganizer': true,
      'userId': user?.uid ?? '',
    });
    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Chat - ${widget.eventTitle}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isOrganizer = data['isOrganizer'] == true;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isOrganizer ? Colors.deepPurple : Colors.blue,
                        child: Text((data['userName'] ?? '?')[0].toUpperCase()),
                      ),
                      title: Text(data['userName'] ?? ''),
                      subtitle: Text(data['message'] ?? ''),
                      trailing: isOrganizer
                          ? const Icon(Icons.verified, color: Colors.deepPurple)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
