import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:speak_dine/config/api_keys.dart';

class ImageUploadService {
  static final _picker = ImagePicker();

  static Future<XFile?> pickImage() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
  }

  static Future<String?> uploadMenuImage({
    required String restaurantId,
    required XFile imageFile,
  }) {
    return _uploadToImgbb(
      imageFile: imageFile,
      imageName: 'menu_${restaurantId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static Future<String?> uploadProfileImage({
    required String userId,
    required XFile imageFile,
  }) {
    return _uploadToImgbb(
      imageFile: imageFile,
      imageName: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static Future<String?> _uploadToImgbb({
    required XFile imageFile,
    required String imageName,
  }) async {
    if (imgbbApiKey.isEmpty) {
      debugPrint('[ImageUpload] IMGBB_API_KEY not set. '
          'Run with --dart-define=IMGBB_API_KEY=your_key');
      return null;
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {
          'key': imgbbApiKey,
          'image': base64Image,
          'name': imageName,
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[ImageUpload] ImgBB returned status ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;

      if (!success) {
        debugPrint('[ImageUpload] ImgBB upload failed: ${response.body}');
        return null;
      }

      final imageData = json['data'] as Map<String, dynamic>;
      return imageData['url'] as String?;
    } catch (e) {
      debugPrint('[ImageUpload] Upload failed: $e');
      return null;
    }
  }
}
