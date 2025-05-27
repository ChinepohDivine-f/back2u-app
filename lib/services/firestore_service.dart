import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/models/user_model.dart';
import 'package:back2u/models/category_model.dart';
import 'package:back2u/models/location_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Base path for Cameroon-specific collections
  static const String _basePath = 'back2u/countries/cameroon';

  // --- Report Operations ---

  Future<void> addReport(Report report) async {
    try {
      await _db
          .collection('$_basePath/reports')
          .doc(report.reportId)
          .set(report.toFirestore());
      print('Report added successfully!');
    } catch (e) {
      print('Error adding report: $e');
      rethrow;
    }
  }

  Future<Report?> getReport(String reportId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('$_basePath/reports').doc(reportId).get();
      if (doc.exists) {
        return Report.fromFirestore(doc);
      } else {
        print('Report with ID $reportId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error getting report: $e');
      rethrow;
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      QuerySnapshot snapshot = await _db.collection('$_basePath/reports').get();
      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all reports: $e');
      rethrow;
    }
  }

  Future<void> updateReport(Report report) async {
    try {
      await _db
          .collection('$_basePath/reports')
          .doc(report.reportId)
          .update(report.toFirestore());
      print('Report updated successfully!');
    } catch (e) {
      print('Error updating report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _db.collection('$_basePath/reports').doc(reportId).delete();
      print('Report deleted successfully!');
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }

  // --- User Operations ---

  Future<void> addUser(AppUser user) async {
    try {
      await _db
          .collection('$_basePath/users')
          .doc(user.userId)
          .set(user.toFirestore());
      print('User added successfully!');
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  Future<AppUser?> getUser(String userId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('$_basePath/users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      } else {
        print('User with ID $userId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await _db
          .collection('$_basePath/users')
          .doc(user.userId)
          .update(user.toFirestore());
      print('User updated successfully!');
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // --- Category Operations ---

  Future<void> addCategory(Category category) async {
    try {
      await _db
          .collection('$_basePath/categories')
          .doc(category.categoryId)
          .set(category.toFirestore());
      print('Category added successfully!');
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<Category?> getCategory(String categoryId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('$_basePath/categories').doc(categoryId).get();
      if (doc.exists) {
        return Category.fromFirestore(doc);
      } else {
        print('Category with ID $categoryId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error getting category: $e');
      rethrow;
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      QuerySnapshot snapshot =
          await _db.collection('$_basePath/categories').get();
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all categories: $e');
      rethrow;
    }
  }

  // --- Location Operations ---

  Future<void> addLocation(Location location) async {
    try {
      await _db
          .collection('$_basePath/locations')
          .doc(location.locationId)
          .set(location.toFirestore());
      print('Location added successfully!');
    } catch (e) {
      print('Error adding location: $e');
      rethrow;
    }
  }

  Future<Location?> getLocation(String locationId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('$_basePath/locations').doc(locationId).get();
      if (doc.exists) {
        return Location.fromFirestore(doc);
      } else {
        print('Location with ID $locationId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  Future<List<Location>> getAllLocations() async {
    try {
      QuerySnapshot snapshot =
          await _db.collection('$_basePath/locations').get();
      return snapshot.docs
          .map((doc) => Location.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all locations: $e');
      rethrow;
    }
  }

  // --- Feedback Operations (Assuming a simple Feedback model) ---
  // You would need to define a Feedback model similarly if it has specific fields.
  // For now, let's assume it's just a map of data.

  Future<void> addFeedback(Map<String, dynamic> feedbackData, String feedbackId) async {
    try {
      await _db
          .collection('$_basePath/feedback')
          .doc(feedbackId)
          .set(feedbackData);
      print('Feedback added successfully!');
    } catch (e) {
      print('Error adding feedback: $e');
      rethrow;
    }
  }
}