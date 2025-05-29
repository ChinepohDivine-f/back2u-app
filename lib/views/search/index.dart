import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/views/search/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:back2u/models/report_model.dart'; // Import your Report model
import 'package:back2u/views/home/index.dart'; // Import reportData from your Home page for now
import 'package:back2u/components/report_details.dart'; // Import ReportDetails

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentQuery = '';
  List<Report> _filteredData = []; // Now using List<Report>
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];

  String? _filterType;
  String? _filterCategory; // Changed from _filterDocumentType to _filterCategory
  String? _filterLocation;
  bool? _filterIsResolved;

  // Use properties from the Report model for filter options
  List<String> get _reportTypes => ['Lost', 'Found'];
  List<String> get _categories {
    return reportData.map((e) => e.category).toSet().toList()..sort();
  }

  List<String> get _locations {
    return reportData.map((e) => e.locationLost).toSet().toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _loadSearchHistory();
    _filteredData = List.from(reportData); // Initialize with all reports
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchQueryChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
      if (query.isNotEmpty) {
        _searchSuggestions = reportData
            .where((item) => _reportContainsQuery(item, query)) // Use Report for suggestion
            .map((item) => item.documentName) // Suggest document name or owner name
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

  // Helper method to check if a Report contains the query
  bool _reportContainsQuery(Report report, String query) {
    return (report.ownerName?.toLowerCase().contains(query) ?? false) ||
        report.documentName.toLowerCase().contains(query) ||
        report.category.toLowerCase().contains(query) ||
        report.subcategory.toLowerCase().contains(query) ||
        report.locationLost.toLowerCase().contains(query) ||
        report.subLocationLost.toLowerCase().contains(query) ||
        report.notes.toLowerCase().contains(query);
  }

  void _performSearch([String? queryOverride]) {
    final query = (queryOverride ?? _searchController.text).toLowerCase();

    _searchSuggestions = [];
    _searchFocusNode.unfocus();

    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        if (_searchHistory.length >= 10) {
          _searchHistory.removeAt(0);
        }
        _searchHistory.add(query);
      });
    }

    setState(() {
      _filteredData = reportData.where((item) {
        bool matchesQuery = _reportContainsQuery(item, query);
        bool matchesFilterType =
            _filterType == null || item.type.toLowerCase() == _filterType?.toLowerCase();
        bool matchesFilterCategory = _filterCategory == null ||
            item.category.toLowerCase() == _filterCategory?.toLowerCase();
        bool matchesFilterLocation =
            _filterLocation == null || item.locationLost.toLowerCase() == _filterLocation?.toLowerCase();
        bool matchesFilterIsResolved =
            _filterIsResolved == null || item.resolved == _filterIsResolved;

        return matchesQuery &&
            matchesFilterType &&
            matchesFilterCategory && // Corrected filter name
            matchesFilterLocation &&
            matchesFilterIsResolved;
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _currentQuery = '';
      _filteredData = List.from(reportData); // Reset to all reports
      _searchSuggestions = [];
      _filterType = null;
      _filterCategory = null; // Corrected filter name
      _filterLocation = null;
      _filterIsResolved = null;
      _searchFocusNode.unfocus();
    });
  }

  void _applyFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FilterBottomSheet(
          initialFilterType: _filterType,
          initialFilterDocumentType: _filterCategory, // Pass category to documentType
          initialFilterLocation: _filterLocation,
          initialFilterIsResolved: _filterIsResolved,
          reportTypes: _reportTypes,
          documentTypes: _categories, // Pass categories to documentTypes
          locations: _locations,
          onApplyFilters: (type, docType, location, isResolved) {
            setState(() {
              _filterType = type;
              _filterCategory = docType; // Assign docType back to category
              _filterLocation = location;
              _filterIsResolved = isResolved;
            });
            _performSearch();
          },
        );
      },
    );
  }

  Widget _buildReportsList() {
    if (_filteredData.isEmpty) {
      String message;
      if (_currentQuery.isNotEmpty ||
          _filterType != null ||
          _filterCategory != null || // Corrected filter name
          _filterLocation != null ||
          _filterIsResolved != null) {
        message = 'No results found matching your criteria.';
      } else {
        message =
            'Start typing to search or use filters to find lost and found items.';
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
      itemCount: _filteredData.length,
      
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 40),
      separatorBuilder: (context, index) => const SizedBox(
        height: 1,
      ),
      itemBuilder: (context, index) {
        final report = _filteredData[index];
        return SimpleCard(
          onTap: () {
            // Navigate to ReportDetails, passing the Report object
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetails(report: report), // Pass the Report object
              ),
            );
          },
          report: report, // Pass the Report object
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