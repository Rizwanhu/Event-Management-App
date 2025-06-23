class ChatMessage {
  final String id;
  final String userName;
  final String message;
  final DateTime timestamp;
  final bool isOrganizer;

  ChatMessage({
    required this.id,
    required this.userName,
    required this.message,
    required this.timestamp,
    required this.isOrganizer,
  });
}
