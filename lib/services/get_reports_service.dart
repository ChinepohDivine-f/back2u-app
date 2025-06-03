// lib/services/get_reports_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart';
import 'dart:async'; // Required for StreamController

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Correct path for reports collection based on your structure
  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('back2u/countries/cameroon/data/reports');

  // StreamController for general reports (already existing)
  final _reportsController = StreamController<List<Report>>.broadcast();
  Stream<List<Report>> get reportsStream => _reportsController.stream;

  List<Report> _currentReports = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingReports = false;

  String? _currentFilterType;

  // --- NEW: StreamController specifically for user's reports ---
  final _userReportsController = StreamController<List<Report>>.broadcast();
  Stream<List<Report>> get userReportsStream => _userReportsController.stream;
  // --- END NEW ---

  void dispose() {
    _reportsController.close();
    _userReportsController.close(); // --- NEW: Close the user reports controller ---
  }

  Future<void> fetchInitialReports({
    int limit = 8,
    String? typeFilter,
  }) async {
    _lastDocument = null;
    _hasMore = true;
    _currentFilterType = typeFilter;
    _currentReports = [];
    _reportsController.add([]); // Clear previous reports instantly in UI
    return fetchMoreReports(limit: limit);
  }

  Future<void> fetchMoreReports({int limit = 8}) async {
    if (!_hasMore || _isLoadingReports) {
      return;
    }

    _isLoadingReports = true;

    try {
      Query query = _reportsCollection.orderBy('createdAt', descending: true);

      if (_currentFilterType != null && _currentFilterType != 'All') {
        query = query.where('type', isEqualTo: _currentFilterType!.toLowerCase());
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        final newReports = querySnapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();

        _currentReports.addAll(newReports);
        _reportsController.add(_currentReports);

        _hasMore = newReports.length == limit;
      } else {
        _hasMore = false;
        _reportsController.add(_currentReports); // Emit current (unchanged) list if no new docs
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        _reportsController.addError('Network error: Please check your internet connection.');
      } else {
        _reportsController.addError('Failed to load reports: ${e.toString()}');
      }
      print("Error fetching reports: $e");
    } finally {
      _isLoadingReports = false;
    }
  }

  // --- NEW FUNCTION: Get reports submitted by a specific user ---
  Stream<List<Report>> getReportsByUserId(String uid) {
    return _reportsCollection
        .where('reporterUid', isEqualTo: uid) // Filter by the user's UID
        .orderBy('createdAt', descending: true) // Order by creation date, newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromFirestore(doc))
            .toList());
  }
  // --- END NEW FUNCTION ---

  bool get hasMoreReports => _hasMore;
}