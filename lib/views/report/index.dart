import 'package:back2u/l10n/app_localizations.dart';
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
      category: '', categoryFr: '', contactPhone: '',
      reportedDate: Timestamp.now(),
      reporterName: '', images: [], locationLost: '',
      locationLostFr: '', // this has to be changed
      notes: '', createdAt: Timestamp.now(), resolved: false,
      reward: '', searchKeyWords: [], status: 'unresolved', subLocationLost: '',
      subLocationLostFr: '', subcategory: '', subcategoryFr: '',
      whatsappNumber: '',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportForm(
                report: newReport,
                isEditing: false,
              )),
    );
  }

  // Show the KYC prompt dialog
  Future<void> _showKycPromptDialog(
      String reportType, BuildContext context) async {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    // Access AuthKycService without listening in a method if you don't need UI rebuilds based on it
    final authService = Provider.of<AuthKycService>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.completeYourProfileTitle,
            style: theme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.kycEnhancesTrust,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                loc.completeOrProceed,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(loc.continueAnyway),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (authService.currentUser != null) {
                  _navigateToReportForm(
                      reportType, authService.currentUser!.uid);
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
              child: Text(loc.completeNow),
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
    final loc = AppLocalizations.of(context);

    // Listen to AuthKycService for user data and loading state
    final authService = Provider.of<AuthKycService>(context);
    final currentUser = authService.currentUser;
    final appUser = authService.appUser;
    final isLoadingAuth = authService.isLoadingAuth;
    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.createReport),
        // centerTitle: true,
        // elevation: 0,
        // backgroundColor: colors.background,
        // foregroundColor: colors.primary,
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
                        ? loc.whatToReport
                        : loc.register,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!isAuthenticated)
                    _buildAuthPrompt(theme,
                        colors) // No need to pass authService here, just navigate
                  else
                    _buildReportButtons(
                        theme, colors, appUser, currentUser!.uid),
                ],
              ),
            ),
    );
  }

  // Modified _buildAuthPrompt to navigate to AuthPage
  Widget _buildAuthPrompt(ThemeData theme, ColorScheme colors) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          loc.pleaseSignInToReport,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthPage()), // Go to AuthPage
                );
              },
              child: Text(loc.signIn, style: theme.textTheme.titleMedium)),
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

  Widget _buildReportButtons(ThemeData theme, ColorScheme colors,
      AppUser? appUser, String reporterUid) {
    final kycCompleted = appUser?.verified ?? false;
    final loc = AppLocalizations.of(context);

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
                    loc.profileNotVerifiedWarning,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.onTertiaryContainer),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const KycFormPage()),
                    ).then((_) {
                      // After returning from KYC form, refresh user profile via provider
                      Provider.of<AuthKycService>(context, listen: false)
                          .refreshUserProfile();
                    });
                  },
                  child: Text(
                    loc.verifyNow,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: colors.tertiary),
                  ),
                ),
              ],
            ),
          ),
        if (!kycCompleted) const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _actionCard(
              icon: Icons.search_off,
              label: loc.lostItem,
              bgColor: colors.primaryContainer,
              fgColor: colors.onPrimaryContainer,
              onTap: () {
                if (!kycCompleted) {
                  _showKycPromptDialog('lost', context);
                } else {
                  _navigateToReportForm('lost', reporterUid);
                }
              },
            ),
            _actionCard(
              icon: Icons.volunteer_activism,
              label: loc.foundItem,
              bgColor: colors.secondaryContainer,
              fgColor: colors.onSecondaryContainer,
              onTap: () {
                if (!kycCompleted) {
                  _showKycPromptDialog('found', context);
                } else {
                  _navigateToReportForm('found', reporterUid);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: fgColor),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(color: fgColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
