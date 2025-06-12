// lib/views/report/report_summary.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/views/home/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:back2u/services/image_upload_service.dart';
import 'package:back2u/services/update_report_service.dart';

class SummaryPage extends StatefulWidget {
  final Report report;
  final List<XFile> localImageFiles;
  final List<String> existingImageUrls;
  final Set<String> imagesToDelete;
  final bool isEditing;

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
  final UpdateReportService _updateReportService = UpdateReportService();

  bool _isSubmitting = false;
  bool _hasSubmittedSuccessfully = false;
  // Unique ID for each submission attempt, primarily for idempotency if implemented.
  // Currently, the UpdateReportService doesn't use it, but keeping it as a pattern.
  String? _submissionId;

  @override
  void initState() {
    super.initState();
    _submissionId = '${DateTime.now().millisecondsSinceEpoch}_${widget.report.hashCode}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final List<String> currentDisplayImageUrls = widget.existingImageUrls
        .where((url) => !widget.imagesToDelete.contains(url))
        .toList();

    return PopScope(
      // Prevent accidental back navigation during submission
      canPop: !_isSubmitting,
      onPopInvoked: (didPop) {
        if (_isSubmitting && !didPop) {
          _showSubmissionInProgressDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.report.type} Report - Summary'),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          // Disable back button when submitting
          automaticallyImplyLeading: !_isSubmitting,
        ),
        body: _isSubmitting
            ? _buildSubmissionLoadingWidget() // Show a dedicated loading screen
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
                            // Handle null safety for ownerName here
                            widget.report.ownerName?.isNotEmpty == true
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
                        onPressed: _canSubmit() ? _submitFinalReport : null,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(_getButtonText()),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                          backgroundColor: _canSubmit()
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.12),
                          foregroundColor: _canSubmit()
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // Determines if the button should be enabled
  bool _canSubmit() {
    return !_isSubmitting && !_hasSubmittedSuccessfully;
  }

  // Dynamically changes the button text
  String _getButtonText() {
    if (_isSubmitting) {
      return widget.isEditing ? 'Updating Report...' : 'Submitting Report...';
    }
    if (_hasSubmittedSuccessfully) {
      return widget.isEditing ? 'Report Updated!' : 'Report Submitted!';
    }
    return widget.isEditing ? 'Confirm and Update Report' : 'Confirm and Submit Report';
  }

  // A dedicated loading widget for the body when submitting
  Widget _buildSubmissionLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 24),
          Text(
            widget.isEditing ? 'Updating your report...' : 'Submitting your report...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Please do not close the app or navigate away.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dialog to show if user tries to go back during submission
  void _showSubmissionInProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Submission in Progress'),
        content: const Text(
          'Your report is currently being processed. Please wait for the submission to complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFinalReport() async {
    // Safeguard against double-tap if UI state hasn't updated yet
    if (_isSubmitting || _hasSubmittedSuccessfully) {
      debugPrint('Submission blocked: already in progress or completed');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in. Please log in to submit a report.');
      }

      // Check network connectivity first
      await _validateSubmissionPrerequisites();

      // Delegate the entire submission/update process to UpdateReportService
      await _updateReportService.handleReportSubmission(
        report: widget.report,
        localImageFiles: widget.localImageFiles,
        existingImageUrls: widget.existingImageUrls,
        imagesToDelete: widget.imagesToDelete,
        isEditing: widget.isEditing,
        userId: currentUser!.uid,
      ).timeout(const Duration(seconds: 30)); // 30-second timeout for the whole operation

      // If successful, set flag
      _hasSubmittedSuccessfully = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Report updated successfully!' : 'Report submitted successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Small delay to allow the user to see the success message and button state
        await Future.delayed(const Duration(milliseconds: 1500));

        // Navigate to Home and remove all previous routes
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on TimeoutException {
      debugPrint('Submission timed out.');
      _showErrorSnackBar(
        widget.isEditing
            ? 'Update timed out. Please check your internet connection and try again.'
            : 'Submission timed out. Please check your internet connection and try again.',
      );
    } on SocketException {
      debugPrint('SocketException: No internet connection.');
      _showErrorSnackBar(
        'No internet connection. Please connect to the internet and try again.',
      );
    } on FirebaseException catch (e) {
      debugPrint('Firebase Error during report submission/update: ${e.code} - ${e.message}');
      String message;
      if (e.code == 'unavailable' || e.code == 'deadlinerexceeded') {
        message = 'Server unreachable. Please check your internet connection.';
      } else if (e.code == 'permission-denied') {
        message = 'Permission denied. You may not have access to perform this action.';
      } else if (e.code == 'unauthenticated') {
        message = 'You are not logged in. Please log in again.';
      } else {
        message = 'An unexpected Firebase error occurred: ${e.message}';
      }
      _showErrorSnackBar(
        widget.isEditing ? 'Failed to update report: $message' : 'Failed to submit report: $message',
      );
    } catch (e) {
      debugPrint('General Error during report submission/update: $e');
      _showErrorSnackBar(
        widget.isEditing
            ? 'Failed to update report: An unknown error occurred.'
            : 'Failed to submit report: An unknown error occurred.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false; // Reset submission state
        });
      }
    }
  }

  // Pre-submission checks (network and authentication)
  Future<void> _validateSubmissionPrerequisites() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw const SocketException('No active network connection.');
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Authentication expired. Please log in again.');
    }
  }

  // Generic error snackbar display
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Helper to generate search keywords from report data (This logic is also in UpdateReportService,
  // ideally it should be a method on the Report model or in a dedicated helper class if widely used).
  List<String> _generateSearchKeywords(Report r) {
    final keywords = <String>[];

    if (r.ownerName?.isNotEmpty == true) {
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
      if (term?.isNotEmpty == true) {
        final cleanedTerm = term!
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