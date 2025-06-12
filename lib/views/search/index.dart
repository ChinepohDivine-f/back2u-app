import 'package:back2u/components/SimpleCard.dart';
        import 'package:back2u/views/search/filter_bottom_sheet.dart';
        import 'package:flutter/material.dart';
        import 'package:back2u/models/report_model.dart';
        import 'package:back2u/components/report_details.dart';
        import 'dart:async';

        import 'package:back2u/services/report_search_service.dart';

        class SearchPage extends StatefulWidget {
          const SearchPage({super.key});

          @override
          State<SearchPage> createState() => _SearchPageState();
        }

        class _SearchPageState extends State<SearchPage> {
          final ReportSearchService _searchService = ReportSearchService();
          StreamSubscription<List<Report>>? _filteredReportsSubscription;
          StreamSubscription<Map<String, List<String>>>? _filterOptionsSubscription;

          final TextEditingController _searchController = TextEditingController();
          final FocusNode _searchFocusNode = FocusNode();
          String _currentQuery = ''; // Actual query submitted for search
          List<Report> _displayedReports = []; // Data currently displayed
          bool _isLoading = false; // Track loading state for search results
          bool _hasSearched = false; // Track if a search has been performed

          // For search history and suggestions
          List<String> _searchHistory = []; // In a real app, load from SharedPreferences
          List<String> _searchSuggestions = []; // Dynamic suggestions based on current query input

          // Filter states (passed to service and FilterBottomSheet)
          String? _filterType;
          String? _filterCategory;
          String? _filterSubCategory;
          String? _filterLocation;
          String? _filterSubLocation;
          bool? _filterIsResolved;

          // Dynamic filter options from service
          List<String> _availableCategories = [];
          List<String> _availableLocations = [];
          // No longer need to store all subcategories/sublocations here,
          // as they are fetched on demand for the bottom sheet.
          final List<String> _reportTypes = ['Lost', 'Found']; // These are static

          @override
          void initState() {
            super.initState();
            _searchController.addListener(_onSearchQueryChanged);
            _searchFocusNode.addListener(_onSearchFocusChanged);
            _loadSearchHistory();

            _listenToFilteredReports();
            _listenToFilterOptions();

            // No initial _performSearch() here. Results will only show after user input.
          }

          @override
          void dispose() {
            _searchController.removeListener(_onSearchQueryChanged);
            _searchFocusNode.removeListener(_onSearchFocusChanged);
            _searchController.dispose();
            _searchFocusNode.dispose();
            _filteredReportsSubscription?.cancel();
            _filterOptionsSubscription?.cancel();
            _searchService.dispose();
            super.dispose();
          }

          void _listenToFilteredReports() {
            _filteredReportsSubscription = _searchService.filteredReportsStream.listen(
              (reports) {
                if (mounted) {
                  setState(() {
                    _displayedReports = reports;
                    _isLoading = false;
                  });
                }
              },
              onError: (error) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error loading reports: $error')),
                    );
                  });
                }
                debugPrint('Error in filtered reports stream: $error');
              },
            );
          }

          void _listenToFilterOptions() {
            _filterOptionsSubscription = _searchService.filterOptionsStream.listen(
              (options) {
                if (mounted) {
                  setState(() {
                    _availableCategories = options['categories'] ?? [];
                    _availableLocations = options['locations'] ?? [];
                    // _availableSubCategories and _availableSubLocations are NOT needed here anymore
                    // as they are dynamically passed to the bottom sheet.
                  });
                }
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading filter options: $error')),
                );
                debugPrint('Error fetching filter options: $error');
              },
            );
          }

          void _loadSearchHistory() {
            setState(() {
              _searchHistory = [      
              ];
              _searchHistory.sort();
            });
          }

          void _onSearchQueryChanged() {
            final input = _searchController.text.toLowerCase();
            setState(() {
              if (input.isNotEmpty) {
                _searchSuggestions = _searchHistory
                    .where((item) => item.toLowerCase().contains(input))
                    .toSet()
                    .take(5)
                    .toList();
                _searchSuggestions.sort();
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

          void _performSearch([String? queryOverride]) {
            final query = (queryOverride ?? _searchController.text);
            _searchController.text = query;
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: _searchController.text.length),
            );

            _searchFocusNode.unfocus();
            _searchSuggestions = [];

            if (query.isNotEmpty && !_searchHistory.contains(query.toLowerCase())) {
              setState(() {
                if (_searchHistory.length >= 10) {
                  _searchHistory.removeAt(0);
                }
                _searchHistory.add(query.toLowerCase());
                _searchHistory.sort();
              });
            }

            setState(() {
              _isLoading = true;
              _hasSearched = true;
              _currentQuery = query;
            });

            _searchService.applySearchAndFilters(
              currentQuery: _currentQuery,
              filterType: _filterType,
              filterCategory: _filterCategory,
              filterSubCategory: _filterSubCategory,
              filterLocation: _filterLocation,
              filterSubLocation: _filterSubLocation,
              filterIsResolved: _filterIsResolved,
            );
          }

          void _clearSearch() {
            setState(() {
              _searchController.clear();
              _currentQuery = '';
              _filterType = null;
              _filterCategory = null;
              _filterSubCategory = null;
              _filterLocation = null;
              _filterSubLocation = null;
              _filterIsResolved = null;
              _searchSuggestions = [];
              _searchFocusNode.unfocus();
              _hasSearched = false;
              _displayedReports = [];
            });
          }

          void _applyFilters(BuildContext context) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return FilterBottomSheet(
                  searchService: _searchService, // Pass the service instance
                  initialFilterType: _filterType,
                  initialFilterCategory: _filterCategory,
                  initialFilterSubCategory: _filterSubCategory,
                  initialFilterLocation: _filterLocation,
                  initialFilterSubLocation: _filterSubLocation,
                  initialFilterIsResolved: _filterIsResolved,
                  reportTypes: _reportTypes,
                  availableCategories: _availableCategories,
                  availableLocations: _availableLocations,
                  onApplyFilters: (type, cat, subCat, loc, subLoc, isResolved) {
                    setState(() {
                      _filterType = type;
                      _filterCategory = cat;
                      _filterSubCategory = subCat;
                      _filterLocation = loc;
                      _filterSubLocation = subLoc;
                      _filterIsResolved = isResolved;
                    });
                    _performSearch();
                  },
                );
              },
            );
          }

          Widget _buildSearchResultsContent() {
            if (!_hasSearched) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Start typing to search for lost or found items, or use filters to narrow down results.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }

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
                  _filterSubCategory != null ||
                  _filterLocation != null ||
                  _filterSubLocation != null ||
                  _filterIsResolved != null) {
                message = 'No results found matching your criteria.';
              } else {
                // This case should ideally not be reached if _hasSearched is true,
                // unless a search with no query/filters also yields no results.
                message = 'No reports found. Try a different search or adjust your filters.';
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
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
                  //todo: i might use this later
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ReportDetails(report: report),
                  //     ),
                  //   );
                  // },
                  report: report,
                );
              },
            );
          }

          @override
          Widget build(BuildContext context) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            bool showSuggestionsOrHistory = _searchFocusNode.hasFocus &&
                (_searchController.text.isNotEmpty || _searchHistory.isNotEmpty);

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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Search by owner, document, location...',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.search, color: Colors.black54),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: _clearSearch,
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                              ),
                              onSubmitted: (query) {
                                _performSearch(query);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: colorScheme.primary,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: IconButton(
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            onPressed: () => _applyFilters(context),
                            tooltip: 'Filter Search',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: showSuggestionsOrHistory
                        ? (_searchController.text.isNotEmpty && _searchSuggestions.isNotEmpty
                            ? _buildSuggestionsList()
                            : (_searchController.text.isEmpty && _searchHistory.isNotEmpty
                                ? _buildSearchHistoryList()
                                : const SizedBox.shrink()
                              )
                          )
                        : _buildSearchResultsContent(),
                  ),
                ],
              ),
            );
          }

          Widget _buildSuggestionsList() {
            return ListView.builder(
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
            );
          }

          Widget _buildSearchHistoryList() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            );
          }
        }