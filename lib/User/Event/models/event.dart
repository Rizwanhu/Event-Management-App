class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String organizer;
  final String organizerImage;
  final String bannerImage;
  final bool isPast;
  final List<EventPassType> passTypes;
  final int likeCount;
  final int commentCount;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.organizerImage,
    required this.bannerImage,
    required this.isPast,
    required this.passTypes,
    required this.likeCount,
    required this.commentCount,
  });

  // Sample event for testing
  static Event getSampleEvent() {
    return Event(
      id: '1',
      title: 'Summer Music Festival 2024',
      description: 'Join us for an unforgettable evening of live music featuring top artists from around the world. Experience the magic of live performances in one of the most iconic venues in New York City.',
      date: 'December 25, 2024',
      time: '7:00 PM',
      location: 'Madison Square Garden, New York',
      organizer: 'NYC Events Co.',
      organizerImage: 'https://randomuser.me/api/portraits/men/32.jpg',
      bannerImage: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
      isPast: true,
      passTypes: [
        EventPassType(
          title: 'Free RSVP',
          price: 'Free',
          description: 'General access to the event',
          isFree: true,
        ),
        EventPassType(
          title: 'General Admission',
          price: '\$75',
          description: 'Access to main floor',
          isFree: false,
        ),
        EventPassType(
          title: 'VIP Package',
          price: '\$150',
          description: 'Premium seating + backstage access',
          isFree: false,
        ),
      ],
      likeCount: 245,
      commentCount: 42,
    );
  }
}

class EventPassType {
  final String title;
  final String price;
  final String description;
  final bool isFree;

  EventPassType({
    required this.title,
    required this.price,
    required this.description,
    required this.isFree,
  });
}
