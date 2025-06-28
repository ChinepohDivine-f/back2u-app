// lib/services/update_report_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart'; // Added for debugPrint, though not strictly a service dependency
import 'package:image_picker/image_picker.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/services/image_upload_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user

class UpdateReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  static const String _reportsCollectionPath = 'back2u/countries/cameroon/data/reports';
  // static const String _usersCollectionPath = 'back2u/countries/cameroon/data/users'; // Not used in this service, can remove

  Future<void> handleReportSubmission({
    required Report report,
    required List<XFile> localImageFiles,
    required List<String> existingImageUrls,
    required Set<String> imagesToDelete,
    required bool isEditing,
    required String userId,
    String? submissionId,
  }) async {
    // 1. Delete images marked for removal from Firebase Storage
    await _deleteImagesFromStorage(imagesToDelete);

    // 2. Upload new images
    final List<String> newlyUploadedImageUrls = await _imageUploadService.uploadImagesToCloudinary(
      imageFiles: localImageFiles,
      userId: userId,
    );

    // 3. Combine remaining existing image URLs with newly uploaded ones
    List<String> finalImageUrls = [
      ...existingImageUrls.where((url) => !imagesToDelete.contains(url)),
      ...newlyUploadedImageUrls,
    ];
    if (finalImageUrls.length > 2) {
      finalImageUrls = finalImageUrls.sublist(0, 2);
    }

    // Get current user's display name for reporterName
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String reporterName = currentUser?.displayName ?? 'Unknown';

    if (isEditing) {
      // Update existing report: only update fields in the model, and use server timestamp for updatedAt
      if (report.reportId.isEmpty) {
        throw Exception('Report ID is missing for an update operation.');
      }
      final updatedReport = report.copyWith(
        images: finalImageUrls,
        reporterName: reporterName,
        searchKeyWords: _generateSearchKeywords(report),
      );
      await _firestore
          .collection(_reportsCollectionPath)
          .doc(report.reportId)
          .update({
            ...updatedReport.toFirestore(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } else {
      // Create new report: set createdAt and updatedAt to server timestamp
      final newReportRef = _firestore.collection(_reportsCollectionPath).doc();
      final newReport = report.copyWith(
        reportId: newReportRef.id,
        reporterUid: userId,
        reporterName: reporterName,
        images: finalImageUrls,
        searchKeyWords: _generateSearchKeywords(report),
      );
      await newReportRef.set({
        ...newReport.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _deleteImagesFromStorage(Set<String> imageUrls) async {
    for (final imageUrl in imageUrls) {
      try {
        // Ensure the URL is a Firebase Storage URL before trying to delete
        // If you are using Cloudinary for new uploads, but Firebase Storage for existing ones,
        // this check is important. If all images move to Cloudinary, this logic needs adjustment.
        if (imageUrl.contains('firebasestorage.googleapis.com')) {
          await _firebaseStorage.refFromURL(imageUrl).delete();
          debugPrint('Deleted image from Firebase Storage: $imageUrl');
        } else {
          // Assuming Cloudinary URLs don't need direct deletion from Firebase Storage
          debugPrint('Skipping deletion for non-Firebase Storage URL: $imageUrl (Likely Cloudinary)');
          // If you need to delete from Cloudinary, you'd add imageUploadService.deleteImage(imageUrl) here.
        }
      } catch (e) {
        debugPrint('Error deleting image from storage ($imageUrl): $e');
      }
    }
  }

  // Re-use your keyword generation logic - consider moving this to the Report model itself
  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>[];
    // Handle nullable ownerName safely
    if (r.ownerName != null && r.ownerName!.isNotEmpty) {
      keywords.add(r.ownerName!.toLowerCase());
    }
    for (var term in [
      r.ownerName, // Now includes nullable check directly via '?' in Report model
    ]) {
      // Handle nullable terms safely
      if (term != null && term.isNotEmpty) {
        final cleanedTerm = term
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '');
        final words = cleanedTerm.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);

        for (var word in words) {
          keywords.add(word);
          // Add prefixes as keywords for better search
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