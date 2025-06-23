import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  
  // Dummy comments data
  final List<Map<String, dynamic>> comments = [
    {
      'id': 1,
      'username': 'Sarah Johnson',
      'avatar': 'SJ',
      'time': '2h ago',
      'content': 'This looks amazing! Can\'t wait to attend. Will there be parking available?',
      'likes': 12,
      'isLiked': false,
    },
    {
      'id': 2,
      'username': 'Mike Chen',
      'avatar': 'MC',
      'time': '4h ago',
      'content': 'Great lineup of artists! I\'ve been to this venue before and it\'s fantastic.',
      'likes': 8,
      'isLiked': true,
    },
    {
      'id': 3,
      'username': 'Emma Davis',
      'avatar': 'ED',
      'time': '6h ago',
      'content': 'Just bought my VIP tickets! So excited for the backstage access 🎵',
      'likes': 15,
      'isLiked': false,
    },
    {
      'id': 4,
      'username': 'Alex Rivera',
      'avatar': 'AR',
      'time': '8h ago',
      'content': 'Is this event suitable for kids? Looking to bring my family.',
      'likes': 3,
      'isLiked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu selection
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Text('Sort by newest'),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: Text('Filter comments'),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('Report issue'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Comments Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.comment, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  '${comments.length} Comments',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, size: 16),
                  label: const Text('Sort'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          
          // Comments List
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _buildCommentCard(comment, index);
              },
            ),
          ),
        ],
      ),
      
      // Comment Input Bottom Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.deepPurple,
              child: const Text(
                'YU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Comment Input Field
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            
            // Send Button
            Container(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    // Add comment logic here
                    _commentController.clear();
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  comment['avatar'],
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['username'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      comment['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // More Options
              PopupMenuButton<String>(
                onSelected: (value) {
                  // Handle comment actions
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'reply',
                    child: Text('Reply'),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Text('Report'),
                  ),
                  const PopupMenuItem(
                    value: 'block',
                    child: Text('Block User'),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Comment Content
          Text(
            comment['content'],
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // Comment Actions
          Row(
            children: [
              // Like Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    comments[index]['isLiked'] = !comments[index]['isLiked'];
                    comments[index]['likes'] += comments[index]['isLiked'] ? 1 : -1;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      comment['isLiked'] ? Icons.favorite : Icons.favorite_border,
                      color: comment['isLiked'] ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment['likes']}',
                      style: TextStyle(
                        color: comment['isLiked'] ? Colors.red : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Reply Button
              GestureDetector(
                onTap: () {
                  // Handle reply
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Time ago
              Text(
                comment['time'],
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}