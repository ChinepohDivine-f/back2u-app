import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/views/home/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:back2u/services/image_upload_service.dart'; // NEW: Import your service

class SummaryPage extends StatefulWidget {
  final Report report; // The complete Report object
  final List<XFile> localImageFiles; // Local image files to display

  const SummaryPage({
    super.key,
    required this.report,
    this.localImageFiles = const [],
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _rememberContactInfo = true; // Default to true, users can uncheck

  // Instantiate the ImageUploadService
  final ImageUploadService _imageUploadService = ImageUploadService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.report.type} Report - Summary'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please review your report details carefully before submitting.',
              style: textTheme.titleMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 24),

            // Item/Document Details
            _buildSection(
              context,
              title: 'Item Details',
              children: [
                _buildInfoRow(context, 'Type', widget.report.type,
                    icon: widget.report.type == 'Lost'
                        ? Icons.search_off
                        : Icons.volunteer_activism),
                _buildInfoRow(
                    context,
                    'Owner Name',
                    widget.report.ownerName!.isNotEmpty
                        ? widget.report.ownerName!
                        : 'N/A', // Handle empty owner name
                    icon: Icons.person_outline),
                _buildInfoRow(context, 'Category',
                    '${widget.report.category} > ${widget.report.subcategory}',
                    icon: Icons.category_outlined),
                _buildInfoRow(
                    context,
                    'Incident Date',
                    DateFormat('MMM dd, yyyy') // Changed format for clarity
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
                    context, // Always show sub-location, even if N/A
                    'Sub-Location',
                    widget.report.subLocationLost.isNotEmpty
                        ? widget.report.subLocationLost
                        : 'N/A',
                    icon: Icons.location_city_outlined),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Notes - Simplified and padding adjusted
            if (widget.report.notes.isNotEmpty) // Only show if notes exist
              _buildSection(
                context,
                title: 'Additional Notes',
                children: [
                  Text(widget.report.notes, style: textTheme.bodyLarge),
                ],
              ),
            if (widget.report.notes.isNotEmpty) const SizedBox(height: 16),

            // Images
            if (widget.localImageFiles.isNotEmpty)
              _buildSection(
                context,
                title: 'Images',
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.localImageFiles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(widget.localImageFiles[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            if (widget.localImageFiles.isNotEmpty) const SizedBox(height: 16),

            // Reward - Simplified and padding adjusted
            if (widget.report.reward.isNotEmpty && widget.report.reward != '0')
              _buildSection(
                context,
                title: 'Reward Offered',
                titleColor: colorScheme.primary, // Highlight reward title
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
                        : 'N/A', // Handle empty phone number
                    icon: Icons.phone_outlined),
                _buildInfoRow(
                    context,
                    'WhatsApp Number',
                    widget.report.whatsappNumber.isNotEmpty
                        ? widget.report.whatsappNumber
                        : 'N/A', // Handle empty WhatsApp number
                    icon: Icons
                        .phone_android), // Changed icon to WhatsApp specific
                const SizedBox(height: 10), // Small space before checkbox

                // Checkbox to remember contact info
                // Row(
                //   children: [
                //     Checkbox(
                //       value: _rememberContactInfo,
                //       onChanged: (bool? value) {
                //         setState(() {
                //           _rememberContactInfo = value ?? false;
                //         });
                //       },
                //       activeColor: colorScheme.primary,
                //     ),
                //     Expanded(
                //       // Use Expanded to prevent overflow for long text
                //       child: Text(
                //         'Remember my phone and WhatsApp numbers for future reports',
                //         style: textTheme
                //             .bodyMedium, // Use bodyMedium for checkbox text
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
            const SizedBox(height: 30),

            // Confirm and Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _submitFinalReport(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm and Submit Report'),
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

  Future<void> _submitFinalReport(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting report...')),
    );

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception(
            'User not logged in. Please log in to submit a report.');
      }

      // --- 1. Upload Images to ImageKit.io with Compression using the Service ---
      final List<String> imageUrls =
          await _imageUploadService.uploadImagesToCloudinary(
        imageFiles: widget.localImageFiles,
        userId: currentUser.uid,
      );
      // Removed the check for empty imageUrls here, as it's possible to have no images
      // if the report type is 'Lost'. The previous logic would throw an error.
      print('Images uploaded. URLs: $imageUrls');

      // --- 2. Finalize Report Object with Generated IDs and Uploaded Image URLs ---
      final String reportId = FirebaseFirestore.instance
          .collection('back2u/countries/cameroon/data/reports')
          .doc()
          .id;
      final finalReport = widget.report.copyWith(
        reportId: reportId,
        reporterId: currentUser.uid,
        reporterUid: currentUser.uid,
        createdAt: Timestamp.now(),
        images:
            imageUrls, // Assign the ImageKit.io URLs (can be empty if no images)
        status: 'pending',
        searchKeyWords: _generateSearchKeywords(widget.report),
      );

      // --- 3. Save the Report object to Firestore ---
      await FirebaseFirestore.instance
          .collection('back2u/countries/cameroon/data/reports')
          .doc(finalReport.reportId)
          .set(finalReport.toFirestore());
      print('Report saved to Firestore with ID: ${finalReport.reportId}');

      // --- 4. Update User's Profile with Phone/WhatsApp if checked ---
      if (_rememberContactInfo) {
        final userRef = FirebaseFirestore.instance
            .collection('back2u/countries/cameroon/data/users')
            .doc(currentUser.uid);

        // Only update if numbers are provided
        final Map<String, dynamic> updateData = {
          'updatedAt': Timestamp.now(),
        };
        if (finalReport.contactPhone.isNotEmpty) {
          updateData['phone'] = finalReport.contactPhone;
        }
        if (finalReport.whatsappNumber.isNotEmpty) {
          updateData['whatsappNumber'] = finalReport.whatsappNumber;
        }

        if (updateData.length > 1) {
          // If more than just updatedAt is present
          await userRef.update(updateData);
          print(
              'User contact info updated in Firestore for ${currentUser.uid}');
        } else {
          print('No contact info to update for user ${currentUser.uid}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Home and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to submit report: ${e.toString()}'), // Use .toString() for better error message
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error submitting report: $e');
    }
  }

  // Helper to generate search keywords from report data
  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>[];

    // 1. Store the full name as written (lowercase)
    if (r.ownerName != null && r.ownerName!.isNotEmpty) {
      keywords.add(r.ownerName!.toLowerCase());
    }

    // 2. Add individual words from ownerName, category, subcategory, location, type
    // and also generate slices (prefixes) for each word.
    for (var term in [
      r.ownerName,
      // r.category,
      // r.subcategory,
      // r.locationLost,
      // r.subLocationLost,
      // r.type
    ]) {
      if (term != null && term.isNotEmpty) {
        final cleanedTerm = term
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), ''); // Remove punctuation
        final words =
            cleanedTerm.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);

        for (var word in words) {
          // Store the full word
          keywords.add(word);

          // Generate slices (prefixes) of the word
          for (int i = 1; i <= word.length; i++) {
            keywords.add(word.substring(0, i));
          }
        }
      }
    }

    // 3. Add words from notes, split by space, remove punctuation (existing logic)
    if (r.notes.isNotEmpty) {
      keywords.addAll(r.notes
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .map((word) => word.replaceAll(RegExp(r'[^\w\s]'), ''))
          .where((word) => word.isNotEmpty));
    }

    // Ensure unique and non-empty keywords before returning
    return keywords
        .where((k) =>
            k.isNotEmpty &&
            k.length > 0) // Ensure not empty or just zero length
        .toSet()
        .toList();
  }

  // Helper widget to build sections with titles and dividers
  Widget _buildSection(BuildContext context,
      {required String title,
      required List<Widget> children,
      Color? titleColor}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 0.0), // Reduced horizontal padding
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
