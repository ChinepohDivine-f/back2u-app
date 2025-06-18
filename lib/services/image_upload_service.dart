import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUploadService {
  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  ImageUploadService() {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      // ignore: avoid_print
      print('⚠️ Cloudinary environment variables are missing.');
    }
  }

  Future<List<String>> uploadImagesToCloudinary({
    required List<XFile> imageFiles,
    required String userId,
  }) async {
    List<String> uploadedUrls = [];

    for (XFile file in imageFiles) {
      File imageFile = File(file.path);

      final uploadUrl = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest("POST", uploadUrl);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = "back2u/$userId";
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final json = jsonDecode(resStr);
        uploadedUrls.add(json['secure_url']);
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    }

    return uploadedUrls;
  }
}
