// lib/services/saved_report_service.dart
import 'package:back2u/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart';
// import 'package:back2u/models/app_user_model.dart'; // Make sure your AppUser model is available
import 'dart:async';
import 'package:flutter/foundation.dart'; // For debugPrint

class SavedReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollectionPath = 'back2u/countries/cameroon/data/users';
  static const String _reportsCollectionPath = 'back2u/countries/cameroon/data/reports';

  // Use a StreamController to manage the stream of saved reports
  // This approach allows for more control over when the stream updates,
  // particularly useful if report details are fetched asynchronously.
  final StreamController<List<Report>> _savedReportsController =
      StreamController<List<Report>>.broadcast();

  Stream<List<Report>> get savedReportsStream => _savedReportsController.stream;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userProfileSubscription;

  void listenToSavedReports(String userId) {
    // Cancel previous subscription if it exists
    _userProfileSubscription?.cancel();

    // Listen to the user's profile document for changes in savedReportIds
    _userProfileSubscription = _firestore
        .collection(_usersCollectionPath)
        .doc(userId)
        .snapshots()
        .listen((userDocSnapshot) async {
      if (userDocSnapshot.exists) {
        final appUser = AppUser.fromFirestore(userDocSnapshot);
        final List<String> savedReportIds = appUser.savedReports ?? [];

        if (savedReportIds.isEmpty) {
          _savedReportsController.add([]); // Emit empty list if no saved reports
          return;
        }

        // Fetch the actual Report documents based on the IDs
        final List<Report> fetchedReports = [];
        // Use a Future.wait to fetch reports concurrently for efficiency
        final List<Future<DocumentSnapshot<Map<String, dynamic>>>> futures =
            savedReportIds.map((id) => _firestore.collection(_reportsCollectionPath).doc(id).get()).toList();

        try {
          final List<DocumentSnapshot<Map<String, dynamic>>> reportSnapshots =
              await Future.wait(futures);

          for (var docSnapshot in reportSnapshots) {
            if (docSnapshot.exists) {
              try {
                fetchedReports.add(Report.fromFirestore(docSnapshot));
              } catch (e) {
                debugPrint('Error parsing saved report ${docSnapshot.id}: $e');
                // Optionally, log this specific report ID for investigation
              }
            } else {
              debugPrint('Saved report with ID ${docSnapshot.id} not found in reports collection.');
              // Optionally, you might want to clean up missing IDs from the user's profile
              // _userProfileService.removeMissingSavedReportId(userId, docSnapshot.id);
            }
          }
          _savedReportsController.add(fetchedReports); // Emit the list of fetched reports

        } catch (e) {
          debugPrint('Error fetching saved reports data: $e');
          _savedReportsController.addError(e); // Propagate error to stream listener
        }
      } else {
        debugPrint('User profile for ID $userId not found. No saved reports to fetch.');
        _savedReportsController.add([]); // User profile doesn't exist, no saved reports
      }
    }, onError: (error) {
      debugPrint('Error in user profile stream for saved reports: $error');
      _savedReportsController.addError(error); // Propagate error
    });
  }

  void dispose() {
    _userProfileSubscription?.cancel();
    _savedReportsController.close();
  }
}