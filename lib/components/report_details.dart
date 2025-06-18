import 'package:back2u/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetails extends StatefulWidget {
  final Report report;
  final String? currentUserId;
  final List<String>? userSavedReports;
  final bool showActions; // This prop is currently not used to hide/show AppBar actions
  final VoidCallback? onBack; // This prop is currently not used

  const ReportDetails({
    Key? key,
    required this.report,
    this.currentUserId,
    this.userSavedReports,
    this.showActions = true,
    this.onBack,
  }) : super(key: key);

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.userSavedReports?.contains(widget.report.reportId) ?? false;
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    // Using context.read is safe here as it's within initState and the AuthKycService is expected to be present.
    final currentUser = context.read<AuthKycService>().currentUser;
    if (mounted) {
      setState(() {
        _isOwner = currentUser?.uid == widget.report.reporterUid;
      });
    }
  }

  Future<void> _toggleSave() async {
    if (widget.currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save reports')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      await AuthKycService().toggleSavedReport(
        widget.currentUserId!,
        widget.report.reportId,
      );
      setState(() => _isSaved = !_isSaved);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Report saved!' : 'Report removed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _shareReport() {
    try {
      // THIS IS THE KEY: The URL 'https://back2u.app/report/${widget.report.reportId}'
      // MUST have Open Graph and Twitter Card meta tags on its HTML backend.
      // The descriptive text you want in the share preview will come from those tags,
      // not primarily from the 'text' variable here, though 'text' is used for apps
      // that don't render rich previews.
      final reportUrl = 'https://back2u.app/report/${widget.report.reportId}';
      final text = '''
${widget.report.type.toUpperCase()} Report
Owner: ${widget.report.ownerName ?? 'Anonymous'}
Category: ${widget.report.category} > ${widget.report.subcategory}
Location: ${widget.report.locationLost}
${widget.report.subLocationLost.isNotEmpty ? 'Sublocation: ${widget.report.subLocationLost}\n' : ''}
View details: $reportUrl
Shared via Back2U''';

      Share.share(text, subject: '${widget.report.type} Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper method to build consistent detail rows with icons
  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Launch URL helper
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) { // Use externalApplication for deep linking
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  // Show contact information modal
  void _showContactModal() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Format phone numbers for dialer and WhatsApp
    // Clean both phone number and WhatsApp number for safety
    final cleanedContactPhone = widget.report.contactPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final cleanedWhatsappNumber = widget.report.whatsappNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    final whatsappUrl = 'https://wa.me/$cleanedWhatsappNumber';
    final callUrl = 'tel:$cleanedContactPhone';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contact Reporter',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reporter Information
              _buildDetailRow(
                'Reported by',
                widget.report.reporterName ?? 'Anonymous',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchUrl(callUrl);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green, // Consider using theme.colorScheme.primary if it aligns with your brand
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  // Only show WhatsApp button if a WhatsApp number is provided
                  if (widget.report.whatsappNumber.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _launchUrl(whatsappUrl);
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366), // WhatsApp brand color
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16), // Added this missing closing bracket for the Column in the modal
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.report.type} Report'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          if (widget.showActions) // Conditionally show actions if showActions is true
            IconButton(
              onPressed: _shareReport,
              icon: const Icon(Icons.share),
              tooltip: 'Share Report',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Type and Status Badge ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.report.type.toLowerCase() == 'lost'
                        ? colorScheme.error
                        : colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.report.type.toUpperCase(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.report.type.toLowerCase() == 'lost'
                          ? colorScheme.onError
                          : colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.report.resolved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.primary),
                    ),
                    child: Text(
                      'RESOLVED',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Owner Name (Primary Focus) ---
            Text(
              widget.report.ownerName ?? 'N/A', // Display 'N/A' if ownerName is null
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // --- Basic Information ---
            Text(
              'Basic Information',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Divider(height: 24),

            _buildDetailRow(
              'Category',
              '${widget.report.category} • ${widget.report.subcategory}',
              icon: Icons.category_outlined,
            ),
            // Conditionally display 'Document Owner' only if ownerName is not null/empty
            if (widget.report.ownerName?.isNotEmpty ?? false)
              _buildDetailRow(
                'Document Owner',
                widget.report.ownerName!,
                icon: Icons.person_outline,
              ),
            _buildDetailRow(
              'Reward',
              widget.report.reward.isNotEmpty && widget.report.reward != '0 CFA'
                  ? widget.report.reward
                  : 'No reward',
              icon: Icons.monetization_on_outlined,
            ),
            const SizedBox(height: 24),

            // --- Location & Dates ---
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 24,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location & Dates',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            _buildDetailRow(
              'Location',
              '${widget.report.locationLost}${widget.report.subLocationLost.isNotEmpty ? ' • ${widget.report.subLocationLost}' : ''}',
              icon: Icons.pin_drop_outlined,
            ),
            _buildDetailRow(
              'Incident Date',
              // Fixed the date format pattern
              DateFormat('MMM dd, yyyy').format(widget.report.reportedDate.toDate()),
              icon: Icons.calendar_today_outlined,
            ),
            _buildDetailRow(
              'Reported On',
              // Fixed the date format pattern
              DateFormat('MMM dd, yyyy').format(widget.report.createdAt.toDate()),
              icon: Icons.access_time_outlined,
            ),
            const SizedBox(height: 24),

            // --- Notes ---
            if (widget.report.notes.isNotEmpty) ...[
              Text(
                'Additional Notes',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Divider(height: 24),
              Text(
                widget.report.notes,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
            ],

            // --- Action Buttons ---
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _toggleSave,
                    icon: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: _isSaved ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      _isSaved ? 'Saved' : 'Save',
                      style: TextStyle(
                        color: _isSaved ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(
                        color: _isSaved
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _showContactModal,
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('Contact'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --- Claim Photo Dialog ---
class _ClaimPhotoDialog extends StatefulWidget {
  final VoidCallback onSubmitted;
  const _ClaimPhotoDialog({required this.onSubmitted});

  @override
  State<_ClaimPhotoDialog> createState() => _ClaimPhotoDialogState();
}

class _ClaimPhotoDialogState extends State<_ClaimPhotoDialog> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Claim Lost Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload a photo of yourself with the item or a relevant document.'),
          const SizedBox(height: 16),
          _uploading
              ? const Center(child: CircularProgressIndicator())
              : OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Upload Photo'),
                  onPressed: () async {
                    setState(() => _uploading = true);
                    await Future.delayed(const Duration(seconds: 2)); // Simulate upload
                    if (mounted) {
                      setState(() => _uploading = false);
                      widget.onSubmitted();
                      Navigator.pop(context); // Close dialog after submission
                    }
                  },
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// --- Claim Message Dialog ---
class _ClaimMessageDialog extends StatefulWidget {
  final Function(String) onSubmitted;
  const _ClaimMessageDialog({required this.onSubmitted});

  @override
  State<_ClaimMessageDialog> createState() => _ClaimMessageDialogState();
}

class _ClaimMessageDialogState extends State<_ClaimMessageDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Contact Finder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Describe your lost item and why you think it's yours."),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter your message...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _sending || _controller.text.trim().isEmpty
              ? null
              : () async {
                  setState(() => _sending = true);
                  await Future.delayed(const Duration(seconds: 2)); // Simulate send
                  if (mounted) {
                    setState(() => _sending = false);
                    widget.onSubmitted(_controller.text.trim());
                    Navigator.pop(context); // Close dialog after submission
                  }
                },
          child: _sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}