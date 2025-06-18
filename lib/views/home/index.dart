import 'dart:async';
import 'package:flutter/material.dart';
import 'package:back2u/components/SimpleCard.dart'; // This will be updated to handle images
import 'package:back2u/utils/app_drawer.dart';
import 'package:back2u/views/report/index.dart';
import 'package:back2u/views/search/index.dart';
// import 'package:back2u/components/report_details.dart'; // Assuming this shows full details
import 'package:back2u/models/report_model.dart';
import 'package:intl/intl.dart';
import 'package:back2u/services/get_reports_service.dart'; // Your ReportService
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart'; // Import Provider to access ReportService

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ReportService will be accessed via Provider now
  late ReportService
  _reportService; // Changed to late to be initialized in didChangeDependencies
  StreamSubscription<List<Report>>? _reportsSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _isOffline = false;
  String _activeFilter = 'All';
  List<Report> _displayedReports = [];
  String? _errorMessage;

  final List<String> filters = ['All', 'Lost', 'Found'];
  final ScrollController _scrollController = ScrollController();

  // Pagination configuration
  static const double _scrollThreshold =
      200.0; // Pixels from bottom to trigger load
  static const int _pageSize = 10; // Items per page

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
    _setupScrollListener();
    // Reports will be loaded after _reportService is initialized in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize ReportService here using Provider
    _reportService = Provider.of<ReportService>(context);
    // Listen to reports only after _reportService is initialized
    _listenToReports();
    // Load initial reports once service is ready
    if (_displayedReports.isEmpty && _isLoadingInitial) {
      _loadInitialReports();
    }
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // _reportService.dispose(); // ReportService is disposed by MultiProvider in main.dart
    super.dispose();
  }

  /// Initialize connectivity listener
  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      bool becameOffline = results.contains(ConnectivityResult.none);

      if (becameOffline && !_isOffline) {
        setState(() {
          _isOffline = true;
          _errorMessage =
              'No internet connection. Please check your network settings.';
          _isLoadingInitial =
              false; // Stop initial loading spinner if it was running
          _isLoadingMore = false; // Stop more loading spinner
        });
        _showOfflineSnackBar();
      } else if (!becameOffline && _isOffline) {
        setState(() {
          _isOffline = false;
          // Clear network-specific error message only if it's the one we set
          if (_errorMessage ==
              'No internet connection. Please check your network settings.') {
            _errorMessage = null;
          }
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Retry loading if we had no reports or were specifically offline
        if (_displayedReports.isEmpty || _errorMessage != null) {
          // Also retry if there was a previous error
          _loadInitialReports();
        }
      }
    });
  }

  /// Show persistent offline notification
  void _showOfflineSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are offline. Data might be outdated.'),
        backgroundColor: Colors.orange,
        duration: Duration(days: 365), // Persistent snackbar
      ),
    );
  }

  /// Listen to reports stream
  void _listenToReports() {
    // Cancel previous subscription if it exists, to avoid multiple listeners
    _reportsSubscription?.cancel();
    _reportsSubscription = _reportService.reportsStream.listen(
      (reports) {
        if (mounted) {
          setState(() {
            _displayedReports = reports;
            _isLoadingInitial = false;
            _isLoadingMore = false;
            _errorMessage = null; // Clear any previous error
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoadingInitial = false;
            _isLoadingMore = false;
            _errorMessage = error.toString();
          });
          _showErrorSnackBar(error.toString());
        }
        debugPrint('Error fetching reports: $error');
      },
    );
  }

  /// Show error notification
  void _showErrorSnackBar(String error) {
    // Only show if it's not the specific offline message already handled
    if (!error.contains('No internet connection')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Setup scroll listener for pagination
  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    if (!mounted) return;

    final position = _scrollController.position;
    final maxScrollExtent = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // Check if we're near the bottom and should load more
    // Added a check for _reportService.isLoading to prevent double-loading
    if (currentScroll >= maxScrollExtent - _scrollThreshold &&
        !_isLoadingMore &&
        !_isLoadingInitial && // Don't load more if initial load is still in progress
        _reportService.hasMoreReports &&
        !_isOffline &&
        !_reportService.isLoading) {
      // Use ReportService's isLoading to prevent concurrent fetches
      _loadMoreReports();
    }
  }

  /// Load initial reports
  Future<void> _loadInitialReports() async {
    // Check connectivity before attempting to load
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        _isOffline = true;
        _errorMessage = 'No internet connection. Cannot load reports.';
        _isLoadingInitial = false;
      });
      _showOfflineSnackBar();
      return;
    } else if (_isOffline) {
      // If was offline but now connected, clear offline state
      setState(() {
        _isOffline = false;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }

    if (mounted) {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null; // Clear previous error
        _displayedReports = []; // Clear current reports before new load
      });
    }

    try {
      await _reportService.fetchInitialReports(
        limit: _pageSize,
        typeFilter: _activeFilter == 'All' ? null : _activeFilter,
      );
    } catch (e) {
      debugPrint('Error in _loadInitialReports: $e');
      // Error will be caught by _listenToReports onError
    }
  }

  /// Load more reports for pagination
  Future<void> _loadMoreReports() async {
    // Check against ReportService's isLoading to prevent race conditions
    if (_isLoadingMore ||
        !_reportService.hasMoreReports ||
        _isOffline ||
        _isLoadingInitial ||
        _reportService.isLoading) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await _reportService.fetchMoreReports(limit: _pageSize);
    } catch (e) {
      debugPrint('Error in _loadMoreReports: $e');
      // Error will be caught by _listenToReports onError
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Apply filter and reload reports
  void _applyFilter(String filter) {
    if (filter == _activeFilter) return;

    setState(() {
      _activeFilter = filter;
      _isLoadingInitial = true; // Indicate new initial load
      _displayedReports = []; // Clear reports immediately for visual feedback
      _errorMessage = null; // Clear error on new filter
    });

    // Scroll to top when filter changes for fresh view
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    _loadInitialReports(); // Reload with new filter
  }

  /// Group reports by month for display
  Map<String, List<Report>> _groupReportsByMonth(List<Report> reports) {
    final Map<String, List<Report>> groupedReports = {};
    // Use 'MMMM yyyy' for full month name and year (e.g., June 2025)
    final DateFormat formatter = DateFormat('MMMM yyyy');

    for (var report in reports) {
      final String monthYear = formatter.format(report.createdAt.toDate());
      groupedReports.putIfAbsent(monthYear, () => []).add(report);
    }
    return groupedReports;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search items',
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  ),
            ),
            // More options button (can be a PopupMenuButton)
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
              onPressed: () {
                // Example of a simple dialog for more options
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("More Options"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.feedback_outlined),
                            title: const Text('Send Feedback'),
                            onTap: () {
                              Navigator.pop(context); // Close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Feedback feature coming soon!',
                                  ),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('Help'),
                            onTap: () {
                              Navigator.pop(context); // Close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Help content not yet available.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            _buildFilterChips(),

            // Offline status bar
            if (_isOffline) _buildOfflineStatusBar(),

            // Main content
            Expanded(child: _buildContent()),
          ],
        ),
        floatingActionButton: _isOffline ? null : _buildFloatingActionButton(),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Wrap(
        spacing: 8,
        children:
            filters.map((filter) {
              final isSelected = _activeFilter == filter;
              return ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                onSelected: (selected) {
                  if (selected) {
                    _applyFilter(filter);
                  }
                },
                showCheckmark: false, // Hide the default checkmark
              );
            }).toList(),
      ),
    );
  }

  /// Build offline status bar
  Widget _buildOfflineStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Theme.of(context).colorScheme.error,
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
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportPage()),
        );
      },
      label: const Text('Make a Report'),
      icon: const Icon(Icons.add),
      tooltip: 'Create a new lost or found report',
      // backgroundColor: Theme.of(context).colorScheme.tertiary, // Use a distinct color
      // foregroundColor: Theme.of(context).colorScheme.onTertiary,
    );
  }

  /// Build main content based on current state
  Widget _buildContent() {
    // If there's a persistent error and no reports to display
    if (_errorMessage != null && _displayedReports.isEmpty) {
      return _buildErrorView();
    }

    // If initial loading and no reports yet
    if (_isLoadingInitial && _displayedReports.isEmpty) {
      return _buildLoadingView();
    }

    // If no reports found after loading (and no error)
    if (_displayedReports.isEmpty &&
        !_isLoadingInitial &&
        _errorMessage == null) {
      return _buildNoReportsView();
    }

    // Otherwise, display the reports list
    return _buildReportsList();
  }

  /// Build loading view
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading reports...",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Build no reports view
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            // Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_isOffline) ...[
              const SizedBox(height: 24),
              Text(
                "You are offline. Content may not be up-to-date.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Oops! Something went wrong.",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null; // Clear error to allow retry
                });
                _loadInitialReports(); // Attempt to reload
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

  /// Build reports list with pagination
  Widget _buildReportsList() {
    final groupedReports = _groupReportsByMonth(_displayedReports);
    final sortedMonths =
        groupedReports.keys.toList()..sort((a, b) {
          // Parse "MMMM yyyy" to DateTime for correct sorting
          final DateFormat formatter = DateFormat('MMMM yyyy');
          final DateTime dateA = formatter.parse(a);
          final DateTime dateB = formatter.parse(b);
          return dateB.compareTo(
            dateA,
          ); // Sort descending (most recent month first)
        });

    return RefreshIndicator(
      onRefresh: _loadInitialReports, // Pull-to-refresh
      color: Theme.of(context).colorScheme.primary, // Customize indicator color
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80.0), // Padding for FAB
        itemCount:
            sortedMonths.length +
            (_reportService.hasMoreReports || _isLoadingMore
                ? 1
                : 0), // Add 1 for footer if more reports or loading
        itemBuilder: (context, index) {
          if (index < sortedMonths.length) {
            // This is a month section
            return _buildMonthSection(
              sortedMonths[index],
              groupedReports[sortedMonths[index]]!,
              index <
                  sortedMonths.length - 1, // Add spacing if not the last month
            );
          } else {
            // This is the pagination footer
            return _buildPaginationFooter();
          }
        },
      ),
    );
  }

  /// Build month section (header + reports)
  Widget _buildMonthSection(
    String month,
    List<Report> reports,
    bool addSpacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            month,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        // Reports for this month
        ...reports.map((report) => SimpleCard(report: report)).toList(),
        // Spacing between months (optional)
        if (addSpacing) const SizedBox(height: 12),
      ],
    );
  }

  /// Build pagination footer (loading indicator or "No more reports")
  Widget _buildPaginationFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child:
            _isLoadingMore
                ? Column(
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading more reports...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
                : Text(
                  _reportService.hasMoreReports
                      ? 'Scroll down to load more' // Message when more reports are available
                      : 'No more reports', // Message when all reports are loaded
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
      ),
    );
  }
}
