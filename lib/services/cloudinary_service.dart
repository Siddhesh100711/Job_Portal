import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'dqlyuowvx';
  final String uploadPreset = 'jop-portal';

  /// Uploads a file to Cloudinary and returns the secure URL.
  Future<String?> uploadFile(File file) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      return json['secure_url'] as String?;
    } else {
      final errorData = await response.stream.bytesToString();
      throw Exception(
        'Cloudinary upload failed: ${response.statusCode} - $errorData',
      );
    }
  }
}
