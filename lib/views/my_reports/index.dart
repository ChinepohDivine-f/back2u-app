// lib/views/reports/my_reports_page.dart
import 'dart:async';

import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:back2u/views/report/edit_report.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/services/get_reports_service.dart';
import 'package:back2u/models/report_model.dart';
// import 'package:back2u/components/simple_card.dart';
// import 'package:back2u/views/reports/edit_report_page.dart';
import 'package:back2u/views/auth/auth_page.dart'; // Import AuthPage for navigation

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  late ReportService _reportService;
  late AuthKycService _authKycService;
  Stream<List<Report>>? _myReportsStream;

  // Added a listener for auth state changes to dynamically update the stream
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize services in initState
    _reportService = Provider.of<ReportService>(context, listen: false);
    _authKycService = Provider.of<AuthKycService>(context, listen: false);

    // Set up the reports stream based on the current authenticated user's UID
    // Use an immediate call for the initial state
    _updateReportsStream(_authKycService.currentUser?.uid);

    // Subscribe to auth state changes to react to user login/logout
    _authStateSubscription = _authKycService.authStateChanges.listen((user) {
      if (mounted) {
        // Only update the stream if the user UID has actually changed
        // This prevents unnecessary rebuilds if other user properties change
        if (user?.uid != _authKycService.currentUser?.uid) {
          _updateReportsStream(user?.uid);
        }
      }
    });
  }

  void _updateReportsStream(String? userId) {
    setState(() {
      if (userId != null) {
        _myReportsStream = _reportService.getReportsByUserId(userId);
      } else {
        _myReportsStream = Stream.value([]); // No user, no reports
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel(); // Cancel the subscription to prevent memory leaks
    super.dispose();
  }

  Future<void> _editReport(Report report) async {
    // Navigate to edit report page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportPage(report: report),
      ),
    );

    if (result == true) {
      // Refresh the reports list if changes were made
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteReport(Report report) async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      try {
        // Delete report from Firestore using report.id
        await FirebaseFirestore.instance
            .collection('back2u/countries/cameroon/data/reports')
            .doc(report.reportId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Report deleted successfully'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete report: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleResolveStatus(Report report) async {
    try {
      // Determine new status based on current status
      final newStatus = report.status.toLowerCase() == 'resolved' ? 'active' : 'resolved';

      await FirebaseFirestore.instance
          .collection('back2u/countries/cameroon/data/reports')
          .doc(report.reportId) // Use report.id for the document reference
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'resolved': newStatus == 'resolved', // Update the resolved boolean field
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report marked as ${newStatus.toUpperCase()}'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: colors.error,
            size: 32,
          ),
          title: const Text('Delete Report'),
          content: const Text(
            'Are you sure you want to delete this report? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              child: const Text('Delete'),
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

    // Use Consumer or Provider.of to listen to AuthKycService for UI updates
    final authService = Provider.of<AuthKycService>(context);
    final isAuthenticated = authService.isAuthenticated;

    if (authService.isLoadingAuth) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
         centerTitle: true,
        elevation: 1,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        ),
        drawer: const AppDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading authentication status...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
          centerTitle: true,
        elevation: 1,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        ),
        drawer: const AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sign in to view your reports',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track and manage all your submitted reports in one place',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    // Navigate to AuthPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Now that the user is authenticated, we can safely assume _myReportsStream is not null
    // as it's initialized in initState and updated by _authStateSubscription.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/report');
            },
            icon: const Icon(Icons.add),
            tooltip: 'Create New Report',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Report>>(
        stream: _myReportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your reports...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
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
                        color: colors.errorContainer.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colors.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error loading reports',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          // Re-fetch the stream
                          _myReportsStream = _reportService.getReportsByUserId(authService.currentUser!.uid);
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No reports yet',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first report to help find lost items or report found ones',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/report');
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create Report'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<Report> reports = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 8.0), // Adjusted bottom padding
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 24,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reports.length} report${reports.length != 1 ? 's' : ''}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
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
                      final report = reports[index];
                      return SimpleCard(
                        report: report,
                        showActions: true, // Show actions for owner's reports
                        onEdit: () => _editReport(report),
                        onDelete: () => _deleteReport(report),
                        onToggleResolve: () => _toggleResolveStatus(report),
                        // onTap is handled internally by SimpleCard to navigate to ReportDetails
                      );
                    },
                    childCount: reports.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16), // Padding at the bottom of the list
              ),
            ],
          );
        },
      ),
    );
  }
}