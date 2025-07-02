import 'package:back2u/models/report_model.dart';
import 'package:back2u/models/user_model.dart';
import 'package:back2u/views/auth/auth_page.dart';
import 'package:back2u/views/auth/kyc_form_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:back2u/services/auth_kyc_service.dart';
import 'package:back2u/utils/text_formatter.dart';
import 'package:back2u/views/auth/phone_verification_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back2u/services/claim_service.dart';
import 'package:back2u/models/claim_model.dart';
import 'package:back2u/services/image_upload_service.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:back2u/l10n/app_localizations.dart';
import 'package:back2u/constants/app_enums.dart';

class ReportDetails extends StatefulWidget {
  final Report report;
  final bool showActions; // This prop is currently not used to hide/show AppBar actions
  final VoidCallback? onBack; // This prop is currently not used

  const ReportDetails({
    Key? key,
    required this.report,
    this.showActions = true,
    this.onBack,
  }) : super(key: key);

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  bool _isSaving = false;
  bool _isOwner = false;
  bool _isProcessing = false;
  bool _hasClaimed = false;
  bool _checkingClaim = false;

  String get localizedCategory => 
    Localizations.localeOf(context).languageCode == 'fr' 
      ? widget.report.categoryFr 
      : widget.report.category;

  String get localizedSubcategory => 
    Localizations.localeOf(context).languageCode == 'fr' 
      ? widget.report.subcategoryFr 
      : widget.report.subcategory;

  String get localizedLocation => 
    Localizations.localeOf(context).languageCode == 'fr' 
      ? widget.report.locationLostFr 
      : widget.report.locationLost;

  String get localizedSubLocation => 
    Localizations.localeOf(context).languageCode == 'fr' 
      ? widget.report.subLocationLostFr 
      : widget.report.subLocationLost;

  @override
  void initState() {
    super.initState();
    _checkOwnership();
    _checkIfAlreadyClaimed();
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

  Future<void> _checkIfAlreadyClaimed() async {
    setState(() => _checkingClaim = true);
    try {
      final authService = context.read<AuthKycService>();
      final claimService = ClaimService();
      final userId = authService.currentUser?.uid;
      if (userId == null) {
        setState(() => _hasClaimed = false);
        return;
      }
      final claims = await claimService.getClaimsForUser(userId);
      final alreadyClaimed = claims.any((c) => c.reportId == widget.report.reportId);
      if (mounted) setState(() => _hasClaimed = alreadyClaimed);
    } finally {
      if (mounted) setState(() => _checkingClaim = false);
    }
  }

  Future<void> _toggleSave() async {
    final authService = context.read<AuthKycService>();
    final currentUserId = authService.currentUser?.uid;
    final l10n = AppLocalizations.of(context);

    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseSignInToSave)),
        );
      }
      return;
    }

    final isCurrentlySaved =
        authService.appUser?.savedReports.contains(widget.report.reportId) ?? false;

    // Prevent user from saving their own report, but allow unsaving
    if (!isCurrentlySaved && widget.report.reporterUid == currentUserId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotSaveOwnReport),
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      await authService.toggleSavedReport(
        currentUserId,
        widget.report.reportId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!isCurrentlySaved ? l10n.reportSaved : l10n.reportRemoved),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToSave(e.toString())),
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

  void _shareReport() async {
    // Check if phone is verified before allowing sharing
    final isVerified = await _isPhoneVerified();
    if (!isVerified) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pleaseVerifyPhoneToShare),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    try {
      final l10n = AppLocalizations.of(context);
      final reportUrl = DeepLinks.getReportUrl(widget.report.reportId);
      
      // Create a friendly message based on report type
      final isLostReport = widget.report.type.toLowerCase() == 'lost';
      final message = isLostReport 
          ? '''📢 LOST ITEM ALERT! Can you help?

🔍 ${widget.report.ownerName ?? 'Someone'} has lost their ${widget.report.subcategory.toLowerCase()}
📍 Last seen: ${widget.report.locationLost}${widget.report.subLocationLost.isNotEmpty ? ' (${widget.report.subLocationLost})' : ''}
📅 Date: ${DateFormat('MMM dd, yyyy').format(widget.report.reportedDate.toDate())}
${widget.report.reward != '0' ? '💰 Reward offered: XAF ${widget.report.reward}\n' : ''}
🙏 Please help us find it!

📱 View full details: $reportUrl

#Back2U #LostAndFound #HelpingOthers'''
          : '''✨ FOUND ITEM ALERT!

📦 A ${widget.report.subcategory.toLowerCase()} has been found
📍 Location: ${widget.report.locationLost}${widget.report.subLocationLost.isNotEmpty ? ' (${widget.report.subLocationLost})' : ''}
📅 Found on: ${DateFormat('MMM dd, yyyy').format(widget.report.reportedDate.toDate())}

If this might be yours, please check the details:
📱 $reportUrl

#Back2U #LostAndFound #CommunitySupport''';

      Share.share(message, subject: '${widget.report.type} Report - Back2U');
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

  // Check if user's phone is verified
  Future<bool> _isPhoneVerified() async {
    final authService = context.read<AuthKycService>();
    await authService.reloadUser();
    return authService.isPhoneVerified;
  }

  // Secure claim/contact process
  Future<void> _startClaimProcess() async {
    setState(() => _isProcessing = true);
    try {
      final authService = context.read<AuthKycService>();
      
      // Ensure user data is fresh
      await authService.reloadUser();
  
      // Step 0: Check if the user is claiming their own report
      if (authService.currentUser?.uid == widget.report.reporterUid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You cannot claim your own report.")),
          );
        }
        return; // Stop the process
      }
  
      // Step 1: Check for permanent authentication
      if (authService.currentUser == null || authService.currentUser!.isAnonymous) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to continue.')),
          );
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
        }
        
        // Re-check after attempting sign-in
        await authService.reloadUser();
        if (authService.currentUser == null || authService.currentUser!.isAnonymous) {
          return; // User did not sign in, so we stop here.
        }
      }
  print('------------------------------------------ \n isPhoneVerified: ${authService.isPhoneVerified} \n ---------------------------------------');
      // Step 2: Check for phone verification (KYC)
      if (!authService.isPhoneVerified) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete your profile to continue.')),
          );
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KycFormPage(isFromClaimFlow: true)),
          );
        }
        
        // Re-check after attempting KYC
        await authService.reloadUser();
        if (!authService.isPhoneVerified) {
          return; // User did not complete KYC, so we stop here.
        }
      }
  
      // If we reach here, user is authenticated and verified. Proceed to claim.
      // Show unified claim form for both lost and found items
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _UnifiedClaimBottomSheet(
          onSubmitted: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Claim sent! The owner will review your message and images.'),
                backgroundColor: Colors.green,
              ),
            );
          },
          report: widget.report,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showImageGallery(List<String> imagePaths, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.95),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      File(imagePaths[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white, size: 80),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final authService = context.watch<AuthKycService>();
    final isSaved = authService.appUser?.savedReports.contains(widget.report.reportId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.report.type} ${l10n.report}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          if (widget.showActions)
            IconButton(
              onPressed: _shareReport,
              icon: const Icon(Icons.share),
              tooltip: l10n.shareReport,
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
                      l10n.resolved,
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
              l10n.basicInformation,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Divider(height: 24),

            _buildDetailRow(
              l10n.category,
              '$localizedCategory • $localizedSubcategory',
              icon: Icons.category_outlined,
            ),
            // Conditionally display 'Document Owner' only if ownerName is not null/empty
            if (widget.report.ownerName?.isNotEmpty ?? false)
              _buildDetailRow(
                l10n.documentOwner,
                widget.report.ownerName!,
                icon: Icons.person_outline,
              ),
            _buildDetailRow(
              l10n.rewardOffered,
              formatReward(widget.report.reward),
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
                  l10n.locationAndDates,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            _buildDetailRow(
              l10n.location,
              '$localizedLocation${localizedSubLocation.isNotEmpty ? ' • $localizedSubLocation' : ''}',
              icon: Icons.pin_drop_outlined,
            ),
            _buildDetailRow(
              l10n.incidentDate,
              // Fixed the date format pattern
              DateFormat('MMM dd, yyyy').format(widget.report.reportedDate.toDate()),
              icon: Icons.calendar_today_outlined,
            ),
            _buildDetailRow(
              l10n.reportedOn,
              // Fixed the date format pattern
              DateFormat('MMM dd, yyyy').format(widget.report.createdAt.toDate()),
              icon: Icons.access_time_outlined,
            ),
            const SizedBox(height: 24),

            // --- Notes ---
            if (widget.report.notes.isNotEmpty) ...[
              Text(
                l10n.additionalNotes,
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

            // --- Images Section ---
            if (widget.report.images.isNotEmpty) ...[
              Text(
                l10n.images,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              
              // Large featured image display
              if (widget.report.images.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      onTap: () => _showImageGallery(widget.report.images, 0),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.report.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: colorScheme.surfaceVariant,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: colorScheme.surfaceVariant,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Image count overlay
                          if (widget.report.images.length > 1)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+${widget.report.images.length - 1}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          // Tap indicator
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Thumbnail grid for additional images
                if (widget.report.images.length > 1) ...[
                  Text(
                    'All Images (${widget.report.images.length})',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: widget.report.images.length,
                    itemBuilder: (context, index) {
                      final imageUrl = widget.report.images[index];
                      return GestureDetector(
                        onTap: () => _showImageGallery(widget.report.images, index),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: colorScheme.surfaceVariant,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: colorScheme.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: colorScheme.surfaceVariant,
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 24,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                // Selected indicator for first image
                                if (index == 0)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Main',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
              const SizedBox(height: 24),
            ],

            // --- Action Buttons ---
            const SizedBox(height: 24),
            if (_isOwner) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'You created this report',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 8),
                    // Text(
                    //   'Created on: ' + DateFormat('MMM dd, yyyy').format(widget.report.createdAt.toDate()),
                    //   style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    // ),
                    // const SizedBox(height: 4),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _toggleSave,
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                      label: Text(
                        isSaved ? 'Saved' : 'Save',
                        style: TextStyle(
                          color: isSaved ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(
                          color: isSaved
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
                      onPressed: _isProcessing || _checkingClaim || _hasClaimed ? null : _startClaimProcess,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: _checkingClaim
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_hasClaimed ? 'Already Claimed' : 'Claim this report'),
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
              if (_hasClaimed)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'You have already submitted a claim for this report.',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Unified Claim Bottom Sheet ---
class _UnifiedClaimBottomSheet extends StatefulWidget {
  final Function(String) onSubmitted;
  final Report report;
  const _UnifiedClaimBottomSheet({required this.onSubmitted, required this.report});

  @override
  State<_UnifiedClaimBottomSheet> createState() => _UnifiedClaimBottomSheetState();
}

class _UnifiedClaimBottomSheetState extends State<_UnifiedClaimBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _uploading = false;
  static const int minCharacters = 10;
  static const int maxCharacters = 300;
  static const int maxImages = 2;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showImageGallery(List<String> imagePaths, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.95),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      File(imagePaths[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white, size: 80),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreviewGrid() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Images (${_selectedImages.length}/$maxImages)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_selectedImages.length < maxImages)
              TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: _selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < _selectedImages.length - 1 ? 8 : 0),
                height: 80,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 16),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(4),
                            minimumSize: const Size(20, 20),
                          ),
                          onPressed: () => setState(() => _selectedImages.removeAt(index)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $maxImages images allowed')),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (mounted && images.isNotEmpty) {
        final remainingSlots = maxImages - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_selectedImages.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $maxImages images allowed')),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (photo != null && mounted) {
        setState(() {
          _selectedImages.add(photo);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }

  Future<void> _submitClaim() async {
    final message = _messageController.text.trim();
    
    if (message.isEmpty || message.length < minCharacters) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least $minCharacters characters')),
      );
      return;
    }

    // Require at least one image for lost reports, optional for found reports
    final isLostReport = widget.report.type.toLowerCase() == 'lost';
    if (isLostReport && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image for lost item claims')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit claim for ${widget.report.type} item?'),
            const SizedBox(height: 8),
            Text(
              'Message: "${message.length > 30 ? '${message.substring(0, 30)}...' : message}"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Images: ${_selectedImages.length} photo${_selectedImages.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _uploading = true);
    try {
      final authService = context.read<AuthKycService>();
      final claimService = ClaimService();
      final imageUploadService = ImageUploadService();
      
      // Upload images to Cloudinary
      final List<String> photoUrls = await imageUploadService.uploadImagesToCloudinary(
        imageFiles: _selectedImages,
        userId: authService.currentUser!.uid,
      );
      
      final claim = Claim(
        claimId: '',
        reportId: widget.report.reportId,
        claimerId: authService.currentUser!.uid,
        ownerId: widget.report.reporterUid,
        type: widget.report.type,
        status: 'pending',
        createdAt: Timestamp.now(),
        photoUrls: photoUrls,
        message: message,
      );
      
      await claimService.createClaim(claim);
      if (mounted) {
        widget.onSubmitted(message);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit claim: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final message = _messageController.text.trim();
    final isLostReport = widget.report.type.toLowerCase() == 'lost';
    final isValid = message.length >= minCharacters && 
                   message.length <= maxCharacters && 
                   (!isLostReport || _selectedImages.isNotEmpty); // Images required only for lost reports
    final isOverLimit = message.length > maxCharacters;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Icon(
                      widget.report.type.toLowerCase() == 'lost' 
                        ? Icons.search_outlined 
                        : Icons.find_in_page_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Claim ${widget.report.type} Item',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.report.type.toLowerCase() == 'lost'
                    ? 'Provide proof that you found this item'
                    : 'Provide proof that this item belongs to you',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Message input
                Text(
                  'Message',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  maxLength: maxCharacters,
                  decoration: InputDecoration(
                    hintText: widget.report.type.toLowerCase() == 'lost'
                      ? 'Describe how you found the item...'
                      : 'Describe the item and provide proof...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    counterText: '${message.length}/$maxCharacters',
                    errorText: isOverLimit 
                      ? 'Too long' 
                      : message.isNotEmpty && message.length < minCharacters
                        ? 'Min $minCharacters chars'
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Images section
                Text(
                  'Images (${_selectedImages.length}/$maxImages)${isLostReport ? ' *Required' : ' (Optional)'}',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                // Image preview
                if (_selectedImages.isNotEmpty) ...[
                  _buildImagePreviewGrid(),
                  const SizedBox(height: 12),
                ],

                // Image selection buttons
                if (_selectedImages.length < maxImages) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Camera'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Submit button
                if (_uploading) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  const Center(child: Text('Submitting...')),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isValid ? _submitClaim : null,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Submit Claim'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}