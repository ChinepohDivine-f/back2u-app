// lib/views/report/report_summary.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/views/home/index.dart'; // Assuming this is your home page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:back2u/services/image_upload_service.dart'; // For new image uploads
import 'package:back2u/services/update_report_service.dart'; // NEW: Your service for report updates

class SummaryPage extends StatefulWidget {
  final Report report; // The complete Report object
  final List<XFile> localImageFiles; // NEWLY picked local image files to upload
  final List<String> existingImageUrls; // URLs of existing images (from original report)
  final Set<String> imagesToDelete; // URLs of existing images marked for deletion
  final bool isEditing; // Flag to indicate if this is an edit operation

  const SummaryPage({
    super.key,
    required this.report,
    this.localImageFiles = const [],
    this.existingImageUrls = const [],
    this.imagesToDelete = const {},
    this.isEditing = false,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  // We assume _rememberContactInfo is handled by the ContactPage before navigating here
  // and applied to the user's profile. So, it's not strictly needed for _submitFinalReport.
  // bool _rememberContactInfo = true; // Kept for consistency if needed later

  final ImageUploadService _imageUploadService = ImageUploadService();
  final UpdateReportService _updateReportService = UpdateReportService(); // Instantiate the new service
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Combine images for display: existing (not deleted) + new local ones
    final List<String> currentDisplayImageUrls = widget.existingImageUrls
        .where((url) => !widget.imagesToDelete.contains(url))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.report.type} Report - Summary'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please review your report details carefully before submitting.',
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 24),

                  // Item/Document Details
                  _buildSection(
                    context,
                    title: 'Item Details',
                    children: [
                      _buildInfoRow(
                          context,
                          'Type',
                          widget.report.type,
                          icon: widget.report.type == 'Lost'
                              ? Icons.search_off
                              : Icons.volunteer_activism),
                      _buildInfoRow(
                          context,
                          'Owner Name',
                          widget.report.ownerName!.isNotEmpty
                              ? widget.report.ownerName!
                              : 'N/A',
                          icon: Icons.person_outline),
                      _buildInfoRow(context, 'Category',
                          '${widget.report.category} > ${widget.report.subcategory}',
                          icon: Icons.category_outlined),
                      _buildInfoRow(
                          context,
                          'Incident Date',
                          DateFormat('MMM dd, yyyy')
                              .format(widget.report.reportedDate.toDate()),
                          icon: Icons.event_note_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Details
                  _buildSection(
                    context,
                    title: 'Location',
                    children: [
                      _buildInfoRow(
                          context, 'Main Location', widget.report.locationLost,
                          icon: Icons.location_on_outlined),
                      _buildInfoRow(
                          context,
                          'Sub-Location',
                          widget.report.subLocationLost.isNotEmpty
                              ? widget.report.subLocationLost
                              : 'N/A',
                          icon: Icons.location_city_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Notes
                  if (widget.report.notes.isNotEmpty)
                    _buildSection(
                      context,
                      title: 'Additional Notes',
                      children: [
                        Text(widget.report.notes, style: textTheme.bodyLarge),
                      ],
                    ),
                  if (widget.report.notes.isNotEmpty) const SizedBox(height: 16),

                  // Images
                  if (currentDisplayImageUrls.isNotEmpty || widget.localImageFiles.isNotEmpty)
                    _buildSection(
                      context,
                      title: 'Images',
                      children: [
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentDisplayImageUrls.length + widget.localImageFiles.length,
                            itemBuilder: (context, index) {
                              if (index < currentDisplayImageUrls.length) {
                                // Existing image (not marked for deletion)
                                final imageUrl = currentDisplayImageUrls[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                );
                              } else {
                                // Newly selected image
                                final newImageIndex = index - currentDisplayImageUrls.length;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(widget.localImageFiles[newImageIndex].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  if (currentDisplayImageUrls.isNotEmpty || widget.localImageFiles.isNotEmpty) const SizedBox(height: 16),

                  // Reward
                  if (widget.report.reward.isNotEmpty && widget.report.reward != '0')
                    _buildSection(
                      context,
                      title: 'Reward Offered',
                      titleColor: colorScheme.primary,
                      children: [
                        _buildInfoRow(
                            context, 'Amount', 'XAF ${widget.report.reward}',
                            icon: Icons.monetization_on_outlined),
                      ],
                    ),
                  if (widget.report.reward.isNotEmpty && widget.report.reward != '0')
                    const SizedBox(height: 16),

                  // Contact Information
                  _buildSection(
                    context,
                    title: 'Contact Information',
                    children: [
                      _buildInfoRow(
                          context,
                          'Phone Number',
                          widget.report.contactPhone.isNotEmpty
                              ? widget.report.contactPhone
                              : 'N/A',
                          icon: Icons.phone_outlined),
                      _buildInfoRow(
                          context,
                          'WhatsApp Number',
                          widget.report.whatsappNumber.isNotEmpty
                              ? widget.report.whatsappNumber
                              : 'N/A',
                          icon: Icons.message),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Confirm and Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submitFinalReport,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(widget.isEditing ? 'Confirm and Update Report' : 'Confirm and Submit Report'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Future<void> _submitFinalReport() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in. Please log in to submit a report.');
      }

      await _updateReportService.handleReportSubmission(
        report: widget.report,
        localImageFiles: widget.localImageFiles,
        existingImageUrls: widget.existingImageUrls,
        imagesToDelete: widget.imagesToDelete,
        isEditing: widget.isEditing,
        userId: currentUser.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Report updated successfully!' : 'Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Home and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during report submission/update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Failed to update report: ${e.toString()}' : 'Failed to submit report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Helper to generate search keywords from report data
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

  // Helper widget to build sections with titles and dividers
  Widget _buildSection(BuildContext context,
      {required String title,
      required List<Widget> children,
      Color? titleColor}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor ?? textTheme.titleLarge?.color,
            ),
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  // Helper widget to build individual info rows
  Widget _buildInfoRow(BuildContext context, String label, String value,
      {IconData? icon}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}