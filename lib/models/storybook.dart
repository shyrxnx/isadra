import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../views/screens/storybook/create_storybook/functionality/slide_manager.dart';

class Storybook {
  String id;
  String title;
  DateTime createdAt;
  List<StorySlide> slides;

  Storybook({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.slides,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'slides': slides.map((slide) => slide.toJson()).toList(),
    };
  }

  factory Storybook.fromJson(Map<String, dynamic> json) {
    return Storybook(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      slides: (json['slides'] as List).map((slideJson) => StorySlide.fromJson(slideJson)).toList(),
    );
  }

  static Future<void> saveStorybook(Storybook storybook) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/storybooks/${storybook.id}.json');
    
    // Create directory if it doesn't exist
    await file.parent.create(recursive: true);
    
    // Save the storybook
    await file.writeAsString(jsonEncode(storybook.toJson()));
  }

  static Future<List<Storybook>> loadStorybooks() async {
    final directory = await getApplicationDocumentsDirectory();
    final storybooksDir = Directory('${directory.path}/storybooks');
    
    if (!await storybooksDir.exists()) {
      return [];
    }

    final List<Storybook> storybooks = [];
    
    await for (final file in storybooksDir.list()) {
      if (file is File && file.path.endsWith('.json')) {
        final content = await file.readAsString();
        storybooks.add(Storybook.fromJson(jsonDecode(content)));
      }
    }

    // Sort by creation date, newest first
    storybooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return storybooks;
  }

  static Future<void> deleteStorybook(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/storybooks/$id.json');
    
    if (await file.exists()) {
      await file.delete();
    }
  }
}
