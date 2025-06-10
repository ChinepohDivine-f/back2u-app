import 'package:back2u/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDetails extends StatelessWidget {
  final Report report;

  const ReportDetails({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${report.type} Report'), // More generic title
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: report.type.toLowerCase() == 'lost'
                        ? colorScheme.error
                        : colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.type.toUpperCase(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: report.type.toLowerCase() == 'lost'
                          ? colorScheme.onError
                          : colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (report.resolved)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            const SizedBox(height: 16),

            // --- Owner Name and Document Type (Primary Focus) ---
            Text(
              report.ownerName ?? 'N/A', // Prioritize owner name
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.documentName, // Second, the document type
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24), // More space before details

            // --- Details Card ---
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    context,
                    'Category',
                    '${report.category} > ${report.subcategory}',
                    Icons.category_outlined,
                  ),
                  _buildDetailRow(
                    context,
                    // report.type == 'Lost' ? 'Owner' : 'Finder',
                    'Documument Owner',
                    report.ownerName ?? 'Not Specified',
                    Icons.person_outline,
                  ),
                  _buildDetailRow(
                    context,
                    'Reward',
                    report.reward.isNotEmpty && report.reward != '0 CFA'
                        ? report.reward 
                        : 'None',
                    Icons.money_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Location & Dates Card ---
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location & Dates',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    context,
                    'Location',
                    '${report.locationLost}, ${report.subLocationLost}',
                    Icons.location_on_outlined,
                  ),
                  _buildDetailRow(
                    context,
                    'Incident Date',
                    DateFormat('MMM dd, yyyy')
                        .format(report.reportedDate.toDate()),
                    Icons.event_note_outlined,
                  ),
                  _buildDetailRow(
                    context,
                    'Reported On',
                    DateFormat('MMM dd, yyyy')
                        .format(report.createdAt.toDate()),
                    Icons.access_time,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Notes Card ---
            if (report.notes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 16),
                  Text(
                    report.notes,
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            if (report.notes.isNotEmpty) const SizedBox(height: 16),

            // --- Images Card (if any) ---
            if (report.images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Images',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 16),
                  SizedBox(
                    height: 120, // Adjusted height for image scroll view
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: report.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              report.images[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            if (report.images.isNotEmpty) const SizedBox(height: 16),

            // --- Contact Reporter Button ---
            const SizedBox(height: 24),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showContactModal(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    minimumSize: const Size(
                        double.infinity, 50), // Make button full width
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _showContactModal(context);
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact Reporter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(
                        double.infinity, 50), // Make button full width
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Method to show contact information modal
  void _showContactModal(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

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
                    'Reporter Information',
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

              // Reporter Name
              _buildContactDetailRow(
                context,
                'Reporter Name',
                report.reporterId ?? 'Not Specified',
                Icons.person,
              ),

              
            
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement phone call
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling ${report.contactPhone}...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (report.whatsappNumber.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement WhatsApp
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Opening WhatsApp for ${report.whatsappNumber}...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for contact detail rows in modal
  Widget _buildContactDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isClickable
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isClickable
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.primary,
            ),
        ],
      ),
    );

    if (isClickable && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }

  // Helper method to build consistent detail rows
  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
