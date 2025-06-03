import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:back2u/views/report/report_form.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/views/auth/kyc_form_page.dart';
import 'package:back2u/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final AuthKycService _authKycService = AuthKycService();
  User? _currentUser;
  AppUser? _appUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authKycService.authStateChanges.listen((user) async {
      setState(() {
        _currentUser = user;
        _isLoading = true;
      });
      if (user != null) {
        await _checkAndLoadUserProfile(user.uid);
      } else {
        _appUser = null;
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _checkAndLoadUserProfile(String uid) async {
    _appUser = await _authKycService.getUserProfile(uid);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authKycService.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToReportForm(String reportType) {
    final newReport = Report(
      type: reportType,
      reportId: 'temp_id_${DateTime.now().microsecondsSinceEpoch}',
      reporterUid: _currentUser!.uid,
      category: '',
      categoryFr: '',
      contactPhone: '',
      reportedDate: Timestamp.now(),
      documentName: '',
      images: [],
      locationLost: '',
      locationLostFr: '',
      notes: '',
      createdAt: Timestamp.now(),
      reporterId: '',
      resolved: false,
      reward: '',
      searchKeyWords: [],
      status: '',
      subLocationLost: '',
      subLocationLostFr: '',
      subcategory: '',
      subcategoryFr: '',
      whatsappNumber: '',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportForm(report: newReport)),
    );
  }

  Future<void> _showKycPromptDialog(String reportType) async {
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Complete Your Profile (KYC)',
            style: theme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your profile is not fully verified. Completing KYC enhances trust and security for interactions on Back2u.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Do you want to complete it now or proceed with your report without it?',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Continue Anyway'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _navigateToReportForm(reportType);
              },
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KycFormPage()),
                ).then((_) async {
                  if (_currentUser != null) {
                    await _checkAndLoadUserProfile(_currentUser!.uid);
                  }
                });
              },
              child: const Text('Complete Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Report'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : Padding(
              padding: const EdgeInsets.all(20.0), // Outer padding for the whole body content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures children stretch horizontally
                children: [
                  Text(
                    (_currentUser == null || _currentUser!.isAnonymous)
                        ? 'Register'
                        : 'What would you like to report?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Conditional rendering based on authentication status
                  if (_currentUser == null || _currentUser!.isAnonymous)
                    _buildAuthPrompt(theme, colors)
                  else
                    _buildReportButtons(theme, colors),
                ],
              ),
            ),
    );
  }

  Widget _buildAuthPrompt(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Text(
          'Please sign in to create a report and help us keep the community safe.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _signInWithGoogle,
            icon: Image.asset('assets/images/google-logo.png', height: 24.0),
            label: Text(
              'Sign in with Google',
              style: theme.textTheme.titleMedium,
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportButtons(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure children stretch horizontally
      children: [
        // Display KYC status if not complete
        if (_appUser != null && !_appUser!.kycCompleted)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.onTertiaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your profile is not fully verified. Consider completing KYC for full trust.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.onTertiaryContainer),
                  ),
                ),
                TextButton(
                  onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KycFormPage()),
                     ).then((_) async {
                        if (_currentUser != null) {
                          await _checkAndLoadUserProfile(_currentUser!.uid);
                        }
                     });
                  },
                  child: Text(
                    'Verify Now',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: colors.tertiary),
                  ),
                ),
              ],
            ),
          ),
        // Add spacing between the KYC banner and the buttons if the banner is present
        if (_appUser != null && !_appUser!.kycCompleted)
          const SizedBox(height: 20),

        // NEW: Row for Report Lost/Found Item Buttons
        Row(
          children: [
            SizedBox(
              child: FilledButton.icon(
                onPressed: () {
                  if (_appUser != null && !_appUser!.kycCompleted) {
                    _showKycPromptDialog('lost');
                  } else {
                    _navigateToReportForm('lost');
                  }
                },
                icon: const Icon(Icons.search_off, size: 30),
                label: Text(
                  'Report Lost Item',
                  style: theme.textTheme.titleSmall, // Use titleSmall for better fit
                  textAlign: TextAlign.center, // Center text within the button
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.secondaryContainer, // Added explicit background color
                  foregroundColor: colors.onSecondaryContainer, // Added explicit foreground color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Adjusted horizontal padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center, // Center content within the button
                ),
              ),
            ),
            const SizedBox(width: 15), // Horizontal spacing between buttons

            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (_appUser != null && !_appUser!.kycCompleted) {
                    _showKycPromptDialog('found');
                  } else {
                    _navigateToReportForm('found');
                  }
                },
                icon: const Icon(Icons.volunteer_activism, size: 30),
                label: Text(
                  'Report Found Item',
                  style: theme.textTheme.titleSmall, // Use titleSmall for better fit
                  textAlign: TextAlign.center, // Center text within the button
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primaryContainer, // Added explicit background color
                  foregroundColor: colors.onPrimaryContainer, // Added explicit foreground color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Adjusted horizontal padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center, // Center content within the button
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}