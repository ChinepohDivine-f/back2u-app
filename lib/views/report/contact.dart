import 'dart:io'; // Required for XFile
import 'package:back2u/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:back2u/models/report_model.dart'; // Import your Report model
import 'package:back2u/views/report/report_summary.dart'; // Import the new SummaryPage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required to get current user ID

import 'package:back2u/services/form_data_fetch_service.dart'; // Import your data fetch service

class ContactPage extends StatefulWidget {
  final Report report; // Receive the partially filled Report object
  final List<XFile> localImageFiles; // Pass local image files for summary/upload

  const ContactPage({
    super.key,
    required this.report,
    this.localImageFiles = const [], // Initialize as empty list
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _whatsappController;
  late TextEditingController _phoneController;
  bool _saveToProfile = false;
  bool _isLoadingContactInfo = false; // New state to manage loading of user contact info

  final DataFetchService _dataFetchService = DataFetchService(); // Instance of your service
  String? _currentUserId; // To store the current authenticated user's ID

  @override
  void initState() {
    super.initState();
    _whatsappController = TextEditingController(text: widget.report.whatsappNumber);
    _phoneController = TextEditingController(text: widget.report.contactPhone);

    _getCurrentUserAndFetchContactInfo();
  }

  void _getCurrentUserAndFetchContactInfo() async {
    setState(() {
      _isLoadingContactInfo = true;
    });

    // Get the current authenticated user's ID
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      final AppUser? appUser = await _dataFetchService.fetchUser(_currentUserId!);

      if (appUser != null) {
        setState(() {
          // Only pre-fill if the fields are empty from the passed Report object
          // This ensures that if the user already typed something on the previous screen, it's not overwritten.
          if (widget.report.whatsappNumber.isEmpty && appUser.whatsappNumber != null) {
            _whatsappController.text = appUser.whatsappNumber!;
          }
          if (widget.report.contactPhone.isEmpty && appUser.phone != null) {
            _phoneController.text = appUser.phone!;
          }
        });
      }
    } else {
      // Handle case where user is not logged in or userId is null
      print('User is not logged in. Cannot fetch profile contact info.');
      // You might want to show a message to the user or navigate to login.
    }

    setState(() {
      _isLoadingContactInfo = false;
    });
  }

  // Validator to ensure at least one number is provided
  String? _validateContactNumbers(String? whatsapp, String? phone) {
    if ((whatsapp == null || whatsapp.trim().isEmpty) && (phone == null || phone.trim().isEmpty)) {
      return 'Please provide at least one contact number (WhatsApp or Phone).';
    }
    return null;
  }

  void _navigateToSummary() async {
    final String? whatsappText = _whatsappController.text.trim();
    final String? phoneText = _phoneController.text.trim();
    final String? combinedError = _validateContactNumbers(whatsappText, phoneText);

    if (_formKey.currentState!.validate() && combinedError == null) {
      // If 'Save to profile' is checked and user is logged in, update profile
      if (_saveToProfile && _currentUserId != null) {
        try {
          await FirebaseFirestore.instance
              .collection(_dataFetchService.usersCollectionPath()) // Using the path from service
              .doc(_currentUserId!)
              .update({
                'whatsappNumber': whatsappText,
                'phone': phoneText,
                'updatedAt': Timestamp.now(), // Update timestamp
              });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact info saved to profile!')),
          );
        } catch (e) {
          print('Error saving contact info to profile: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save contact info to profile.'), backgroundColor: Colors.red),
          );
        }
      }

      // Create a *copy* of the report object and update its contact properties
      final updatedReport = widget.report.copyWith(
        whatsappNumber: whatsappText ?? '',
        contactPhone: phoneText ?? '',
        createdAt: Timestamp.now(), // Set report creation date here
        // Set reporterId, unique reportId, etc. here or during final submission
      );

      // Pass the fully populated Report object and local images to the SummaryPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SummaryPage(report: updatedReport, localImageFiles: widget.localImageFiles)),
      );
    } else {
      if (combinedError != null) {
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
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
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
                        labelText: 'WhatsApp Number (e.g., 67X XXX XXXX)', // Updated hint for 9 digits
                        hintText: 'e.g., 671234567',
                        prefixIcon: const Icon(Icons.phone_callback),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        // Check if both fields are empty. If so, the _validateContactNumbers
                        // function called before _formKey.currentState.validate() will catch it.
                        // This validator only checks the length of the current field if it's not empty.
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
                        labelText: 'Phone Number (e.g., 69X XXX XXXX)', // Updated hint for 9 digits
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
                          onChanged: (bool? newValue) {
                            setState(() {
                              _saveToProfile = newValue ?? false;
                            });
                          },
                          activeColor: colorScheme.primary,
                        ),
                        Text('Save this information to my profile', style: Theme.of(context).textTheme.bodyLarge),
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