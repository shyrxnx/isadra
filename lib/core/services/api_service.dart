import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';  // Import dotenv

class ApiService {
  // Load the .env variables
  static String get imageProcessingBaseUrl {
    print('IMAGE_API_URL: ${dotenv.env['IMAGE_API_URL']}');  // Check the value
    return dotenv.env['IMAGE_API_URL'] ?? 'http://192.168.101.74:5000';
  }

  static String get animationApiBaseUrl {
    print('ANIMATION_API_URL: ${dotenv.env['ANIMATION_API_URL']}');  // Check the value
    return dotenv.env['ANIMATION_API_URL'] ?? 'http://192.168.101.74:5001';
  }

  // Upload image method
  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$imageProcessingBaseUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');
        return response.body;
      } else {
        print('Error: Response status ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred during image upload: $e');
      return null;
    }
  }

  // Generate GIF method
  Future<String?> generateGif(String imageName, String motionName) async {
    try {
      // Construct the request payload
      final url = Uri.parse('$animationApiBaseUrl/generate_gif');
      final headers = {'Content-Type': 'application/json'};
      final body = {
        'image_name': imageName,
        'motion_name': motionName,
      };

      // Send the POST request
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final gifBase64 = jsonResponse['gif_base64'];

        // Decode the Base64 GIF if needed (e.g., to save locally)
        // Or return the Base64 string
        return gifBase64;
      } else {
        print('Error: Response status ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred during GIF generation: $e');
      return null;
    }
  }
}
