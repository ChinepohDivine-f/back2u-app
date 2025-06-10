import 'package:back2u/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:provider/provider.dart'; // Import Provider
import 'package:back2u/views/report/report_form.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/views/auth/kyc_form_page.dart';
import 'package:back2u/services/auth_kyc_service.dart'; // <--- UPDATED: Use AuthKycService directly

import 'package:back2u/views/auth/auth_page.dart'; // <--- NEW: Import the AuthPage

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Removed all auth-related state variables and initState from here.

  // Helper to navigate to ReportForm
  void _navigateToReportForm(String reportType, String reporterUid) {
    final newReport = Report(
      type: reportType,
      reportId: 'temp_id_${DateTime.now().microsecondsSinceEpoch}',
      reporterUid: reporterUid,
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
  Future<void> _showKycPromptDialog(String reportType, BuildContext context) async {
    final theme = Theme.of(context);
    // Access AuthKycService without listening in a method if you don't need UI rebuilds based on it
    final authService = Provider.of<AuthKycService>(context, listen: false);

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
                if (authService.currentUser != null) {
                  _navigateToReportForm(reportType, authService.currentUser!.uid);
                }
              },
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KycFormPage()),
                ).then((_) {
                  // After returning from KYC form, refresh user profile via provider
                  authService.refreshUserProfile();
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

    // Listen to AuthKycService for user data and loading state
    final authService = Provider.of<AuthKycService>(context);
    final currentUser = authService.currentUser;
    final appUser = authService.appUser;
    final isLoadingAuth = authService.isLoadingAuth;
    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Report'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        // The back button will automatically appear if this page is pushed onto a stack.
        // If you want to explicitly add it, you can use:
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: isLoadingAuth
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isAuthenticated
                        ? 'What would you like to report?'
                        : 'Register',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (!isAuthenticated)
                    _buildAuthPrompt(theme, colors) // No need to pass authService here, just navigate
                  else
                    _buildReportButtons(theme, colors, appUser, currentUser!.uid),
                ],
              ),
            ),
    );
  }

  // Modified _buildAuthPrompt to navigate to AuthPage
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
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: (){
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()), // Go to AuthPage
              );
            }, child: Text("Sign in", style: theme.textTheme.titleMedium)),
          // child: ElevatedButton.icon(
          //   onPressed: () {
          //     // Navigate to the separate AuthPage
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const AuthPage()), // Go to AuthPage
          //     );
          //   },
          //   icon: Image.asset('assets/images/google-logo.png', height: 24.0),
          //   label: Text(
          //     'Sign in with Google',
          //     style: theme.textTheme.titleMedium,
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     padding: const EdgeInsets.symmetric(vertical: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          // ),
        ),
      ],
    );
  }

  Widget _buildReportButtons(ThemeData theme, ColorScheme colors, AppUser? appUser, String reporterUid) {
    final kycCompleted = appUser?.kycCompleted ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!kycCompleted)
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
                     ).then((_) {
                        // After returning from KYC form, refresh user profile via provider
                        Provider.of<AuthKycService>(context, listen: false).refreshUserProfile();
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
        if (!kycCompleted)
          const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (!kycCompleted) {
                    _showKycPromptDialog('lost', context);
                  } else {
                    _navigateToReportForm('lost', reporterUid);
                  }
                },
                icon: const Icon(Icons.search_off, size: 30),
                label: Text(
                  'Report Lost Item',
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (!kycCompleted) {
                    _showKycPromptDialog('found', context);
                  } else {
                    _navigateToReportForm('found', reporterUid);
                  }
                },
                icon: const Icon(Icons.volunteer_activism, size: 30),
                label: Text(
                  'Report Found Item',
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}