import 'package:flutter/material.dart';
import '../functionality/slide_manager.dart';
import '../../create_storybook.dart';

class SlideNavigation extends StatelessWidget {
  final int currentIndex;
  final int totalSlides;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;
  final bool canAddMoreSlides;

  const SlideNavigation({
    super.key,
    required this.currentIndex,
    required this.totalSlides,
    required this.onPrevious,
    required this.onNext,
    required this.onAdd,
    this.onDelete,
    this.canAddMoreSlides = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show limit message when close to max
        if (totalSlides >= SlideManager.maxSlides - 3 && totalSlides < SlideManager.maxSlides)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              'Approaching slide limit (${totalSlides}/${SlideManager.maxSlides})',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
            ),
          ),
        // Show limit reached message when at max
        if (totalSlides >= SlideManager.maxSlides)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              'Maximum slides reached (${SlideManager.maxSlides})',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onPrevious,
            ),
            Text('Slide ${currentIndex + 1} of $totalSlides'),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: onNext,
            ),
            Tooltip(
              message: canAddMoreSlides 
                ? 'Add a new slide' 
                : 'Maximum slides reached (${SlideManager.maxSlides})',
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: canAddMoreSlides ? onAdd : null, // Disable if at limit
                color: canAddMoreSlides ? null : Colors.grey,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ],
    );
  }
}
