// lib/services/get_reports_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/models/user_model.dart'; // Import your AppUser model
import 'dart:async';

import 'package:flutter/material.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ensure your collection path is correct. Based on your current structure,
  // it seems to be nested within 'back2u/countries/cameroon/data/reports'.
  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('back2u/countries/cameroon/data/reports');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('back2u/countries/cameroon/data/users');


  // StreamController for general reports displayed on the home page
  final _reportsController = StreamController<List<Report>>.broadcast();
  Stream<List<Report>> get reportsStream => _reportsController.stream;

  // Current state for pagination
  List<Report> _currentReports = [];
  DocumentSnapshot? _lastDocument; // Cursor for pagination
  bool _hasMore = true; // Indicates if there are more reports to load
  bool _isLoading = false; // Prevents multiple simultaneous fetch calls
  String? _currentFilterType; // Stores the active filter for pagination
  static const int _defaultPageSize = 10; // Consistent page size

  // StreamController specifically for user's reports (for MyReportsPage)
  final _userReportsController = StreamController<List<Report>>.broadcast();
  Stream<List<Report>> get userReportsStream => _userReportsController.stream;

  // NEW StreamController for saved reports
  final _savedReportsController = StreamController<List<Report>>.broadcast();
  Stream<List<Report>> get savedReportsStream => _savedReportsController.stream;


  /// Disposes all stream controllers to prevent memory leaks.
  void dispose() {
    _reportsController.close();
    _userReportsController.close();
    _savedReportsController.close(); // Dispose the new controller
  }

  /// Fetches the initial set of reports, resetting pagination state.
  Future<void> fetchInitialReports({
    int limit = _defaultPageSize,
    String? typeFilter,
  }) async {
    if (_isLoading) return; // Prevent new fetch if one is already in progress

    _isLoading = true;

    try {
      // Reset pagination state for a fresh load
      _lastDocument = null;
      _hasMore = true;
      _currentFilterType = typeFilter;
      _currentReports = [];

      // Emit empty list to visually indicate a fresh load/clearing old data
      if (!_reportsController.isClosed) {
        _reportsController.add([]);
      }

      // Fetch the first page of reports
      await _fetchReports(limit: limit, isInitial: true);
    } finally {
      _isLoading = false;
    }
  }

  /// Fetches more reports for infinite scrolling/pagination.
  Future<void> fetchMoreReports({int limit = _defaultPageSize}) async {
    if (!_hasMore || _isLoading) {
      return; // No more data or already loading
    }

    _isLoading = true;

    try {
      // Fetch the next page of reports
      await _fetchReports(limit: limit, isInitial: false);
    } finally {
      _isLoading = false;
    }
  }

  /// Internal method to fetch reports from Firestore based on query parameters.
  Future<void> _fetchReports({
    required int limit,
    required bool isInitial,
  }) async {
    try {
      Query query = _reportsCollection.orderBy('createdAt', descending: true);

      // Apply filter if specified and not 'All'
      if (_currentFilterType != null && _currentFilterType != 'All') {
        query = query.where('type', isEqualTo: _currentFilterType!.toLowerCase());
      }

      // Add pagination cursor if fetching subsequent pages
      if (!isInitial && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update the last document for the next pagination request
        _lastDocument = querySnapshot.docs.last;

        // Convert fetched documents into Report objects
        final newReports = querySnapshot.docs
            .map((doc) => Report.fromFirestore(doc))
            .toList();

        // Update the list of current reports
        if (isInitial) {
          _currentReports = newReports;
        } else {
          _currentReports.addAll(newReports);
        }

        // Determine if there are potentially more reports
        _hasMore = newReports.length == limit;

        // Emit the updated list of reports to all listeners
        if (!_reportsController.isClosed) {
          _reportsController.add(List<Report>.from(_currentReports));
        }
      } else {
        // No new documents were found, so no more reports to load
        _hasMore = false;
        // Even if no new docs, emit the current list to update listeners
        if (!_reportsController.isClosed) {
          _reportsController.add(List<Report>.from(_currentReports));
        }
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseException) {
        // Handle specific Firebase errors
        switch (e.code) {
          case 'unavailable':
            errorMessage = 'Network error: Please check your internet connection.';
            break;
          case 'permission-denied':
            errorMessage = 'Permission denied: You don\'t have access to these reports.';
            break;
          case 'deadline-exceeded':
            errorMessage = 'Request timed out: Please try again.';
            break;
          default:
            errorMessage = 'Firebase error: ${e.message ?? e.code}';
        }
      } else {
        errorMessage = 'Failed to load reports: ${e.toString()}';
      }

      // Emit the error to listeners
      if (!_reportsController.isClosed) {
        _reportsController.addError(errorMessage);
      }
      debugPrint("Error fetching reports: $e"); // Log error for debugging
    }
  }

  /// Retrieves a stream of reports submitted by a specific user.
  /// Used for "My Reports" page.
  Stream<List<Report>> getReportsByUserId(String uid) {
    return _reportsCollection
        .where('reporterUid', isEqualTo: uid) // Corrected field name
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
        })
        .handleError((error) {
          debugPrint('Error loading user reports: $error');
          // No need to re-throw here if you want to handle the error in the UI
          // throw Exception('Failed to load your reports: $error');
        });
  }

  /// NEW METHOD: Fetches reports based on a list of report IDs from the user's savedReports array.
  Future<void> fetchAndStreamSavedReports(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        debugPrint('User document for ID $userId not found.');
        if (!_savedReportsController.isClosed) {
          _savedReportsController.add([]);
        }
        return;
      }

      final AppUser appUser = AppUser.fromFirestore(userDoc);
      final List<String> savedReportIds = appUser.savedReports ?? [];

      if (savedReportIds.isEmpty) {
        debugPrint('User $userId has no saved reports.');
        if (!_savedReportsController.isClosed) {
          _savedReportsController.add([]);
        }
        return;
      }

      // Firestore 'in' query supports up to 10 items
      if (savedReportIds.length <= 10) {
        final reports = await _fetchReportsByIds(savedReportIds);
        if (!_savedReportsController.isClosed) {
          _savedReportsController.add(reports);
        }
      } else {
        // If more than 10, split into chunks and fetch
        List<Report> allSavedReports = [];
        for (int i = 0; i < savedReportIds.length; i += 10) {
          final chunk = savedReportIds.sublist(
            i,
            i + 10 > savedReportIds.length ? savedReportIds.length : i + 10,
          );
          final chunkReports = await _fetchReportsByIds(chunk);
          allSavedReports.addAll(chunkReports);
        }
        if (!_savedReportsController.isClosed) {
          _savedReportsController.add(allSavedReports);
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to load saved reports: ${e.toString()}';
      if (e is FirebaseException) {
        errorMessage = 'Firebase error loading saved reports: ${e.message ?? e.code}';
      }
      debugPrint(errorMessage);
      if (!_savedReportsController.isClosed) {
        _savedReportsController.addError(errorMessage);
      }
    }
  }

  /// Helper to fetch a list of reports by their IDs (max 10 per query).
  Future<List<Report>> _fetchReportsByIds(List<String> reportIds) async {
    if (reportIds.isEmpty) return [];

    try {
      final querySnapshot = await _reportsCollection
          .where(FieldPath.documentId, whereIn: reportIds)
          .get();

      return querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching reports by IDs: $e');
      rethrow; // Re-throw to be caught by the calling method
    }
  }


  /// Getter to check if more reports are available for general feed pagination.
  bool get hasMoreReports => _hasMore;

  /// Getter to check if the ReportService is currently performing a fetch operation.
  bool get isLoading => _isLoading;

  /// Utility to get the total count of reports (can be filtered).
  Future<int> getTotalReportsCount({String? typeFilter}) async {
    try {
      Query query = _reportsCollection;

      if (typeFilter != null && typeFilter != 'All') {
        query = query.where('type', isEqualTo: typeFilter.toLowerCase());
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint("Error getting reports count: $e");
      return 0;
    }
  }

  /// Resets the pagination state for the general reports stream.
  void resetPaginationState() {
    _lastDocument = null;
    _currentFilterType = null;
    _hasMore = true;
    _currentReports = [];
  }

  // Legacy methods (can be removed if not used elsewhere, or kept for backward compatibility)
  // These directly use the internal state and might be less flexible than `fetchInitialReports`/`fetchMoreReports`
  Future<List<Report>> fetchInitialReportsForPagination({
    required int limit,
    String? typeFilter,
  }) async {
    await fetchInitialReports(limit: limit, typeFilter: typeFilter);
    return List<Report>.from(_currentReports); // Return a copy
  }

  Future<List<Report>> fetchMoreReportsForPagination({required int limit}) async {
    await fetchMoreReports(limit: limit);
    return List<Report>.from(_currentReports); // Return a copy
  }
}