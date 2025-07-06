import 'package:flutter/material.dart';
import '../data/search_screen_data.dart';
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
            SearchScreenData.categories,
            onCategoryChanged,
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Location',
            selectedLocation,
            SearchScreenData.locations,
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
            SearchScreenData.sortOptions.map(getSortDisplayName).toList(),
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
      case 'relevance': return 'Relevance';
      case 'date_asc': return 'Date (Earliest First)';
      case 'date_desc': return 'Date (Latest First)';
      case 'price_asc': return 'Price (Low to High)';
      case 'price_desc': return 'Price (High to Low)';
      case 'rating': return 'Highest Rated';
      case 'popularity': return 'Most Popular';
      default: return sortValue;
    }
  }

  static Widget buildResults({
    required bool isLoading,
    required List<Map<String, dynamic>> filteredResults,
    required String searchQuery,
    required bool isLoadingMore,
    required ScrollController scrollController,
    required VoidCallback onResetAll,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                  style: TextStyle(color: Colors.teal.shade50,),
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

  static Event _mapToEvent(Map<String, dynamic> eventMap) {
    // Convert pass types data
    List<EventPassType> passTypes = [];
    if (eventMap['price'] == 0) {
      passTypes.add(
        EventPassType(
          title: 'Free RSVP',
          price: 'Free',
          description: 'General access to the event',
          isFree: true,
        ),
      );
    } else {
      passTypes.add(
        EventPassType(
          title: 'General Admission',
          price: '\$${eventMap['price']}',
          description: 'Access to all areas',
          isFree: false,
        ),
      );
    }

    // Create and return the Event object
    return Event(
      id: eventMap['id']?.toString() ?? '1',
      title: eventMap['title'] ?? 'Event Title',
      description: eventMap['description'] ?? 'No description available',
      date: eventMap['date'] != null 
          ? '${eventMap['date'].day}/${eventMap['date'].month}/${eventMap['date'].year}'
          : 'Date TBD',
      time: eventMap['time'] ?? '7:00 PM',
      location: eventMap['location'] ?? 'Location TBD',
      organizer: eventMap['organizer'] ?? 'Event Organizer',
      organizerImage: 'https://randomuser.me/api/portraits/men/32.jpg', // Default image
      bannerImage: eventMap['image'] ?? 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
      isPast: false, // Default to upcoming event
      passTypes: passTypes,
      likeCount: eventMap['likes'] ?? 0,
      commentCount: eventMap['comments'] ?? 0,
    );
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
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.shade50,
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
                child: Image.network(
                  event['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.teal.shade50,
                      child: const Icon(Icons.image, size: 50),
                    );
                  },
                ),
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
                            event['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event['price'] == 0 ? 'Free' : '\$${event['price']}',
                            style: const TextStyle(
                              color: Colors.deepPurple,
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
                            event['category'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' ${event['rating']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          event['location'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${event['date'].day}/${event['date'].month}/${event['date'].year}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${event['attendees']} attending',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          'by ${event['organizer']}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),            ],
          ),
        ),
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