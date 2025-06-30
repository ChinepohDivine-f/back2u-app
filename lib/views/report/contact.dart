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
import 'package:back2u/utils/phone_number_formatter.dart';

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
  late TextEditingController _phoneController;
  bool _useSameForWhatsApp = false;
  bool _isLoadingContactInfo = false;
  bool _isPhoneFromProfile = false;

  final DataFetchService _dataFetchService = DataFetchService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Remove '+237' prefix if present for display
    String initialPhone = widget.report.contactPhone;
    if (initialPhone.startsWith('+237')) {
      initialPhone = initialPhone.substring(4).trim();
    }
    _phoneController = TextEditingController(text: initialPhone);

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
          // Only pre-fill from profile if the report's contact field is empty.
          // This way, if we're editing and number was already set, it persists.
          if (widget.report.contactPhone.isEmpty && appUser.phone != null) {
            String phone = appUser.phone!;
            if (phone.startsWith('+237')) {
              phone = phone.substring(4).trim();
            }
            _phoneController.text = phone;
            _isPhoneFromProfile = true;
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

  // Validator to ensure phone number is provided
  String? _validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Please provide a phone number.';
    }
    // Adjust validation to account for spaces from the formatter
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 9) {
      return 'Number must be 9 digits.';
    }
    return null;
  }

  void _navigateToSummary() async {
    final String phoneText = _phoneController.text.trim();
    final String whatsappText = _useSameForWhatsApp ? phoneText : '';

    if (_formKey.currentState!.validate()) {
      // Create a *copy* of the report object and update its contact properties
      // Note: createdAt will be set in SummaryPage for new reports, not here.
      final updatedReport = widget.report.copyWith(
        contactPhone: phoneText,
        whatsappNumber: whatsappText,
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
    }
  }

  @override
  void dispose() {
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
                      'Provide your contact details for people to reach you.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),

                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      readOnly: _isPhoneFromProfile, // Make read-only if from profile
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                        PhoneNumberFormatter(), // Apply custom formatter
                      ],
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '671 234 567',
                        prefixText: '+237 ',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                      ),
                      validator: _validatePhoneNumber,
                    ),
                    const SizedBox(height: 10),

                    // Info box if phone is from profile
                    if (_isPhoneFromProfile)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This is the verified phone number from your profile.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Checkbox to use same number for WhatsApp
                    Row(
                      children: [
                        Checkbox(
                          value: _useSameForWhatsApp,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _useSameForWhatsApp = newValue ?? false;
                            });
                          },
                          activeColor: colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            'Use the same number for WhatsApp',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
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