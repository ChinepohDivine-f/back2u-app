// // lib/views/report/saved_reports_page.dart
// import 'package:back2u/components/SimpleCard.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:back2u/services/get_reports_service.dart';
// import 'package:back2u/models/report_model.dart';
// import 'package:back2u/views/report/report_detail_page.dart';
// import 'package:back2u/services/user_profile_service.dart'; // NEW: Your user profile service

// class SavedReportsPage extends StatefulWidget {
//   const SavedReportsPage({super.key});

//   @override
//   State<SavedReportsPage> createState() => _SavedReportsPageState();
// }

// class _SavedReportsPageState extends State<SavedReportsPage> {
//   final ReportService _reportService = ReportService();
//   final UserProfileService _userProfileService = UserProfileService(); // NEW: Instance of your service
//   User? _currentUser;
//   List<String> _currentSavedReportIds = []; // Local state to track saved IDs

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = FirebaseAuth.instance.currentUser;
//     if (_currentUser != null) {
//       // Start fetching saved reports
//       _reportService.fetchAndStreamSavedReports(_currentUser!.uid);

//       // Listen to changes in the user's profile to update savedReportIds
//       _userProfileService.getUserProfileStream(_currentUser!.uid).listen((appUser) {
//         if (mounted) {
//           setState(() {
//             _currentSavedReportIds = appUser.savedReports ?? [];
//           });
//         }
//       }, onError: (error) {
//         debugPrint('Error listening to user profile for saved reports: $error');
//       });
//     }
//   }

//   @override
//   void dispose() {
//     // No need to dispose _reportService here if it's managed globally,
//     // otherwise ensure it's disposed if this is the only place it's used.
//     super.dispose();
//   }

//   // Function to toggle save/unsave status
//   void _toggleSaveReport(String reportId) async {
//     if (_currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to save reports.')),
//       );
//       return;
//     }

//     // This service method will handle adding/removing the ID
//     await _userProfileService.toggleSavedReport(_currentUser!.uid, reportId);

//     // No need to manually update _currentSavedReportIds here,
//     // the stream listener for _userProfileService will handle it.

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _currentSavedReportIds.contains(reportId)
//               ? 'Report removed from saved.'
//               : 'Report added to saved.',
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Saved Reports'),
//         backgroundColor: colorScheme.primary,
//         foregroundColor: colorScheme.onPrimary,
//       ),
//       body: _currentUser == null
//           ? Center(
//               child: Text(
//                 'Please log in to view your saved reports.',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//             )
//           : StreamBuilder<List<Report>>(
//               stream: _reportService.savedReportsStream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text('Error loading saved reports: ${snapshot.error}',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.error),
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'You have no reports saved yet. Browse items and save them!',
//                       style: Theme.of(context).textTheme.titleMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }

//                 final savedReports = snapshot.data!;
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: savedReports.length,
//                   itemBuilder: (context, index) {
//                     final report = savedReports[index];
//                     final isSaved = _currentSavedReportIds.contains(report.reportId);

//                     return SimpleCard(
//                       report: report,
//                       onToggleSave: () => _toggleSaveReport(report.reportId),
//                       // Pass a custom trailing widget for save/unsave functionality
//                       // trailingWidget: IconButton(
//                       //   icon: Icon(
//                       //     isSaved ? Icons.bookmark : Icons.bookmark_border,
//                       //     color: isSaved ? colorScheme.secondary : colorScheme.onSurfaceVariant,
//                       //   ),
//                       //   onPressed: () => _toggleSaveReport(report.reportId!),
//                       //   tooltip: isSaved ? 'Unsave Report' : 'Save Report',
//                       // ),
//                     );
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }