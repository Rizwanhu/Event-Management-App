import 'package:flutter/material.dart';
// import 'EventQNAScreen.dart';
// import 'PostEventReviewScreen.dart';
import 'widgets/event_detail_widgets.dart';
import 'comments_page.dart';
import 'models/event.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool isLiked = false;
  bool isRSVPd = false;
  late int likeCount;
  late int commentCount;
  String selectedPassType = '';
  late bool isEventPast;
  bool hasUserAttended = true; // Mock: User attended the event
  bool hasUserReviewed = false; // Mock: User hasn't reviewed yet

  @override
  void initState() {
    super.initState();
    likeCount = widget.event.likeCount;
    commentCount = widget.event.commentCount;
    isEventPast = widget.event.isPast;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () => _showShareOptions(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Banner/Media Section
            EventMediaSection(imageUrl: widget.event.bannerImage),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Event Info
                  EventInfoRow(
                      icon: Icons.calendar_today,
                      text: '${widget.event.date} • ${widget.event.time}'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showLocationMap(),
                    child: EventInfoRow(
                      icon: Icons.location_on,
                      text: widget.event.location,
                      isClickable: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Organizer Section
                  EventOrganizerSection(
                    organizerName: widget.event.organizer,
                    organizerImage: widget.event.organizerImage,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pass Types Section
                  const Text(
                    'Pass Types',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dynamically generate pass type cards
                  ...widget.event.passTypes
                      .map((passType) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: EventPassTypeCard(
                              title: passType.title,
                              price: passType.price,
                              description: passType.description,
                              isFree: passType.isFree,
                              isSelected: selectedPassType == passType.title,
                              onSelect: (title) {
                                setState(() {
                                  selectedPassType = title;
                                });
                              },
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 20),

                  // Social Actions
                  EventSocialActions(
                    isLiked: isLiked,
                    likeCount: likeCount,
                    commentCount: commentCount,
                    onLikePressed: () {
                      setState(() {
                        isLiked = !isLiked;
                        likeCount += isLiked ? 1 : -1;
                      });
                    },
                    onCommentPressed: () => _showComments(),
                    onSharePressed: () => _showShareOptions(),
                  ),
                  const SizedBox(height: 20),

                  // Q&A and Chat Section
                  EventQAChatSection(
                    eventId: widget.event.id,
                    eventTitle: widget.event.title,
                  ),
                  const SizedBox(height: 20),

                  // Reviews Section (for past events)
                  if (isEventPast)
                    EventReviewsSection(
                      hasUserAttended: hasUserAttended,
                      hasUserReviewed: hasUserReviewed,
                    ),
                  if (isEventPast) const SizedBox(height: 20),

                  // Join Chat Button (shown only if RSVP'd)
                  if (isRSVPd)
                    EventJoinChatButton(
                      eventId: widget.event.id,
                      eventTitle: widget.event.title,
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleMainAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedPassType == 'Free RSVP'
                  ? Colors.green
                  : Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _getMainActionText(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMainActionText() {
    if (selectedPassType == 'Free RSVP') {
      return isRSVPd ? 'RSVP Confirmed ✓' : 'RSVP Now';
    } else if (selectedPassType.isNotEmpty) {
      return 'Buy Tickets';
    }
    return 'Select Pass Type';
  }

  void _handleMainAction() {
    if (selectedPassType == 'Free RSVP') {
      setState(() {
        isRSVPd = !isRSVPd;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isRSVPd ? 'RSVP Confirmed!' : 'RSVP Cancelled'),
          backgroundColor: isRSVPd ? Colors.green : Colors.orange,
        ),
      );
    } else if (selectedPassType.isNotEmpty) {
      // Handle ticket purchase
      _showTicketPurchase();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pass type')),
      );
    }
  }

  void _showLocationMap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event Location'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Container(
                height: 150,
                color: Colors.grey[300],
                child: Center(
                  child: Text('Map View\n${widget.event.location}'),
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.event.location),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Get Directions'),
          ),
        ],
      ),
    );
  }

  void _showComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          eventId: widget.event.id,
          eventTitle: widget.event.title,
        ),
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Share Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ShareOptionButton(icon: Icons.message, label: 'Message'),
                ShareOptionButton(icon: Icons.email, label: 'Email'),
                ShareOptionButton(icon: Icons.copy, label: 'Copy Link'),
                ShareOptionButton(icon: Icons.more_horiz, label: 'More'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketPurchase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase $selectedPassType'),
        content: const Text('Redirecting to payment gateway...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle payment
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Example: If you have a navigation to EventQNAScreen somewhere, e.g. in EventQAChatSection or a button callback,
// update it like this:

// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => EventQNAScreen(
//       eventTitle: widget.event.title,
//     ),
//   ),
// );
