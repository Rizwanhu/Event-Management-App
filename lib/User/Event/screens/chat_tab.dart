import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/chat_message_widget.dart';

class ChatTab extends StatelessWidget {
  final Stream<List<ChatMessage>> chatStream;
  final int onlineCount;
  final ScrollController chatScrollController;
  final TextEditingController messageController;
  final VoidCallback onSendMessage;

  const ChatTab({
    super.key,
    required this.chatStream,
    required this.onlineCount,
    required this.chatScrollController,
    required this.messageController,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Online users indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$onlineCount people online',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              Text(
                'Live Chat',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Chat messages
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: chatStream,
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];
              return ListView.builder(
                controller: chatScrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageWidget(message: messages[index]);
                },
              );
            },
          ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => onSendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: onSendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
