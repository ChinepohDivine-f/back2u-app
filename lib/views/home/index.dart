import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:back2u/views/report/index.dart'; // Ensure this is your Report submission screen
import 'package:back2u/views/search/index.dart';
import 'package:flutter/material.dart';
import 'package:back2u/components/report_details.dart'; // Import ReportDetails
import 'package:back2u/models/report_model.dart'; // Import your Report model
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion
import 'package:intl/intl.dart'; // For date formatting in headers

// Helper to convert DateTime to Timestamp for mock data
Timestamp _toTimestamp(DateTime date) {
  return Timestamp.fromDate(date);
}

// Reduced and converted sample data using the Report model
final List<Report> reportData = [
  Report(
    ownerName: 'John Doe',
    category: 'Documents', categoryFr: 'Documents',
    contactPhone: '123-456-7890',
    reportedDate: _toTimestamp(DateTime(2025, 5, 20)), // Incident: May 20
    documentName: 'Birth Certificate',
    images: [
      'https://via.placeholder.com/150/FF0000/FFFFFF?text=BC1',
      'https://via.placeholder.com/150/0000FF/FFFFFF?text=BC2'
    ],
    locationLost: 'New York', locationLostFr: 'New York',
    notes: 'Lost at Central Park. Very important.',
    createdAt:
        _toTimestamp(DateTime(2025, 5, 22)), // Reported: May 22 (Most Recent)
    reportId: 'rep001', reporterId: 'user123', resolved: false, reward: '100',
    searchKeyWords: ['birth certificate', 'john doe'], status: 'active',
    subLocationLost: 'Central Park', subLocationLostFr: 'Central Park',
    subcategory: 'Birth Certificate', subcategoryFr: 'Birth Certificate',
    type: 'Lost', whatsappNumber: '123-456-7890',
  ),
  Report(
    ownerName: 'Jane Smith',
    category: 'ID Cards', categoryFr: 'ID Cards', contactPhone: '098-765-4321',
    reportedDate: _toTimestamp(DateTime(2025, 5, 15)), // Incident: May 15
    documentName: 'National ID',
    images: ['https://via.placeholder.com/150/00FF00/FFFFFF?text=ID1'],
    locationLost: 'Los Angeles', locationLostFr: 'Los Angeles',
    notes: 'Found near Hollywood sign. Blue wallet.',
    createdAt: _toTimestamp(DateTime(2025, 5, 16)), // Reported: May 16 (Recent)
    reportId: 'rep002', reporterId: 'user124',
    resolved: true, // Resolved example
    reward: '0', searchKeyWords: ['id card', 'jane smith'], status: 'resolved',
    subLocationLost: 'Hollywood', subLocationLostFr: 'Hollywood',
    subcategory: 'ID Card', subcategoryFr: 'ID Card',
    type: 'Found', whatsappNumber: '098-765-4321',
  ),
  Report(
    ownerName: 'Mike Johnson',
    category: 'Accessories', categoryFr: 'Accessoires',
    contactPhone: '111-222-3333',
    reportedDate: _toTimestamp(DateTime(2025, 4, 10)), // Incident: April 10
    documentName: 'Brown Wallet',
    images: [
      'https://via.placeholder.com/150/FFFF00/000000?text=Wallet1',
      'https://via.placeholder.com/150/FF00FF/FFFFFF?text=Wallet2'
    ],
    locationLost: 'Chicago', locationLostFr: 'Chicago',
    notes: 'Lost at O\'Hare airport, Terminal 5. Brown leather.',
    createdAt: _toTimestamp(DateTime(2025, 4, 12)), // Reported: April 12
    reportId: 'rep003', reporterId: 'user125', resolved: false, reward: '50',
    searchKeyWords: ['wallet', 'mike johnson'], status: 'active',
    subLocationLost: 'Airport', subLocationLostFr: 'Airport',
    subcategory: 'Wallet', subcategoryFr: 'Wallet',
    type: 'Lost', whatsappNumber: '111-222-3333',
  ),
  Report(
    ownerName: 'Sarah Williams',
    category: 'Electronics', categoryFr: 'Électronique',
    contactPhone: '444-555-6666',
    reportedDate: _toTimestamp(DateTime(2025, 3, 5)), // Incident: March 5
    documentName: 'MacBook Air', images: [], // No image example
    locationLost: 'Houston', locationLostFr: 'Houston',
    notes: 'Found in a coffee shop downtown. Silver color.',
    createdAt: _toTimestamp(DateTime(2025, 3, 6)), // Reported: March 6
    reportId: 'rep004', reporterId: 'user126', resolved: false, reward: '0',
    searchKeyWords: ['laptop', 'sarah williams'], status: 'active',
    subLocationLost: 'Coffee Shop', subLocationLostFr: 'Coffee Shop',
    subcategory: 'Laptop', subcategoryFr: 'Laptop',
    type: 'Found', whatsappNumber: '444-555-6666',
  ),
  Report(
    ownerName: 'David Lee',
    category: 'Keys', categoryFr: 'Clés', contactPhone: '777-888-9999',
    reportedDate: _toTimestamp(DateTime(2025, 2, 28)), // Incident: Feb 28
    documentName: 'Audi Car Keys',
    images: ['https://via.placeholder.com/150/00FFFF/000000?text=Keys1'],
    locationLost: 'Denver', locationLostFr: 'Denver',
    notes: 'Lost on a hiking trail near Red Rocks.',
    createdAt:
        _toTimestamp(DateTime(2025, 3, 1)), // Reported: March 1 (Also March)
    reportId: 'rep005', reporterId: 'user127', resolved: false, reward: '20',
    searchKeyWords: ['car keys', 'david lee'], status: 'active',
    subLocationLost: 'Hiking Trail', subLocationLostFr: 'Hiking Trail',
    subcategory: 'Car Keys', subcategoryFr: 'Car Keys',
    type: 'Lost', whatsappNumber: '777-888-9999',
  ),
  Report(
    ownerName: 'Anna Kim',
    category: 'Bags', categoryFr: 'Sacs', contactPhone: '333-222-1111',
    reportedDate:
        _toTimestamp(DateTime(2024, 12, 1)), // Incident: Dec 1 (Oldest example)
    documentName: 'Blue Backpack',
    images: [
      'https://via.placeholder.com/150/FFC0CB/000000?text=BP1',
      'https://via.placeholder.com/150/800080/FFFFFF?text=BP2'
    ],
    locationLost: 'Seattle', locationLostFr: 'Seattle',
    notes: 'Found at library. Contains books.',
    createdAt:
        _toTimestamp(DateTime(2024, 12, 3)), // Reported: Dec 3 (Oldest example)
    reportId: 'rep006', reporterId: 'user128', resolved: false, reward: '0',
    searchKeyWords: ['backpack', 'anna kim'], status: 'active',
    subLocationLost: 'Library', subLocationLostFr: 'Library',
    subcategory: 'Backpack', subcategoryFr: 'Backpack',
    type: 'Found', whatsappNumber: '333-222-1111',
  ),
  // Added one more recent report to demonstrate "Most Recent" better
  Report(
    ownerName: 'Chloe Green',
    category: 'Documents', categoryFr: 'Documents',
    contactPhone: '999-888-7777',
    reportedDate: _toTimestamp(DateTime(2025, 5, 23)), // Incident: May 23
    documentName: 'Passport',
    images: ['https://via.placeholder.com/150/C0C0C0/000000?text=Passport'],
    locationLost: 'San Francisco', locationLostFr: 'San Francisco',
    notes: 'Lost at airport security.',
    createdAt: _toTimestamp(
        DateTime(2025, 5, 24)), // Reported: May 24 (Even more recent!)
    reportId: 'rep007', reporterId: 'user129', resolved: false, reward: '500',
    searchKeyWords: ['passport', 'chloe green'], status: 'active',
    subLocationLost: 'SFO Airport', subLocationLostFr: 'SFO Airport',
    subcategory: 'Passport', subcategoryFr: 'Passport',
    type: 'Lost', whatsappNumber: '999-888-7777',
  ),
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  String _activeFilter = 'All';
  List<Report> _filteredData = []; // Changed to List<Report>

  final List<String> filters = ['All', 'Lost', 'Found'];

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(reportData); // Use reportData as source
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _filteredData = filter == 'All'
            ? List.from(reportData) // Filter from original reportData
            : reportData
                .where((item) => item.type == filter)
                .toList(); // Filter by item.type
        _isLoading = false;
      });
    });
  }

  // Helper to group reports by month and year
  Map<String, List<Report>> _groupReportsByMonth(List<Report> reports) {
    // Sort reports by creation date (most recent first) within the group
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
                  : _filteredData.isEmpty
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
    final groupedReports = _groupReportsByMonth(_filteredData);
    final sortedMonths = groupedReports.keys.toList()
      ..sort((a, b) {
        // Parse "Month Year" strings back to DateTime for proper sorting
        final DateFormat formatter = DateFormat('MMMM yyyy');
        final DateTime dateA = formatter.parse(a);
        final DateTime dateB = formatter.parse(b);
        return dateB.compareTo(dateA); // Sort months from most recent to oldest
      });

    return ListView.builder(
      // physics: const BouncingScrollPhysics(),
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
