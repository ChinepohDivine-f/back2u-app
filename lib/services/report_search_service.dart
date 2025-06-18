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

  // Internal state
  List<Report> _allReportsCache = [];
  List<Category> _cachedCategories = [];
  List<Location> _cachedLocations = [];
  StreamSubscription? _reportsSubscription;
  bool _isInitialLoad = true;
  bool _hasData = false;

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

  // Add the searchByOwnerName method
Future<void> searchByOwnerName(String ownerName) async {
  try {
    _loadingStateController.add(true);
    _errorStateController.add(null);

    final query = _reportsCollection
        .where('owner_name', isEqualTo: ownerName)
        .orderBy('createdAt', descending: true);

    final querySnapshot = await query.get();
    final reports = querySnapshot.docs
        .map((doc) => Report.fromFirestore(doc))
        .toList();
        
    _filteredReportsController.add(reports);
  } catch (e) {
    _errorStateController.add('Failed to search by owner: ${e.toString()}');
    _filteredReportsController.add([]);
  } finally {
    _loadingStateController.add(false);
  }
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
        // applySearchAndFilters(
        //   currentQuery: _lastQuery,
        //   filterType: _lastFilterType,
        //   filterCategory: _lastFilterCategory,
        //   filterSubCategory: _lastFilterSubCategory,
        //   filterLocation: _lastFilterLocation,
        //   filterSubLocation: _lastFilterSubLocation,
        //   filterIsResolved: _lastFilterIsResolved,
        // );
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

  // --- Firestore-powered search suggestions (max 7) ---
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
    Query query = _reportsCollection;
    
    // Apply all active filters
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
    
    // Get all relevant reports
    final querySnapshot = await query.get();
    
    // Create a map to store unique suggestions with their relevance score
    final Map<String, int> suggestionScores = {};

    for (var doc in querySnapshot.docs) {
      final report = Report.fromFirestore(doc);
      final searchableFields = [
        report.ownerName,
        report.category,
        report.subcategory,
        report.locationLost,
        report.subLocationLost,
        report.notes,
      ].where((field) => field != null && field.isNotEmpty).cast<String>().toList();

      // Check each field for matches
      for (var field in searchableFields) {
        if (field.toLowerCase().contains(input.toLowerCase())) {
          // Calculate a simple relevance score
          final score = field.toLowerCase().indexOf(input.toLowerCase());
          final isExactMatch = field.toLowerCase() == input.toLowerCase();
          
          // Prefer exact matches and longer matches
          final relevanceScore = isExactMatch 
              ? 0  // Highest priority for exact matches
              : score >= 0 
                  ? 1  // Higher priority for matches at the start
                  : 2; // Lower priority for partial matches

          // Store the most relevant version of each suggestion
          if (!suggestionScores.containsKey(field) || 
              suggestionScores[field]! > relevanceScore) {
            suggestionScores[field] = relevanceScore;
          }
        }
      }
    }

    // Sort suggestions by relevance and then alphabetically
   // Sort suggestions by relevance and then alphabetically
final sortedEntries = suggestionScores.entries.toList();
sortedEntries.sort((a, b) {
  // First sort by relevance score
  final scoreCompare = a.value.compareTo(b.value);
  if (scoreCompare != 0) return scoreCompare;
  // Then sort alphabetically
  return a.key.toLowerCase().compareTo(b.key.toLowerCase());
});

final sortedSuggestions = sortedEntries
    .map((e) => e.key)
    .take(7)
    .toList();

    return sortedSuggestions.take(7).toList();
  } catch (e) {
    _errorStateController.add('Failed to fetch suggestions: ${e.toString()}');
    return [];
  }
}
  // --- Update applySearchAndFilters to use Firestore-powered search ---
  
  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>{};

    final List<String?> termsToProcess = [
      r.ownerName,
      // r.documentName,
      // r.category,
      // r.subcategory,
      // r.locationLost,
      // r.subLocationLost,
      // r.type,
      // r.notes,
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
  }
}
