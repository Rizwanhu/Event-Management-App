import 'package:flutter/material.dart';

class PostEventReviewScreen extends StatefulWidget {
  final String eventTitle;
  final String eventId;
  final bool hasUserReviewed;

  const PostEventReviewScreen({
    super.key,
    required this.eventTitle,
    required this.eventId,
    this.hasUserReviewed = false,
  });

  @override
  State<PostEventReviewScreen> createState() => _PostEventReviewScreenState();
}

class _PostEventReviewScreenState extends State<PostEventReviewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reviewController = TextEditingController();
  
  int userRating = 0;
  bool isSubmitting = false;
  bool hasSubmittedReview = false;
  
  List<EventReview> allReviews = [];
  double averageRating = 4.2;
  int totalReviews = 127;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    hasSubmittedReview = widget.hasUserReviewed;
    _loadReviews();
  }

  void _loadReviews() {
    // Mock reviews data
    allReviews = [
      EventReview(
        id: '1',
        userName: 'Sarah Johnson',
        rating: 5,
        comment: 'Amazing event! The music was fantastic and the venue was perfect. Definitely recommend to anyone who loves live music!',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isVerifiedAttendee: true,
      ),
      EventReview(
        id: '2',
        userName: 'Mike Chen',
        rating: 4,
        comment: 'Great lineup and sound quality. Only downside was the long queues for drinks, but overall a wonderful experience.',
        date: DateTime.now().subtract(const Duration(days: 3)),
        isVerifiedAttendee: true,
      ),
      EventReview(
        id: '3',
        userName: 'Alex Rodriguez',
        rating: 5,
        comment: 'Best concert I\'ve been to this year! The organizers did an excellent job.',
        date: DateTime.now().subtract(const Duration(days: 4)),
        isVerifiedAttendee: true,
      ),
      EventReview(
        id: '4',
        userName: 'Emma Wilson',
        rating: 3,
        comment: 'Good music but the venue was a bit crowded. Could have been better organized.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        isVerifiedAttendee: false,
      ),
      EventReview(
        id: '5',
        userName: 'David Kim',
        rating: 5,
        comment: 'Absolutely incredible! Worth every penny. Can\'t wait for the next one.',
        date: DateTime.now().subtract(const Duration(days: 6)),
        isVerifiedAttendee: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              'Reviews & Feedback',
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
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.rate_review),
                  SizedBox(width: 8),
                  Text('Write Review'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.reviews),
                  SizedBox(width: 8),
                  Text('All Reviews'),
                ],
              ),
            ),
          ],
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWriteReviewTab(),
          _buildAllReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildWriteReviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Summary Card
          _buildEventSummaryCard(),
          const SizedBox(height: 24),
          
          if (!hasSubmittedReview) ...[
            // Rating Section
            _buildRatingSection(),
            const SizedBox(height: 24),
            
            // Feedback Section
            _buildFeedbackSection(),
            const SizedBox(height: 24),
            
            // Submit Button
            _buildSubmitButton(),
          ] else ...[
            // Already Reviewed Message
            _buildAlreadyReviewedMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildAllReviewsTab() {
    return Column(
      children: [
        // Review Statistics
        _buildReviewStats(),
        
        // Reviews List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allReviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(allReviews[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'December 25, 2024 • Madison Square Garden',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Attended',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How was your experience?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate your overall experience at this event',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    userRating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < userRating ? Icons.star : Icons.star_border,
                    color: index < userRating ? Colors.amber : Colors.grey,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Rating Text
          Center(
            child: Text(
              _getRatingText(userRating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: userRating > 0 ? Colors.deepPurple : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share your feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell others about your experience (optional)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        
        TextField(
          controller: _reviewController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'What did you think about the event? Share details about the music, venue, organization, etc.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: userRating > 0 ? _submitReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildAlreadyReviewedMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Thank you for your review!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your feedback helps other attendees make informed decisions about future events.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _tabController.animateTo(1);
            },
            child: const Text('View All Reviews'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor() ? Icons.star : 
                        index < averageRating ? Icons.star_half : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalReviews reviews',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 89),
                    _buildRatingBar(4, 23),
                    _buildRatingBar(3, 8),
                    _buildRatingBar(2, 3),
                    _buildRatingBar(1, 4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    double percentage = count / totalReviews;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(EventReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.deepPurple,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
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
                          review.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (review.isVerifiedAttendee) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'VERIFIED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Tap to rate';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isSubmitting = false;
      hasSubmittedReview = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your review!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }
}

class EventReview {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;
  final bool isVerifiedAttendee;

  EventReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.isVerifiedAttendee,
  });
}
