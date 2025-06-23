import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart';
import 'package:flutter/foundation.dart';

class ReportValidationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Report>> findPotentialDuplicates({
    required String ownerName,
    required String category,
    required String subcategory,
    required String locationLost,
  }) async {
    // Path to the reports collection
    const String reportsCollectionPath = 'back2u/countries/cameroon/data/reports';

    if (kDebugMode) {
      print('--- Checking for Duplicates ---');
      print('Owner Name: $ownerName');
      print('Category: $category');
      print('Subcategory: $subcategory');
      print('Location: $locationLost');
    }

    try {
      // Calculate the date 3 months ago from now.
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final threeMonthsAgoTimestamp = Timestamp.fromDate(threeMonthsAgo);

      // Query for reports that match on all specified fields.
      // NOTE: This query now requires the composite index to include 'date_of_loss'
      final querySnapshot = await _firestore
          .collection(reportsCollectionPath)
          .where('owner_name', isEqualTo: ownerName)
          .where('category', isEqualTo: category)
          .where('subcategory', isEqualTo: subcategory)
          .where('location_lost', isEqualTo: locationLost)
          .where('resolved', isEqualTo: false) // Only check against unresolved reports
          .where('date_of_loss', isGreaterThanOrEqualTo: threeMonthsAgoTimestamp)
          .limit(5) // Limit to 5 potential duplicates to avoid overwhelming the user
          .get();
      
      if (kDebugMode) {
        print('Found ${querySnapshot.docs.length} potential duplicates within the last 3 months.');
      }

      if (querySnapshot.docs.isEmpty) {
        return []; // No duplicates found
      }

      // Map the document snapshots to Report objects
      final List<Report> duplicateReports = querySnapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();

      return duplicateReports;
    } catch (e) {
      if (kDebugMode) {
        print('--- Firestore Query Error ---');
        print('Error finding potential duplicates: $e');
        print('This often means a composite index is missing in Firestore.');
        print('Please check your Firebase console. You might need an index on:');
        print('[owner_name(asc), category(asc), subcategory(asc), location_lost(asc), resolved(asc), date_of_loss(desc)]');
        print('-----------------------------');
      }
      return [];
    }
  }
}
