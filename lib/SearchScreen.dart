import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Search and filter states
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  
  // Filter states
  String? _selectedCategory;
  String? _selectedLocation;
  DateTimeRange? _selectedDateRange;
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _sortBy = 'relevance';
  bool _showFilters = false;

  // Demo data
  final List<Map<String, dynamic>> _allEvents = [
    {
      'id': '1',
      'title': 'Jazz Night at Blue Note',
      'category': 'Music & Concerts',
      'location': 'New York, NY',
      'date': DateTime.now().add(const Duration(days: 5)),
      'price': 75.0,
      'image': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
      'organizer': 'Blue Note Club',
      'attendees': 120,
      'rating': 4.8,
      'description': 'An evening of smooth jazz with renowned artists.',
    },
    {
      'id': '2',
      'title': 'Tech Conference 2024',
      'category': 'Technology',
      'location': 'San Francisco, CA',
      'date': DateTime.now().add(const Duration(days: 12)),
      'price': 299.0,
      'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
      'organizer': 'TechCorp',
      'attendees': 500,
      'rating': 4.9,
      'description': 'Latest trends in technology and innovation.',
    },
    {
      'id': '3',
      'title': 'Food Festival Downtown',
      'category': 'Food & Dining',
      'location': 'Chicago, IL',
      'date': DateTime.now().add(const Duration(days: 8)),
      'price': 45.0,
      'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
      'organizer': 'Downtown Association',
      'attendees': 300,
      'rating': 4.6,
      'description': 'Taste the best food from local restaurants.',
    },
    {
      'id': '4',
      'title': 'Art Gallery Opening',
      'category': 'Art & Culture',
      'location': 'Los Angeles, CA',
      'date': DateTime.now().add(const Duration(days: 3)),
      'price': 25.0,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'organizer': 'Modern Art Gallery',
      'attendees': 150,
      'rating': 4.7,
      'description': 'Contemporary art exhibition featuring local artists.',
    },
    {
      'id': '5',
      'title': 'Marathon Training Session',
      'category': 'Sports & Fitness',
      'location': 'Boston, MA',
      'date': DateTime.now().add(const Duration(days: 1)),
      'price': 0.0,
      'image': 'https://images.unsplash.com/photo-1544717297-fa95b6ee9643?w=400',
      'organizer': 'Boston Runners Club',
      'attendees': 80,
      'rating': 4.5,
      'description': 'Prepare for the upcoming marathon with professional trainers.',
    },
    {
      'id': '6',
      'title': 'Business Networking Event',
      'category': 'Business',
      'location': 'New York, NY',
      'date': DateTime.now().add(const Duration(days: 15)),
      'price': 120.0,
      'image': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=400',
      'organizer': 'Business Leaders NYC',
      'attendees': 200,
      'rating': 4.4,
      'description': 'Connect with industry professionals and expand your network.',
    },
    {
      'id': '7',
      'title': 'Photography Workshop',
      'category': 'Photography',
      'location': 'Seattle, WA',
      'date': DateTime.now().add(const Duration(days: 7)),
      'price': 85.0,
      'image': 'https://images.unsplash.com/photo-1606983340126-99ab4feaa64a?w=400',
      'organizer': 'Photo Masters',
      'attendees': 25,
      'rating': 4.9,
      'description': 'Learn advanced photography techniques from professionals.',
    },
    {
      'id': '8',
      'title': 'Yoga Retreat Weekend',
      'category': 'Health & Wellness',
      'location': 'Austin, TX',
      'date': DateTime.now().add(const Duration(days: 20)),
      'price': 150.0,
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
      'organizer': 'Zen Studios',
      'attendees': 40,
      'rating': 4.8,
      'description': 'Relax and rejuvenate with meditation and yoga.',
    },
  ];

  final List<String> _categories = [
    'All Categories',
    'Music & Concerts',
    'Technology',
    'Food & Dining',
    'Art & Culture',
    'Sports & Fitness',
    'Business',
    'Health & Wellness',
    'Education',
    'Photography',
    'Travel',
  ];

  final List<String> _locations = [
    'All Locations',
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'San Francisco, CA',
    'Boston, MA',
    'Austin, TX',
    'Seattle, WA',
    'Miami, FL',
  ];

  final List<String> _sortOptions = [
    'relevance',
    'date_asc',
    'date_desc',
    'price_asc',
    'price_desc',
    'rating',
    'popularity',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    setState(() {
      _searchResults = List.from(_allEvents);
      _filteredResults = List.from(_allEvents);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
    });

    if (query.isNotEmpty) {
      _generateSuggestions(query);
      _performSearch(query);
    } else {
      setState(() {
        _searchSuggestions.clear();
        _filteredResults = List.from(_searchResults);
      });
    }
  }

  void _generateSuggestions(String query) {
    final suggestions = <String>{};
    
    for (final event in _allEvents) {
      final title = event['title'].toString().toLowerCase();
      final category = event['category'].toString().toLowerCase();
      final location = event['location'].toString().toLowerCase();
      
      if (title.contains(query)) suggestions.add(event['title']);
      if (category.contains(query)) suggestions.add(event['category']);
      if (location.contains(query)) suggestions.add(event['location']);
    }
    
    setState(() {
      _searchSuggestions = suggestions.take(5).toList();
    });
  }

  void _performSearch(String query) {
    final results = _allEvents.where((event) {
      final title = event['title'].toString().toLowerCase();
      final category = event['category'].toString().toLowerCase();
      final location = event['location'].toString().toLowerCase();
      final organizer = event['organizer'].toString().toLowerCase();
      
      return title.contains(query) ||
             category.contains(query) ||
             location.contains(query) ||
             organizer.contains(query);
    }).toList();

    setState(() {
      _searchResults = results;
    });
    _applyFilters();
  }

  void _applyFilters() {
    var results = List<Map<String, dynamic>>.from(_searchResults);

    // Category filter
    if (_selectedCategory != null && _selectedCategory != 'All Categories') {
      results = results.where((event) => event['category'] == _selectedCategory).toList();
    }

    // Location filter
    if (_selectedLocation != null && _selectedLocation != 'All Locations') {
      results = results.where((event) => event['location'] == _selectedLocation).toList();
    }

    // Date range filter
    if (_selectedDateRange != null) {
      results = results.where((event) {
        final eventDate = event['date'] as DateTime;
        return eventDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               eventDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Price range filter
    results = results.where((event) {
      final price = event['price'] as double;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Sort results
    _sortResults(results);

    setState(() {
      _filteredResults = results;
    });
  }

  void _sortResults(List<Map<String, dynamic>> results) {
    switch (_sortBy) {
      case 'date_asc':
        results.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        break;
      case 'date_desc':
        results.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
      case 'price_asc':
        results.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'price_desc':
        results.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'rating':
        results.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'popularity':
        results.sort((a, b) => (b['attendees'] as int).compareTo(a['attendees'] as int));
        break;
      case 'relevance':
      default:
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoadingMore = false;
        _currentPage++;
      });
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedLocation = null;
      _selectedDateRange = null;
      _priceRange = const RangeValues(0, 1000);
      _sortBy = 'relevance';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search Events',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.deepPurple,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilters(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search events, categories, locations...',
              prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _searchSuggestions.clear();
                          _filteredResults = List.from(_allEvents);
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
                borderSide: const BorderSide(color: Colors.deepPurple),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          if (_searchSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
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
                children: _searchSuggestions.map((suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.search, color: Colors.grey),
                    title: Text(suggestion),
                    onTap: () {
                      _searchController.text = suggestion;
                      _performSearch(suggestion.toLowerCase());
                      setState(() => _searchSuggestions.clear());
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
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
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            'Category',
            _selectedCategory,
            _categories,
            (value) => setState(() {
              _selectedCategory = value;
              _applyFilters();
            }),
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Location',
            _selectedLocation,
            _locations,
            (value) => setState(() {
              _selectedLocation = value;
              _applyFilters();
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final dateRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _selectedDateRange,
                    );
                    if (dateRange != null) {
                      setState(() => _selectedDateRange = dateRange);
                      _applyFilters();
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDateRange != null
                        ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                        : 'Select Date Range',
                  ),
                ),
              ),
              if (_selectedDateRange != null)
                IconButton(
                  onPressed: () {
                    setState(() => _selectedDateRange = null);
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                activeColor: Colors.deepPurple,
                onChanged: (values) => setState(() => _priceRange = values),
                onChangeEnd: (values) => _applyFilters(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Sort by',
            _getSortDisplayName(_sortBy),
            _sortOptions.map(_getSortDisplayName).toList(),
            (value) {
              final sortValue = _sortOptions[_sortOptions.indexWhere((option) => 
                _getSortDisplayName(option) == value)];
              setState(() => _sortBy = sortValue);
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  String _getSortDisplayName(String sortValue) {
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

  Widget _buildFilterDropdown(
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

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredResults.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredResults.length} events found',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (_searchQuery.isNotEmpty)
                Text(
                  'for "$_searchQuery"',
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _filteredResults.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _filteredResults.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildEventCard(_filteredResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  color: Colors.grey[300],
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
                        color: Colors.deepPurple.withOpacity(0.1),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            onPressed: () {
              _searchController.clear();
              _clearFilters();
              setState(() {
                _searchQuery = '';
                _filteredResults = List.from(_allEvents);
              });
            },
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }
}
