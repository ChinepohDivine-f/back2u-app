import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/views/search/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:back2u/models/report_model.dart'; // Import your Report model
import 'package:back2u/components/report_details.dart'; // Import ReportDetails
import 'dart:async'; // For StreamSubscription

// NEW: Import the ReportSearchService
import 'package:back2u/services/report_search_service.dart';

// Removed: import 'package:back2u/views/home/index.dart'; // No longer importing reportData from Home

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // NEW: Instance of the search service
  final ReportSearchService _searchService = ReportSearchService();
  // NEW: Stream subscriptions for filtered reports and filter options
  StreamSubscription<List<Report>>? _filteredReportsSubscription;
  StreamSubscription<Map<String, List<String>>>? _filterOptionsSubscription;


  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentQuery = '';
  List<Report> _displayedReports = []; // Data currently displayed
  bool _isLoading = true; // Track loading state

  // For search history and suggestions
  List<String> _searchHistory = []; // In a real app, load from SharedPreferences
  List<String> _searchSuggestions = []; // Dynamic suggestions based on current query

  // Filter states
  String? _filterType;
  String? _filterCategory;
  String? _filterLocation;
  bool? _filterIsResolved;

  // Dynamic filter options from service
  List<String> _availableCategories = [];
  List<String> _availableLocations = [];
  final List<String> _reportTypes = ['Lost', 'Found']; // These are static

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _loadSearchHistory();

    // NEW: Listen to streams from the search service
    _listenToFilteredReports();
    _listenToFilterOptions();

    // Initial search to load all reports
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchQueryChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _filteredReportsSubscription?.cancel(); // Cancel subscription
    _filterOptionsSubscription?.cancel(); // Cancel subscription
    _searchService.dispose(); // Dispose the service
    super.dispose();
  }

  // NEW: Method to listen to filtered reports from the service
  void _listenToFilteredReports() {
    _filteredReportsSubscription = _searchService.filteredReportsStream.listen(
      (reports) {
        if (mounted) {
          setState(() {
            _displayedReports = reports;
            _isLoading = false; // Data has been loaded
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading reports: $error')),
          );
        }
        debugPrint('Error in filtered reports stream: $error');
      },
    );
  }

  // NEW: Method to listen to filter options from the service
  void _listenToFilterOptions() {
    _filterOptionsSubscription = _searchService.filterOptionsStream.listen(
      (options) {
        if (mounted) {
          setState(() {
            _availableCategories = options['categories'] ?? [];
            _availableLocations = options['locations'] ?? [];
          });
        }
      },
      onError: (error) {
        debugPrint('Error fetching filter options: $error');
      },
    );
  }

  void _loadSearchHistory() {
    // In a real app, load this from SharedPreferences or similar
    setState(() {
      _searchHistory = [
        'National ID',
        'Passport',
        'Driving License',
        'Birth Certificate'
      ];
    });
  }

  void _onSearchQueryChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _currentQuery = query;
      // Suggestions are now derived from a separate mechanism if needed,
      // or from local cache. For simplicity, we'll keep them basic here.
      // A more advanced suggestion system would live in the service.
      if (query.isNotEmpty) {
        _searchSuggestions = _searchHistory // Or from a pre-defined list
            .where((item) => item.toLowerCase().contains(query))
            .toSet()
            .take(5)
            .toList();
      } else {
        _searchSuggestions = [];
      }
    });
  }

  void _onSearchFocusChanged() {
    setState(() {
      // Rebuild to show/hide suggestions based on focus
    });
  }

  // This method now calls the service to perform the search and filter
  void _performSearch([String? queryOverride]) {
    final query = (queryOverride ?? _searchController.text); // Keep case for display if needed
    _searchController.text = query; // Update controller if queryOverride
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );

    _searchFocusNode.unfocus(); // Unfocus after search
    _searchSuggestions = []; // Clear suggestions

    // Add to history only if it's a new, non-empty query
    if (query.isNotEmpty && !_searchHistory.contains(query.toLowerCase())) {
      setState(() {
        if (_searchHistory.length >= 10) { // Keep history limit
          _searchHistory.removeAt(0);
        }
        _searchHistory.add(query.toLowerCase()); // Store history in lowercase
      });
    }

    setState(() {
      _isLoading = true; // Indicate loading while service processes
    });

    _searchService.applySearchAndFilters(
      currentQuery: query,
      filterType: _filterType,
      filterCategory: _filterCategory,
      filterLocation: _filterLocation,
      filterIsResolved: _filterIsResolved,
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _currentQuery = '';
      _filterType = null;
      _filterCategory = null;
      _filterLocation = null;
      _filterIsResolved = null;
      _searchSuggestions = [];
      _searchFocusNode.unfocus();
    });
    _performSearch(); // Re-run search to show all reports
  }

  void _applyFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FilterBottomSheet(
          initialFilterType: _filterType,
          initialFilterDocumentType: _filterCategory,
          initialFilterLocation: _filterLocation,
          initialFilterIsResolved: _filterIsResolved,
          reportTypes: _reportTypes,
          documentTypes: _availableCategories, // Use dynamic categories
          locations: _availableLocations, // Use dynamic locations
          onApplyFilters: (type, docType, location, isResolved) {
            setState(() {
              _filterType = type;
              _filterCategory = docType;
              _filterLocation = location;
              _filterIsResolved = isResolved;
            });
            _performSearch(); // Re-perform search with new filters
          },
        );
      },
    );
  }

  Widget _buildReportsList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              "Fetching reports...",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }
    if (_displayedReports.isEmpty) {
      String message;
      if (_currentQuery.isNotEmpty ||
          _filterType != null ||
          _filterCategory != null ||
          _filterLocation != null ||
          _filterIsResolved != null) {
        message = 'No results found matching your criteria.';
      } else {
        message = 'Start typing to search or use filters to find lost and found items.';
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _displayedReports.length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 40),
      separatorBuilder: (context, index) => const SizedBox(
        height: 1,
      ),
      itemBuilder: (context, index) {
        final report = _displayedReports[index];
        return SimpleCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetails(report: report),
              ),
            );
          },
          report: report,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Lost & Found'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search by owner, document, location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                    ),
                    onSubmitted: (query) {
                      _performSearch(query);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () => _applyFilters(context),
                    tooltip: 'Filter Search',
                  ),
                ),
              ],
            ),
          ),
          if (_searchFocusNode.hasFocus &&
              _searchController.text.isNotEmpty &&
              _searchSuggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _searchSuggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.search),
                    title: Text(suggestion),
                    onTap: () {
                      _searchController.text = suggestion;
                      _performSearch(suggestion);
                    },
                  );
                },
              ),
            )
          else if (_searchFocusNode.hasFocus &&
              _searchController.text.isEmpty &&
              _searchHistory.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Recent Searches',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem = _searchHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(historyItem),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchHistory.removeAt(index);
                                // No need to re-perform search just for history removal
                              });
                            },
                          ),
                          onTap: () {
                            _searchController.text = historyItem;
                            _performSearch(historyItem);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: _buildReportsList(),
            ),
        ],
      ),
    );
  }
}