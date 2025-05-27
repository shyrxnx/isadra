import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'supabase_client.dart';

class SupabaseStorageService {
  // Download a file from Supabase URL and return as a File
  Future<File?> downloadFileFromUrl(String url, String localPath) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      print('Error downloading file from URL: $e');
      return null;
    }
  }

  // Download file as bytes
  Future<Uint8List?> downloadFileAsBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('Error downloading file as bytes: $e');
      return null;
    }
  }

  // List all files in a character folder
  Future<List<String>> listCharacterFiles(String characterId, String fileType) async {
    try {
      final files = await SupabaseManager.client
          .storage
          .from(SupabaseManager.CHARACTERS_BUCKET)
          .list(path: '$characterId/$fileType');
      
      // Convert FileObjects to URLs
      return files.map((file) => 
        SupabaseManager.client
          .storage
          .from(SupabaseManager.CHARACTERS_BUCKET)
          .getPublicUrl('$characterId/$fileType/${file.name}')
      ).toList();
    } catch (e) {
      print('Error listing character files: $e');
      return [];
    }
  }
  
  // Get mask image URL for a character
  Future<String?> getCharacterMaskUrl(String characterId) async {
    try {
      final path = '$characterId/mask.png';
      return SupabaseManager.client
        .storage
        .from(SupabaseManager.CHARACTERS_BUCKET)
        .getPublicUrl(path);
    } catch (e) {
      print('Error getting character mask URL: $e');
      return null;
    }
  }
  
  // Get texture image URL for a character
  Future<String?> getCharacterTextureUrl(String characterId) async {
    try {
      final path = '$characterId/texture.png';
      return SupabaseManager.client
        .storage
        .from(SupabaseManager.CHARACTERS_BUCKET)
        .getPublicUrl(path);
    } catch (e) {
      print('Error getting character texture URL: $e');
      return null;
    }
  }
  
  // Get original image URL for a character
  Future<String?> getCharacterOriginalImageUrl(String characterId) async {
    try {
      final path = '$characterId/orig_image.png';
      return SupabaseManager.client
        .storage
        .from(SupabaseManager.CHARACTERS_BUCKET)
        .getPublicUrl(path);
    } catch (e) {
      print('Error getting character original image URL: $e');
      return null;
    }
  }
  
  // Get animation URLs for a character
  Future<List<String>> getCharacterAnimations(String characterId) async {
    try {
      final files = await SupabaseManager.client
          .storage
          .from(SupabaseManager.CHARACTERS_BUCKET)
          .list(path: characterId);
      
      // Filter animations (files that end with .gif)
      final animations = files.where((file) => file.name.toLowerCase().endsWith('.gif')).toList();
      
      // Convert FileObjects to URLs
      return animations.map((file) => 
        SupabaseManager.client
          .storage
          .from(SupabaseManager.CHARACTERS_BUCKET)
          .getPublicUrl('$characterId/${file.name}')
      ).toList();
    } catch (e) {
      print('Error listing character animations: $e');
      return [];
    }
  }
  
  // Download character mask and save locally
  Future<File?> downloadCharacterMask(String characterId) async {
    try {
      final maskUrl = await getCharacterMaskUrl(characterId);
      if (maskUrl == null) return null;
      
      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/${characterId}_mask.png';
      
      return await downloadFileFromUrl(maskUrl, localPath);
    } catch (e) {
      print('Error downloading character mask: $e');
      return null;
    }
  }
  
  // Download character texture and save locally
  Future<File?> downloadCharacterTexture(String characterId) async {
    try {
      final textureUrl = await getCharacterTextureUrl(characterId);
      if (textureUrl == null) return null;
      
      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/${characterId}_texture.png';
      
      return await downloadFileFromUrl(textureUrl, localPath);
    } catch (e) {
      print('Error downloading character texture: $e');
      return null;
    }
  }
  
  // Download character animation and save locally
  Future<File?> downloadCharacterAnimation(String animationUrl, String characterId, String animationName) async {
    try {      
      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/${characterId}_${animationName}.gif';
      
      return await downloadFileFromUrl(animationUrl, localPath);
    } catch (e) {
      print('Error downloading character animation: $e');
      return null;
    }
  }
  
  // Get character config (YAML) URL
  Future<String?> getCharacterConfigUrl(String characterId) async {
    try {
      final path = '$characterId/char_cfg.yaml';
      return SupabaseManager.client
        .storage
        .from(SupabaseManager.CHARACTERS_BUCKET)
        .getPublicUrl(path);
    } catch (e) {
      print('Error getting character config URL: $e');
      return null;
    }
  }
}