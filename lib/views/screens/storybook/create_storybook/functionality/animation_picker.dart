import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../widgets/draggable_scalable_widget.dart';
import '../../../../../core/services/animation_cache_manager.dart';
import 'package:flutter/services.dart' show rootBundle;

class AnimationPicker {
  static Future<List<FileSystemEntity>> getSavedAnimations() async {
    final savedAnimationPaths = await AnimationCacheManager.getSavedAnimations();
    final animations = savedAnimationPaths.map((path) => File(path)).toList();
    
    // Sort in descending order (newest first)
    animations.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    
    return animations;
  }

  static void showAnimationPicker(BuildContext context, List<FileSystemEntity> animations, Function(File) onAnimationSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.green.shade50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Choose an Animation',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ),
              Divider(color: Colors.green.shade300),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: animations.length,
                  itemBuilder: (context, index) {
                    final animationFile = animations[index] as File;
                    return AnimationPreviewCard(
                      animationFile: animationFile,
                      onTap: () {
                        onAnimationSelected(animationFile);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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

class AnimationPreviewCard extends StatefulWidget {
  final File animationFile;
  final VoidCallback onTap;

  const AnimationPreviewCard({
    Key? key,
    required this.animationFile,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimationPreviewCardState createState() => _AnimationPreviewCardState();
}

class _AnimationPreviewCardState extends State<AnimationPreviewCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        color: Colors.green.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Image.file(
                widget.animationFile,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }
}
