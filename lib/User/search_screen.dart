import 'package:flutter/material.dart';
import 'search_screen_widgets.dart';
import '../data/search_screen_data.dart';
import 'ProfileScreen.dart';
import 'promote_event_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const SearchEventsPage(),
    const PromoteEventPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Promote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class SearchEventsPage extends StatefulWidget {
  const SearchEventsPage({super.key});

  @override
  State<SearchEventsPage> createState() => _SearchEventsPageState();
}

class _SearchEventsPageState extends State<SearchEventsPage> {
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
  
  // Filter states
  String? _selectedCategory;
  String? _selectedLocation;
  DateTimeRange? _selectedDateRange;
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _sortBy = 'relevance';
  bool _showFilters = false;

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
      _searchResults = List.from(SearchScreenData.allEvents);
      _filteredResults = List.from(SearchScreenData.allEvents);
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
        _searchResults = List.from(SearchScreenData.allEvents);
      });
      _applyFilters();
    }
  }

  void _generateSuggestions(String query) {
    final suggestions = <String>{};
    
    for (final event in SearchScreenData.allEvents) {
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
    final results = SearchScreenData.allEvents.where((event) {
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

    // TODO: Replace with actual API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoadingMore = false;
        _currentPage++;
        // In real implementation, you would load more data here
        // For now, we'll just simulate having no more data after a few pages
        if (_currentPage > 3) {
          _hasMoreData = false;
        }
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

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchSuggestions.clear();
      _searchResults = List.from(SearchScreenData.allEvents);
    });
    _applyFilters();
  }

  void _resetAll() {
    _searchController.clear();
    _clearFilters();
    setState(() {
      _searchQuery = '';
      _searchResults = List.from(SearchScreenData.allEvents);
      _filteredResults = List.from(SearchScreenData.allEvents);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back button
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
          SearchScreenWidgets.buildSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            suggestions: _searchSuggestions,
            onClear: _clearSearch,
            onSuggestionTap: (suggestion) {
              _searchController.text = suggestion;
              _performSearch(suggestion.toLowerCase());
              setState(() => _searchSuggestions.clear());
            },
          ),
          if (_showFilters)
            SearchScreenWidgets.buildFilters(
              selectedCategory: _selectedCategory,
              selectedLocation: _selectedLocation,
              selectedDateRange: _selectedDateRange,
              priceRange: _priceRange,
              sortBy: _sortBy,
              onCategoryChanged: (value) {
                setState(() => _selectedCategory = value);
                _applyFilters();
              },
              onLocationChanged: (value) {
                setState(() => _selectedLocation = value);
                _applyFilters();
              },
              onDateRangeChanged: (dateRange) {
                setState(() => _selectedDateRange = dateRange);
                _applyFilters();
              },
              onDateRangeCleared: () {
                setState(() => _selectedDateRange = null);
                _applyFilters();
              },
              onPriceRangeChanged: (values) => setState(() => _priceRange = values),
              onPriceRangeChangeEnd: (values) => _applyFilters(),
              onSortChanged: (value) {
                final sortValue = SearchScreenData.sortOptions[
                    SearchScreenData.sortOptions.indexWhere((option) => 
                        SearchScreenWidgets.getSortDisplayName(option) == value)];
                setState(() => _sortBy = sortValue);
                _applyFilters();
              },
              onClearFilters: _clearFilters,
            ),
          Expanded(
            child: SearchScreenWidgets.buildResults(
              isLoading: _isLoading,
              filteredResults: _filteredResults,
              searchQuery: _searchQuery,
              isLoadingMore: _isLoadingMore,
              scrollController: _scrollController,
              onResetAll: _resetAll,
            ),
          ),
        ],
      ),
    );
  }
}