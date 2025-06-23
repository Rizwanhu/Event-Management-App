import 'package:flutter/material.dart';
import 'models/chat_message.dart';
import 'models/qa_item.dart';
// import 'screens/chat_tab.dart';
// import 'screens/qa_tab.dart';

class EventQNAScreen extends StatefulWidget {
  final String eventTitle;
  final bool isChatEnabled;
  final bool isQAEnabled;

  const EventQNAScreen({
    super.key,
    required this.eventTitle,
    this.isChatEnabled = true,
    this.isQAEnabled = true,
  });

  @override
  State<EventQNAScreen> createState() => _EventQNAScreenState();
}

class _EventQNAScreenState extends State<EventQNAScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  List<ChatMessage> messages = [];
  List<QAItem> qaItems = [];
  int onlineCount = 24;

  @override
  void initState() {
    super.initState();
    int tabLength = 0;
    if (widget.isChatEnabled) tabLength++;
    if (widget.isQAEnabled) tabLength++;
    
    _tabController = TabController(length: tabLength, vsync: this);
    _loadMockData();
  }

  void _loadMockData() {
    // Mock chat messages
    messages = [
      ChatMessage(
        id: '1',
        userName: 'Alex Johnson',
        message: 'Hey everyone! Super excited for this event 🎉',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isOrganizer: false,
      ),
      ChatMessage(
        id: '2',
        userName: 'MusicEvents Inc.',
        message: 'Welcome to the pre-event chat! Feel free to ask any questions.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isOrganizer: true,
      ),
      ChatMessage(
        id: '3',
        userName: 'Sarah Wilson',
        message: 'What time do the doors open?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isOrganizer: false,
      ),
      ChatMessage(
        id: '4',
        userName: 'Mike Chen',
        message: 'Can\'t wait to see the lineup! This is going to be amazing 🎵',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isOrganizer: false,
      ),
    ];

    // Mock Q&A items
    qaItems = [
      QAItem(
        id: '1',
        question: 'What time do the doors open?',
        askedBy: 'Sarah Wilson',
        askedAt: DateTime.now().subtract(const Duration(hours: 2)),
        answer: 'Doors open at 6:00 PM, one hour before the show starts.',
        answeredBy: 'MusicEvents Inc.',
        answeredAt: DateTime.now().subtract(const Duration(hours: 1)),
        upvotes: 12,
      ),
      QAItem(
        id: '2',
        question: 'Is there parking available at the venue?',
        askedBy: 'John Doe',
        askedAt: DateTime.now().subtract(const Duration(hours: 3)),
        answer: 'Yes, there\'s a parking garage next to Madison Square Garden. We recommend arriving early as it fills up quickly.',
        answeredBy: 'MusicEvents Inc.',
        answeredAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        upvotes: 8,
      ),
      QAItem(
        id: '3',
        question: 'Will there be food and drinks available?',
        askedBy: 'Emma Davis',
        askedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        upvotes: 5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [];
    if (widget.isChatEnabled) {
      tabs.add(Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline),
            const SizedBox(width: 8),
            const Text('Chat'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$onlineCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ));
    }
    
    if (widget.isQAEnabled) {
      tabs.add(const Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 8),
            Text('Q&A'),
          ],
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Pre-event Discussion',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showEventInfo(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (widget.isChatEnabled) _buildChatTab(),
          if (widget.isQAEnabled) _buildQATab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
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
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildChatMessage(messages[index]);
            },
          ),
        ),
        
        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildQATab() {
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: qaItems.length + 1, // +1 for the question input
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildQuestionInput();
              }
              return _buildQAItem(qaItems[index - 1]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: message.isOrganizer ? Colors.deepPurple : Colors.blue,
            child: Text(
              message.userName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.userName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: message.isOrganizer ? Colors.deepPurple : Colors.black,
                      ),
                    ),
                    if (message.isOrganizer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ORGANIZER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQAItem(QAItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, size: 20, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Asked by ${item.askedBy} • ${_formatTime(item.askedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Upvote button
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () => _upvoteQuestion(item.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    '${item.upvotes}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Answer (if available)
          if (item.answer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Answer by ${item.answeredBy}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                      if (item.answeredAt != null)
                        Text(
                          _formatTime(item.answeredAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.answer!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
            controller: _questionController,
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
              onPressed: () => _submitQuestion(),
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
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
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'You',
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isOrganizer: false,
      ));
    });

    _messageController.clear();
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      qaItems.insert(0, QAItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: _questionController.text.trim(),
        askedBy: 'You',
        askedAt: DateTime.now(),
        upvotes: 0,
      ));
    });

    _questionController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question submitted! The organizer will answer soon.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _upvoteQuestion(String questionId) {
    setState(() {
      final index = qaItems.indexWhere((item) => item.id == questionId);
      if (index != -1) {
        qaItems[index] = qaItems[index].copyWith(
          upvotes: qaItems[index].upvotes + 1,
        );
      }
    });
  }

  void _showEventInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event Discussion'),
        content: const Text(
          'This is a pre-event discussion space where you can:\n\n'
          '• Chat with other attendees\n'
          '• Ask questions to the organizer\n'
          '• Get event updates and announcements\n\n'
          'Be respectful and follow community guidelines.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _questionController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }
}
