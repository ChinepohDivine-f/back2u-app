import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/app_info_model.dart';
import 'package:back2u/models/category_model.dart';
import 'package:back2u/models/location_model.dart';
import 'package:back2u/models/country_model.dart'; // Import the new model
import 'package:back2u/data/cameroon_data.dart';
import 'dart:async';

class DataUploadService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  Stream<String> get logs => _logController.stream;

  void _log(String message) {
    _logController.add(message);
    print(message); // Also print to console for debugging
  }

  Future<void> uploadAllDummyData() async {
    _log('--- Starting data upload process ---');

    await _uploadAppInfo();
    await _uploadCountryData(); // Call the new method
    await _uploadCategories();
    await _uploadLocations();

    _log('--- Data upload process completed ---');
  }

  Future<void> _uploadAppInfo() async {
    _log('Attempting to upload App Info...');
    final appInfoData = CameroonData.getAppInfoData();
    // Path: ROOT/Back2u/app_info (document)
    final appInfoRef = _db.collection('back2u').doc('app_info');

    try {
      final docSnapshot = await appInfoRef.get();
      if (docSnapshot.exists) {
        _log('App Info document already exists. Skipping upload.');
      } else {
        await appInfoRef.set(appInfoData.toFirestore());
        _log('App Info uploaded successfully.');
      }
    } catch (e) {
      _log('Error uploading App Info: $e');
    }
  }

  // Updated method to upload country data to /back2u/countries/{countryId}/country_info
  Future<void> _uploadCountryData() async {
    _log('Attempting to upload Country data for Cameroon...');
    final countryData = CameroonData.getCameroonCountryData();
    // Path: ROOT/Back2u/countries/cameroon/country_info
    // This matches the rule: /back2u/countries/cameroon/country_info
    final countryRef = _db
        .collection('back2u')
        .doc('countries')
        .collection('cameroon') // Now 'cameroon' is a document within 'countries' collection
        .doc('country_info'); // And 'country_info' is a sub-document of 'cameroon'
        
    try {
      final docSnapshot = await countryRef.get();
      if (docSnapshot.exists) {
        _log(
            'Country data for "${countryData.nameEn}" already exists. Skipping upload.');
      } else {
        await countryRef.set(countryData.toFirestore());
        _log('Country data for "${countryData.nameEn}" uploaded successfully.');
      }
    } catch (e) {
      _log('Error uploading Country data for "${countryData.nameEn}": $e');
    }
  }

  Future<void> _uploadCategories() async {
    _log('Attempting to upload Categories...');
    final categories = CameroonData.getCategoriesData();
    // Path: ROOT/Back2u/countries/cameroon/data/categories/{categoryId}
    final CollectionReference categoriesRef = _db
        .collection('back2u')
        .doc('countries')
        .collection('cameroon')
        .doc('data')
        .collection('categories');

    for (var category in categories) {
      try {
        final DocumentSnapshot docSnapshot =
            await categoriesRef.doc(category.categoryId).get();
        if (docSnapshot.exists) {
          _log('Category "${category.nameEn}" already exists. Skipping.');
        } else {
          await categoriesRef
              .doc(category.categoryId)
              .set(category.toFirestore());
          _log('Category "${category.nameEn}" uploaded.');
        }
      } catch (e) {
        _log('Error uploading category "${category.nameEn}": $e');
      }
    }
    _log('Category upload process finished.');
  }

  Future<void> _uploadLocations() async {
    _log('Attempting to upload Locations (Regions & Sub-locations)...');
    final locations = CameroonData.getCameroonLocations();
    // Path: ROOT/Back2u/countries/cameroon/data/locations/{locationId}
    final CollectionReference locationsRef = _db
        .collection('back2u')
        .doc('countries')
        .collection('cameroon')
        .doc('data')
        .collection('locations');

    for (var location in locations) {
      try {
        final DocumentSnapshot docSnapshot =
            await locationsRef.doc(location.locationId).get();
        if (docSnapshot.exists) {
          _log('Location "${location.nameEn}" already exists. Skipping.');
        } else {
          await locationsRef
              .doc(location.locationId)
              .set(location.toFirestore());
          _log(
              'Location "${location.nameEn}" uploaded with ${location.sublocations.length} sub-locations.');
        }
      } catch (e) {
        _log('Error uploading location "${location.nameEn}": $e');
      }
    }
    _log('Location upload process finished.');
  }

  void dispose() {
    _logController.close();
  }
}