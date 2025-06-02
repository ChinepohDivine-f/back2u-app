// lib/services/report_search_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart';
import 'dart:async'; // For StreamController

class ReportSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for reports (Cameroon specific)
  late final CollectionReference<Map<String, dynamic>> _reportsCollection;

  // StreamController to emit filtered reports
  final _filteredReportsController = StreamController<List<Report>>.broadcast();
  Stream<List<Report>> get filteredReportsStream => _filteredReportsController.stream;

  // StreamController to emit available filter options
  final _filterOptionsController = StreamController<Map<String, List<String>>>.broadcast();
  Stream<Map<String, List<String>>> get filterOptionsStream => _filterOptionsController.stream;

  // Internal cache of all reports
  List<Report> _allReportsCache = [];
  StreamSubscription? _reportsSubscription;

  ReportSearchService() {
    _reportsCollection = _firestore.collection('back2u/countries/cameroon/data/reports');
    _listenToAllReports();
  }

  void _listenToAllReports() {
    _reportsSubscription = _reportsCollection
        .orderBy('createdAt', descending: true) // Always sort by creation date
        .snapshots()
        .listen((querySnapshot) {
      _allReportsCache = querySnapshot.docs.map((doc) {
        return Report.fromFirestore(doc);
      }).toList();

      // Emit updated filter options whenever reports change
      _updateFilterOptions();

      // Re-apply the last known filters/query (if any) to the new data
      // Or just emit all reports if no active search/filters
      // FIX: Changed _applySearchAndFilters to applySearchAndFilters
      applySearchAndFilters(
        currentQuery: _lastQuery,
        filterType: _lastFilterType,
        filterCategory: _lastFilterCategory,
        filterLocation: _lastFilterLocation,
        filterIsResolved: _lastFilterIsResolved,
      );

    }, onError: (error) {
      _filteredReportsController.addError(error);
      _filterOptionsController.addError(error);
      print("Error fetching all reports for search: $error");
    });
  }

  void _updateFilterOptions() {
    final Set<String> categories = {};
    final Set<String> locations = {};

    for (var report in _allReportsCache) {
      categories.add(report.category);
      locations.add(report.locationLost);
    }

    _filterOptionsController.add({
      'categories': categories.toList()..sort(),
      'locations': locations.toList()..sort(),
      // 'reportTypes': ['Lost', 'Found'], // Static, but can be dynamic if needed
    });
  }

  // Store last applied filters/query
  String _lastQuery = '';
  String? _lastFilterType;
  String? _lastFilterCategory;
  String? _lastFilterLocation;
  bool? _lastFilterIsResolved;

  /// Applies search query and filters to the cached reports and emits the result.
  void applySearchAndFilters({
    String currentQuery = '',
    String? filterType,
    String? filterCategory,
    String? filterLocation,
    bool? filterIsResolved,
  }) {
    // Store current filters for re-application when base data changes
    _lastQuery = currentQuery;
    _lastFilterType = filterType;
    _lastFilterCategory = filterCategory;
    _lastFilterLocation = filterLocation;
    _lastFilterIsResolved = filterIsResolved;

    List<Report> results = List.from(_allReportsCache); // Start with all cached reports

    // 1. Apply Text Search
    if (currentQuery.isNotEmpty) {
      final query = currentQuery.toLowerCase();
      results = results.where((report) {
        // Generate keywords for the current report and check for query match
        final reportKeywords = _generateSearchKeywords(report);
        return reportKeywords.any((keyword) => keyword.contains(query));
      }).toList();
    }

    // 2. Apply Filters
    results = results.where((item) {
      bool matchesFilterType =
          filterType == null || item.type.toLowerCase() == filterType.toLowerCase();
      bool matchesFilterCategory = filterCategory == null ||
          item.category.toLowerCase() == filterCategory.toLowerCase();
      bool matchesFilterLocation =
          filterLocation == null || item.locationLost.toLowerCase() == filterLocation.toLowerCase();
      bool matchesFilterIsResolved =
          filterIsResolved == null || item.resolved == filterIsResolved;

      return matchesFilterType &&
          matchesFilterCategory &&
          matchesFilterLocation &&
          matchesFilterIsResolved;
    }).toList();

    _filteredReportsController.add(results); // Emit the filtered results
  }

  // Helper to generate search keywords from report data, including prefixes
  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>[];

    // Add search keywords from Report model (ensure they are lowercase)
    final List<String?> termsToProcess = [
      r.ownerName, // Now ownerName can be null
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
        final cleanedTerm = term.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ''); // Remove punctuation
        final words = cleanedTerm.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);

        for (var word in words) {
          // Store the full word
          keywords.add(word);

          // Generate slices (prefixes) of the word
          for (int i = 1; i <= word.length; i++) {
            keywords.add(word.substring(0, i));
          }
        }
      }
    }

    // Ensure unique and non-empty keywords
    return keywords
        .where((k) => k.isNotEmpty)
        .toSet()
        .toList();
  }

  void dispose() {
    _reportsSubscription?.cancel();
    _filteredReportsController.close();
    _filterOptionsController.close();
  }
}