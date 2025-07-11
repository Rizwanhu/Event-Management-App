import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganizerEventQNAScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerEventQNAScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  State<OrganizerEventQNAScreen> createState() =>
      _OrganizerEventQNAScreenState();
}

class _OrganizerEventQNAScreenState extends State<OrganizerEventQNAScreen> {
  late Stream<QuerySnapshot> _qaStream;

  @override
  void initState() {
    super.initState();
    _qaStream = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('qa_items')
        .orderBy('askedAt', descending: true)
        .snapshots();
  }

  Future<void> _answerQuestion(String qaId, String answer) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('qa_items')
        .doc(qaId)
        .update({
      'answer': answer,
      'answeredBy': user?.displayName ?? user?.email ?? 'Organizer',
      'answeredAt': FieldValue.serverTimestamp(),
    });
  }

  void _showAnswerDialog(String qaId) {
    final TextEditingController _answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Answer Question'),
        content: TextField(
          controller: _answerController,
          decoration: const InputDecoration(hintText: 'Type your answer...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_answerController.text.trim().isNotEmpty) {
                _answerQuestion(qaId, _answerController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Q&A - ${widget.eventTitle}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _qaStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No questions yet.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final hasAnswer = data['answer'] != null &&
                  data['answer'].toString().isNotEmpty;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['question'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text('Asked by: ${data['askedBy'] ?? 'User'}'),
                      const SizedBox(height: 8),
                      if (hasAnswer) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Answer: ${data['answer']}'),
                              if (data['answeredBy'] != null)
                                Text('By: ${data['answeredBy']}'),
                            ],
                          ),
                        ),
                      ] else ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => _showAnswerDialog(docs[index].id),
                            child: const Text('Answer'),
                          ),
                        ),
                      ],
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
