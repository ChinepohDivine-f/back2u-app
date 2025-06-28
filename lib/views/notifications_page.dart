import 'package:back2u/utils/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/services/claim_service.dart';
import 'package:back2u/models/claim_model.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/services/get_reports_service.dart';
import 'package:back2u/components/report_details.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:back2u/models/user_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ClaimService _claimService = ClaimService();
  final ReportService _reportService = ReportService();
  bool _isLoading = false;
  String? _error;
  List<Claim> _claims = [];
  Map<String, Report> _reportDetails = {}; // Store report details for owner names
  String _sortBy = 'date'; // 'date' or 'status'
  String _sortOrder = 'desc'; // 'asc' or 'desc'
  int _previousClaimCount = 0; // Track previous claim count for popup notifications

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = context.read<AuthKycService>();
      final userId = authService.currentUser?.uid;

      if (userId == null) {
        setState(() {
          _error = 'Please sign in to view notifications';
          _isLoading = false;
        });
        return;
      }

      final results = await Future.wait([
        _claimService.getClaimsForUser(userId),
        _claimService.getClaimsForOwner(userId),
      ]);

      final allClaims = [...results[0], ...results[1]];
      _sortClaims(allClaims);

      // Fetch report details for all claims to get owner names
      final reportDetails = <String, Report>{};
      for (final claim in allClaims) {
        try {
          final report = await _reportService.getReportById(claim.reportId);
          if (report != null) {
            reportDetails[claim.reportId] = report;
          }
        } catch (e) {
          // If report not found, continue without it
          debugPrint('Failed to load report ${claim.reportId}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _claims = allClaims;
          _reportDetails = reportDetails;
          _isLoading = false;
        });
        
        // Show popup notification for new claims
        _showPopupNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load notifications: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _sortClaims(List<Claim> claims) {
    switch (_sortBy) {
      case 'date':
        claims.sort((a, b) {
          final comparison = a.createdAt.compareTo(b.createdAt);
          return _sortOrder == 'desc' ? -comparison : comparison;
        });
        break;
      case 'status':
        claims.sort((a, b) {
          final statusOrder = {'pending': 0, 'accepted': 1, 'rejected': 2};
          final aOrder = statusOrder[a.status] ?? 3;
          final bOrder = statusOrder[b.status] ?? 3;
          final comparison = aOrder.compareTo(bOrder);
          return _sortOrder == 'desc' ? -comparison : comparison;
        });
        break;
    }
  }

  Future<void> _refreshNotifications() async {
    final previousCount = _claims.length;
    await _loadNotifications();
    
    // Show popup for new claims during manual refresh
    if (_claims.length > previousCount) {
      final newClaims = _claims.take(_claims.length - previousCount).toList();
      for (final claim in newClaims) {
        _showPopupNotification(claim);
      }
    }
  }

  void _showPopupNotifications() {
    if (_previousClaimCount > 0 && _claims.length > _previousClaimCount) {
      final newClaimsCount = _claims.length - _previousClaimCount;
      final newClaims = _claims.take(newClaimsCount).toList();
      
      for (final claim in newClaims) {
        _showPopupNotification(claim);
      }
    }
    _previousClaimCount = _claims.length;
  }

  void _showPopupNotification(Claim claim) {
    final theme = Theme.of(context);
    final isOwner = claim.ownerId == context.read<AuthKycService>().currentUser?.uid;
    
    String title;
    String message;
    IconData icon;

    if (isOwner) {
      title = 'New Claim Received';
      message = 'Someone wants to claim your ${claim.type}';
      icon = Icons.notification_important;
    } else {
      title = 'Claim Status Update';
      switch (claim.status) {
        case 'accepted':
          message = 'Your claim was accepted! Contact the owner.';
          icon = Icons.check_circle;
          break;
        case 'rejected':
          message = 'Your claim was not accepted.';
          icon = Icons.cancel;
          break;
        default:
          message = 'Your claim is being reviewed.';
          icon = Icons.pending;
      }
    }

    // Show overlay notification
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _getStatusColor(claim.status).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(claim.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: _getStatusColor(claim.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    overlayEntry?.remove();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto-remove after 2.5 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry?.remove();
    });
  }

  Widget _buildNotificationTile(Claim claim, String userId) {
    final theme = Theme.of(context);
    final isOwner = claim.ownerId == userId;
    final isUnread = claim.status == 'pending';
    final report = _reportDetails[claim.reportId];
    final ownerName = report?.ownerName ?? 'Unknown Owner';

    String title;
    String subtitle;
    IconData icon;

    if (isOwner) {
      title = 'New claim on your ${claim.type} report';
      icon = Icons.notification_important_outlined;
      switch (claim.status) {
        case 'pending':
          subtitle = 'Someone wants to claim your item';
          break;
        case 'accepted':
          subtitle = 'Claim accepted • Contact shared';
          break;
        case 'rejected':
          subtitle = 'Claim rejected';
          break;
        default:
          subtitle = 'Status: ${claim.status}';
      }
    } else {
      title = 'Your claim on ${claim.type} item';
      subtitle = 'Owner: $ownerName';
      icon = Icons.send_outlined;
      switch (claim.status) {
        case 'pending':
          subtitle = 'Owner: $ownerName • Waiting for review';
          break;
        case 'accepted':
          subtitle = 'Owner: $ownerName • Claim accepted!';
          break;
        case 'rejected':
          subtitle = 'Owner: $ownerName • Claim not accepted';
          break;
        default:
          subtitle = 'Owner: $ownerName • Status: ${claim.status}';
      }
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      elevation: 0,
      color: isUnread ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(claim.status).withOpacity(0.1),
          child: Icon(
            icon,
            color: _getStatusColor(claim.status),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(status: claim.status),
                if (claim.photoUrls.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${claim.photoUrls.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  _formatDate(claim.createdAt.toDate()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete button for user's own claims
            if (!isOwner && claim.status == 'pending')
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _deleteClaim(claim),
                tooltip: 'Delete claim',
              ),
            if (isOwner && claim.status == 'pending')
              const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _showClaimDetails(claim, isOwner),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  String _formatMonth(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return 'This Week';
    } else if (difference.inDays < 30) {
      return 'This Month';
    } else {
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  Map<String, List<Claim>> _groupClaimsByMonth() {
    final grouped = <String, List<Claim>>{};
    
    for (final claim in _claims) {
      final monthKey = _formatMonth(claim.createdAt.toDate());
      grouped.putIfAbsent(monthKey, () => []).add(claim);
    }
    
    return grouped;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showClaimDetails(Claim claim, bool isOwner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClaimDetailsBottomSheet(
        claim: claim,
        isOwner: isOwner,
        onStatusChanged: _refreshNotifications,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthKycService>();
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Sort button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort notifications',
            onSelected: (value) {
              setState(() {
                if (value.startsWith('date_')) {
                  _sortBy = 'date';
                  _sortOrder = value.split('_')[1];
                } else if (value.startsWith('status_')) {
                  _sortBy = 'status';
                  _sortOrder = value.split('_')[1];
                }
                _sortClaims(_claims);
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date_desc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'date' && _sortOrder == 'desc' 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Newest First'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date_asc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'date' && _sortOrder == 'asc' 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Oldest First'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'status_desc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'status' && _sortOrder == 'desc' 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Status (Pending First)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'status_asc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'status' && _sortOrder == 'asc' 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text('Status (Resolved First)'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _isLoading ? null : _refreshNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _buildBody(userId),
      ),
    );
  }

  Widget _buildBody(String? userId) {
    if (userId == null) {
      return _buildEmptyState(
        icon: Icons.login,
        title: 'Sign In Required',
        subtitle: 'Please sign in to view your notifications',
        action: FilledButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Sign In'),
        ),
      );
    }

    if (_isLoading && _claims.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Error Loading',
        subtitle: _error!,
        action: FilledButton(
          onPressed: _refreshNotifications,
          child: const Text('Try Again'),
        ),
      );
    }

    if (_claims.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: 'No Notifications',
        subtitle: 'You\'ll see updates here when there are new claims',
      );
    }

    final groupedClaims = _groupClaimsByMonth();
    final sortedMonths = groupedClaims.keys.toList()
      ..sort((a, b) {
        // Custom sorting for month keys
        final monthOrder = {
          'Today': 0,
          'Yesterday': 1,
          'This Week': 2,
          'This Month': 3,
        };
        
        final aOrder = monthOrder[a] ?? 4;
        final bOrder = monthOrder[b] ?? 4;
        
        if (aOrder != 4 && bOrder != 4) {
          return aOrder.compareTo(bOrder);
        }
        
        // For actual month names, sort by date
        return b.compareTo(a); // Reverse for newest first
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final claims = groupedClaims[month]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                month,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // Claims for this month
            ...claims.map((claim) => _buildNotificationTile(claim, userId)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteClaim(Claim claim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Claim'),
        content: const Text('Are you sure you want to delete this claim? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _claimService.deleteClaim(claim.claimId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim deleted successfully')),
        );
        _loadNotifications(); // Reload the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete claim: $e')),
        );
      }
    }
  }
}

// Status chip widget
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = theme.colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

// Bottom sheet for showing claim details
class _ClaimDetailsBottomSheet extends StatefulWidget {
  final Claim claim;
  final bool isOwner;
  final VoidCallback onStatusChanged;

  const _ClaimDetailsBottomSheet({
    required this.claim,
    required this.isOwner,
    required this.onStatusChanged,
  });

  @override
  State<_ClaimDetailsBottomSheet> createState() => _ClaimDetailsBottomSheetState();
}

class _ClaimDetailsBottomSheetState extends State<_ClaimDetailsBottomSheet> {
  bool _isProcessing = false;
  bool _isLoadingReport = false;
  Report? _report;
  AppUser? _claimerUser;
  bool _isLoadingClaimer = true;

  @override
  void initState() {
    super.initState();
    _loadReportDetails();
    _loadClaimerUser();
  }

  Future<void> _loadReportDetails() async {
    setState(() => _isLoadingReport = true);
    try {
      final reportService = ReportService();
      final report = await reportService.getReportById(widget.claim.reportId);
      if (mounted) {
        setState(() {
          _report = report;
          _isLoadingReport = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReport = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load report: $e')),
        );
      }
    }
  }

  Future<void> _loadClaimerUser() async {
    setState(() => _isLoadingClaimer = true);
    try {
      final authService = AuthKycService();
      final user = await authService.getUserProfile(widget.claim.claimerId);
      if (mounted) {
        setState(() {
          _claimerUser = user;
          _isLoadingClaimer = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingClaimer = false);
      }
    }
  }

  Future<void> _updateClaimStatus(String status) async {
    setState(() => _isProcessing = true);

    try {
      final authService = context.read<AuthKycService>();
      final claimService = ClaimService();
      
      await claimService.updateClaimStatus(
        widget.claim.claimId,
        status,
        reviewerId: authService.currentUser?.uid,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onStatusChanged();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Claim ${status}'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update claim: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    // Clean and format phone number
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+$cleanPhone';
    }
    
    final uri = Uri.parse('tel:$cleanPhone');
    
    try {
      // Try to launch directly without checking canLaunchUrl first
      // This works better on MIUI and other custom Android ROMs
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open phone app. Please dial $cleanPhone manually.'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: cleanPhone));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number copied to clipboard')),
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Clean phone number for WhatsApp (remove + and spaces)
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Create a friendly, compelling message
    String message = _buildWhatsAppMessage();
    
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    
    try {
      // Try to launch directly without checking canLaunchUrl first
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp. Number: +$cleanPhone'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '+$cleanPhone'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number copied to clipboard')),
                );
              },
            ),
          ),
        );
      }
    }
  }

  String _buildWhatsAppMessage() {
    if (_report == null) {
      return "Hello! I'm contacting you about a claim on your lost item. Could we discuss the details?";
    }

    final report = _report!;
    final itemType = report.subcategory.toLowerCase();
    final location = report.subLocationLost;
    final date = DateFormat('MMM dd, yyyy').format(report.reportedDate.toDate());
    final reward = report.reward != '0' ? 'XAF ${report.reward}' : null;

    String message = "Hi! 👋\n\n";
    message += "Good news! I found your ${itemType} that you reported lost on ${date} in ${location}.\n\n";
    message += "📋 *Report Details:*\n";
    message += "• Item: ${itemType} document\n";
    message += "• Location: ${location}\n";
    message += "• Date: ${date}\n";
    if (reward != null) {
      message += "• Reward: ${reward}\n";
    }
    message += "\nCan we arrange a safe meetup to return it to you?\n\n";
    message += "Please reply when you're available! 😊\n\n";
    message += "- Back2U Team";

    return message;
  }

  void _showImageGallery(List<String> imageUrls, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.95),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Claim Images',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: PageController(initialPage: initialIndex),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        child: Center(
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.white, size: 80),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showContact = widget.claim.status == 'accepted';
    
    String? phone;
    String? whatsapp;
    
    if (showContact && _report != null) {
      phone = _report!.contactPhone?.isNotEmpty == true ? _report!.contactPhone : null;
      whatsapp = _report!.whatsappNumber?.isNotEmpty == true ? _report!.whatsappNumber : null;
      
      // Use phone number for WhatsApp if no specific WhatsApp number
      whatsapp ??= phone;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Text(
                      'Claim Details',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    _StatusChip(status: widget.claim.status),
                  ],
                ),
                const SizedBox(height: 24),

                // Report card
                if (_isLoadingReport) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                ] else if (_report != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description_outlined, 
                              color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text('Report Details', 
                              style: theme.textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _InfoRow('Owner', _report!.ownerName ?? 'N/A'),
                        _InfoRow('Document Type', '${_report!.category}'),
                        _InfoRow('Location', _report!.locationLost),
                        _InfoRow('Date', DateFormat('MMM dd, yyyy')
                          .format(_report!.reportedDate.toDate())),
                        if (_report!.reward != '0')
                          _InfoRow('Reward', 'XAF ${_report!.reward}'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportDetails(report: _report!),
                                ),
                              );
                            },
                            child: const Text('View Full Report'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Claim message
                if (widget.claim.message?.isNotEmpty ?? false) ...[
                  Text('Message', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(widget.claim.message!),
                  ),
                  const SizedBox(height: 16),
                ],

                // Claim images
                if (widget.claim.photoUrls.isNotEmpty) ...[
                  Text('Claim Images', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.claim.photoUrls.length} photo${widget.claim.photoUrls.length > 1 ? 's' : ''} submitted',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: widget.claim.photoUrls.length,
                          itemBuilder: (context, index) {
                            final imageUrl = widget.claim.photoUrls[index];
                            return GestureDetector(
                              onTap: () => _showImageGallery(widget.claim.photoUrls, index),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: theme.colorScheme.surfaceVariant,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / 
                                                  loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: theme.colorScheme.surfaceVariant,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            size: 24,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Failed to load',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Contact section
                if (showContact && (phone != null || whatsapp != null)) ...[
                  // Claimer info card
                  if (_isLoadingClaimer) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16),
                  ] else if (_claimerUser != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: _claimerUser!.profileImageUrl != null
                                ? NetworkImage(_claimerUser!.profileImageUrl!)
                                : null,
                            child: _claimerUser!.profileImageUrl == null
                                ? Icon(Icons.person, size: 28, color: theme.colorScheme.primary)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_claimerUser!.username, style: theme.textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(_claimerUser!.email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Safety advisory
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Safety Reminder',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '⚠️ Please prioritize your safety when meeting up:\n'
                          '• Meet in a public, well-lit area\n'
                          '• Bring a friend or family member\n'
                          '• Avoid meeting alone, especially at night\n'
                          '• Trust your instincts - if something feels off, don\'t proceed\n'
                          '• Consider meeting at a police station or shopping mall',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Contact Information', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        if (phone != null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _launchPhone(phone!),
                              icon: const Icon(Icons.phone),
                              label: Text('Call $phone'),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                        if (phone != null && whatsapp != null) 
                          const SizedBox(height: 8),
                        if (whatsapp != null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _launchWhatsApp(whatsapp!),
                              icon: const Icon(Icons.chat),
                              label: Text('WhatsApp $whatsapp'),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons for pending claims
                if (widget.isOwner && widget.claim.status == 'pending') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isProcessing ? null : () => _updateClaimStatus('rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isProcessing ? null : () => _updateClaimStatus('accepted'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],

                if (_isProcessing) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper widget for info rows
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}