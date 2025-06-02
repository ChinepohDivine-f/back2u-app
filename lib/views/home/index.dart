import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/services/get_reports_service.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:back2u/views/report/index.dart'; // Ensure this is your Report submission screen
import 'package:back2u/views/search/index.dart';
import 'package:flutter/material.dart';
import 'package:back2u/components/report_details.dart'; // Import ReportDetails
import 'package:back2u/models/report_model.dart'; // Import your Report model
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion
import 'package:intl/intl.dart'; // For date formatting in headers
import 'dart:async'; // Import for StreamSubscription

// import 'package:back2u/services/report_service.dart'; // NEW: Import your ReportService

// Remove the mock reportData list as we will fetch live data
// final List<Report> reportData = [...];


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // NEW: Instance of your ReportService
  final ReportService _reportService = ReportService();
  // NEW: StreamSubscription to manage the Firestore stream
  StreamSubscription<List<Report>>? _reportsSubscription;

  bool _isLoading = true; // Set to true initially as we are fetching data
  String _activeFilter = 'All';
  List<Report> _allReportsFromFirestore = []; // Stores all reports fetched from Firestore
  List<Report> _filteredReports = []; // Stores reports after applying filters

  final List<String> filters = ['All', 'Lost', 'Found'];

  @override
  void initState() {
    super.initState();
    _listenToReports(); // Start listening to Firestore reports
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  // NEW: Method to listen to the Firestore stream
  void _listenToReports() {
    // Set loading to true while waiting for the first data snapshot
    setState(() {
      _isLoading = true;
    });

    _reportsSubscription = _reportService.getReportsStream().listen(
      (reports) {
        // When new data arrives, update the cache and apply the current filter
        if (mounted) {
          setState(() {
            _allReportsFromFirestore = reports;
            _applyFilter(_activeFilter); // Re-apply filter with new data
            _isLoading = false; // Data loaded, set loading to false
          });
        }
      },
      onError: (error) {
        // Handle errors in fetching data
        if (mounted) {
          setState(() {
            _isLoading = false;
            // Optionally, show an error message to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading reports: $error')),
            );
          });
        }
        debugPrint('Error fetching reports: $error');
      },
      onDone: () {
        // This might not be triggered by Firestore streams, but good practice
        debugPrint('Report stream finished.');
      },
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      // Filter from the _allReportsFromFirestore cache
      _filteredReports = filter == 'All'
          ? List.from(_allReportsFromFirestore)
          : _allReportsFromFirestore
              .where((item) => item.type == filter)
              .toList();
    });
  }

  // Helper to group reports by month and year
  Map<String, List<Report>> _groupReportsByMonth(List<Report> reports) {
    // Sort reports by creation date (most recent first) within the group
    // The stream already provides sorted data, but a local sort ensures consistency
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<Report>> groupedReports = {};
    final DateFormat formatter = DateFormat('MMMM yyyy'); // e.g., "May 2025"

    for (var report in reports) {
      final String monthYear = formatter.format(report.createdAt.toDate());
      if (!groupedReports.containsKey(monthYear)) {
        groupedReports[monthYear] = [];
      }
      groupedReports[monthYear]!.add(report);
    }
    return groupedReports;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: true,
          elevation: 1,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search items',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
              onPressed: () {
                // TODO: Implement more options functionality
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ChoiceChip filter section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Wrap(
                spacing: 8,
                children: filters.map((filter) {
                  final isSelected = _activeFilter == filter;
                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _applyFilter(filter),
                    // Material 3 automatically handles colors based on theme
                  );
                }).toList(),
              ),
            ),

            // Card list or status view
            Expanded(
              child: _isLoading
                  ? _buildLoadingView()
                  : _filteredReports.isEmpty // Use _filteredReports for checking emptiness
                      ? _buildNoReportsView()
                      : _buildReportsList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const ReportPage()), // Assuming Report is your submission form
            );
          },
          label: const Text('Make a Report'),
          icon: const Icon(Icons.add),
          tooltip: 'Create a new lost or found report',
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Loading reports...",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReportsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No reports found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            "Try changing your filters or create a new report",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    final groupedReports = _groupReportsByMonth(_filteredReports); // Group filtered reports
    final sortedMonths = groupedReports.keys.toList()
      ..sort((a, b) {
        // Parse "Month Year" strings back to DateTime for proper sorting
        final DateFormat formatter = DateFormat('MMMM yyyy');
        final DateTime dateA = formatter.parse(a);
        final DateTime dateB = formatter.parse(b);
        return dateB.compareTo(dateA); // Sort months from most recent to oldest
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedMonths.length,
      itemBuilder: (context, monthIndex) {
        final month = sortedMonths[monthIndex];
        final reportsInMonth = groupedReports[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                month,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            // Reports for this month
            ListView.builder(
              shrinkWrap: true, // Important to allow nested ListViews
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling for inner list
              itemCount: reportsInMonth.length,
              itemBuilder: (context, reportIndex) {
                final report = reportsInMonth[reportIndex];
                return SimpleCard(
                  onTap: () {
                    // Navigate to ReportDetails, passing the Report object
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetails(
                            report: report), // Pass the Report object
                      ),
                    );
                  },
                  report: report, // Pass the Report object
                );
              },
            ),
            // Add a small space between months sections, unless it's the last one
            if (monthIndex < sortedMonths.length - 1)
              const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}