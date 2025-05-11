import 'dart:io'; // For File
import 'package:path_provider/path_provider.dart'; // For getTemporaryDirectory and getApplicationDocumentsDirectory
import 'package:shared_preferences/shared_preferences.dart';

class AnimationCacheManager {
  // Returns the path to the temporary directory.
  static Future<String> getTempDirPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  // Checks if an animation with the given name exists in the temporary cache.
  // Returns the file path if it exists, otherwise returns null.
  static Future<String?> checkIfCached(String animationName) async {
    final path = await getTempDirPath();
    final file = File('$path/$animationName.gif');
    return file.existsSync() ? file.path : null;
  }

  // Saves the provided byte data as a GIF animation in the temporary directory.
  // Returns the path to the saved file.
  static Future<String> saveTempAnimation(String animationName, List<int> bytes) async {
    final path = await getTempDirPath();
    final file = File('$path/$animationName.gif');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // Copies an animation from the temporary directory to permanent application storage.
  // It also saves the path of the saved animation in SharedPreferences.
  static Future<void> saveToPermanentStorage(String animationName) async {
    final tempPath = await getTempDirPath();
    final file = File('$tempPath/$animationName.gif');

    if (await file.exists()) {
      final dir = await getApplicationDocumentsDirectory();
      final savedPath = '${dir.path}/$animationName.gif';
      await file.copy(savedPath);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('saved_animations') ?? [];
      saved.add(savedPath);
      await prefs.setStringList('saved_animations', saved);
    }
  }

  // Retrieves a list of paths to animations that have been saved to permanent storage.
  static Future<List<String>> getSavedAnimations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_animations') ?? [];
  }

  static Future<void> clearTemporaryCache() async {
    final tempPath = await getTempDirPath();
    final directory = Directory(tempPath);
    try {
      final files = await directory.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.gif')) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error clearing temporary cache: $e');
    }
  }
}