import 'package:flutter/material.dart';

class DraggableScalableWidget extends StatefulWidget {
  final Widget child;
  final double initialX;
  final double initialY;
  final double initialScale;
  final Function(double x, double y, double scale)? onPositionChanged;
  final String uniqueId;

  const DraggableScalableWidget({
    super.key,
    required this.child,
    required this.uniqueId,
    this.initialX = 100,
    this.initialY = 100,
    this.initialScale = 1.0,
    this.onPositionChanged,
  });

  @override
  State<DraggableScalableWidget> createState() => _DraggableScalableWidgetState();
}

class _DraggableScalableWidgetState extends State<DraggableScalableWidget> {
  late Offset position;
  late double scale;
  Offset _startPosition = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _startScale = 1.0;

  @override
  void initState() {
    super.initState();
    position = Offset(widget.initialX, widget.initialY);
    scale = widget.initialScale;
  }

  @override
  void didUpdateWidget(DraggableScalableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialX != widget.initialX || 
        oldWidget.initialY != widget.initialY || 
        oldWidget.initialScale != widget.initialScale) {
      setState(() {
        position = Offset(widget.initialX, widget.initialY);
        scale = widget.initialScale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          _startScale = scale;
          _startPosition = position;
          _lastFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          setState(() {
            // Update scale
            scale = (_startScale * details.scale).clamp(0.1, 5.0);
            
            // Update position
            final delta = details.focalPoint - _lastFocalPoint;
            position = Offset(
              position.dx + delta.dx,
              position.dy + delta.dy,
            );
            _lastFocalPoint = details.focalPoint;
            
            widget.onPositionChanged?.call(
              position.dx,
              position.dy,
              scale,
            );
          });
        },
        child: Transform.scale(
          scale: scale,
          child: widget.child,
        ),
      ),
    );
  }
}