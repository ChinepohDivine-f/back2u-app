import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/views/search/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:back2u/models/report_model.dart';
import 'dart:async';

import 'package:back2u/services/report_search_service.dart';
import 'package:back2u/l10n/app_localizations.dart';

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
  Timer? _debounce; // debounce for remote suggestions
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
    _debounce?.cancel();
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
              SnackBar(content: Text(AppLocalizations.of(context).errorLoadingReports(error.toString()))),
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
          SnackBar(content: Text(AppLocalizations.of(context).errorLoadingFilterOptions(error.toString()))),
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
    final input = _searchController.text.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      if (!mounted) return;

      List<String> remote = [];
      if (input.isNotEmpty) {
        // Only fetch suggestions by owner name
        remote = await _searchService.fetchSearchSuggestions(
          input: input,
        );
      }

      setState(() {
        if (input.isNotEmpty) {
          final local = _searchHistory.where((h) => h.contains(input));
          _searchSuggestions = {...remote, ...local}.toList();
        } else {
          _searchSuggestions = [];
        }
      });
    });
  }

  void _onSearchFocusChanged() {
    setState(() {
      // Rebuild to show/hide suggestions based on focus
    });
  }

  void _performSearch([String? queryOverride]) async {
    final query = (queryOverride ?? _searchController.text).trim();
    if (query.isEmpty) return;

    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );

    _searchFocusNode.unfocus();
    _searchSuggestions = [];

    // Add to search history if not already present
    if (!_searchHistory.any((h) => h.toLowerCase() == query.toLowerCase())) {
      setState(() {
        if (_searchHistory.length >= 10) {
          _searchHistory.removeAt(0);
        }
        _searchHistory.add(query);
        _searchHistory.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      });
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _currentQuery = query;
    });

    // Only search by owner name
    await _searchService.searchByOwnerName(query);
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
    final l10n = AppLocalizations.of(context);
    
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
                l10n.startTypingToSearch,
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
              l10n.fetchingReports,
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
        message = l10n.noResultsFound;
      } else {
        // This case should ideally not be reached if _hasSearched is true,
        // unless a search with no query/filters also yields no results.
        message = l10n.noReportsFound;
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
    final l10n = AppLocalizations.of(context);
    bool showSuggestionsOrHistory = _searchFocusNode.hasFocus &&
        (_searchController.text.isNotEmpty || _searchHistory.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchLostFound),
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
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: l10n.searchByOwner,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    tooltip: l10n.filterSearch,
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.recentSearches,
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