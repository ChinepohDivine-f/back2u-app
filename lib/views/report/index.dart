import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:back2u/views/report/report_form.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/services/auth_kyc_service.dart'; // Import the AuthKycService
import 'package:back2u/views/auth/kyc_form_page.dart'; // Import the KYC form page
import 'package:back2u/models/user_model.dart'; // Import AppUser model
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

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
    // Listen to authentication state changes
    _authKycService.authStateChanges.listen((user) async {
      setState(() {
        _currentUser = user;
        _isLoading = true; // Set loading true while fetching user profile
      });
      if (user != null) {
        // If user is logged in, fetch their AppUser profile
        await _checkAndLoadUserProfile(user.uid);
      } else {
        _appUser = null; // Clear AppUser if logged out
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
      // Auth state listener will automatically update _currentUser and _appUser
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

  // Helper to navigate to ReportForm
  void _navigateToReportForm(String reportType) {
    final newReport = Report(
      type: reportType,
      reportId: 'temp_id_${DateTime.now().microsecondsSinceEpoch}', // temp ID
      reporterUid: _currentUser!.uid, // Assign the authenticated user's UID
      category: '', categoryFr: '', contactPhone: '', reportedDate: Timestamp.now(),
      documentName: '', images: [], locationLost: '', locationLostFr: '',
      notes: '', createdAt: Timestamp.now(), reporterId: '', resolved: false,
      reward: '', searchKeyWords: [], status: '', subLocationLost: '',
      subLocationLostFr: '', subcategory: '', subcategoryFr: '',
      whatsappNumber: '',
    );  
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportForm(report: newReport)),
    );
  }

  // Show the KYC prompt dialog
  Future<void> _showKycPromptDialog(String reportType) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Complete Your Profile (KYC)',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Your profile is not fully verified. Completing KYC enhances trust and security for interactions on Back2u.',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text(
                  'Do you want to complete it now or proceed with your report without it?',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Continue Anyway',
                style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                _navigateToReportForm(reportType); // Proceed to report form
              },
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KycFormPage()),
                ).then((_) async {
                  // After returning from KYC form, refresh user profile to update KYC status
                  if (_currentUser != null) {
                    await _checkAndLoadUserProfile(_currentUser!.uid);
                  }
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                'Complete Now',
                style: textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Report'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (_currentUser == null || _currentUser!.isAnonymous)?'Register':'What would you like to report?',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Conditional rendering based on authentication status
                  if (_currentUser == null || _currentUser!.isAnonymous)
                    // User not authenticated or is anonymous, prompt to sign in
                    _buildAuthPrompt(context, colorScheme, textTheme)
                  else
                    // User authenticated (Google) - show report buttons directly
                    // KYC check will happen when report buttons are pressed
                    _buildReportButtons(context, colorScheme, textTheme),
                ],
              ),
            ),
    );
  }

  Widget _buildAuthPrompt(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          'Please sign in to create a report and help us keep the community safe.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _signInWithGoogle,
          icon: Image.asset('assets/images/google-logo.png', height: 24.0), // Google logo
          label: Text(
            'Sign in with Google',
            style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.onPrimary,
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildReportButtons(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display KYC status if not complete
        if (_appUser != null && !_appUser!.kycCompleted)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer, // A distinct color for notices
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.onTertiaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your profile is not fully verified. Consider completing KYC for full trust.',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer),
                  ),
                ),
                const SizedBox(width: 8),
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
                    style: textTheme.labelLarge?.copyWith(color: colorScheme.tertiary),
                  ),
                )
              ],
            ),
          ),


        // Report Lost Item Button
        FilledButton.icon(
          
          onPressed: () {
            // Check KYC status before proceeding
            if (_appUser != null && !_appUser!.kycCompleted) {
              _showKycPromptDialog('lost');
            } else {
              _navigateToReportForm('lost');
            }
          },
          icon: Icon(Icons.search_off, size: 30, color: colorScheme.onSecondaryContainer),
          label: Text(
            'Report Lost Item',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
          ),
        ),
        const SizedBox(height: 20),

        // Report Found Item Button
        FilledButton.icon(
          onPressed: () {
            // Check KYC status before proceeding
            if (_appUser != null && !_appUser!.kycCompleted) {
              _showKycPromptDialog('found');
            } else {
              _navigateToReportForm('found');
            }
          },
          icon: Icon(Icons.volunteer_activism, size: 30, color: colorScheme.onPrimaryContainer),
          label: Text(
            'Report Found Item',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }
}