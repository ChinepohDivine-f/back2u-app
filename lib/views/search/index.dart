import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/views/search/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
// import 'package:your_app_name/filter_bottom_sheet.dart'; // <--- IMPORTANT: Update this import path!

// --- Your SimpleCard Widget (exactly as you provided it) ---
// I'm including it here for a self-contained example,
// but in your actual project, it would be in its own file (e.g., simple_card.dart)

// --- Report Data Model for Lost Documents (remains the same) ---
class ReportData {
  final String ownerName;
  final String subCategory;
  final String type;
  final String location;
  final String description;
  final DateTime incidentDate;
  final int imageCount;
  final bool isResolved;
  final DateTime reportDate; // New field for report date

  ReportData({
    required this.ownerName,
    required this.subCategory,
    required this.type,
    required this.location,
    this.description = '',
    required this.incidentDate,
    this.imageCount = 0,
    this.isResolved = false,
    required this.reportDate,
  });

  bool containsQuery(String query) {
    return ownerName.toLowerCase().contains(query) ||
        subCategory.toLowerCase().contains(query) ||
        type.toLowerCase().contains(query) ||
        location.toLowerCase().contains(query) ||
        description.toLowerCase().contains(query);
  }
}

// --- Dummy Data (remains the same) ---
final List<ReportData> _dummySystemData = [
  ReportData(
    ownerName: 'National ID - John Doe',
    subCategory: 'National ID',
    type: 'Lost',
    location: 'Buea',
    incidentDate: DateTime(2025, 5, 10),
    description: 'Lost near UB gate. Contains ID card and student card.',
    imageCount: 1,
    isResolved: false,
    reportDate: DateTime(2025, 5, 11), // Added reportDate
    // reportDate: DateTime(2025, 5, 11), // Added reportDate
  ),
  ReportData(
    ownerName: 'Passport - Jane Smith',
    subCategory: 'Passport',
    type: 'Lost',
    location: 'Limbe',
    incidentDate: DateTime(2025, 5, 8),
    description: 'Lost at Down Beach. Cameroonian passport.',
    imageCount: 2,
    isResolved: true,
    reportDate: DateTime(2025, 5, 9), // Added reportDate
  ),
  ReportData(
    ownerName: 'Driving License - Peter Obi',
    subCategory: 'Driving License',
    type: 'Found',
    location: 'Buea',
    incidentDate: DateTime(2025, 5, 15),
    description: 'Found near the main market, laminated.',
    imageCount: 0,
    isResolved: false,
    reportDate: DateTime(2025, 5, 16), // Added reportDate
  ),
  ReportData(
    ownerName: 'Birth Certificate - Mary Anne',
    subCategory: 'Birth Certificate',
    type: 'Lost',
    location: 'Kumba',
    incidentDate: DateTime(2025, 5, 12),
    description: 'Original birth certificate, dated 1995.',
    imageCount: 1,
    isResolved: false,
    reportDate: DateTime(2025, 5, 13), // Added reportDate
  ),
  ReportData(
    ownerName: 'University Diploma - David King',
    subCategory: 'Diploma',
    type: 'Lost',
    location: 'Douala',
    incidentDate: DateTime(2025, 5, 7),
    description: 'Lost after graduation ceremony.',
    imageCount: 1,
    isResolved: true,
    reportDate: DateTime(2025, 5, 8), // Added reportDate
  ),
  ReportData(
    ownerName: 'Marriage Certificate - Fam. Nsom',
    subCategory: 'Marriage Certificate',
    type: 'Found',
    location: 'Yaounde',
    incidentDate: DateTime(2025, 5, 18),
    description: 'Found near Ngoa-Ekelle. Sealed envelope.',
    imageCount: 3,
    isResolved: false,
    reportDate: DateTime(2025, 5, 19), // Added reportDate
  ),
  ReportData(
    ownerName: 'GCE Certificate - Limbe',
    subCategory: 'GCE Certificate',
    type: 'Found',
    location: 'Buea',
    incidentDate: DateTime(2025, 5, 17),
    description: 'Found opposite UB Molyko main gate.',
    imageCount: 0,
    isResolved: false,
    reportDate: DateTime(2025, 5, 18), // Added reportDate
  ),
  ReportData(
    ownerName: 'National ID - Aisha Bello',
    subCategory: 'National ID',
    type: 'Lost',
    location: 'Limbe',
    incidentDate: DateTime(2025, 5, 9),
    description: 'Lost at a café, in a brown wallet.',
    imageCount: 1,
    isResolved: false,
    reportDate: DateTime(2025, 5, 10), // Added reportDate
  ),
  ReportData(
    ownerName: 'Voter ID - Samuel Tchoupo',
    subCategory: 'Voter ID',
    type: 'Lost',
    location: 'Buea',
    incidentDate: DateTime(2025, 5, 14),
    description: 'Lost during a political rally.',
    imageCount: 0,
    isResolved: false,
    reportDate: DateTime(2025, 5, 15), // Added reportDate
  ),];

// --- Main Search Page Widget ---
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentQuery = '';
  List<ReportData> _filteredData = [];
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];

  String? _filterType;
  String? _filterDocumentType;
  String? _filterLocation;
  bool? _filterIsResolved;

  List<String> get _reportTypes => ['Lost', 'Found'];
  List<String> get _documentTypes {
    return _dummySystemData.map((e) => e.subCategory).toSet().toList()..sort();
  }

  List<String> get _locations {
    return _dummySystemData.map((e) => e.location).toSet().toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _loadSearchHistory();
    _filteredData = List.from(_dummySystemData);
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
    setState(() {
      _searchHistory = [
        'national id',
        'passport',
        'driving license',
        'birth certificate'
      ];
    });
  }

  void _onSearchQueryChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _currentQuery = query;
      if (query.isNotEmpty) {
        _searchSuggestions = _dummySystemData
            .where((item) => item.containsQuery(query))
            .map((item) => item.ownerName)
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
      _filteredData = _dummySystemData.where((item) {
        bool matchesQuery = item.containsQuery(query);
        bool matchesFilterType =
            _filterType == null || item.type == _filterType;
        bool matchesFilterDocumentType = _filterDocumentType == null ||
            item.subCategory == _filterDocumentType;
        bool matchesFilterLocation =
            _filterLocation == null || item.location == _filterLocation;
        bool matchesFilterIsResolved =
            _filterIsResolved == null || item.isResolved == _filterIsResolved;

        return matchesQuery &&
            matchesFilterType &&
            matchesFilterDocumentType &&
            matchesFilterLocation &&
            matchesFilterIsResolved;
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _currentQuery = '';
      _filteredData = List.from(_dummySystemData);
      _searchSuggestions = [];
      _filterType = null;
      _filterDocumentType = null;
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
          initialFilterDocumentType: _filterDocumentType,
          initialFilterLocation: _filterLocation,
          initialFilterIsResolved: _filterIsResolved,
          reportTypes: _reportTypes,
          documentTypes: _documentTypes,
          locations: _locations,
          onApplyFilters: (type, docType, location, isResolved) {
            setState(() {
              _filterType = type;
              _filterDocumentType = docType;
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
          _filterDocumentType != null ||
          _filterLocation != null ||
          _filterIsResolved != null) {
        message = 'No results found matching your criteria.';
      } else {
        message =
            'Start typing to search or use filters to find lost documents.';
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
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 40),
      separatorBuilder: (context, index) => const SizedBox(
        height: 1,
      ),
      itemBuilder: (context, index) {
        final cardInfo = _filteredData[index];
        return SimpleCard(
          ownerName: cardInfo.ownerName,
          subCategory: cardInfo.subCategory,
          type: cardInfo.type,
          location: cardInfo.location,
          imageCount: cardInfo.imageCount,
          incidentDate: cardInfo.incidentDate,
          isResolved: cardInfo.isResolved,
          reportDate: cardInfo.reportDate, // Use the new reportDate field
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Documents'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary, // Use primary color from theme
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
                      hintText: 'Search for documents...',
                      prefixIcon: const Icon(Icons.search),
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

// --- Main App for demonstration (needed to run the SearchPage) ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost Documents Finder',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SearchPage(),
    );
  }
}
