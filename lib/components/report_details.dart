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

    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save reports')),
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
          const SnackBar(
            content: Text("You can't save your own report. View your reports in the 'My Reports' section."),
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
            content: Text(!isCurrentlySaved ? 'Report saved!' : 'Report removed'),
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

  void _shareReport() async {
    // Check if phone is verified before allowing sharing
    final isVerified = await _isPhoneVerified();
    if (!isVerified) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your phone number to share this report'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
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
      if (widget.report.type.toLowerCase() == 'lost') {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _ClaimPhotoBottomSheet(
            onSubmitted: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo submitted for verification!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            report: widget.report,
          ),
        );
      } else {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _ClaimMessageBottomSheet(
            onSubmitted: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Claim sent! The finder will review your message.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            report: widget.report,
          ),
        );
      }
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

    final authService = context.watch<AuthKycService>();
    final isSaved = authService.appUser?.savedReports.contains(widget.report.reportId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.report.type} Report'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          if (widget.showActions)
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

            // --- Images Section ---
            if (widget.report.images.isNotEmpty) ...[
              Text(
                'Images',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
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
                itemCount: widget.report.images.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.report.images[index];
                  return GestureDetector(
                    onTap: () => _showImageGallery(widget.report.images, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (context, url, error) =>
                            Container(
                              color: colorScheme.surfaceVariant,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                      ),
                    ),
                  );
                },
              ),
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
                      icon: const Icon(Icons.shield_outlined),
                      label: _checkingClaim
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_hasClaimed ? 'Already Claimed' : (widget.report.type.toLowerCase() == 'lost' ? 'I Have Found This' : 'Claim My Item')),
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

// --- Claim Photo Bottom Sheet ---
class _ClaimPhotoBottomSheet extends StatefulWidget {
  final VoidCallback onSubmitted;
  final Report report;
  const _ClaimPhotoBottomSheet({required this.onSubmitted, required this.report});

  @override
  State<_ClaimPhotoBottomSheet> createState() => _ClaimPhotoBottomSheetState();
}

class _ClaimPhotoBottomSheetState extends State<_ClaimPhotoBottomSheet> {
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

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
        Text(
          'Selected Images (${_selectedImages.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
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
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            final image = _selectedImages[index];
            return GestureDetector(
              onTap: () => _showImageGallery(
                _selectedImages.map((img) => img.path).toList(),
                index,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(24, 24),
                        ),
                        onPressed: () => setState(() => _selectedImages.removeAt(index)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 35,
      );
      if (mounted && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
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
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 35,
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
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to submit this claim?'),
            const SizedBox(height: 8),
            Text(
              'You\'ve selected ${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''} as proof.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once submitted, the report owner will review your claim and contact you if accepted.',
              style: TextStyle(fontSize: 12),
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
            child: const Text('Submit Claim'),
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
        message: 'Photo evidence submitted',
      );
      await claimService.createClaim(claim);
      if (mounted) {
        widget.onSubmitted();
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

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
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
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Icon(Icons.camera_alt_outlined, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Claim Lost Item',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select photos of yourself with the item or relevant documents for verification.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Image preview section
                if (_selectedImages.isNotEmpty) ...[
                  _buildImagePreviewGrid(),
                  const SizedBox(height: 24),
                ],

                // Action buttons
                if (_uploading) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('Uploading images...'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitClaim,
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Submit Claim'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- Claim Message Bottom Sheet ---
class _ClaimMessageBottomSheet extends StatefulWidget {
  final Function(String) onSubmitted;
  final Report report;
  const _ClaimMessageBottomSheet({required this.onSubmitted, required this.report});

  @override
  State<_ClaimMessageBottomSheet> createState() => _ClaimMessageBottomSheetState();
}

class _ClaimMessageBottomSheetState extends State<_ClaimMessageBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  static const int minCharacters = 15;
  static const int maxCharacters = 500;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    final message = _controller.text.trim();
    if (message.isEmpty || message.length < minCharacters) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to submit this claim?'),
            const SizedBox(height: 8),
            Text(
              'Your message: "${message.length > 50 ? '${message.substring(0, 50)}...' : message}"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once submitted, the report owner will review your claim and contact you if accepted.',
              style: TextStyle(fontSize: 12),
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
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _sending = true);

    try {
      final authService = context.read<AuthKycService>();
      final claimService = ClaimService();

      // Create claim
      final claim = Claim(
        claimId: '', // Will be set by Firestore
        reportId: widget.report.reportId,
        claimerId: authService.currentUser!.uid,
        ownerId: widget.report.reporterUid,
        type: widget.report.type,
        status: 'pending',
        createdAt: Timestamp.now(),
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
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final message = _controller.text.trim();
    final isValid = message.length >= minCharacters && message.length <= maxCharacters;
    final isOverLimit = message.length > maxCharacters;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
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
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Icon(Icons.message_outlined, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Contact Finder',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Describe your lost items and why you think they\'re yours.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Minimum $minCharacters characters, maximum $maxCharacters characters.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Message input
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  maxLength: maxCharacters,
                  decoration: InputDecoration(
                    hintText: 'Enter your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    counterText: '${message.length}/$maxCharacters',
                    errorText: isOverLimit 
                      ? 'Message is too long' 
                      : message.isNotEmpty && message.length < minCharacters
                        ? 'At least $minCharacters characters required'
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                
                // Character count indicator
                if (message.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        message.length >= minCharacters ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: message.length >= minCharacters 
                          ? Colors.green 
                          : colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.length >= minCharacters 
                          ? 'Minimum length met' 
                          : '${minCharacters - message.length} more characters needed',
                        style: textTheme.bodySmall?.copyWith(
                          color: message.length >= minCharacters 
                            ? Colors.green 
                            : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Submit button
                if (_sending) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('Sending claim...'),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isValid ? _submitClaim : null,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Send Claim'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}