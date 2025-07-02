// lib/components/simple_card.dart
import 'package:flutter/material.dart';
import 'package:back2u/models/report_model.dart';
import 'package:back2u/components/report_details.dart'; // Assuming this exists for onTap navigation
import 'package:back2u/components/image_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:back2u/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SimpleCard extends StatefulWidget {
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

  @override
  State<SimpleCard> createState() => _SimpleCardState();
}

class _SimpleCardState extends State<SimpleCard> {
  String get localizedSubcategory => 
    Localizations.localeOf(context).languageCode == 'fr' 
      ? widget.report.subcategoryFr 
      : widget.report.subcategory;

  String get localizedSubLocation => 
    Localizations.localeOf(context).languageCode == 'fr' 
      ? widget.report.subLocationLostFr 
      : widget.report.subLocationLost;

  // Helper method to format relative time
  String _getRelativeTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final l10n = AppLocalizations.of(context);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ${l10n.ago}';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ${l10n.ago}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ${l10n.ago}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ${l10n.ago}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ${l10n.ago}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ${l10n.ago}';
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

  void _showImageGallery(BuildContext context) {
    if (widget.report.images.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageGallery(
            images: widget.report.images,
            initialIndex: 0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.hardEdge,
      elevation: 2.0,
      shadowColor: colors.onPrimaryFixedVariant.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap ?? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportDetails(report: widget.report,)),
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
                        label: Text(widget.report.type.toUpperCase()),                        
                        backgroundColor: widget.report.type.toLowerCase() == 'lost'
                          ? colors.errorContainer.withOpacity(0.9)
                          : colors.tertiaryContainer.withOpacity(0.9),
                        labelStyle: textTheme.labelSmall?.copyWith(
                          color: widget.report.type.toLowerCase() == 'lost'
                            ? colors.error
                            : colors.tertiary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(
                          color: widget.report.type.toLowerCase() == 'lost'
                            ? colors.error
                            : colors.tertiary,
                          width: 1.2,
                        ),
                        elevation: 1.5,
                        shadowColor: colors.shadow,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      if (widget.report.resolved)
                        InputChip(
                          label: Text(l10n.resolved),
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
                  if (widget.showActions) _buildOwnerActions(colors, l10n)
                  else if (widget.onToggleSave != null) _buildSaveActionMenu(context, colors, l10n)
                ],
              ),

              const SizedBox(height: 5),

              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner name and subcategory
                  Text(
                    widget.report.ownerName ?? 'Anonymous',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedSubcategory,
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
                        label: Text(localizedSubLocation),
                        labelStyle: textTheme.labelLarge,
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        backgroundColor: colors.surfaceVariant,
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(_formatDate(widget.report.reportedDate.toDate())),
                        labelStyle: textTheme.labelLarge,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  
                  // Image display
                  if (widget.report.images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
                          onTap: () => _showImageGallery(context),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: widget.report.images.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: colors.surfaceVariant,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: colors.surfaceVariant,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              // Image count overlay
                              if (widget.report.images.length > 1)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
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
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  
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
                        '${l10n.reported} ${_getRelativeTime(widget.report.createdAt.toDate(), context)}',
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

  Widget _buildOwnerActions(ColorScheme colors, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit' && widget.onEdit != null) {
          widget.onEdit!();
        } else if (value == 'delete' && widget.onDelete != null) {
          widget.onDelete!();
        } else if (value == 'toggle_status' && widget.onToggleResolve != null) {
          widget.onToggleResolve!();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (widget.onEdit != null)
          PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editReport),
            ),
          ),
          if (widget.onToggleResolve != null)
          PopupMenuItem<String>(
            value: 'toggle_status',
            child: ListTile(
              leading: Icon(
                  widget.report.status == 'resolved' ? Icons.undo : Icons.check_circle_outline,
                  color: widget.report.status == 'resolved' ? Colors.orange : Colors.green),
              title: Text(widget.report.status == 'resolved' ? l10n.markAsActive : l10n.markAsResolved),
            ),
          ),
        if (widget.onDelete != null)
          PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(l10n.deleteReport),
            ),
          ),
        
      ],
      icon: Icon(Icons.more_vert, color: colors.onSurfaceVariant),
      tooltip: 'More options', // Fallback value since moreOptions is commented out
    );
  }

  Widget _buildSaveActionMenu(BuildContext context, ColorScheme colors, AppLocalizations l10n) {
    return widget.loading
        ? SizedBox(
            width: 28,
            height: 28,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
            ),
          )
        : PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_save' && widget.onToggleSave != null) {
                widget.onToggleSave!();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'toggle_save',
                child: ListTile(
                  leading: Icon(
                    widget.isSaved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                    color: widget.isSaved ? colors.error : colors.primary,
                  ),
                  title: Text(widget.isSaved ? l10n.unsaveReport : l10n.saveReport),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
            tooltip: 'Options', // Fallback value since options might be missing
          );
  }
}