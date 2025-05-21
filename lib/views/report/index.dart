import 'package:flutter/material.dart';
import 'package:back2u/views/report/report_form.dart'; // Ensure this path is correct

class Report extends StatelessWidget {
  const Report({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary, // Use primary color from theme
        foregroundColor: colorScheme.onPrimary, // Text color on primary
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons take full width
          children: [
            Text(
              'What would you like to report?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // Use onSurface for text on background
              ),
            ),
            const SizedBox(height: 40),

            // Lost Item Button (using ElevatedButton.icon)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportForm()),
                );
              },
              icon: Icon(Icons.search_off, size: 30, color: colorScheme.onSecondaryContainer),
              label: Text(
                'Report Lost Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer, // A distinct color for 'Lost'
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft, // Align content to the left
              ),
            ),

            const SizedBox(height: 20),

            // Found Item Button (using ElevatedButton.icon)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportForm()),
                );
              },
              icon: Icon(Icons.volunteer_activism, size: 30, color: colorScheme.onPrimaryContainer),
              label: Text(
                'Report Found Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer, // A distinct color for 'Found'
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft, // Align content to the left
              ),
            ),
          ],
        ),
      ),
    );
  }
}