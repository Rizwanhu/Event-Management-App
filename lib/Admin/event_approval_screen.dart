import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Firebase/event_moderation_service.dart';

class EventModerationScreen extends StatefulWidget {
  const EventModerationScreen({super.key});

  @override
  State<EventModerationScreen> createState() => _EventModerationScreenState();
}

class _EventModerationScreenState extends State<EventModerationScreen> {
  final EventModerationService _moderationService = EventModerationService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, high, medium, low priority
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleEventAction(String eventId, String action, [String? reason]) async {
    try {
      if (action == 'approved') {
        await _moderationService.approveEvent(eventId);
        _showSnackBar('Event Approved Successfully', Colors.green, Icons.check_circle);
      } else if (action == 'rejected') {
        await _moderationService.rejectEvent(eventId, reason ?? 'No reason provided');
        _showSnackBar('Event Rejected Successfully', Colors.red, Icons.cancel);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red, Icons.error);
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'food':
        return Icons.restaurant;
      case 'technology':
        return Icons.computer;
      case 'sports':
        return Icons.sports;
      case 'conference':
        return Icons.business;
      case 'workshop':
        return Icons.work;
      case 'seminar':
        return Icons.school;
      case 'concert':
        return Icons.music_note;
      case 'festival':
        return Icons.celebration;
      case 'networking':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  String _getEventPriority(Map<String, dynamic> event) {
    final dynamic eventDate = event['eventDate'] ?? event['date'];
    if (eventDate != null && eventDate is Timestamp) {
      final date = eventDate.toDate();
      final now = DateTime.now();
      final daysUntilEvent = date.difference(now).inDays;
      
      if (daysUntilEvent <= 7) {
        return 'high';
      } else if (daysUntilEvent <= 30) {
        return 'medium';
      } else {
        return 'low';
      }
    }
    return 'medium';
  }

  List<Map<String, dynamic>> _filterEvents(List<Map<String, dynamic>> events) {
    List<Map<String, dynamic>> filtered = events;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        final title = (event['title'] ?? '').toLowerCase();
        final description = (event['description'] ?? '').toLowerCase();
        final organizer = (event['organizerName'] ?? '').toLowerCase();
        final category = (event['category'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return title.contains(query) || 
               description.contains(query) || 
               organizer.contains(query) || 
               category.contains(query);
      }).toList();
    }

    // Apply priority filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((event) {
        return _getEventPriority(event) == _selectedFilter;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Event Moderation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Debug action to check database
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => _showDebugInfo(),
            tooltip: 'Debug Info',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events by title, organizer, or category...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _debounceTimer?.cancel();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) {
                    // Debounce the search to prevent excessive rebuilds
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          _searchQuery = value;
                        });
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Priority Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Events', 'all'),
                      _buildFilterChip('High Priority', 'high'),
                      _buildFilterChip('Medium Priority', 'medium'),
                      _buildFilterChip('Low Priority', 'low'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Events List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _moderationService.getPendingEvents(),
              builder: (context, snapshot) {
                print('StreamBuilder state: ${snapshot.connectionState}');
                print('Has data: ${snapshot.hasData}');
                print('Data length: ${snapshot.data?.length ?? 0}');
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading pending events...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print('StreamBuilder error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading events',
                          style: TextStyle(fontSize: 18, color: Colors.red[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Trigger rebuild
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allEvents = snapshot.data ?? [];
                final filteredEvents = _filterEvents(allEvents);
                
                print('All events: ${allEvents.length}, Filtered: ${filteredEvents.length}');

                if (filteredEvents.isEmpty) {
                  return _buildEmptyState();
                }

                return CustomScrollView(
                  slivers: [
                    // Stats Header
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.pending_actions, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${filteredEvents.length} pending events for review',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Events List
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = filteredEvents[index];
                          return _buildEventCard(event);
                        },
                        childCount: filteredEvents.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[700],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No events found' : 'All events reviewed!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search or filters'
                : 'No pending events for moderation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final priority = _getEventPriority(event);
    final title = event['title'] ?? 'Untitled Event';
    final description = event['description'] ?? 'No description available';
    final location = event['location'] ?? 'Location TBD';
    final category = event['category'] ?? 'Other';
    final organizerName = event['organizerName'] ?? 'Unknown Organizer';

    String formatTimestamp(dynamic timestamp) {
      if (timestamp == null) return 'Unknown';
      
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else {
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    }

    String formatEventDate(dynamic date) {
      if (date == null) return 'Date TBD';
      
      if (date is Timestamp) {
        final DateTime dateTime = date.toDate();
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (date is String) {
        return date;
      }
      
      return 'Date TBD';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority and category
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPriorityColor(priority).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${priority.toUpperCase()} PRIORITY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _getCategoryIcon(category),
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  formatTimestamp(event['createdAt']),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Organizer
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'By $organizerName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Location and date
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      formatEventDate(event['eventDate']),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.red[200]!),
                          ),
                        ),
                        onPressed: () => _showRejectDialog(event['id'], title),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _handleEventAction(event['id'], 'approved'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        onPressed: () => _showEventOptions(context, event),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String eventId, String eventTitle) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject "$eventTitle"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Please provide a reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleEventAction(eventId, 'rejected', reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEventOptions(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Event Options',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('View Full Details'),
                    onTap: () {
                      Navigator.pop(context);
                      _showEventDetails(event);
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('View Organizer'),
                    onTap: () {
                      Navigator.pop(context);
                      _showOrganizerInfo(event['organizerId']);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['title'] ?? 'Event Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Description', event['description']),
              _buildDetailRow('Location', event['location']),
              _buildDetailRow('Category', event['category']),
              _buildDetailRow('Organizer', event['organizerName']),
              _buildDetailRow('Max Attendees', event['maxAttendees']?.toString()),
              _buildDetailRow('Ticket Type', event['ticketType']),
              if (event['ticketPrice'] != null)
                _buildDetailRow('Ticket Price', '\$${event['ticketPrice']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not specified',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrganizerInfo(String? organizerId) {
    // TODO: Implement organizer info display
    _showSnackBar('Organizer info feature coming soon', Colors.blue, Icons.info);
  }

  void _showDebugInfo() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();
      
      final allEvents = snapshot.docs.length;
      final pendingEvents = snapshot.docs
          .where((doc) => (doc.data()['status'] ?? '') == 'pending')
          .length;
      final approvedEvents = snapshot.docs
          .where((doc) => (doc.data()['status'] ?? '') == 'approved')
          .length;

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Debug Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Events: $allEvents'),
                Text('Pending Events: $pendingEvents'),
                Text('Approved Events: $approvedEvents'),
                const SizedBox(height: 16),
                if (pendingEvents == 0) ...[
                  const Text('No pending events found.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _createTestEvent();
                    },
                    child: const Text('Create Test Event'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Debug error: ${e.toString()}', Colors.red, Icons.error);
    }
  }

  void _createTestEvent() async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': 'Test Event ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test event created for debugging purposes.',
        'organizerId': 'test_organizer',
        'organizerName': 'Test Organizer',
        'location': 'Test Location',
        'category': 'Testing',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'maxAttendees': 100,
        'ticketType': 'free',
        'currentAttendees': 0,
      });
      
      _showSnackBar('Test event created successfully', Colors.green, Icons.check);
    } catch (e) {
      _showSnackBar('Error creating test event: ${e.toString()}', Colors.red, Icons.error);
    }
  }
}
