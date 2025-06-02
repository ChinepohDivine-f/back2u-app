// lib/services/form_data_fetch_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/category_model.dart';
import 'package:back2u/models/location_model.dart';
import 'package:back2u/models/user_model.dart'; // Import your AppUser model

class DataFetchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _categoriesPath =
      'back2u/countries/cameroon/data/categories';
  static const String _locationsPath =
      'back2u/countries/cameroon/data/locations';
  static const String _usersCollectionPath =
      'back2u/countries/cameroon/data/users'; // Path to the users collection

  String usersCollectionPath() {
    return _usersCollectionPath;
  }

  /// Fetches all categories and their subcategories from Firestore,
  /// ensuring uniqueness by 'nameEn'.
  Future<List<Category>> fetchCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_categoriesPath).get();

      // Convert to a Set based on nameEn to filter duplicates, then back to List
      final List<Category> uniqueCategories = snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .fold<List<Category>>([], (previousValue, element) {
        if (!previousValue.any((cat) => cat.nameEn == element.nameEn)) {
          previousValue.add(element);
        }
        return previousValue;
      });

      // Also ensure subcategories are unique by nameEn
      for (var category in uniqueCategories) {
        // Use a Set to track seen subcategory names for the current category
        final Set<String> seenSubCategoryNames = {};
        category.subcategories.retainWhere((subCat) {
          if (seenSubCategoryNames.contains(subCat.nameEn)) {
            return false; // Remove if duplicate name found
          } else {
            seenSubCategoryNames.add(subCat.nameEn);
            return true; // Keep if unique
          }
        });
      }

      return uniqueCategories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Fetches all locations and their sublocations from Firestore,
  /// ensuring uniqueness by 'nameEn'.
  Future<List<Location>> fetchLocations() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(_locationsPath).get();

      // Convert to a Set based on nameEn to filter duplicates, then back to List
      final List<Location> uniqueLocations = snapshot.docs
          .map((doc) => Location.fromFirestore(doc))
          .fold<List<Location>>([], (previousValue, element) {
        if (!previousValue.any((loc) => loc.nameEn == element.nameEn)) {
          previousValue.add(element);
        }
        return previousValue;
      });

      // Also ensure sublocations are unique by nameEn
      for (var location in uniqueLocations) {
        // Use a Set to track seen sublocation names for the current location
        final Set<String> seenSubLocationNames = {};
        location.sublocations.retainWhere((subLoc) {
          if (seenSubLocationNames.contains(subLoc.nameEn)) {
            return false; // Remove if duplicate name found
          } else {
            seenSubLocationNames.add(subLoc.nameEn);
            return true; // Keep if unique
          }
        });
      }

      return uniqueLocations;
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }

  /// Fetches a single user's data from Firestore.
  /// Requires the userId (typically Firebase Auth UID).
  Future<AppUser?> fetchUser(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection(_usersCollectionPath).doc(userId).get();

      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      } else {
        print('User with ID $userId not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching user data for $userId: $e');
      return null;
    }
  }
}
