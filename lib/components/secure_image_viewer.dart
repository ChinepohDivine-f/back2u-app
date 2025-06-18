import 'package:flutter/material.dart';
import 'package:back2u/models/report_model.dart';

class SecureImageViewer extends StatelessWidget {
  final Report report;
  
  const SecureImageViewer({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Secure Document Viewer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Images are watermarked and cannot be downloaded', 
          style: Theme.of(context).textTheme.bodySmall),
        // Implement actual secure image viewing here
      ],
    );
  }
}
