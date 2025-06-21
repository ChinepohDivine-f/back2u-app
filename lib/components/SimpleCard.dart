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
        return colors.secondary;
      case 'pending':
        return colors.tertiary;
      default:
        return colors.primary;
    }
  }

  // Helper to format date
  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.hardEdge,
      elevation: 2.0,
      shadowColor: colors.onPrimaryFixedVariant.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportDetails(report: report)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Type and status chips
                  Wrap(
                    spacing: 8,
                    children: [
                      InputChip(
                        label: Text(report.type.toUpperCase()),                        
                        backgroundColor: report.type.toLowerCase() == 'lost'
                          ? colors.errorContainer.withOpacity(0.9)
                          : colors.tertiaryContainer.withOpacity(0.9),
                        labelStyle: textTheme.labelSmall?.copyWith(
                          color: report.type.toLowerCase() == 'lost'
                            ? colors.error
                            : colors.tertiary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: report.type.toLowerCase() == 'lost'
                            ? colors.error
                            : colors.tertiary,
                          width: 1.2,
                        ),
                        elevation: 1.5,
                        shadowColor: colors.shadow,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      if (report.resolved)
                        InputChip(
                          label: const Text('RESOLVED'),
                          backgroundColor: colors.secondaryContainer,
                          labelStyle: textTheme.labelSmall?.copyWith(
                            color: colors.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: const StadiumBorder(),
                        ),
                    ],
                  ),
                  // Actions
                  if (showActions) _buildOwnerActions(colors)
                  else if (onToggleSave != null) _buildSaveButton(colors)
                ],
              ),

              const SizedBox(height: 5),

              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner name and subcategory
                  Text(
                    report.ownerName ?? 'Anonymous',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.subcategory,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  // Info chips row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        backgroundColor: colors.surfaceVariant,
                        avatar: const Icon(Icons.location_on, size: 16),
                        label: Text(report.subLocationLost),
                        labelStyle: textTheme.labelLarge,
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        backgroundColor: colors.surfaceVariant,
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(_formatDate(report.reportedDate.toDate())),
                        labelStyle: textTheme.labelLarge,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Created time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reported ${_getRelativeTime(report.createdAt.toDate())}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerActions(ColorScheme colors) {
    return PopupMenuButton<String>(
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
      icon: Icon(Icons.more_vert, color: colors.onSurfaceVariant),
      tooltip: 'More options',
    );
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return loading
        ? SizedBox(
            width: 28,
            height: 28,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
            ),
          )
        : IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? colors.primary : colors.onSurfaceVariant,
            ),
            onPressed: onToggleSave,
            tooltip: isSaved ? 'Unsave Report' : 'Save Report',
          );
  }
}