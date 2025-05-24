import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/core/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../screens/animation/mask_confirmation_screen.dart';
import '../../../core/state/processed_image.dart';
import 'draw_screen.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      print('Selected image path: ${_image!.path}');
      _uploadImage(context, prefix: 'picked');
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.camera);
    if (xfile != null) {
      final String dir = (await getTemporaryDirectory()).path;
      final String targetPath = '$dir/temp_fixed.jpg';
      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        xfile.path,
        targetPath,
        quality: 100,
        rotate: 0,
      );
      if (compressedFile != null) {
        setState(() {
          _image = compressedFile;
        });
        print('Fixed and saved image path: ${_image!.path}');
        _uploadImage(context, prefix: 'pictaken_');
      } else {
        print('Failed to fix orientation');
        _showErrorDialog(context);
      }
    }
  }

  Future<void> _uploadImage(BuildContext context, {String prefix = 'image_'}) async {
    if (_image != null) {
      setState(() {
        _isLoading = true;
      });
      print('Uploading image...');
      try {
        File? fileToSend;
        if (_image is XFile) {
          fileToSend = File((_image as XFile).path);
        } else if (_image is File) {
          fileToSend = _image as File;
        }

        if (fileToSend != null) {
          final File timestampedImage = await _createTimestampedImageCopy(fileToSend, prefix: prefix);
          String? resultUrl = await _apiService.uploadImage(timestampedImage);

          if (resultUrl != null) {
            print('API Response: $resultUrl');
            try {
              var decoded;
              if (resultUrl.contains('{')) {
                decoded = json.decode(resultUrl);
                print('Decoded API Response: $decoded');
              } else {
                print('ResultUrl is not JSON, treating as direct URL.');
                _handleFallbackResponse(resultUrl, context);
                return;
              }

              if (decoded is Map<String, dynamic>) {
                final imageName = decoded['image_name'];
                if (imageName != null) {
                  Provider.of<ProcessedImageProvider>(context, listen: false)
                      .setProcessedImageUrls(
                    maskUrl: decoded['mask_url'] ?? '',
                    textureUrl: decoded['texture_url'] ?? '',
                    originalUrl: decoded['orig_image_url'] ?? '',
                  );
                  print('Image uploaded successfully. Image Name: $imageName, URLs: ${decoded['mask_url']}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaskConfirmationScreen(imageName: imageName),
                    ),
                  );
                } else {
                  print('Error: "image_name" key not found in JSON response.');
                  _showErrorDialog(context);
                }
              } else {
                print('Error: Unexpected API response format. Expected a JSON object.');
                _showErrorDialog(context);
              }
            } on FormatException catch (e) {
              print('FormatException in _uploadImage: $e');
              _handleFallbackResponse(resultUrl, context);
            } catch (e) {
              print('Unexpected error decoding response: $e');
              _showErrorDialog(context);
            }
          } else {
            print('Image upload failed: Response is null.');
            _showErrorDialog(context);
          }
        } else {
          print('Error: Could not convert _image to File for upload.');
          _showErrorDialog(context);
        }
      } catch (e) {
        print('Exception occurred during image upload: $e');
        _showErrorDialog(context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No image selected for upload.');
      _showErrorDialog(context);
    }
  }

  // Updated to accept a prefix
  Future<File> _createTimestampedImageCopy(File originalImage, {String prefix = 'image_'}) async {
    final directory = await getTemporaryDirectory();
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String newPath = '${directory.path}/$prefix$timestamp${_getFileExtension(originalImage.path)}';
    return await originalImage.copy(newPath);
  }

  String _getFileExtension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  void _handleFallbackResponse(String resultUrl, BuildContext context) {
    Provider.of<ProcessedImageProvider>(context, listen: false).setProcessedImageUrls(
      maskUrl: resultUrl,
      textureUrl: resultUrl,
      originalUrl: resultUrl,
    );
    print('Image uploaded successfully (direct URL - no image name). URL: $resultUrl');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MaskConfirmationScreen(imageName: ''),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error ❌'),
        content: const Text('Failed to process the image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrawScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      '🎨 Draw',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _pickFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text(
                      '🖼️ Pick from photos',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _takePicture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      '📷 Take a picture',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
