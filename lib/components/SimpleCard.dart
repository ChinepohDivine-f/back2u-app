// lib/components/simple_card.dart
import 'package:flutter/material.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/components/report_details.dart'; // Assuming this exists for onTap navigation
import 'package:intl/intl.dart'; // For date formatting

class SimpleCard extends StatelessWidget {
  final Report report;
  final bool showActions; // Controls visibility of Edit, Delete, Resolve for owner
  final bool isSaved; // Controls bookmark icon state
  final bool loading;
  final VoidCallback? onToggleSave; // Callback for save/unsave action
  final VoidCallback? onEdit; // Callback for edit action
  final VoidCallback? onDelete; // Callback for delete action
  final VoidCallback? onToggleResolve; // Callback for resolve/reopen action
  final VoidCallback? onTap; // Callback for card tap navigation
  // Constructor for SimpleCard

  const SimpleCard({
    super.key,
    required this.report,
    this.showActions = false,
    this.isSaved = false,
    this.loading = false,
    this.onToggleSave, // Added
    this.onEdit, // Added
    this.onDelete, // Added
    this.onToggleResolve, // Added
    this.onTap, // Added for navigation
  });

  // Helper method to format relative time
  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  // Helper to determine status color based on your preferences
  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green.shade700; // Use a specific green for resolved
      case 'pending': // You might have a 'pending' status
        return Colors.orange.shade700;
      default: // For 'active' or other states
        return colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () {
        // Navigate to ReportDetails page when card is tapped
        // If an explicit onTap callback is provided, use it, otherwise navigate
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetails(report: report),
            ),
          );
        }
      }, 
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Keep your preferred margin
        elevation: 1, // Keep your preferred elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Keep your preferred border radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Keep your preferred padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Icon area
              Stack(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant, // Background color for the image/icon area
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: report.images != null && report.images!.isNotEmpty
                        ? ClipRRect( // Clip for rounded corners on the image
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              report.images!.first, // Display the first image from the list
                              fit: BoxFit.cover, // Cover the container area
                              width: 80, // Ensure it fills the container
                              height: 80, // Ensure it fills the container
                              loadingBuilder: (context, child, loadingProgress) {
                                // Show a circular progress indicator while the image is loading
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to a default icon if the image fails to load
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 40, // Larger size for the fallback icon
                                  ),
                                );
                              },
                            ),
                          )
                        : Center( // Default icon if no images are available in the report
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: 40, // Larger size for the default icon
                            ),
                          ),
                  ),
                  // Lost/Found tag
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorScheme.fromSeed(seedColor: Colors.blue).primary,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        report.type.toUpperCase(), // Use report.type
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Image count badge
                  if (report.images != null && report.images!.isNotEmpty) // Check if images list is not empty
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${report.images!.length}", // Use report.images.length
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Content area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner name with resolved badge and actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            report.ownerName ?? 'N/A', // Use report.ownerName
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (report.resolved) // Use report.resolved for resolved badge
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 12,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Resolved',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Action buttons (edit, delete, resolve) for the owner via PopupMenuButton
                        if (showActions && (onEdit != null || onDelete != null || onToggleResolve != null))
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit' && onEdit != null) {
                                onEdit!();
                              } else if (value == 'delete' && onDelete != null) {
                                onDelete!();
                              } else if (value == 'toggle_status' && onToggleResolve != null) {
                                onToggleResolve!();
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              if (onEdit != null)
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit Report'),
                                  ),
                                ),
                              if (onDelete != null)
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_forever, color: Colors.red),
                                    title: Text('Delete Report'),
                                  ),
                                ),
                              if (onToggleResolve != null)
                                PopupMenuItem<String>(
                                  value: 'toggle_status',
                                  child: ListTile(
                                    leading: Icon(
                                        report.status == 'resolved' ? Icons.undo : Icons.check_circle_outline,
                                        color: report.status == 'resolved' ? Colors.orange : Colors.green),
                                    title: Text(report.status == 'resolved' ? 'Mark as Active' : 'Mark as Resolved'),
                                  ),
                                ),
                            ],
                            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                            tooltip: 'More options',
                          ),
                        // Save/Unsave button (always visible when onToggleSave is provided)
                        if (onToggleSave != null)
                          loading
                              ? SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                                    color: isSaved ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: onToggleSave,
                                  tooltip: isSaved ? 'Unsave Report' : 'Save Report',
                                ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Subcategory
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.subcategory, // Use report.subcategory
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Location with icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.locationLost, // Use report.locationLost
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Incident date (using reportedDate from model)
                    Row(
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Incident: ${DateFormat('MMM dd, yyyy').format(report.reportedDate.toDate())}', // Convert Timestamp to DateTime
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Relative time display (using createdAt from model)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reported: ${_getRelativeTime(report.createdAt.toDate())}', // Convert Timestamp to DateTime
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}