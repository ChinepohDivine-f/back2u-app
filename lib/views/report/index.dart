import 'package:flutter/material.dart';
import 'package:back2u/views/report/report_form.dart'; // Ensure this path is correct
import 'package:back2u/models/report_model.dart'; // Import your Report model

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Report'), // Updated title
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What would you like to report?', // Updated text
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 40),

            // Report Lost Item Button
            FilledButton.icon(
              onPressed: () {
                // Create a new Report object with type 'Lost'
                final newReport = Report(type: 'Lost', reportId: 'temp_id_${DateTime.now().microsecondsSinceEpoch}'); // temp ID
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportForm(report: newReport)), // Pass the report object
                );
              },
              icon: Icon(Icons.search_off, size: 30, color: colorScheme.onSecondaryContainer),
              label: Text(
                'Report Lost Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
              ),
            ),

            const SizedBox(height: 20),

            // Report Found Item Button
            FilledButton.icon(
              onPressed: () {
                // Create a new Report object with type 'Found'
                final newReport = Report(type: 'Found', reportId: 'temp_id_${DateTime.now().microsecondsSinceEpoch}'); // temp ID
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportForm(report: newReport)), // Pass the report object
                );
              },
              icon: Icon(Icons.volunteer_activism, size: 30, color: colorScheme.onPrimaryContainer),
              label: Text(
                'Report Found Item',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}