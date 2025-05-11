import 'dart:io';
import 'package:flutter/material.dart';
import '../functionality/slide_manager.dart';
import 'draggable_scalable_widget.dart';

class AnimationOverlay extends StatelessWidget {
  final AnimationOverlayData data;
  final Function(double x, double y, double scale) onPositionChanged;

  const AnimationOverlay({
    super.key,
    required this.data,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScalableWidget(
      uniqueId: data.id,
      initialX: data.position.x,
      initialY: data.position.y,
      initialScale: data.position.scale,
      onPositionChanged: onPositionChanged,
      child: Image.file(
        data.file,
        width: 100, // Base size, will be scaled by DraggableScalableWidget
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }
}
