import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:back2u/models/report_model.dart'; // Import your Report model
// Import your home page or a success page to navigate after submission
import 'package:back2u/views/home/index.dart'; // Example: navigate to home
import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryPage extends StatelessWidget {
  final Report report; // The complete Report object
  final List<XFile> localImageFiles; // Local image files to display

  const SummaryPage({
    super.key,
    required this.report,
    this.localImageFiles = const [],
  });

  Future<void> _submitFinalReport(BuildContext context) async {
    // TODO: Implement actual report submission logic here
    // 1. Upload images to Firebase Storage or your chosen cloud storage
    //    - Iterate through localImageFiles, upload each one.
    //    - Get the download URLs.
    // 2. Create a new Report object with the image URLs and other final details
    //    - Example: Generate a unique reportId (e.g., UUID).
    //    - Set reporterId (from current user session).
    //    - Set createdAt (if not already set at ContactPage).
    //    - Update the `images` list in the Report model with the new URLs.
    // 3. Save the Report object to Firestore (or your backend database)
    //    - report.toFirestore() will give you a Map to save.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting report...')),
    );

    try {
      // --- Simulate Image Upload ---
      List<String> imageUrls = [];
      if (localImageFiles.isNotEmpty) {
        for (var imageFile in localImageFiles) {
          // In a real app, upload imageFile.path to storage and get URL
          // For demo, we'll just use a placeholder URL
          await Future.delayed(const Duration(milliseconds: 200)); // Simulate upload time
          imageUrls.add('https://via.placeholder.com/150/random_hex_color/FFFFFF?text=Uploaded_${imageFile.path.hashCode}');
        }
      }

      // --- Finalize Report Object with Generated IDs and Uploaded Image URLs ---
      final finalReport = report.copyWith(
        reportId: 'REP-${DateTime.now().millisecondsSinceEpoch}', // Generate a unique ID
        reporterId: 'currentUserId123', // Replace with actual user ID from auth
        createdAt: report.createdAt.toDate().isAfter(DateTime(2000)) ? report.createdAt : Timestamp.now(), // Ensure createdAt is set
        images: imageUrls, // Assign the uploaded image URLs
        status: 'active', // Default status upon submission
        searchKeyWords: _generateSearchKeywords(report), // Generate search keywords
      );

      // --- Simulate Saving to Firestore ---
      // Example Firestore save (requires Firebase setup and initialization)
      // await FirebaseFirestore.instance.collection('reports').doc(finalReport.reportId).set(finalReport.toFirestore());

      await Future.delayed(const Duration(seconds: 1)); // Simulate database save time

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to Home or a dedicated success screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()), // Assuming Home is where you want to go
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error submitting report: $e');
    }
  }

  // Helper to generate search keywords from report data
  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>[];
    keywords.add(r.ownerName?.toLowerCase() ?? '');
    keywords.add(r.documentName.toLowerCase());
    keywords.add(r.category.toLowerCase());
    keywords.add(r.subcategory.toLowerCase());
    keywords.add(r.locationLost.toLowerCase());
    keywords.add(r.subLocationLost.toLowerCase());
    keywords.add(r.type.toLowerCase());
    // Add words from notes, split by space, remove punctuation
    keywords.addAll(r.notes.toLowerCase().split(RegExp(r'\s+')).map((word) => word.replaceAll(RegExp(r'[^\w\s]'), '')).where((word) => word.isNotEmpty));
    return keywords.where((k) => k.isNotEmpty).toSet().toList(); // Ensure unique and non-empty
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {IconData? icon}) {
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
                  style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${report.type} Report - Summary'),
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
              style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 24),

            // Item/Document Details
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item Details', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildInfoRow(context, 'Type', report.type, icon: report.type == 'Lost' ? Icons.search_off : Icons.volunteer_activism),
                  _buildInfoRow(context, 'Owner/Document Name', report.ownerName ?? 'N/A', icon: Icons.person_outline),
                  // _buildInfoRow(context, 'Document/Item', report.documentName, icon: Icons.description_outlined),
                  _buildInfoRow(context, 'Category', '${report.category} > ${report.subcategory}', icon: Icons.category_outlined),
                  _buildInfoRow(context, 'Incident Date', DateFormat('MMM dd, yyyy').format(report.reportedDate.toDate()), icon: Icons.event_note_outlined),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location Details
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildInfoRow(context, 'Main Location', report.locationLost, icon: Icons.location_on_outlined),
                  if (report.subLocationLost.isNotEmpty)
                    _buildInfoRow(context, 'Sub-Location', report.subLocationLost, icon: Icons.location_city_outlined),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            if (report.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Notes', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    Text(report.notes, style: textTheme.bodyLarge),
                  ],
                ),
              ),
            if (report.notes.isNotEmpty) const SizedBox(height: 16),

            // Images
            if (localImageFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Images', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: localImageFiles.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(localImageFiles[index].path),
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
              ),
            if (localImageFiles.isNotEmpty) const SizedBox(height: 16),

            // Reward
            if (report.reward.isNotEmpty && report.reward != '0')
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reward Offered', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    const Divider(height: 20),
                    _buildInfoRow(context, 'Amount', 'XAF ${report.reward}', icon: Icons.monetization_on_outlined),
                  ],
                ),
              ),
            if (report.reward.isNotEmpty && report.reward != '0') const SizedBox(height: 16),

            // Contact Information
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Information', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildInfoRow(context, 'Phone Number', report.contactPhone, icon: Icons.phone_outlined),
                  if (report.whatsappNumber.isNotEmpty)
                    _buildInfoRow(context, 'WhatsApp Number', report.whatsappNumber, icon: Icons.phone),
                ],
              ),
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
                  backgroundColor: colorScheme.primary, // Use a distinct color for confirmation
                  foregroundColor: colorScheme.onTertiary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}