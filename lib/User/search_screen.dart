import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_screen_widgets.dart';
import '../Firebase/user_events_service.dart';
import 'ProfileScreen.dart';
import 'promote_event_page.dart';
import 'dart:async';

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
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.teal.shade50,
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
  final UserEventsService _userEventsService = UserEventsService();
  final UserEventsService _testEventsService = UserEventsService();
  Timer? _searchDebounceTimer;

  // Search and filter states
  String _searchQuery = '';
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredResults = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = true;
  String? _error;
  bool _debugMode = false;

  // Filter states
  String? _selectedCategory;
  String? _selectedLocation;
  DateTimeRange? _selectedDateRange;
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _sortBy = 'relevance';
  bool _showFilters = false;

  // Pagination states
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;

  // Stream subscription
  StreamSubscription<List<Map<String, dynamic>>>? _eventsSubscription;

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
    _searchDebounceTimer?.cancel();
    _eventsSubscription?.cancel();
    super.dispose();
  }

  void _loadInitialData() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    print('SearchScreen: Starting to load initial data...');

    // Listen to approved events stream
    _eventsSubscription = _userEventsService.getApprovedEvents().listen(
      (events) {
        print(
            'SearchScreen: Received ${events.length} events from UserEventsService');

        // Debug: Print each event received
        for (var event in events) {
          print(
              'Event received: ${event['title']} - Status: ${event['status']} - Published: ${event['isPublished']}');
        }

        if (mounted) {
          setState(() {
            _allEvents = events;
            _filteredResults = List.from(events);
            _isLoading = false;
            _error = null;
          });
          _applyFilters();
        }
      },
      onError: (error) {
        print('SearchScreen: Error loading events: $error');

        String errorMessage = 'Failed to load events';
        if (error.toString().contains('failed-precondition')) {
          errorMessage =
              'Database configuration issue. Please contact support.';
        } else if (error.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please check your authentication.';
        } else if (error.toString().contains('unavailable')) {
          errorMessage =
              'Service temporarily unavailable. Please try again later.';
        } else {
          errorMessage = 'Failed to load events: ${error.toString()}';
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = errorMessage;
            _allEvents = [];
            _filteredResults = [];
          });
        }
      },
    );
  }

  void _loadDebugData() {
    setState(() {
      _isLoading = true;
      _error = null;
      _debugMode = true;
    });

    print('SearchScreen: Loading debug data (all events with status)...');

    // Listen to all events for debugging
    _eventsSubscription?.cancel();
    _eventsSubscription = _userEventsService.getApprovedEvents().listen(
      (events) {
        print(
            'SearchScreen: DEBUG MODE - Received ${events.length} total events');
        if (mounted) {
          setState(() {
            _allEvents = events;
            _filteredResults = List.from(events);
            _isLoading = false;
            _error = null;
          });
          _applyFilters();
        }
      },
      onError: (error) {
        print('SearchScreen: DEBUG MODE - Error loading events: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Failed to load debug events: $error';
          });
        }
      },
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Set new timer for debounced search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });

        if (query.isNotEmpty) {
          _generateSuggestions(query);
          _performSearch(query);
        } else {
          setState(() {
            _searchSuggestions.clear();
            _filteredResults = List.from(_allEvents);
          });
          _applyFilters();
        }
      }
    });
  }

  void _generateSuggestions(String query) {
    final suggestions = <String>{};

    for (final event in _allEvents) {
      final title = event['title']?.toString().toLowerCase() ?? '';
      final category = event['category']?.toString().toLowerCase() ?? '';
      final location = event['location']?.toString().toLowerCase() ?? '';
      final organizer = event['organizerName']?.toString().toLowerCase() ?? '';

      if (title.contains(query)) suggestions.add(event['title']);
      if (category.contains(query)) suggestions.add(event['category']);
      if (location.contains(query)) suggestions.add(event['location']);
      if (organizer.contains(query))
        suggestions.add(event['organizerName'] ?? 'Unknown');
    }

    setState(() {
      _searchSuggestions = suggestions.take(5).toList();
    });
  }

  void _performSearch(String query) {
    final results = _allEvents.where((event) {
      final title = event['title']?.toString().toLowerCase() ?? '';
      final category = event['category']?.toString().toLowerCase() ?? '';
      final location = event['location']?.toString().toLowerCase() ?? '';
      final description = event['description']?.toString().toLowerCase() ?? '';
      final organizer = event['organizerName']?.toString().toLowerCase() ?? '';

      return title.contains(query) ||
          category.contains(query) ||
          location.contains(query) ||
          description.contains(query) ||
          organizer.contains(query);
    }).toList();

    setState(() {
      _filteredResults = results;
    });
    _applyFilters();
  }

  void _applyFilters() {
    var results = List<Map<String, dynamic>>.from(
        _searchQuery.isEmpty ? _allEvents : _filteredResults);

    // Category filter
    if (_selectedCategory != null && _selectedCategory != 'All Categories') {
      results = results
          .where((event) => event['category']?.toString() == _selectedCategory)
          .toList();
    }

    // Location filter
    if (_selectedLocation != null && _selectedLocation != 'All Locations') {
      results = results
          .where((event) => event['location']?.toString() == _selectedLocation)
          .toList();
    }

    // Date range filter
    if (_selectedDateRange != null) {
      results = results.where((event) {
        final eventDate = _parseEventDate(event['eventDate']);
        if (eventDate == null) return false;

        return eventDate.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            eventDate
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Price range filter (if price field exists)
    results = results.where((event) {
      final price = _parsePrice(event['price']) ?? 0.0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Sort results
    _sortResults(results);

    setState(() {
      _filteredResults = results;
    });
  }

  DateTime? _parseEventDate(dynamic date) {
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

  double? _parsePrice(dynamic price) {
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

  void _sortResults(List<Map<String, dynamic>> results) {
    switch (_sortBy) {
      case 'date_asc':
        results.sort((a, b) {
          final dateA = _parseEventDate(a['eventDate']);
          final dateB = _parseEventDate(b['eventDate']);
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });
        break;
      case 'date_desc':
        results.sort((a, b) {
          final dateA = _parseEventDate(a['eventDate']);
          final dateB = _parseEventDate(b['eventDate']);
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
        break;
      case 'price_asc':
        results.sort((a, b) {
          final priceA = _parsePrice(a['price']) ?? 0;
          final priceB = _parsePrice(b['price']) ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_desc':
        results.sort((a, b) {
          final priceA = _parsePrice(a['price']) ?? 0;
          final priceB = _parsePrice(b['price']) ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'alphabetical':
        results.sort((a, b) {
          final titleA = a['title']?.toString() ?? '';
          final titleB = b['title']?.toString() ?? '';
          return titleA.compareTo(titleB);
        });
        break;
      case 'relevance':
      default:
        // Keep original order for relevance (Firebase already orders by date)
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // In a real app, you would implement pagination here
    // For now, we'll just simulate having no more data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage++;
          // Simulate no more data after a few pages
          if (_currentPage > 3) {
            _hasMoreData = false;
          }
        });
      }
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
      _filteredResults = List.from(_allEvents);
    });
    _applyFilters();
  }

  void _resetAll() {
    _searchController.clear();
    _clearFilters();
    setState(() {
      _searchQuery = '';
      _filteredResults = List.from(_allEvents);
      _error = null;
    });
    // Reload data if there was an error
    if (_error != null) {
      _loadInitialData();
    }
  }

  List<String> get _availableCategories {
    final categories = _allEvents
        .map((event) => event['category']?.toString() ?? 'Other')
        .toSet()
        .toList();
    categories.sort();
    return ['All Categories', ...categories];
  }

  List<String> get _availableLocations {
    final locations = _allEvents
        .map((event) => event['location']?.toString() ?? 'Unknown')
        .toSet()
        .toList();
    locations.sort();
    return ['All Locations', ...locations];
  }

  List<String> get _sortOptions {
    return [
      'relevance',
      'date_asc',
      'date_desc',
      'price_asc',
      'price_desc',
      'alphabetical'
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _debugMode ? 'Search Events (Debug)' : 'Search Events',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Debug toggle button
          IconButton(
            icon: Icon(
              _debugMode ? Icons.bug_report : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              if (_debugMode) {
                setState(() => _debugMode = false);
                _loadInitialData();
              } else {
                _loadDebugData();
              }
            },
            tooltip: _debugMode
                ? 'Switch to Normal Mode'
                : 'Debug Mode (Show All Events)',
          ),
          // Filter toggle button
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
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
              availableCategories: _availableCategories,
              availableLocations: _availableLocations,
              sortOptions: _sortOptions,
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
              onPriceRangeChanged: (values) =>
                  setState(() => _priceRange = values),
              onPriceRangeChangeEnd: (values) => _applyFilters(),
              onSortChanged: (value) {
                if (value != null) {
                  // Find the sort option that matches the display name
                  final sortValue = _sortOptions.firstWhere(
                    (option) =>
                        SearchScreenWidgets.getSortDisplayName(option) == value,
                    orElse: () => 'relevance',
                  );
                  setState(() => _sortBy = sortValue);
                  _applyFilters();
                }
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
              error: _error,
            ),
          ),
        ],
      ),
      floatingActionButton: _debugMode
          ? FloatingActionButton(
              onPressed: _showDebugMenu,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.build, color: Colors.white),
              tooltip: 'Debug Tools',
            )
          : null,
    );
  }

  void _showDebugMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Debug Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('Create Test Approved Events'),
                onTap: () {
                  Navigator.pop(context);
                  _createTestApprovedEvents();
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending, color: Colors.orange),
                title: const Text('Create Test Pending Events'),
                onTap: () {
                  Navigator.pop(context);
                  _createTestPendingEvents();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('Check Firebase Status'),
                onTap: () {
                  Navigator.pop(context);
                  _checkFirebaseStatus();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete All Test Events'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAllTestEvents();
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified, color: Colors.green),
                title: const Text('Debug Approved Events'),
                onTap: () {
                  Navigator.pop(context);
                  _debugApprovedEvents();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('Create Multiple Test Approved Events'),
                onTap: () {
                  Navigator.pop(context);
                  _createMultipleTestApprovedEvents();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('Create Single Test Approved Event'),
                onTap: () {
                  Navigator.pop(context);
                  _createApprovedEventViaUserService();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _createTestApprovedEvents() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating test approved events...')),
    );

    await _testEventsService.createTestApprovedEvents();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test approved events created!')),
    );
  }

  void _createTestPendingEvents() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating test pending events...')),
    );

    await _testEventsService.createTestPendingEvents();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test pending events created!')),
    );
  }

  void _checkFirebaseStatus() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking Firebase status...')),
    );

    await _testEventsService.checkFirebaseStatus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Firebase status checked (see console logs)')),
    );
  }

  void _deleteAllTestEvents() async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete ALL events? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  const Text('Delete All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleting all test events...')),
      );

      await _testEventsService.deleteAllTestEvents();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All test events deleted!')),
      );
    }
  }

  Future<void> _debugApprovedEvents() async {
    try {
      print('=== DEBUG: Checking approved events via UserEventsService ===');

      // Call the debug method from UserEventsService
      await _userEventsService.debugEventStatuses();

      // Also check current state
      print('Current loaded events: ${_allEvents.length}');
      print('Current filtered events: ${_filteredResults.length}');
      print('Is loading: $_isLoading');
      print('Error: $_error');

      // Show a snackbar with summary
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Debug complete. Check console for details. Found ${_allEvents.length} loaded events.'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error in debug approved events: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e is FirebaseException ? '${e.code}: ${e.message}' : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _createApprovedEventViaUserService() async {
    try {
      print('Creating approved event via UserEventsService...');

      // Call the test method from UserEventsService
      await _userEventsService.createTestApprovedEvent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test approved event created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error creating approved event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e is FirebaseException ? '${e.code}: ${e.message}' : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _createMultipleTestApprovedEvents() async {
    try {
      print('Creating multiple approved events via UserEventsService...');

      // Call the test method from UserEventsService
      await _userEventsService.createMultipleTestApprovedEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Multiple test approved events created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating test events: ${e.toString()}');
      if (mounted) {
        final message = e is FirebaseException 
          ? 'Failed: ${e.code}' 
          : 'Operation failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
