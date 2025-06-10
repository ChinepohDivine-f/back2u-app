// lib/views/report/contact.dart
import 'dart:io';
import 'package:back2u/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/views/report/report_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:back2u/services/form_data_fetch_service.dart';

class ContactPage extends StatefulWidget {
  final Report report;
  final List<XFile> localImageFiles; // New images to upload
  final List<String> existingImageUrls; // Original image URLs on the report
  final Set<String> imagesToDelete; // URLs of images marked for deletion
  final bool isEditing; // Flag to indicate if this is an edit flow

  const ContactPage({
    super.key,
    required this.report,
    this.localImageFiles = const [],
    this.existingImageUrls = const [],
    this.imagesToDelete = const {},
    this.isEditing = false, // Default to false for new reports
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _whatsappController;
  late TextEditingController _phoneController;
  bool _saveToProfile = false;
  bool _isLoadingContactInfo = false;

  final DataFetchService _dataFetchService = DataFetchService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing report data or empty string
    _whatsappController = TextEditingController(text: widget.report.whatsappNumber);
    _phoneController = TextEditingController(text: widget.report.contactPhone);

    _getCurrentUserAndFetchContactInfo();
  }

  void _getCurrentUserAndFetchContactInfo() async {
    setState(() {
      _isLoadingContactInfo = true;
    });

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      final AppUser? appUser = await _dataFetchService.fetchUser(_currentUserId!);

      if (appUser != null) {
        setState(() {
          // Only pre-fill from profile if the report's contact fields are empty.
          // This way, if we're editing and numbers were already set, they persist.
          if (widget.report.whatsappNumber.isEmpty && appUser.whatsappNumber != null) {
            _whatsappController.text = appUser.whatsappNumber!;
          }
          if (widget.report.contactPhone.isEmpty && appUser.phone != null) {
            _phoneController.text = appUser.phone!;
          }
        });
      }
    } else {
      debugPrint('User is not logged in. Cannot fetch profile contact info.');
      // Optionally, show a snackbar or guide the user to log in
    }

    setState(() {
      _isLoadingContactInfo = false;
    });
  }

  // Validator to ensure at least one number is provided
  String? _validateContactNumbers(String? whatsapp, String? phone) {
    if ((whatsapp == null || whatsapp.trim().isEmpty) && (phone == null || phone.trim().isEmpty)) {
      return 'Please provide at least one contact number.';
    }
    return null;
  }

  void _navigateToSummary() async {
    final String whatsappText = _whatsappController.text.trim();
    final String phoneText = _phoneController.text.trim();
    final String? combinedError = _validateContactNumbers(whatsappText, phoneText);

    if (_formKey.currentState!.validate() && combinedError == null) {
      // If 'Save to profile' is checked and user is logged in, update profile
      if (_saveToProfile && _currentUserId != null) {
        try {
          // Use .set with merge: true to avoid overwriting other user data
          await FirebaseFirestore.instance
              .collection(_dataFetchService.usersCollectionPath())
              .doc(_currentUserId!)
              .set(
                {
                  'whatsappNumber': whatsappText.isNotEmpty ? whatsappText : null, // Set to null if empty
                  'phone': phoneText.isNotEmpty ? phoneText : null, // Set to null if empty
                  'updatedAt': FieldValue.serverTimestamp(), // Use server timestamp
                },
                SetOptions(merge: true),
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact info saved to profile!')),
            );
          }
        } catch (e) {
          debugPrint('Error saving contact info to profile: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save contact info to profile.'), backgroundColor: Colors.red),
            );
          }
        }
      }

      // Create a *copy* of the report object and update its contact properties
      // Note: createdAt will be set in SummaryPage for new reports, not here.
      final updatedReport = widget.report.copyWith(
        whatsappNumber: whatsappText,
        contactPhone: phoneText,
      );

      // Pass all necessary data to the SummaryPage for final processing
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryPage(
              report: updatedReport,
              localImageFiles: widget.localImageFiles,
              existingImageUrls: widget.existingImageUrls,
              imagesToDelete: widget.imagesToDelete,
              isEditing: widget.isEditing,
            ),
          ),
        );
      }
    } else {
      if (mounted && combinedError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(combinedError), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Information'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoadingContactInfo
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Provide your contact details. At least one number is required.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),

                    // WhatsApp Number Field
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9), // Standard 9 digits for Cameroon
                      ],
                      decoration: InputDecoration(
                        labelText: 'WhatsApp Number (e.g., 67X XXX XXXX)',
                        hintText: 'e.g., 671234567',
                        prefixIcon: const Icon(Icons.message),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 9) {
                          return 'Number must be 9 digits.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9), // Standard 9 digits for Cameroon
                      ],
                      decoration: InputDecoration(
                        labelText: 'Phone Number (e.g., 69X XXX XXXX)',
                        hintText: 'e.g., 698765432',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                      ),
                       validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 9) {
                          return 'Number must be 9 digits.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Checkbox to save to profile
                    Row(
                      children: [
                        Checkbox(
                          value: _saveToProfile,
                          onChanged: _currentUserId != null
                              ? (bool? newValue) {
                                  setState(() {
                                    _saveToProfile = newValue ?? false;
                                  });
                                }
                              : null, // Disable if user is not logged in
                          activeColor: colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            'Save this information to my profile',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    if (_currentUserId == null)
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, top: 4.0),
                        child: Text(
                          'Sign in to enable this option.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _navigateToSummary,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('NEXT: Review Report'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}