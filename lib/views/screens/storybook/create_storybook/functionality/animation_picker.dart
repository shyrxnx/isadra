import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/draggable_scalable_widget.dart';
import '../../../../../core/services/animation_cache_manager.dart';

class AnimationPicker {
  static Future<List<FileSystemEntity>> getSavedAnimations() async {
    final savedAnimationPaths = await AnimationCacheManager.getSavedAnimations();
    return savedAnimationPaths.map((path) => File(path)).toList();
  }

  static void showAnimationPicker(BuildContext context, List<FileSystemEntity> animations, Function(File) onAnimationSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return ListView.builder(
          itemCount: animations.length,
          itemBuilder: (context, index) {
            final animationFile = animations[index] as File;
            return ListTile(
              leading: const Icon(Icons.movie),
              title: Text(animationFile.uri.pathSegments.last),
              onTap: () {
                onAnimationSelected(animationFile);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  static Widget buildAnimationWidget(
    File animationFile,
    String uniqueId,
    {double x = 100,
    double y = 100,
    double scale = 1.0,
    Function(double x, double y, double scale)? onPositionChanged}
  ) {
    return DraggableScalableWidget(
      uniqueId: uniqueId,
      initialX: x,
      initialY: y,
      initialScale: scale,
      onPositionChanged: onPositionChanged,
      child: Image.file(animationFile, fit: BoxFit.contain),
    );
  }
}
