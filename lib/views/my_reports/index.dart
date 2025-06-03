import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // <--- NEW: Import Provider
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/services/get_reports_service.dart'; // <--- NEW: Import your ReportService
import 'package:back2u/models/report_model.dart';
import 'package:back2u/models/user_model.dart';
import 'package:back2u/components/report_details.dart'; // Assuming you have a detail page

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final AuthKycService _authKycService = AuthKycService();
  late ReportService _reportService; // <--- NEW: Declare ReportService
  
  User? _currentUser;
  AppUser? _appUser;
  late Stream<List<Report>> _myReportsStream;
  bool _isLoadingUser = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize ReportService using Provider once context is available
    _reportService = Provider.of<ReportService>(context); // <--- NEW: Get ReportService from Provider
  }

  @override
  void initState() {
    super.initState();
    _authKycService.authStateChanges.listen((user) async {
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _isLoadingUser = true;
      });
      if (user != null) {
        _appUser = await _authKycService.getUserProfile(user.uid);
        // Use the getReportsByUserId from the injected ReportService
        _myReportsStream = _reportService.getReportsByUserId(user.uid); // <--- IMPORTANT CHANGE
      } else {
        _appUser = null;
        _myReportsStream = Stream.value([]);
      }
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoadingUser) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    if (_currentUser == null || _currentUser!.isAnonymous) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_outlined, size: 80, color: colors.onSurfaceVariant.withOpacity(0.6)),
                const SizedBox(height: 20),
                Text(
                  'Please sign in to view your reports.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login / Sign Up'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: theme.textTheme.titleMedium,
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: StreamBuilder<List<Report>>(
        stream: _myReportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading reports: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: colors.error),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 80, color: colors.onSurfaceVariant.withOpacity(0.6)),
                  const SizedBox(height: 20),
                  Text(
                    'You haven\'t submitted any reports yet.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/report');
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create a Report'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: theme.textTheme.titleMedium,
                      backgroundColor: colors.secondary,
                      foregroundColor: colors.onSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<Report> reports = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetails(report: report),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              report.type == 'lost' ? 'Lost Item Report' : 'Found Item Report',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: report.type == 'lost' ? colors.error : colors.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: report.status == 'resolved' ? Colors.green.shade100 : colors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                report.status.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: report.status == 'resolved' ? Colors.green.shade800 : colors.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.documentName.isNotEmpty
                              ? 'Document: ${report.documentName}'
                              : 'Category: ${report.category}',
                          style: theme.textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${report.locationLost}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant.withOpacity(0.8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reported: ${_formatTimestamp(report.reportedDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    // Current time is Tuesday, June 3, 2025 at 3:49:33 PM WAT.
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}