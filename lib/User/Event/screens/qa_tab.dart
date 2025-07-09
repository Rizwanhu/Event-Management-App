import 'package:flutter/material.dart';
import '../models/qa_item.dart';
import '../widgets/qa_item_widget.dart';

class QATab extends StatelessWidget {
  final Stream<List<QAItem>> qaStream;
  final Function(String) onUpvoteQuestion;
  final TextEditingController questionController;
  final VoidCallback onSubmitQuestion;

  const QATab({
    super.key,
    required this.qaStream,
    required this.questionController,
    required this.onSubmitQuestion,
    required this.onUpvoteQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Q&A Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask a Question',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Get answers from the event organizer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Q&A List
        Expanded(
          child: StreamBuilder<List<QAItem>>(
            stream: qaStream,
            builder: (context, snapshot) {
              final qaItems = snapshot.data ?? [];
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: qaItems.length + 1, // +1 for the question input
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildQuestionInput();
                  }
                  return QAItemWidget(
                    item: qaItems[index - 1],
                    onUpvote: onUpvoteQuestion,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have a question?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: questionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your question here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmitQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit Question'),
            ),
          ),
        ],
      ),
    );
  }
}
