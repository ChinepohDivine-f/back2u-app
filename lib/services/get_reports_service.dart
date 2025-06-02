// lib/services/report_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart'; // Make sure this path is correct

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the reports collection for Cameroon
  // This path must match your Firestore security rules and data structure.
  // Based on your rules, the path is 'back2u/countries/cameroon/data/reports'
  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('back2u/countries/cameroon/data/reports');

  /// Fetches a stream of all reports, ordered by creation date (most recent first).
  ///
  /// This stream will emit a new list of reports whenever the data in Firestore changes.
  Stream<List<Report>> getReportsStream() {    
    return _reportsCollection
        // .orderBy('createdAt', descending: true) // Sort by creation date
        .snapshots() // Get real-time updates
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            print(Report.fromFirestore(doc)); // Debug log
            // Use the Report.fromFirestore factory to convert document to Report object
            return Report.fromFirestore(doc); // Pass null for options
          }).toList();
        });
  }

  // You can add more methods here for
  // Future<Report> getReportById(String reportId)
  // Future<void> updateReportStatus(String reportId, String status)
  // etc.
}