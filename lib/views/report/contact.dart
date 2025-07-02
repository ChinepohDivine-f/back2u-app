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
import 'package:back2u/l10n/app_localizations.dart';

import 'package:back2u/services/form_data_fetch_service.dart';
import 'package:back2u/utils/phone_number_formatter.dart';
import 'package:back2u/views/settings/kyc_update_page.dart';

class ContactPage extends StatefulWidget {
  final Report report;
  final List<XFile> localImageFiles;
  final List<String> existingImageUrls;
  final Set<String> imagesToDelete;
  final bool isEditing;

  const ContactPage({
    super.key,
    required this.report,
    this.localImageFiles = const [],
    this.existingImageUrls = const [],
    this.imagesToDelete = const {},
    this.isEditing = false,
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  bool _usePhoneAsWhatsapp = false;
  bool _isLoadingContactInfo = false;
  bool _isPhoneFromProfile = false;

  final DataFetchService _dataFetchService = DataFetchService();
  String? _currentUserId;
  static const String _userCollectionPath = 'back2u/countries/cameroon/data/users';

  String _stripCountryCode(String phone) {
    if (phone.isEmpty) return '';
    phone = phone.trim();
    if (phone.startsWith('+237 ')) {
      return phone.substring(5).trim();
    }
    if (phone.startsWith('+237')) {
      return phone.substring(4).trim();
    }
    return phone;
  }

  String _addCountryCode(String phone) {
    if (phone.isEmpty) return '';
    phone = phone.trim();
    if (phone.startsWith('+237 ')) return phone;
    if (phone.startsWith('+237')) return '+237 ${phone.substring(4).trim()}';
    return '+237 $phone';
  }

  @override
  void initState() {
    super.initState();
    print('[ContactPage] Initializing contact page');
    
    // Initialize controllers with existing report data
    _phoneController = TextEditingController(text: _stripCountryCode(widget.report.contactPhone));
    _whatsappController = TextEditingController(text: _stripCountryCode(widget.report.whatsappNumber));
    
    // Check if numbers are the same to set checkbox
    _usePhoneAsWhatsapp = widget.report.contactPhone.isNotEmpty && 
                         widget.report.contactPhone == widget.report.whatsappNumber;
    
    _getCurrentUserAndFetchContactInfo();
  }

  void _getCurrentUserAndFetchContactInfo() async {
    print('[ContactPage] Fetching user contact info');
    setState(() {
      _isLoadingContactInfo = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUserId = user.uid;
        try {
          final userDoc = await FirebaseFirestore.instance
              .doc('$_userCollectionPath/${user.uid}')
              .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            print('[ContactPage] Found user profile with phone: ${userData['phone']}');
            setState(() {
              // Only pre-fill from profile if the report's contact field is empty
              if (widget.report.contactPhone.isEmpty && userData['phone'] != null) {
                String phone = _stripCountryCode(userData['phone']);
                _phoneController.text = phone;
                _isPhoneFromProfile = true;
                
                // Check if phone matches whatsapp number and both are not empty
                if (userData['whatsappNumber'] != null && 
                    userData['phone'] != null && 
                    userData['whatsappNumber'] == userData['phone'] &&
                    userData['phone'].isNotEmpty) {
                  _usePhoneAsWhatsapp = true;
                }
                
                print('[ContactPage] Pre-filled phone from profile: $phone');
              }
            });
          }
        } else {
          print('[ContactPage] No user profile found');
        }
        } catch (e) {
          print('[ContactPage] Error accessing Firestore: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Network error: Please check your connection')),
            );
          }
        }
      } else {
        print('[ContactPage] User is not logged in');
      }
    } catch (e) {
      print('[ContactPage] Error fetching user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingContactInfo = false;
        });
      }
    }
  }

  void _onUsePhoneAsWhatsappChanged(bool? value) {
    print('[ContactPage] Use phone as WhatsApp changed to: $value');
    if (value == null) return;
    
    setState(() {
      _usePhoneAsWhatsapp = value;
    });
  }

  String? _validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Please provide a phone number.';
    }
    // Adjust validation to account for spaces from the formatter
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length != 9) {
      return 'Number must be exactly 9 digits.';
    }
    return null;
  }

  Future<void> _updateUserProfile(String uid, String phoneWithCode) async {
    try {
      final updates = {
        'phone': phoneWithCode,
        'whatsappNumber': _usePhoneAsWhatsapp ? phoneWithCode : '',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance
          .doc('$_userCollectionPath/$uid')
          .update(updates);
      print('[ContactPage] Successfully updated user profile');
    } catch (e) {
      print('[ContactPage] Error updating user profile: $e');
      throw e; // Rethrow to handle in calling function
    }
  }

  void _navigateToSummary() async {
    if (!_formKey.currentState!.validate()) {
      print('[ContactPage] Form validation failed');
      return;
    }

    try {
      print('[ContactPage] Form validation passed');
      final phoneWithCode = _addCountryCode(_phoneController.text);
      
      // Update user profile if logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('[ContactPage] Updating user profile');
        await _updateUserProfile(currentUser.uid, phoneWithCode);
      }

      // Update report
      final updatedReport = widget.report.copyWith(
        contactPhone: phoneWithCode,
        whatsappNumber: _usePhoneAsWhatsapp ? phoneWithCode : '',
      );

      print('[ContactPage] Report updated with contact info:');
      print('  - Phone: $phoneWithCode');
      print('  - WhatsApp: ${_usePhoneAsWhatsapp ? phoneWithCode : ""}');

      if (!mounted) return;

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
    } catch (e) {
      print('[ContactPage] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving contact information: $e')),
        );
      }
    }
  }

  void _navigateToPhoneVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KycUpdatePage(),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.contactInformation),
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
                      loc.provideContactDetails,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      readOnly: true, // Always read-only
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                        PhoneNumberFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: loc.phoneNumber,
                        hintText: '671 234 567',
                        prefixText: '+237 ',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _navigateToPhoneVerification,
                          tooltip: 'Update phone number',
                        ),
                      ),
                      validator: _validatePhoneNumber,
                    ),
                    const SizedBox(height: 8),

                    // Info text about phone verification
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Using verified phone number',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'To use a different number, please verify it first',
                                  style: TextStyle(
                                    color: colorScheme.primary.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToPhoneVerification,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Checkbox to use phone number as WhatsApp
                    CheckboxListTile(
                      title: Text('Use this number as WhatsApp number'),
                      value: _usePhoneAsWhatsapp,
                      onChanged: _onUsePhoneAsWhatsappChanged,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 32),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _navigateToSummary,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(loc.nextReviewReport),
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