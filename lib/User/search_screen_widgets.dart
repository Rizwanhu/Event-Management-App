import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './Event/event_detail_page.dart'; // Import the EventDetailPage
import './Event/models/event.dart'; // Import the Event model

class SearchScreenWidgets {
  
  static Widget buildSearchBar({
    required TextEditingController controller,
    required String searchQuery,
    required List<String> suggestions,
    required VoidCallback onClear,
    required Function(String) onSuggestionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal.shade50,
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search events, categories, locations...',
              prefixIcon: const Icon(Icons.search, color: Colors.teal),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal.shade50,),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal),
              ),
              filled: true,
              fillColor: Colors.teal.shade50,
            ),
          ),
          if (suggestions.isNotEmpty) _buildSuggestions(suggestions, onSuggestionTap),
        ],
      ),
    );
  }

  static Widget _buildSuggestions(List<String> suggestions, Function(String) onSuggestionTap) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade50,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],      ),
      child: Column(
        children: suggestions.map((suggestion) {
          return ListTile(
            leading: const Icon(Icons.search, color: Colors.teal),
            title: Text(suggestion),
            onTap: () => onSuggestionTap(suggestion),
          );
        }).toList(),
      ),
    );
  }

  static Widget buildFilters({
    required String? selectedCategory,
    required String? selectedLocation,
    required DateTimeRange? selectedDateRange,
    required RangeValues priceRange,
    required String sortBy,
    required List<String> availableCategories,
    required List<String> availableLocations,
    required List<String> sortOptions,
    required Function(String?) onCategoryChanged,
    required Function(String?) onLocationChanged,
    required Function(DateTimeRange?) onDateRangeChanged,
    required VoidCallback onDateRangeCleared,
    required Function(RangeValues) onPriceRangeChanged,
    required Function(RangeValues) onPriceRangeChangeEnd,
    required Function(String?) onSortChanged,
    required VoidCallback onClearFilters,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Clear All'), 
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            'Category',
            selectedCategory,
            availableCategories,
            onCategoryChanged,
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Location',
            selectedLocation,
            availableLocations,
            onLocationChanged,
          ),
          const SizedBox(height: 12),
          _buildDateRangeSelector(selectedDateRange, onDateRangeChanged, onDateRangeCleared),
          const SizedBox(height: 12),
          _buildPriceRangeSlider(priceRange, onPriceRangeChanged, onPriceRangeChangeEnd),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Sort by',
            getSortDisplayName(sortBy),
            sortOptions.map(getSortDisplayName).toList(),
            onSortChanged,
          ),
        ],
      ),
    );
  }

  static Widget _buildDateRangeSelector(
    DateTimeRange? selectedDateRange,
    Function(DateTimeRange?) onDateRangeChanged,
    VoidCallback onDateRangeCleared,
  ) {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: selectedDateRange,
                );
                if (dateRange != null) {
                  onDateRangeChanged(dateRange);
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                selectedDateRange != null
                    ? '${selectedDateRange.start.day}/${selectedDateRange.start.month} - ${selectedDateRange.end.day}/${selectedDateRange.end.month}'
                    : 'Select Date Range',
              ),
            ),
          ),
          if (selectedDateRange != null)
            IconButton(
              onPressed: onDateRangeCleared,
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }

  static Widget _buildPriceRangeSlider(
    RangeValues priceRange,
    Function(RangeValues) onPriceRangeChanged,
    Function(RangeValues) onPriceRangeChangeEnd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range: \$${priceRange.start.round()} - \$${priceRange.end.round()}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 1000,
          divisions: 20,
          activeColor: Colors.teal,
          onChanged: onPriceRangeChanged,
          onChangeEnd: onPriceRangeChangeEnd,
        ),
      ],
    );
  }

  static Widget _buildFilterDropdown(
    String label,
    String? value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: value,
      items: options.map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      onChanged: onChanged,
    );
  }

  static String getSortDisplayName(String sortValue) {
    switch (sortValue) {
      case 'relevance':
        return 'Relevance';
      case 'date_asc':
        return 'Date (Earliest First)';
      case 'date_desc':
        return 'Date (Latest First)';
      case 'price_asc':
        return 'Price (Low to High)';
      case 'price_desc':
        return 'Price (High to Low)';
      case 'alphabetical':
        return 'Alphabetical';
      default:
        return 'Relevance';
    }
  }

  static Widget buildResults({
    required bool isLoading,
    required List<Map<String, dynamic>> filteredResults,
    required String searchQuery,
    required bool isLoadingMore,
    required ScrollController scrollController,
    required VoidCallback onResetAll,
    String? error,
  }) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text('Loading events...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onResetAll,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredResults.isEmpty) {
      return _buildEmptyState(onResetAll);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color:Colors.teal.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredResults.length} events found',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (searchQuery.isNotEmpty)
                Text(
                  'for "$searchQuery"',
                  style: TextStyle(color: Colors.teal.shade700),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredResults.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= filteredResults.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildEventCard(filteredResults[index]);
            },
          ),
        ),
      ],
    );
  }

  static Event _mapToEvent(Map<String, dynamic> eventData) {
    final eventDate = _parseEventDateTime(eventData['eventDate']) ?? DateTime.now();
    
    return Event(
      id: eventData['id'] ?? '',
      title: eventData['title'] ?? 'Untitled Event',
      description: eventData['description'] ?? '',
      date: '${eventDate.day}/${eventDate.month}/${eventDate.year}',
      time: '${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}',
      location: eventData['location'] ?? 'Location TBD',
      organizer: eventData['organizerName'] ?? 'Unknown Organizer',
      organizerImage: eventData['organizerImage'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
      bannerImage: eventData['imageUrl'] ?? eventData['image'] ?? 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
      isPast: eventDate.isBefore(DateTime.now()),
      passTypes: _createDefaultPassTypes(eventData['price']),
      likeCount: 0,
      commentCount: 0,
    );
  }

  static List<EventPassType> _createDefaultPassTypes(dynamic price) {
    final numPrice = _parsePrice(price) ?? 0.0;
    
    if (numPrice == 0) {
      return [
        EventPassType(
          title: 'Free RSVP',
          price: 'Free',
          description: 'General access to the event',
          isFree: true,
        ),
      ];
    } else {
      return [
        EventPassType(
          title: 'Event Ticket',
          price: '\$${numPrice.toStringAsFixed(0)}',
          description: 'Access to the event',
          isFree: false,
        ),
      ];
    }
  }

  static DateTime? _parseEventDateTime(dynamic date) {
    if (date == null) return null;
    
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is DateTime) {
      return date;
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Widget _buildEventCard(Map<String, dynamic> event) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(event: _mapToEvent(event)),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildEventImage(event),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event['title'] ?? 'Untitled Event',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatPrice(event['ticketPrice'] ?? event['price']),
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event['category'] ?? 'Other',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        _buildStatusIndicator(event['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event['location'] ?? 'Location TBD',
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatEventDate(event['eventDate']),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (event['description'] != null && event['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event['description'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (event['maxAttendees'] != null)
                          Text(
                            'Max: ${event['maxAttendees']} attendees',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          )
                        else if (event['currentAttendees'] != null)
                          Text(
                            '${event['currentAttendees']} attending',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          )
                        else
                          const SizedBox.shrink(),
                        Text(
                          'by ${event['organizerName'] ?? 'Unknown Organizer'}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildEventImage(Map<String, dynamic> event) {
    // Handle both imageUrls array and single imageUrl
    String? imageUrl;
    
    if (event['imageUrls'] != null && event['imageUrls'] is List && (event['imageUrls'] as List).isNotEmpty) {
      imageUrl = (event['imageUrls'] as List).first.toString();
    } else if (event['imageUrl'] != null) {
      imageUrl = event['imageUrl'].toString();
    }
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 150,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Event Image', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      );
    } else {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Event Image', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }

  static String _formatPrice(dynamic price) {
    if (price == null) return 'Free';
    
    final numPrice = _parsePrice(price);
    if (numPrice == null || numPrice == 0) return 'Free';
    
    return '\$${numPrice.toStringAsFixed(0)}';
  }

  static double? _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static String _formatEventDate(dynamic date) {
    if (date == null) return 'Date TBD';
    
    DateTime? eventDate;
    if (date is Timestamp) {
      eventDate = date.toDate();
    } else if (date is DateTime) {
      eventDate = date;
    } else if (date is String) {
      try {
        eventDate = DateTime.parse(date);
      } catch (e) {
        return 'Date TBD';
      }
    }
    
    if (eventDate == null) return 'Date TBD';
    
    return '${eventDate.day}/${eventDate.month}/${eventDate.year}';
  }

  static Widget _buildStatusIndicator(String? status) {
    Color color;
    String text;
    
    switch (status?.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyState(VoidCallback onResetAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onResetAll,
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }
}