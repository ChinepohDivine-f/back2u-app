import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/models/category_model.dart';
import 'package:back2u/models/location_model.dart';
import 'package:back2u/services/form_data_fetch_service.dart';
import 'dart:async';

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class ReportSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DataFetchService _dataFetchService = DataFetchService();

  late final CollectionReference<Map<String, dynamic>> _reportsCollection;

  // Main stream for search results
  final _filteredReportsController = StreamController<List<Report>>.broadcast();
  Stream<List<Report>> get filteredReportsStream =>
      _filteredReportsController.stream;

  // Stream for loading state
  final _loadingStateController = StreamController<bool>.broadcast();
  Stream<bool> get loadingStateStream => _loadingStateController.stream;

  // Stream for error messages
  final _errorStateController = StreamController<String?>.broadcast();
  Stream<String?> get errorStateStream => _errorStateController.stream;

  // Stream for filter options
  final _filterOptionsController =
      StreamController<Map<String, List<String>>>.broadcast();
  Stream<Map<String, List<String>>> get filterOptionsStream =>
      _filterOptionsController.stream;

  // Stream for suggestions loading state
  final _suggestionsLoadingController = StreamController<bool>.broadcast();
  Stream<bool> get suggestionsLoadingStream => _suggestionsLoadingController.stream;

  // Internal state
  List<Report> _allReportsCache = [];
  List<Category> _cachedCategories = [];
  List<Location> _cachedLocations = [];
  StreamSubscription? _reportsSubscription;
  bool _isInitialLoad = true;
  bool _hasData = false;

  // Pagination state
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 15;

  // Filter state
  String _lastQuery = '';
  String? _lastFilterType;
  String? _lastFilterCategory;
  String? _lastFilterSubCategory;
  String? _lastFilterLocation;
  String? _lastFilterSubLocation;
  bool? _lastFilterIsResolved;

  ReportSearchService() {
    _reportsCollection =
        _firestore.collection('back2u/countries/cameroon/data/reports');
    _initializeService();
  }

  // Enhanced search by owner name with pagination
  Future<void> searchByOwnerName(String ownerName, {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _loadingStateController.add(true);
        _errorStateController.add(null);
        _lastDocument = null;
        _hasMore = true;
      } else if (!_hasMore || _isLoadingMore) {
        return;
      }

      _isLoadingMore = true;

      Query query = _reportsCollection
          .where('owner_name', isGreaterThanOrEqualTo: ownerName.toLowerCase())
          .where('owner_name', isLessThan: ownerName.toLowerCase() + '\uf8ff')
          .orderBy('owner_name')
          .orderBy('createdAt', descending: true);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_pageSize);

      final querySnapshot = await query.get();
      final reports = querySnapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();

      if (loadMore) {
        // Append to existing results - we'll need to track current results differently
        final currentReports = _allReportsCache;
        _allReportsCache = [...currentReports, ...reports];
        _filteredReportsController.add(_allReportsCache);
      } else {
        _allReportsCache = reports;
        _filteredReportsController.add(reports);
      }

      // Update pagination state
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        _hasMore = reports.length == _pageSize;
      } else {
        _hasMore = false;
      }

      _lastQuery = ownerName;
    } catch (e) {
      _errorStateController.add('Failed to search by owner: ${e.toString()}');
      if (!loadMore) {
        _filteredReportsController.add([]);
      }
    } finally {
      if (!loadMore) {
        _loadingStateController.add(false);
      }
      _isLoadingMore = false;
    }
  }

  // Enhanced comprehensive search with multiple fields
  Future<void> searchReportsComprehensive({
    String query = '',
    String? filterType,
    String? filterCategory,
    String? filterSubCategory,
    String? filterLocation,
    String? filterSubLocation,
    bool? filterIsResolved,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        _loadingStateController.add(true);
        _errorStateController.add(null);
        _lastDocument = null;
        _hasMore = true;
      } else if (!_hasMore || _isLoadingMore) {
        return;
      }

      _isLoadingMore = true;

      List<Report> reports = [];

      if (query.isNotEmpty) {
        // Try search_key_words first, then fallback to direct field search
        try {
          Query searchQuery = _reportsCollection;

          // Apply filters
          if (filterType != null && filterType.isNotEmpty) {
            searchQuery = searchQuery.where('type', isEqualTo: filterType.toLowerCase());
          }
          if (filterCategory != null && filterCategory.isNotEmpty) {
            searchQuery = searchQuery.where('category', isEqualTo: filterCategory);
          }
          if (filterSubCategory != null && filterSubCategory.isNotEmpty) {
            searchQuery = searchQuery.where('subcategory', isEqualTo: filterSubCategory);
          }
          if (filterLocation != null && filterLocation.isNotEmpty) {
            searchQuery = searchQuery.where('location_lost', isEqualTo: filterLocation);
          }
          if (filterSubLocation != null && filterSubLocation.isNotEmpty) {
            searchQuery = searchQuery.where('sub_location_lost', isEqualTo: filterSubLocation);
          }
          if (filterIsResolved != null) {
            searchQuery = searchQuery.where('resolved', isEqualTo: filterIsResolved);
          }

          // Try search_key_words first
          searchQuery = searchQuery.where('search_key_words', arrayContains: query.toLowerCase());
          
          // Apply pagination
          if (loadMore && _lastDocument != null) {
            searchQuery = searchQuery.startAfterDocument(_lastDocument!);
          }

          // Order by createdAt and limit results
          searchQuery = searchQuery.orderBy('createdAt', descending: true).limit(_pageSize);

          final querySnapshot = await searchQuery.get();
          reports = querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();

          // If no results from search_key_words, try direct field search
          if (reports.isEmpty) {
            reports = await _searchInFieldsDirectly(
              query: query,
              filterType: filterType,
              filterCategory: filterCategory,
              filterSubCategory: filterSubCategory,
              filterLocation: filterLocation,
              filterSubLocation: filterSubLocation,
              filterIsResolved: filterIsResolved,
              loadMore: loadMore,
            );
          }
        } catch (e) {
          // If search_key_words fails, use direct field search
          reports = await _searchInFieldsDirectly(
            query: query,
            filterType: filterType,
            filterCategory: filterCategory,
            filterSubCategory: filterSubCategory,
            filterLocation: filterLocation,
            filterSubLocation: filterSubLocation,
            filterIsResolved: filterIsResolved,
            loadMore: loadMore,
          );
        }
      } else {
        // No search query, just apply filters
        Query searchQuery = _reportsCollection;

        // Apply filters
        if (filterType != null && filterType.isNotEmpty) {
          searchQuery = searchQuery.where('type', isEqualTo: filterType.toLowerCase());
        }
        if (filterCategory != null && filterCategory.isNotEmpty) {
          searchQuery = searchQuery.where('category', isEqualTo: filterCategory);
        }
        if (filterSubCategory != null && filterSubCategory.isNotEmpty) {
          searchQuery = searchQuery.where('subcategory', isEqualTo: filterSubCategory);
        }
        if (filterLocation != null && filterLocation.isNotEmpty) {
          searchQuery = searchQuery.where('location_lost', isEqualTo: filterLocation);
        }
        if (filterSubLocation != null && filterSubLocation.isNotEmpty) {
          searchQuery = searchQuery.where('sub_location_lost', isEqualTo: filterSubLocation);
        }
        if (filterIsResolved != null) {
          searchQuery = searchQuery.where('resolved', isEqualTo: filterIsResolved);
        }

        // Apply pagination
        if (loadMore && _lastDocument != null) {
          searchQuery = searchQuery.startAfterDocument(_lastDocument!);
        }

        // Order by createdAt and limit results
        searchQuery = searchQuery.orderBy('createdAt', descending: true).limit(_pageSize);

        final querySnapshot = await searchQuery.get();
        reports = querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      }

      if (loadMore) {
        final currentReports = _allReportsCache;
        _allReportsCache = [...currentReports, ...reports];
        _filteredReportsController.add(_allReportsCache);
      } else {
        _allReportsCache = reports;
        _filteredReportsController.add(reports);
      }

      // Update pagination state
      if (reports.isNotEmpty) {
        _lastDocument = await _reportsCollection.doc(reports.last.reportId).get();
        _hasMore = reports.length == _pageSize;
      } else {
        _hasMore = false;
      }

      // Update last search state
      _lastQuery = query;
      _lastFilterType = filterType;
      _lastFilterCategory = filterCategory;
      _lastFilterSubCategory = filterSubCategory;
      _lastFilterLocation = filterLocation;
      _lastFilterSubLocation = filterSubLocation;
      _lastFilterIsResolved = filterIsResolved;

    } catch (e) {
      _errorStateController.add('Failed to search reports: ${e.toString()}');
      if (!loadMore) {
        _filteredReportsController.add([]);
      }
    } finally {
      if (!loadMore) {
        _loadingStateController.add(false);
      }
      _isLoadingMore = false;
    }
  }

  // Fallback search method that searches in multiple fields directly
  Future<List<Report>> _searchInFieldsDirectly({
    required String query,
    String? filterType,
    String? filterSubCategory,
    String? filterCategory,
    String? filterLocation,
    String? filterSubLocation,
    bool? filterIsResolved,
    bool loadMore = false,
  }) async {
    final List<Report> allResults = [];
    final Set<String> seenIds = {};
    final lowerQuery = query.toLowerCase();

    // Get all reports and filter in memory (for small datasets)
    final querySnapshot = await _reportsCollection
        .orderBy('createdAt', descending: true)
        .limit(100) // Limit to prevent performance issues
        .get();

    for (final doc in querySnapshot.docs) {
      final report = Report.fromFirestore(doc);
      
      // Apply filters
      if (filterType != null && filterType.isNotEmpty && 
          report.type.toLowerCase() != filterType.toLowerCase()) continue;
      if (filterCategory != null && filterCategory.isNotEmpty && 
          report.category != filterCategory) continue;
      if (filterSubCategory != null && filterSubCategory.isNotEmpty && 
          report.subcategory != filterSubCategory) continue;
      if (filterLocation != null && filterLocation.isNotEmpty && 
          report.locationLost != filterLocation) continue;
      if (filterSubLocation != null && filterSubLocation.isNotEmpty && 
          report.subLocationLost != filterSubLocation) continue;
      if (filterIsResolved != null && report.resolved != filterIsResolved) continue;

      // Search in multiple fields
      final searchableFields = [
        report.ownerName ?? '',
        report.category,
        report.subcategory,
        report.locationLost,
        report.subLocationLost,
        report.notes,
      ];

      bool matches = false;
      for (final field in searchableFields) {
        if (field.toLowerCase().contains(lowerQuery)) {
          matches = true;
          break;
        }
      }

      if (matches && !seenIds.contains(report.reportId)) {
        seenIds.add(report.reportId);
        allResults.add(report);
      }
    }

    // Sort by relevance and date
    allResults.sort((a, b) {
      // Prioritize exact matches
      final aExactMatch = (a.ownerName?.toLowerCase() == lowerQuery) ||
                         (a.category.toLowerCase() == lowerQuery);
      final bExactMatch = (b.ownerName?.toLowerCase() == lowerQuery) ||
                         (b.category.toLowerCase() == lowerQuery);
      
      if (aExactMatch && !bExactMatch) return -1;
      if (!aExactMatch && bExactMatch) return 1;
      
      // Then sort by date
      return b.createdAt.compareTo(a.createdAt);
    });

    // Apply pagination
    return allResults.take(_pageSize).toList();
  }

  // Enhanced search suggestions with better relevance
  Future<List<String>> fetchSearchSuggestions({
    required String input,
    String? filterType,
    String? filterCategory,
    String? filterSubCategory,
    String? filterLocation,
    String? filterSubLocation,
    bool? filterIsResolved,
  }) async {
    try {
      _suggestionsLoadingController.add(true);
      
      if (input.length < 2) {
        return [];
      }

      final List<String> suggestions = [];
      final Map<String, int> suggestionScores = {};

      // Get all reports that match the current filters
      Query baseQuery = _reportsCollection;
      
      if (filterType != null && filterType.isNotEmpty) {
        baseQuery = baseQuery.where('type', isEqualTo: filterType.toLowerCase());
      }
      if (filterCategory != null && filterCategory.isNotEmpty) {
        baseQuery = baseQuery.where('category', isEqualTo: filterCategory);
      }
      if (filterSubCategory != null && filterSubCategory.isNotEmpty) {
        baseQuery = baseQuery.where('subcategory', isEqualTo: filterSubCategory);
      }
      if (filterLocation != null && filterLocation.isNotEmpty) {
        baseQuery = baseQuery.where('location_lost', isEqualTo: filterLocation);
      }
      if (filterSubLocation != null && filterSubLocation.isNotEmpty) {
        baseQuery = baseQuery.where('sub_location_lost', isEqualTo: filterSubLocation);
      }
      if (filterIsResolved != null) {
        baseQuery = baseQuery.where('resolved', isEqualTo: filterIsResolved);
      }

      final querySnapshot = await baseQuery.limit(100).get();

      for (var doc in querySnapshot.docs) {
        final report = Report.fromFirestore(doc);
        
        // Searchable fields with their relevance weights
        final searchableFields = [
          (report.ownerName ?? '', 10), // Highest weight for owner name
          (report.category, 8),
          (report.subcategory, 7),
          (report.locationLost, 6),
          (report.subLocationLost, 5),
          (report.notes, 3),
        ];

        for (var (field, weight) in searchableFields) {
          if (field.isNotEmpty) {
            final lowerField = field.toLowerCase();
            final lowerInput = input.toLowerCase();
            
            if (lowerField.contains(lowerInput)) {
              // Calculate relevance score
              int score = weight;
              
              // Bonus for exact matches
              if (lowerField == lowerInput) {
                score += 100;
              }
              // Bonus for starts with
              else if (lowerField.startsWith(lowerInput)) {
                score += 50;
              }
              // Bonus for shorter matches (more specific)
              else {
                score += (10 - (lowerField.length - lowerInput.length)).clamp(0, 10);
              }

              // Keep the highest score for each unique suggestion
              if (!suggestionScores.containsKey(field) || 
                  suggestionScores[field]! < score) {
                suggestionScores[field] = score;
              }
            }
          }
        }
      }

      // Sort by relevance score and take top suggestions
      final sortedSuggestions = suggestionScores.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      return sortedSuggestions
          .take(10)
          .map((e) => e.key)
          .toList();

    } catch (e) {
      _errorStateController.add('Failed to fetch suggestions: ${e.toString()}');
      return [];
    } finally {
      _suggestionsLoadingController.add(false);
    }
  }

  // Load more results for pagination
  Future<void> loadMoreResults() async {
    if (_lastQuery.isNotEmpty) {
      await searchReportsComprehensive(
        query: _lastQuery,
        filterType: _lastFilterType,
        filterCategory: _lastFilterCategory,
        filterSubCategory: _lastFilterSubCategory,
        filterLocation: _lastFilterLocation,
        filterSubLocation: _lastFilterSubLocation,
        filterIsResolved: _lastFilterIsResolved,
        loadMore: true,
      );
    }
  }

  // Check if more results are available
  bool get hasMoreResults => _hasMore;

  // Check if currently loading more results
  bool get isLoadingMore => _isLoadingMore;

  // Reset pagination state
  void resetPagination() {
    _lastDocument = null;
    _hasMore = true;
    _isLoadingMore = false;
  }

  Future<void> _initializeService() async {
    try {
      _loadingStateController.add(true);
      _errorStateController.add(null);

      // Fetch initial data
      await Future.wait([
        _listenToAllReports(),
        _fetchAndCacheFormData(),
      ]);

      _hasData = true;
      _isInitialLoad = false;
    } catch (e) {
      _errorStateController
          .add('Failed to initialize search service: ${e.toString()}');
      _hasData = false;
    } finally {
      _loadingStateController.add(false);
    }
  }

  Future<void> _listenToAllReports() async {
    _reportsSubscription = _reportsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      _errorStateController.add('Failed to load reports: ${error.toString()}');
      return Stream.empty();
    }).listen((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        _allReportsCache = [];
        _filteredReportsController.add([]);
        _hasData = false;
        return;
      }

      _allReportsCache =
          querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      _hasData = true;

      // Re-apply last filters if they exist
      if (_lastQuery.isNotEmpty ||
          _lastFilterType != null ||
          _lastFilterCategory != null ||
          _lastFilterSubCategory != null ||
          _lastFilterLocation != null ||
          _lastFilterSubLocation != null ||
          _lastFilterIsResolved != null) {
        // No-op: Only owner name search is supported now.
      } else {
        _filteredReportsController.add(_allReportsCache);
      }
    });
  }

  Future<void> _fetchAndCacheFormData() async {
    try {
      final results = await Future.wait([
        _dataFetchService.fetchCategories(),
        _dataFetchService.fetchLocations(),
      ]);

      _cachedCategories = results[0] as List<Category>;
      _cachedLocations = results[1] as List<Location>;
      _updateFilterOptions();
    } catch (e) {
      _errorStateController
          .add('Failed to load filter options: ${e.toString()}');
      rethrow;
    }
  }

  void _updateFilterOptions() {
    try {
      final categories = <String>{};
      final subcategories = <String>{};
      final locations = <String>{};
      final sublocations = <String>{};

      for (var cat in _cachedCategories) {
        categories.add(cat.nameEn);
        for (var subCat in cat.subcategories) {
          subcategories.add(subCat.nameEn);
        }
      }

      for (var loc in _cachedLocations) {
        locations.add(loc.nameEn);
        for (var subLoc in loc.sublocations) {
          sublocations.add(subLoc.nameEn);
        }
      }

      _filterOptionsController.add({
        'categories': categories.toList()..sort(),
        'subcategories': subcategories.toList()..sort(),
        'locations': locations.toList()..sort(),
        'sublocations': sublocations.toList()..sort(),
      });
    } catch (e) {
      _errorStateController
          .add('Failed to update filter options: ${e.toString()}');
    }
  }

  // --- NEW: Firestore-powered search with all filters and keyword search ---
  Future<void> searchReportsWithFilters({
    String currentQuery = '',
    String? filterType,
    String? filterCategory,
    String? filterSubCategory,
    String? filterLocation,
    String? filterSubLocation,
    bool? filterIsResolved,
  }) async {
    try {
      Query query = _reportsCollection;

      // Apply filters
      if (filterType != null && filterType.isNotEmpty) {
        query = query.where('type', isEqualTo: filterType.toLowerCase());
      }
      if (filterCategory != null && filterCategory.isNotEmpty) {
        query = query.where('category', isEqualTo: filterCategory);
      }
      if (filterSubCategory != null && filterSubCategory.isNotEmpty) {
        query = query.where('subcategory', isEqualTo: filterSubCategory);
      }
      if (filterLocation != null && filterLocation.isNotEmpty) {
        query = query.where('location_lost', isEqualTo: filterLocation);
      }
      if (filterSubLocation != null && filterSubLocation.isNotEmpty) {
        query = query.where('sub_location_lost', isEqualTo: filterSubLocation);
      }
      if (filterIsResolved != null) {
        query = query.where('resolved', isEqualTo: filterIsResolved);
      }

      // Apply keyword search (if query is not empty)
      if (currentQuery.isNotEmpty) {
        query = query.where('search_key_words', arrayContains: currentQuery.toLowerCase());
      }

      // Order by createdAt (for consistent results)
      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();
      final reports = querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      _filteredReportsController.add(reports);
    } catch (e) {
      _errorStateController.add('Failed to search reports: ${e.toString()}');
      _filteredReportsController.add([]);
    }
  }

  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>{};

    final List<String?> termsToProcess = [
      r.ownerName,
    ];

    for (var term in termsToProcess) {
      if (term != null && term.isNotEmpty) {
        final cleanedTerm =
            term.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
        final words =
            cleanedTerm.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);

        for (var word in words) {
          keywords.add(word);
          for (int i = 1; i < word.length; i++) {
            keywords.add(word.substring(0, i));
          }
        }
      }
    }
    return keywords.toList();
  }

  List<String> getSubcategoriesForCategory(String categoryName) {
    try {
      final category = _cachedCategories.firstWhereOrNull(
        (cat) => cat.nameEn.toLowerCase() == categoryName.toLowerCase(),
      );
      // return category?.subcategories.map((e) => e.nameEn).toList()..sort() ?? [];
      final subcategories =
          category?.subcategories.map((e) => e.nameEn).toList();
      subcategories?.sort();
      return subcategories ?? [];
    } catch (e) {
      _errorStateController.add('Failed to get subcategories: ${e.toString()}');
      return [];
    }
  }

  List<String> getSublocationsForLocation(String locationName) {
    try {
      final location = _cachedLocations.firstWhereOrNull(
        (loc) => loc.nameEn.toLowerCase() == locationName.toLowerCase(),
      );
      // return location?.sublocations.map((e) => e.nameEn).toList()..sort() ?? [];

      final sublocations = location?.sublocations.map((e) => e.nameEn).toList();
      sublocations?.sort();
      return sublocations ?? [];
    } catch (e) {
      _errorStateController.add('Failed to get sublocations: ${e.toString()}');
      return [];
    }
  }

  Future<void> refreshData() async {
    try {
      _loadingStateController.add(true);
      _errorStateController.add(null);
      await _fetchAndCacheFormData();
      // Reports will update automatically through the existing subscription
    } catch (e) {
      _errorStateController.add('Failed to refresh data: ${e.toString()}');
    } finally {
      _loadingStateController.add(false);
    }
  }

  void dispose() {
    _reportsSubscription?.cancel();
    _filteredReportsController.close();
    _filterOptionsController.close();
    _loadingStateController.close();
    _errorStateController.close();
    _suggestionsLoadingController.close();
  }
}
