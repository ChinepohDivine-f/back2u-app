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
        applySearchAndFilters(
          currentQuery: _lastQuery,
          filterType: _lastFilterType,
          filterCategory: _lastFilterCategory,
          filterSubCategory: _lastFilterSubCategory,
          filterLocation: _lastFilterLocation,
          filterSubLocation: _lastFilterSubLocation,
          filterIsResolved: _lastFilterIsResolved,
        );
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

  void applySearchAndFilters({
    String currentQuery = '',
    String? filterType,
    String? filterCategory,
    String? filterSubCategory,
    String? filterLocation,
    String? filterSubLocation,
    bool? filterIsResolved,
  }) {
    if (!_hasData) return;

    // Store current filters
    _lastQuery = currentQuery;
    _lastFilterType = filterType;
    _lastFilterCategory = filterCategory;
    _lastFilterSubCategory = filterSubCategory;
    _lastFilterLocation = filterLocation;
    _lastFilterSubLocation = filterSubLocation;
    _lastFilterIsResolved = filterIsResolved;

    try {
      List<Report> results = List.from(_allReportsCache);

      // Apply Text Search
      if (currentQuery.isNotEmpty) {
        final query = currentQuery.toLowerCase();
        results = results.where((report) {
          final reportKeywords = _generateSearchKeywords(report);
          return reportKeywords.any((keyword) => keyword.contains(query));
        }).toList();
      }

      // Apply Filters
      results = results.where((item) {
        bool matchesFilterType = filterType == null ||
            item.type.toLowerCase() == filterType.toLowerCase();
        bool matchesFilterCategory = filterCategory == null ||
            item.category.toLowerCase() == filterCategory.toLowerCase();
        bool matchesFilterSubCategory = filterSubCategory == null ||
            (item.subcategory?.toLowerCase() ==
                    filterSubCategory.toLowerCase() ??
                false);
        bool matchesFilterLocation = filterLocation == null ||
            item.locationLost.toLowerCase() == filterLocation.toLowerCase();
        bool matchesFilterSubLocation = filterSubLocation == null ||
            (item.subLocationLost?.toLowerCase() ==
                    filterSubLocation.toLowerCase() ??
                false);
        bool matchesFilterIsResolved =
            filterIsResolved == null || item.resolved == filterIsResolved;

        return matchesFilterType &&
            matchesFilterCategory &&
            matchesFilterSubCategory &&
            matchesFilterLocation &&
            matchesFilterSubLocation &&
            matchesFilterIsResolved;
      }).toList();

      _filteredReportsController.add(results);
    } catch (e) {
      _errorStateController.add('Failed to apply filters: ${e.toString()}');
      _filteredReportsController.add([]);
    }
  }

  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>{};

    final List<String?> termsToProcess = [
      r.ownerName,
      r.documentName,
      r.category,
      r.subcategory,
      r.locationLost,
      r.subLocationLost,
      r.type,
      r.notes,
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
