// lib/views/reports/edit_report_page.dart
import 'package:flutter/material.dart';
import 'package:back2u/models/report_model.dart'; // Ensure Report model is imported
import 'package:back2u/views/report/report_form.dart'; // Import the ReportForm

class EditReportPage extends StatelessWidget {
  final Report report;

  const EditReportPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    // The ReportForm is now repurposed to handle both creation and editing.
    // By passing an existing report, it will pre-fill its fields.
    // The 'type' property of the report (e.g., 'Lost' or 'Found') will be used
    // internally by ReportForm to adjust its UI (e.g., image requirements, reward option).
    return ReportForm(report: report, isEditing: true,);
  }
}
