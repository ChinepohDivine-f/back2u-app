// // Import ML Kit and other services
// import 'dart:io';
// import 'package:back2u/models/report_model.dart';
// import 'package:back2u/views/report/contact.dart';
// import 'package:flutter/material.dart';
// // import 'package:back2u/services/image_processing_service.dart';
// import 'package:back2u/services/document_verification_service.dart';
// import 'package:back2u/utils/document_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:share_plus/share_plus.dart';

// class DocumentVerificationPage extends StatefulWidget {
//   final Report report;
//   final bool isEditing;
//   const DocumentVerificationPage({
//     super.key, 
//     required this.report, 
//     required this.isEditing
//   });

//   @override
//   State<DocumentVerificationPage> createState() => _DocumentVerificationPageState();
// }

// class _DocumentVerificationPageState extends State<DocumentVerificationPage> {
//   final List<XFile> _localImageFiles = [];
//   bool _isProcessing = false;
//   String? _ocrSummary;
//   Map<String, String> _extractedFields = {};
//   bool _fieldsMatch = false;

//   // final ImageProcessingService _imageProcessingService = ImageProcessingService();
//   // final DocumentVerificationService _verificationService = DocumentVerificationService();
//   Map<String, dynamic> _extractedData = {};
//   bool _isVerifying = false;
//   String _verificationResult = '';

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with any existing images if in edit mode
//     if (widget.report.images != null && widget.report.images!.isNotEmpty) {
//       // Note: In production, you'd want to download network images first
//       for (final imageUrl in widget.report.images!) {
//         _localImageFiles.add(XFile(imageUrl));
//       }
//     }
//   }

//   @override
//   void dispose() {
//     // _imageProcessingService.dispose();
//     _verificationService.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImages() async {
//     try {
//       final picker = ImagePicker();
//       final images = await picker.pickMultiImage();
//       if (images.isNotEmpty) {
//         setState(() {
//           _localImageFiles.addAll(images);
//           _isProcessing = true;
//         });
        
//         // Process the first image for OCR
//         await _processImageForOCR(_localImageFiles.last);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//           _verificationResult = 'Error picking images: $e';
//         });
//       }
//     }
//   }

//   Future<void> _processImageForOCR(XFile imageFile) async {
//     if (!mounted) return;
    
//     setState(() {
//       _isProcessing = true;
//       _extractedData = {};
//       _extractedFields = {};
//       _verificationResult = '';
//     });
    
//     try {
//       // Use the enhanced text extraction with detailed results
//       // final result = await _verificationService.extractTextWithDetails(imageFile.path);
//       final result = {'text': 'hello world'};
      
//       // Parse the extracted text
//       _extractedData = DocumentParser.parseDocumentText(result['text']!);
      
//       // Update UI with results
//       if (mounted) {
//         setState(() {
//           // Show first 200 characters as preview
//           _ocrSummary = result['text']!.length > 200 
//               ? '${result['text']!.substring(0, 200)}...' 
//               : result['text'];
              
//           // Convert extracted data to fields for display
//           _extractedFields = _extractedData.map((key, value) => 
//             MapEntry(key, value?.toString() ?? '')
//           );
          
//           // Compare with report data
//           _compareWithReportData();
          
//           // Log detailed extraction results
//           debugPrint('✅ Extracted ${_extractedData.length} fields');
//           _extractedData.forEach((key, value) {
//             debugPrint('   • $key: $value');
//           });
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _verificationResult = '❌ Error processing image: ${e.toString().split('.').first}';
//         });
//       }
//       rethrow;
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   void _compareWithReportData() {
//     // Simple comparison - check if owner name matches
//     final extractedOwnerName = _extractedData['ownerName']?.toString()?.toLowerCase() ?? '';
//     final reportOwnerName = widget.report.ownerName?.toLowerCase() ?? '';
    
//     _fieldsMatch = extractedOwnerName.isNotEmpty && 
//                    reportOwnerName.isNotEmpty &&
//                    extractedOwnerName.contains(reportOwnerName) ||
//                    reportOwnerName.contains(extractedOwnerName);
//   }

//   Future<void> _verifyDocument() async {
//     if (_localImageFiles.isEmpty) {
//       setState(() {
//         _verificationResult = 'Please select a document image first';
//       });
//       return;
//     }
    
//     setState(() {
//       _isVerifying = true;
//       _verificationResult = '';
//     });
  
//     try {
//       // Extract text from image
//       final extractedText = await _verificationService.extractTextFromImage(
//         _localImageFiles.first.path,
//       );
      
//       // Parse document text
//       _extractedData = DocumentParser.parseDocumentText(extractedText);
      
//       // Compare with expected data from the report
//       final expectedData = {
//         'ownerName': widget.report.ownerName ?? '',
//         'location': widget.report.locationLost ?? '',
//         'sublocation': widget.report.subLocationLost ?? '',
//         'dateIssued': widget.report.reportedDate?.toString() ?? '',
//         'category': widget.report.category ?? '',
//         'subcategory': widget.report.subcategory ?? '',
//       };
      
//       final isValid = DocumentParser.compareDocumentData(_extractedData, expectedData);
      
//       // Update fields match status
//       _compareWithReportData();
      
//       // Set verification result
//       if (mounted) {
//         setState(() {
//           _verificationResult = isValid 
//               ? '✅ Document Verified Successfully!' 
//               : '❌ Document Verification Failed. Some fields do not match.';
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _verificationResult = 'Error during verification: ${e.toString()}';
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isVerifying = false);
//       }
//     }
//   }

//   bool get _canProceed {
//     if (widget.report.type == 'found') {
//       return _localImageFiles.isNotEmpty && _fieldsMatch;
//     } else {
//       // For lost documents, verification is optional
//       return true;
//     }
//   }

//   Widget _buildImageGrid() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Selected Images:',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 120,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _localImageFiles.length,
//             itemBuilder: (context, index) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: Stack(
//                   children: [
//                     Container(
//                       width: 100,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           File(_localImageFiles[index].path),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 4,
//                       top: 4,
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _localImageFiles.removeAt(index);
//                           });
//                         },
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Document Verification'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Instructions
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Document Verification',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       widget.report.type == 'found' 
//                           ? 'Please upload clear photos of the document to verify ownership.'
//                           : 'Upload document photos for verification (optional for lost items).',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 20),
            
//             // Image picker button
//             ElevatedButton.icon(
//               onPressed: _isProcessing || _isVerifying ? null : _pickImages,
//               icon: const Icon(Icons.add_photo_alternate),
//               label: const Text('Add Document Photos'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
            
//             const SizedBox(height: 20),
            
//             // Processing indicator
//             if (_isProcessing)
//               const Center(
//                 child: Column(
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 8),
//                     Text('Processing image...'),
//                   ],
//                 ),
//               ),
              
//             // Display selected images
//             if (_localImageFiles.isNotEmpty) _buildImageGrid(),
            
//             // Verification button
//             if (_localImageFiles.isNotEmpty && !_isProcessing)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: ElevatedButton(
//                   onPressed: _isVerifying ? null : _verifyDocument,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Theme.of(context).primaryColor,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: _isVerifying
//                       ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text(
//                           'Verify Document', 
//                           style: TextStyle(fontSize: 16)
//                         ),
//                 ),
//               ),
            
//             // Verification result with improved UI
//             if (_verificationResult.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: _verificationResult.startsWith('✅')
//                         ? Colors.green.shade50
//                         : _verificationResult.startsWith('❌')
//                             ? Colors.red.shade50
//                             : Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: _verificationResult.startsWith('✅')
//                           ? Colors.green.shade100
//                           : _verificationResult.startsWith('❌')
//                               ? Colors.red.shade100
//                               : Colors.orange.shade100,
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         _verificationResult.startsWith('✅')
//                             ? Icons.check_circle
//                             : _verificationResult.startsWith('❌')
//                                 ? Icons.error
//                                 : Icons.warning_amber,
//                         color: _verificationResult.startsWith('✅')
//                             ? Colors.green.shade700
//                             : _verificationResult.startsWith('❌')
//                                 ? Colors.red.shade700
//                                 : Colors.orange.shade700,
//                         size: 24,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           _verificationResult.replaceAll(RegExp(r'^[✅❌]\s*'), ''),
//                           style: TextStyle(
//                             color: _verificationResult.startsWith('✅')
//                                 ? Colors.green.shade800
//                                 : _verificationResult.startsWith('❌')
//                                     ? Colors.red.shade800
//                                     : Colors.orange.shade800,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
            
//             // Extracted text preview with better formatting
//             if (_ocrSummary != null) ...[
//               const SizedBox(height: 24),
//               Text(
//                 'Extracted Information',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Card(
//                 elevation: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Extracted Fields
//                       if (_extractedFields.isNotEmpty) ...[
//                         Text(
//                           'Document Fields:',
//                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         ..._extractedFields.entries.map((entry) => Padding(
//                           padding: const EdgeInsets.only(bottom: 8.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(
//                                 width: 120,
//                                 child: Text(
//                                   '${entry.key}:',
//                                   style: const TextStyle(fontWeight: FontWeight.w500),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   entry.value.isNotEmpty ? entry.value : 'Not detected',
//                                   style: TextStyle(
//                                     color: entry.value.isNotEmpty 
//                                         ? Colors.black87 
//                                         : Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )).toList(),
//                         const Divider(height: 32),
//                       ],
                      
//                       // Raw Text Preview
//                       Text(
//                         'Raw Text Preview:',
//                         style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: SingleChildScrollView(
//                           child: SelectableText(
//                             _ocrSummary!,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               height: 1.4,
//                               fontFamily: 'monospace',
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '${_ocrSummary!.length > 200 ? 'First 200' : 'All'} characters shown',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Colors.grey,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
            
//             const SizedBox(height: 32),
            
//             // Proceed button
//             Column(
//               children: [
//                 if (!_canProceed && _localImageFiles.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: Text(
//                       'Please verify the document before proceeding',
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.error,
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 SizedBox(
//                   width: double.infinity,
//                   child: FilledButton.icon(
//                     onPressed: _canProceed && !_isProcessing && !_isVerifying
//                         ? () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ContactPage(
//                                   report: widget.report.copyWith(
//                                     ownerName: _extractedData['ownerName']?.toString() ?? 
//                                                widget.report.ownerName,
//                                   ),
//                                   localImageFiles: _localImageFiles,
//                                   existingImageUrls: widget.report.images?.toList() ?? const [],
//                                   imagesToDelete: const {},
//                                   isEditing: widget.isEditing,
//                                 ),
//                               ),
//                             );
//                           }
//                         : null,
//                     style: FilledButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       textStyle: const TextStyle(fontSize: 16),
//                     ),
//                     icon: const Icon(Icons.arrow_forward),
//                     label: const Text('NEXT: Contact Information'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }