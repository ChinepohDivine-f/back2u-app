// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:math' as math; // Keep for math functions
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image/image.dart' as img; // Alias to avoid conflicts
// import 'package:path_provider/path_provider.dart';

// // Placeholder for OCR_Parser and ImageProcessingService (now DocumentVerificationService)
// // These would be your existing files or placeholders from previous discussions.
// // import 'package:back2u_scan_secure/utils/ocr_parser.dart'; // Ensure this file exists and is correct

// /// Custom exception for image processing errors
// class ImageProcessingException implements Exception {
//   final String message;
//   ImageProcessingException(this.message);
//   @override
//   String toString() => 'ImageProcessingException: $message';
// }

// /// Helper class for image processing operations using 'package:image'
// class ImageProcessor {
//   /// Load image from file path
//   static Future<img.Image?> loadImage(String imagePath) async {
//     try {
//       final bytes = await File(imagePath).readAsBytes();
//       return img.decodeImage(bytes);
//     } catch (e) {
//       debugPrint('Error loading image: $e');
//       throw ImageProcessingException('Failed to load image: $e');
//     }
//   }

//   /// Save image to temporary file
//   static Future<String> saveTempImage(img.Image image) async {
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final tempPath = '${tempDir.path}/temp_processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final bytes = img.encodeJpg(image, quality: 90); // Adjusted quality for better file size/speed
//       await File(tempPath).writeAsBytes(bytes);
//       return tempPath;
//     } catch (e) {
//       debugPrint('Error saving temporary image: $e');
//       throw ImageProcessingException('Failed to save temporary image: $e');
//     }
//   }

//   /// Convert image to grayscale
//   static img.Image toGrayscale(img.Image image) {
//     // The img.grayscale function returns a new image
//     return img.grayscale(image);
//   }

//   /// Apply contrast enhancement
//   static img.Image enhanceContrast(img.Image image, {double contrast = 1.3}) {
//     // img.adjustColor is used for contrast, brightness, saturation, etc.
//     // Contrast is a double, 1.0 is no change, <1.0 less contrast, >1.0 more contrast
//     return img.adjustColor(image, contrast: contrast);
//   }

//   /// Apply brightness adjustment
//   static img.Image adjustBrightness(img.Image image, {double brightness = 1.0}) {
//     // Brightness is a double, 1.0 is no change, <1.0 darker, >1.0 brighter
//     return img.adjustColor(image, brightness: brightness);
//   }

//   /// Apply sharpening filter
//   static img.Image sharpenImage(img.Image image) {
//     // Sharpening is typically a convolution.
//     // The 'image' package's convolution function expects a flattened 1D list.
//     // A common sharpening kernel:
//     final List<num> sharpenKernel = [
//       0, -1, 0,
//       -1, 5, -1,
//       0, -1, 0,
//     ];
//     // div is often 1.0 for sharpening kernels.
//     return img.convolution(image, filter: sharpenKernel, div: 1.0);
//   }

//   /// Apply noise reduction using Gaussian blur
//   static img.Image reduceNoise(img.Image image, {int radius = 1}) {
//     // img.gaussianBlur function is appropriate for noise reduction
//     return img.gaussianBlur(image, radius: radius);
//   }

//   /// Normalize image (improve overall quality by stretching histogram)
//   static img.Image normalizeImage(img.Image image) {
//     // img.normalize stretches the luminance range to min/max
//     return img.normalize(image, min: 0, max: 255);
//   }

//   /// Apply automatic color correction (simple auto-leveling by normalizing)
//   static img.Image autoLevel(img.Image image) {
//     // Normalizing luminance effectively acts as a simple auto-level
//     return img.normalize(image, min: 0, max: 255);
//   }

//   /// Resize image while maintaining aspect ratio
//   static img.Image resizeForOCR(img.Image image, {int maxWidth = 1500, int maxHeight = 1500}) {
//     // Use smaller max dimensions for faster processing,
//     // ML Kit performs well with reasonable resolutions.
//     if (image.width <= maxWidth && image.height <= maxHeight) {
//       return image;
//     }

//     // Ensure resizing maintains aspect ratio
//     return img.copyResize(
//       image,
//       width: (image.width > image.height) ? maxWidth : null, // Set width for landscape, null for portrait to auto-calculate height
//       height: (image.height > image.width) ? maxHeight : null, // Set height for portrait, null for landscape
//       interpolation: img.Interpolation.average, // Good balance of quality and speed
//     );
//   }

//   /// Apply simple threshold to create binary image
//   static img.Image threshold(img.Image image, {int threshold = 128}) {
//     // This requires the image to be grayscale first for meaningful thresholding
//     final grayscaleImage = img.grayscale(image);
//     // img.thresholdBinary takes a grayscale image and a threshold value
//     return img.thresholdBinary(grayscaleImage, threshold: threshold);
//   }

//   /// Apply adaptive threshold (simple local mean version)
//   /// Note: The 'image' package does not have a built-in adaptive threshold.
//   /// This is a simplified manual implementation and may not be as robust as
//   /// dedicated computer vision libraries.
//   static img.Image adaptiveThreshold(img.Image image, {int blockSize = 15, double c = 8.0}) {
//     // Ensure image is grayscale for adaptive thresholding
//     final grayscaleImage = img.grayscale(image);
//     final result = img.Image(width: grayscaleImage.width, height: grayscaleImage.height);

//     final halfBlock = blockSize ~/ 2;

//     for (int y = 0; y < grayscaleImage.height; y++) {
//       for (int x = 0; x < grayscaleImage.width; x++) {
//         double sum = 0;
//         int count = 0;

//         // Calculate local mean
//         for (int dy = -halfBlock; dy <= halfBlock; dy++) {
//           for (int dx = -halfBlock; dx <= halfBlock; dx++) {
//             final ny = (y + dy).clamp(0, grayscaleImage.height - 1);
//             final nx = (x + dx).clamp(0, grayscaleImage.width - 1);

//             final pixel = grayscaleImage.getPixel(nx, ny);
//             sum += img.getLuminance(pixel); // Luminance of a grayscale pixel is its single channel value
//             count++;
//           }
//         }

//         final localMean = sum / count;
//         final currentPixel = grayscaleImage.getPixel(x, y);
//         final currentGray = img.getLuminance(currentPixel);

//         final value = currentGray > (localMean - c) ? 255 : 0;
//         img.setPixel(result, x, y, img.ColorRgb8(value, value, value)); // Set as grayscale
//       }
//     }
//     return result;
//   }

//   // Edge detection is more complex and typically not needed for direct OCR if other
//   // preprocessing steps (contrast, binarization) are done well.
//   // The 'image' package doesn't have a direct 'detectEdges' function that works
//   // with a custom kernel list of lists as you initially wrote.
//   // Implementing Sobel/Canny from scratch is out of scope for a direct 'img' function replacement.
//   // If edge detection is crucial, consider a different package or a highly optimized custom solution.
//   // Removed `detectEdges` for now to simplify and focus on core OCR preprocessing.
// }

// // Ensure DocumentVerificationService uses the corrected ImageProcessor
// class DocumentVerificationService {
//   final TextRecognizer _textRecognizer = TextRecognizer(
//     script: TextRecognitionScript.latin,
//   );

//   /// Preprocess image for better OCR results
//   Future<String> _preprocessImage(String imagePath) async {
//     try {
//       // 1. Load the original image
//       final originalImage = await ImageProcessor.loadImage(imagePath);
//       if (originalImage == null) {
//         throw ImageProcessingException('Failed to load image');
//       }

//       debugPrint('📸 Original image: ${originalImage.width}x${originalImage.height}');

//       // 2. Resize image if too large (improves processing speed and OCR accuracy)
//       var processedImage = ImageProcessor.resizeForOCR(originalImage, maxWidth: 1500, maxHeight: 1500);
//       debugPrint('📏 Resized to: ${processedImage.width}x${processedImage.height}');

//       // 3. Convert to grayscale
//       processedImage = ImageProcessor.toGrayscale(processedImage);
//       debugPrint('🔘 Converted to grayscale');

//       // 4. Apply noise reduction (Gaussian Blur)
//       processedImage = ImageProcessor.reduceNoise(processedImage, radius: 1); // Small radius for light smoothing
//       debugPrint('🧹 Applied noise reduction');

//       // 5. Enhance contrast (adjusting brightness can also help)
//       processedImage = ImageProcessor.enhanceContrast(processedImage, contrast: 1.5); // Increase contrast slightly
//       debugPrint('🔆 Enhanced contrast');

//       // 6. Apply sharpening (use cautiously, can amplify noise)
//       processedImage = ImageProcessor.sharpenImage(processedImage);
//       debugPrint('🔪 Applied sharpening');

//       // 7. Apply adaptive thresholding for binarization
//       // This is often the most critical step for making text very clear for OCR
//       // Adjust blockSize and c based on testing with your typical documents.
//       // Larger blockSize for smoother gradients, smaller 'c' for more aggressive thresholding.
//       processedImage = ImageProcessor.adaptiveThreshold(processedImage, blockSize: 21, c: 10.0);
//       debugPrint('🎯 Applied adaptive threshold (binarization)');


//       // Save processed image to temporary file
//       final tempPath = await ImageProcessor.saveTempImage(processedImage);
//       debugPrint('💾 Saved processed image to: $tempPath');

//       return tempPath;

//     } catch (e) {
//       debugPrint('❌ Error in image preprocessing: $e');
//       // Re-throw the exception to be handled by the caller (e.g., in _runOcrAndParse)
//       rethrow;
//     }
//   }

//   /// Extract text from an image with enhanced preprocessing
//   Future<String> extractTextFromImage(String imagePath) async {
//     String? tempPath;

//     try {
//       debugPrint('🚀 Starting text extraction for: $imagePath');

//       // 1. Preprocess the image
//       tempPath = await _preprocessImage(imagePath); // This might return the original path if preprocessing fails

//       // 2. Create InputImage from processed file
//       // Ensure InputImage is created from the potentially new tempPath
//       final inputImage = InputImage.fromFilePath(tempPath);

//       // 3. Process the image and extract text
//       debugPrint('🔍 Running OCR...');
//       final recognizedText = await _textRecognizer.processImage(inputImage);

//       // 4. Log the extracted text
//       debugPrint('✅ OCR completed successfully');
//       debugPrint('📝 Extracted ${recognizedText.text.length} characters');
//       debugPrint('--- EXTRACTED TEXT ---\n${recognizedText.text}\n--- END OF TEXT ---');

//       return recognizedText.text;

//     } catch (e) {
//       debugPrint('❌ Error extracting text from image: $e');
//       rethrow;
//     } finally {
//       // Clean up temporary file if it was created and is different from the original
//       if (tempPath != null && tempPath != imagePath) {
//         try {
//           final file = File(tempPath);
//           if (await file.exists()) {
//             await file.delete();
//             debugPrint('🗑️ Cleaned up temporary file');
//           }
//         } catch (e) {
//           debugPrint('⚠️ Failed to delete temporary file: $e');
//         }
//       }
//     }
//   }

//   /// Extract structured text with positions
//   Future<Map<String, dynamic>> extractTextWithPositions(String imagePath) async {
//     // This method will use the default ML Kit processing without custom preprocessing
//     // if you want preprocessing here, call _preprocessImage first
//     try {
//       final inputImage = InputImage.fromFilePath(imagePath);
//       final recognizedText = await _textRecognizer.processImage(inputImage);

//       final result = <String, dynamic>{
//         'fullText': recognizedText.text,
//         'blocks': <Map<String, dynamic>>[],
//         'confidence': _calculateAverageConfidence(recognizedText.blocks),
//         'blockCount': recognizedText.blocks.length,
//       };

//       // Extract text blocks with their positions
//       for (final block in recognizedText.blocks) {
//         final blockData = <String, dynamic>{
//           'text': block.text,
//           'confidence': block.confidence,
//           'boundingBox': {
//             'left': block.boundingBox.left,
//             'top': block.boundingBox.top,
//             'right': block.boundingBox.right,
//             'bottom': block.boundingBox.bottom,
//           },
//           'lines': <Map<String, dynamic>>[],
//         };

//         for (final line in block.lines) {
//           final lineData = <String, dynamic>{
//             'text': line.text,
//             'confidence': line.confidence,
//             'boundingBox': {
//               'left': line.boundingBox.left,
//               'top': line.boundingBox.top,
//               'right': line.boundingBox.right,
//               'bottom': line.boundingBox.bottom,
//             },
//             'elements': <Map<String, dynamic>>[],
//           };

//           for (final element in line.elements) {
//             lineData['elements'].add(<String, dynamic>{
//               'text': element.text,
//               'confidence': element.confidence,
//               'boundingBox': {
//                 'left': element.boundingBox.left,
//                 'top': element.boundingBox.top,
//                 'right': element.boundingBox.right,
//                 'bottom': element.boundingBox.bottom,
//               },
//             });
//           }

//           blockData['lines'].add(lineData);
//         }

//         result['blocks'].add(blockData);
//       }

//       return result;
//     } catch (e) {
//       debugPrint('Error extracting text with positions: $e');
//       throw Exception('Failed to extract text with positions: $e');
//     }
//   }

//   /// Calculate average confidence of text blocks
//   double _calculateAverageConfidence(List<TextBlock> blocks) {
//     if (blocks.isEmpty) return 0.0;

//     double totalConfidence = 0;
//     int count = 0;

//     for (final block in blocks) {
//       // block.confidence can be null, handle it
//       if (block.confidence != null) {
//         totalConfidence += block.confidence! * 100; // Assuming confidence is 0-1, convert to 0-100
//         count++;
//       }
//     }

//     return count > 0 ? totalConfidence / count : 0.0;
//   }

//   /// Simple text extraction without preprocessing (fallback method)
//   Future<String> extractTextSimple(String imagePath) async {
//     try {
//       final inputImage = InputImage.fromFilePath(imagePath);
//       final recognizedText = await _textRecognizer.processImage(inputImage);
//       return recognizedText.text;
//     } catch (e) {
//       debugPrint('Error in simple text extraction: $e');
//       rethrow;
//     }
//   }

//   /// Validate if the service is properly initialized
//   bool isServiceReady() {
//     return true; // As TextRecognizer is initialized in constructor
//   }

//   /// Clean up resources
//   void dispose() {
//     try {
//       _textRecognizer.close();
//       debugPrint('TextRecognizer disposed.');
//     } catch (e) {
//       debugPrint('Error disposing DocumentVerificationService: $e');
//     }
//   }

//   /// Get text extraction statistics
//   Map<String, dynamic> getExtractionStats(String text) {
//     final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
//     final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
//     final characters = text.replaceAll(RegExp(r'\s'), '');

//     return {
//       'totalCharacters': text.length,
//       'charactersNoSpaces': characters.length,
//       'wordCount': words.length,
//       'lineCount': lines.length,
//       'averageWordsPerLine': lines.isNotEmpty ? (words.length / lines.length).toStringAsFixed(1) : '0.0',
//       'averageCharsPerWord': words.isNotEmpty ? (characters.length / words.length).toStringAsFixed(1) : '0.0',
//     };
//   }
// }