import 'dart:async'; // For StreamSubscription
import 'package:flutter/material.dart';
import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:back2u/views/report/index.dart';
import 'package:back2u/views/search/index.dart';
import 'package:back2u/components/report_details.dart';
import 'package:back2u/models/report_model.dart';
import 'package:intl/intl.dart';
import 'package:back2u/services/get_reports_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Ensure this is the correct import

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ReportService _reportService = ReportService();
  StreamSubscription<List<Report>>? _reportsSubscription;
  // Corrected: Connectivity().onConnectivityChanged now emits List<ConnectivityResult>
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isLoadingInitial = true; // True when fetching first set of reports
  bool _isLoadingMore = false; // True when fetching subsequent reports (pagination)
  bool _isOffline = false; // Tracks current network status
  String _activeFilter = 'All'; // 'All', 'Lost', or 'Found'
  List<Report> _displayedReports = []; // Combined list of all loaded reports
  String? _errorMessage; // Stores and displays specific error messages

  final List<String> filters = ['All', 'Lost', 'Found'];
  final ScrollController _scrollController = ScrollController(); // For pagination listener

  @override
  void initState() {
    super.initState();
    _initConnectivityListener(); // Initialize connectivity listener first
    _listenToReports(); // Start listening to the reports stream from ReportService
    _setupScrollListener(); // Set up scroll listener for pagination

    // Initial fetch of reports
    _loadInitialReports();
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel(); // Cancel reports subscription
    _connectivitySubscription?.cancel(); // Cancel connectivity subscription
    _scrollController.removeListener(_onScroll); // Remove scroll listener
    _scrollController.dispose(); // Dispose the scroll controller
    _reportService.dispose(); // Dispose the service controller
    super.dispose();
  }

  /// Initializes a listener for network connectivity changes.
  /// Displays an offline banner and attempts to reload reports when online.
  void _initConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool becameOffline = results.contains(ConnectivityResult.none);

      if (becameOffline && !_isOffline) {
        // App just went offline
        setState(() {
          _isOffline = true;
          _errorMessage = 'No internet connection. Please check your network settings.';
          _isLoadingInitial = false; // Stop initial loading if it was ongoing
          _isLoadingMore = false; // Stop loading more if it was ongoing
          // Clear displayed reports only if they were fetched when online and now we're offline
          // and might be stale. Or, if we want to force re-fetch.
          // For now, let's keep them unless explicitly clearing.
        });
        // You can optionally show a persistent SnackBar here for offline status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are offline. Data might be outdated.'),
            backgroundColor: Colors.orange,
            duration: Duration(days: 365), // Persist indefinitely
          ),
        );
      } else if (!becameOffline && _isOffline) {
        // App just came online
        setState(() {
          _isOffline = false;
          // Only clear network-specific error message
          if (_errorMessage == 'No internet connection. Please check your network settings.') {
            _errorMessage = null;
          }
        });
        // Hide any persistent offline snackbars
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // If no reports were loaded or there was a previous network error, try reloading.
        if (_displayedReports.isEmpty || _errorMessage == 'No internet connection. Please check your network settings.') {
          _loadInitialReports(); // Retry loading when connection is restored
        }
      }
    });
  }

  /// Listens to the stream of reports from the ReportService.
  /// Updates displayed reports and manages loading/error states.
  void _listenToReports() {
    // Set initial loading state when beginning to listen
    if (mounted && _displayedReports.isEmpty && _errorMessage == null) {
      setState(() {
        _isLoadingInitial = true;
      });
    }

    _reportsSubscription = _reportService.reportsStream.listen(
      (reports) {
        if (mounted) {
          setState(() {
            _displayedReports = reports;
            _isLoadingInitial = false; // Initial load finished
            _isLoadingMore = false; // Pagination load finished
            _errorMessage = null; // Clear any previous errors on successful data receive
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoadingInitial = false; // Stop loading
            _isLoadingMore = false; // Stop loading more
            _errorMessage = error.toString(); // Store the error message
          });
          // Show error as a temporary snackbar, unless it's the specific offline message
          if (_errorMessage != 'No internet connection. Please check your network settings.') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $_errorMessage'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
        debugPrint('Error fetching reports: $error'); // Log for debugging
      },
    );
  }

  /// Sets up the scroll listener for pagination.
  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  /// Callback for scroll events to trigger loading more reports.
  void _onScroll() {
    // Only load more if at the bottom, not already loading, not offline, and there are more reports
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoadingInitial && // Don't load more if initial load is still active
        _reportService.hasMoreReports &&
        !_isOffline) {
      _loadMoreReports();
    }
  }

  /// Initiates the first fetch of reports, or re-fetches after a filter change/retry.
  Future<void> _loadInitialReports() async {
    if (_isOffline) {
      // If we are offline, update error message and prevent fetch
      if (mounted) {
        setState(() {
          _errorMessage = 'No internet connection. Cannot load reports.';
          _isLoadingInitial = false; // Ensure loading stops
        });
      }
      return;
    }

    // Only show initial loading spinner if no reports are displayed yet
    // or if we are explicitly trying to reload after an error/filter change.
    if (mounted && _displayedReports.isEmpty && _errorMessage == null) {
      setState(() {
        _isLoadingInitial = true;
      });
    }
    setState(() {
      _errorMessage = null; // Clear error on new load attempt
    });


    try {
      await _reportService.fetchInitialReports(
        typeFilter: _activeFilter == 'All' ? null : _activeFilter,
      );
    } catch (e) {
      // Errors are caught by _listenToReports's onError, which updates _errorMessage.
      // This catch block is mostly for very rare synchronous errors if the stream setup itself fails.
      debugPrint('Synchronous error during initial reports load: $e');
    }
  }

  /// Initiates fetching more reports for pagination.
  Future<void> _loadMoreReports() async {
    // Prevent multiple calls, calls when no more data, or calls when offline/initial loading
    if (_isLoadingMore || !_reportService.hasMoreReports || _isOffline || _isLoadingInitial) {
      return;
    }

    setState(() {
      _isLoadingMore = true; // Show bottom loading indicator
      _errorMessage = null; // Clear error when attempting to load more
    });

    try {
      await _reportService.fetchMoreReports();
    } catch (e) {
      // Errors are caught by _listenToReports's onError
      debugPrint('Synchronous error during more reports load: $e');
    } finally {
      // Final state update to ensure loading indicator is hidden
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Applies a new filter, resets pagination, and reloads reports.
  void _applyFilter(String filter) {
    if (filter == _activeFilter) return; // No change, do nothing

    setState(() {
      _activeFilter = filter;
      _isLoadingInitial = true; // Show initial loading for new filter
      _displayedReports = []; // Clear current displayed reports for new filter
      _errorMessage = null; // Clear any previous error on filter change
      _scrollController.jumpTo(0); // Scroll to top on filter change
    });
    // Trigger a new initial fetch with the selected filter
    _loadInitialReports();
  }

  /// Helper to group reports by month and year for display.
  Map<String, List<Report>> _groupReportsByMonth(List<Report> reports) {
    // Reports are assumed to be sorted by createdAt descending from the service
    final Map<String, List<Report>> groupedReports = {};
    final DateFormat formatter = DateFormat('MMMM y'); // e.g., "May 2025"

    for (var report in reports) {
      final String monthYear = formatter.format(report.createdAt.toDate());
      groupedReports.putIfAbsent(monthYear, () => []).add(report);
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

            // Offline Status bar (visible only when offline)
            if (_isOffline)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Theme.of(context).colorScheme.error, // Use theme's error color
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Theme.of(context).colorScheme.onError),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are offline. Data might not be current.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onError),
                      ),
                    ),
                  ],
                ),
              ),

            // Main content area: handles loading, error, empty, and reports list
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
        floatingActionButton: _isOffline
            ? null // Hide FAB when offline to indicate limited functionality
            : FloatingActionButton.extended(
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

  /// Determines which content widget to display based on current state.
  Widget _buildContent() {
    if (_errorMessage != null && _displayedReports.isEmpty) {
      // Show error only if no reports could be loaded initially
      return _buildErrorView();
    }

    if (_isLoadingInitial && _displayedReports.isEmpty) {
      // Show full-screen loading only if no reports are loaded yet
      return _buildLoadingView();
    }

    if (_displayedReports.isEmpty && !_isLoadingInitial && _errorMessage == null) {
      // Show no reports view if list is empty after initial load and no error
      return _buildNoReportsView();
    }

    // If we have reports, display the list (and handle loading more at the bottom)
    return _buildReportsList();
  }

  // --- UI Helper Methods ---

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
    String message;
    String subMessage;

    if (_activeFilter != 'All') {
      message = 'No ${_activeFilter.toLowerCase()} reports found.';
      subMessage = 'Try changing your filter or create a new report.';
    } else {
      message = 'No reports found yet.';
      subMessage = 'Be the first to make a report!';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          if (_isOffline) ...[
            const SizedBox(height: 24),
            Text(
              "You are offline. Content may not be up-to-date.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.red.shade600),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              "Oops! Something went wrong.",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred.', // Display stored error
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Clear error and retry loading
                setState(() {
                  _errorMessage = null;
                });
                _loadInitialReports();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    final groupedReports = _groupReportsByMonth(_displayedReports);
    final sortedMonths = groupedReports.keys.toList()
      ..sort((a, b) {
        final DateFormat formatter = DateFormat('MMMM y');
        final DateTime dateA = formatter.parse(a);
        final DateTime dateB = formatter.parse(b);
        return dateB.compareTo(dateA); // Sort months from most recent to oldest
      });

    return RefreshIndicator(
      onRefresh: _loadInitialReports, // Pull to refresh triggers initial load
      child: ListView.builder(
        controller: _scrollController, // Assign scroll controller
        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
        // Add an extra item for the loading indicator/status at the bottom
        itemCount: sortedMonths.length + (_reportService.hasMoreReports || _isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < sortedMonths.length) {
            final month = sortedMonths[index];
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
                  shrinkWrap: true, // Important for nested ListViews
                  physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
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
                if (index < sortedMonths.length - 1)
                  const SizedBox(height: 12),
              ],
            );
          } else {
            // This is the loading indicator/status at the bottom of the list
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator() // Show loading spinner
                    : Text(
                        _reportService.hasMoreReports
                            ? 'Pull to refresh or scroll down to load more' // More explicit instruction
                            : 'No more reports', // Message when all reports are loaded
                        style: TextStyle(color: Colors.grey[600]),
                      ),
              ),
            );
          }
        },
      ),
    );
  }
}