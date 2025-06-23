import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/components/report_details.dart';
import 'package:back2u/l10n/app_localizations.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/services/saved_report_servoce.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class SavedReportsPage extends StatefulWidget {
  const SavedReportsPage({super.key});

  @override
  State<SavedReportsPage> createState() => _SavedReportsPageState();
}

class _SavedReportsPageState extends State<SavedReportsPage> {
  late AuthKycService _authKycService;
  final SavedReportService _savedReportService = SavedReportService();

  User? _currentUser;
  List<String> _currentSavedReportIds = [];
  Stream<List<Report>>? _savedReportsStream;
  StreamSubscription? _userProfileSub;
  final Set<String> _loadingReports = {};

  @override
  void initState() {
    super.initState();
    _authKycService = Provider.of<AuthKycService>(context, listen: false);
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _savedReportService.listenToSavedReports(_currentUser!.uid);
      _savedReportsStream = _savedReportService.savedReportsStream;
      _userProfileSub = _authKycService
          .getUserProfileStream(_currentUser!.uid)
          .listen((appUser) {
        if (mounted) {
          setState(() {
            _currentSavedReportIds = appUser?.savedReports ?? [];
          });
        }
      }, onError: (error) {
        debugPrint('Error listening to user profile for saved reports UI update: $error');
      });
    }
  }

  @override
  void dispose() {
    _savedReportService.dispose();
    _userProfileSub?.cancel();
    super.dispose();
  }

  void _toggleSaveReport(String reportId) async {
    final loc = AppLocalizations.of(context);
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseLogInToSave)),
      );
      return;
    }
    setState(() {
      _loadingReports.add(reportId);
    });
    await _authKycService.toggleSavedReport(_currentUser!.uid, reportId);
    setState(() {
      _loadingReports.remove(reportId);
    });
    // UI will update via stream
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentSavedReportIds.contains(reportId)
              ? loc.reportRemovedFromSaved
              : loc.reportAddedToSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context);

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.mySavedReportsTitle),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          leading: const BackButtonIcon(),
        ),
        drawer: const AppDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 24),
              Text(loc.logInToViewSaved, style: textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.mySavedReportsTitle),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Report>>(
        stream: _savedReportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(loc.loadingSavedReports, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                    ),
                    const SizedBox(height: 24),
                    Text(loc.errorLoadingSavedReports, textAlign: TextAlign.center, style: textTheme.headlineSmall?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }
          final savedReports = snapshot.data ?? [];
          if (savedReports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bookmark_border, size: 64, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    Text(loc.noSavedReportsYet, textAlign: TextAlign.center, style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(loc.browseAndSaveReports, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    }, child: Text(loc.browseReports)),
                  ],
                ),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.bookmark, size: 24, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        loc.savedReportsCount(savedReports.length),
                        style: textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final report = savedReports[index];
                      final isSaved = _currentSavedReportIds.contains(report.reportId);
                      final loading = _loadingReports.contains(report.reportId);
                      return SimpleCard(
                        report: report,
                        isSaved: isSaved,
                        loading: loading,
                        onToggleSave: () => _toggleSaveReport(report.reportId),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetails(report: report),
                            ),
                          );
                        },
                      );
                    },
                    childCount: savedReports.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}