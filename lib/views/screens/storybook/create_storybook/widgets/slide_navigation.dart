import 'package:flutter/material.dart';
import '../../create_storybook.dart';

class SlideNavigation extends StatelessWidget {
  final int currentIndex;
  final int totalSlides;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onAdd;
  final VoidCallback? onDelete; // 👈 Add this

  const SlideNavigation({
    super.key,
    required this.currentIndex,
    required this.totalSlides,
    required this.onPrevious,
    required this.onNext,
    required this.onAdd,
    this.onDelete, // 👈 and here
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAdd,
        ),
        IconButton(
          icon: const Icon(Icons.delete), // 👈 Add delete button
          onPressed: onDelete,
        ),
      ],
    );
  }
}
