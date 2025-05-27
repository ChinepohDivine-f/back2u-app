import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class SimpleCard extends StatelessWidget {
  const SimpleCard({
    super.key,
    required this.ownerName,
    required this.subCategory,
    required this.type,
    required this.location,
    this.imageCount = 0,
    required this.incidentDate,
    required this.reportDate,
    required this.isResolved,
    this.onTap, // onTap is nullable, so no default value needed
  });

  final String ownerName;
  final String subCategory;
  final String type; // 'Lost' or 'Found'
  final String location;
  final int imageCount;
  final DateTime incidentDate;
  final DateTime reportDate;
  final bool isResolved;
  final VoidCallback? onTap;

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

  @override
  Widget build(BuildContext context) {
    // Access the current theme for consistent styling
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Use default Card elevation and shape for simplicity
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        elevation: 1, // A subtle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Slightly less rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Slightly reduced padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area with a simpler look
              Stack(
                children: [
                  Container(
                    height: 80, // Slightly reduced height
                    width: 80, // Slightly reduced width
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant, // Use a subtle background from theme
                      borderRadius: BorderRadius.circular(8), // Match card's subtle rounding
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 24, // Slightly smaller icon
                      ),
                    ),
                  ),
                  // Lost/Found tag
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Smaller padding
                      decoration: BoxDecoration(
                        color: type.toLowerCase() == 'lost'
                            ? Colors.red[700] // Direct red for 'Lost'
                            : Colors.green[700], // Direct green for 'Found'
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith( // Use labelSmall for smaller text
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Image count badge
                  if (imageCount > 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54, // Simple translucent black
                          borderRadius: BorderRadius.circular(10), // More circular
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt, // Simpler icon
                              size: 11, // Smaller icon
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$imageCount",
                              style: textTheme.bodyMedium?.copyWith( // Use bodyMedium
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

              const SizedBox(width: 12), // Reduced spacing

              // Content area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner name with resolved badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            ownerName,
                            style: textTheme.titleMedium?.copyWith( // Use titleMedium
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isResolved)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Smaller padding
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1), // Lighter primary background
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 1, // Thinner border
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline, // Simpler outline icon
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
                      ],
                    ),

                    const SizedBox(height: 4), // Reduced spacing

                    // Subcategory
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.5), // Use secondaryContainer with opacity
                        borderRadius: BorderRadius.circular(6), // Simpler rounded corners
                      ),
                      child: Text(
                        subCategory,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8), // Reduced spacing

                    // Location with icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined, // Simpler outline icon
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4), // Reduced spacing

                    // Incident date
                    Row(
                      children: [
                        Icon(
                          Icons.event_note_outlined, // Simpler outline event icon
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Incident: ${DateFormat('MMM dd, yyyy').format(incidentDate)}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4), // Small spacing between dates

                    // Relative time display (for report date)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time, // Simpler time icon
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reported: ${_getRelativeTime(reportDate)}',
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