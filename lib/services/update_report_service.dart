// lib/services/update_report_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back2u/models/report_model.dart'; // Make sure your Report model is here
import 'package:back2u/services/image_upload_service.dart'; // Re-use your image upload service

class UpdateReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ImageUploadService _imageUploadService = ImageUploadService(); // Assuming Cloudinary or similar for ImageKit.io

  // Base path for reports in Firestore. Adjust if your structure is different.
  static const String _reportsCollectionPath = 'back2u/countries/cameroon/data/reports';
  static const String _usersCollectionPath = 'back2u/countries/cameroon/data/users'; // For user profile updates

  Future<void> handleReportSubmission({
    required Report report,
    required List<XFile> localImageFiles,
    required List<String> existingImageUrls,
    required Set<String> imagesToDelete,
    required bool isEditing,
    required String userId,
  }) async {
    // 1. Delete images marked for removal from Firebase Storage
    await _deleteImagesFromStorage(imagesToDelete);

    // 2. Upload new images to Cloudinary (or your chosen service)
    final List<String> newlyUploadedImageUrls = await _imageUploadService.uploadImagesToCloudinary(
      imageFiles: localImageFiles,
      userId: userId,
    );

    // 3. Combine remaining existing image URLs with newly uploaded ones
     List<String> finalImageUrls = [
      ...existingImageUrls.where((url) => !imagesToDelete.contains(url)), // Existing, not deleted
      ...newlyUploadedImageUrls, // Newly uploaded
    ];

    // Ensure we don't exceed max 2 images if somehow more were added (safety)
    if (finalImageUrls.length > 2) {
      // This case should ideally be prevented earlier in the form, but acts as a safeguard.
      // You might log a warning or choose to take only the first 2.
      // For now, we'll just take the first 2.
      finalImageUrls = finalImageUrls.sublist(0, 2);
    }

    // Prepare report data for Firestore
    Map<String, dynamic> reportData = report.toFirestore(); // Convert Report model to Map
    reportData['imageUrls'] = finalImageUrls; // Update with the final image URLs
    reportData['searchKeyWords'] = _generateSearchKeywords(report); // Recalculate keywords

    if (isEditing) {
      // Update existing report
      if (report.reportId == null || report.reportId!.isEmpty) {
        throw Exception('Report ID is missing for an update operation.');
      }
      await _firestore
          .collection(_reportsCollectionPath)
          .doc(report.reportId)
          .update({
            ...reportData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      debugPrint('Report ${report.reportId} updated successfully.');
    } else {
      // Create new report
      final newReportRef = _firestore.collection(_reportsCollectionPath).doc();
      reportData['reportId'] = newReportRef.id;
      reportData['reporterId'] = userId;
      reportData['reporterUid'] = userId; // Assuming reporterUid is also used
      reportData['createdAt'] = FieldValue.serverTimestamp();
      reportData['updatedAt'] = FieldValue.serverTimestamp();
      reportData['status'] = 'pending'; // Default status for new reports
      reportData['resolved'] = false; // Default resolved status
      reportData['resolvedBy'] = null; // Default null for new reports

      await newReportRef.set(reportData);
      debugPrint('New report ${newReportRef.id} submitted successfully.');
    }
  }

  // Helper function to delete images from Firebase Storage
  Future<void> _deleteImagesFromStorage(Set<String> imageUrls) async {
    for (final imageUrl in imageUrls) {
      try {
        // Ensure the URL is a Firebase Storage URL before trying to delete
        if (imageUrl.contains('firebasestorage.googleapis.com')) {
          await _firebaseStorage.refFromURL(imageUrl).delete();
          debugPrint('Deleted image from storage: $imageUrl');
        } else {
          debugPrint('Skipping deletion for non-Firebase Storage URL: $imageUrl');
        }
      } catch (e) {
        debugPrint('Error deleting image from storage ($imageUrl): $e');
        // Continue even if one image fails to delete, log the error.
      }
    }
  }

  // Re-use your keyword generation logic
  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>[];

    if (r.ownerName!.isNotEmpty) {
      keywords.add(r.ownerName!.toLowerCase());
    }

    for (var term in [
      r.ownerName,
      r.category,
      r.subcategory,
      r.locationLost,
      r.subLocationLost,
      r.type,
    ]) {
      if (term!.isNotEmpty) {
        final cleanedTerm = term
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '');
        final words = cleanedTerm.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);

        for (var word in words) {
          keywords.add(word);
          for (int i = 1; i <= word.length; i++) {
            keywords.add(word.substring(0, i));
          }
        }
      }
    }

    if (r.notes.isNotEmpty) {
      keywords.addAll(r.notes
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .map((word) => word.replaceAll(RegExp(r'[^\w\s]'), ''))
          .where((word) => word.isNotEmpty));
    }

    return keywords.where((k) => k.isNotEmpty).toSet().toList();
  }
}