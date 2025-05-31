import 'package:flutter/material.dart';
import '../functionality/slide_manager.dart';

class SlideThumbnail extends StatelessWidget {  // Represents a page thumbnail
  final StorySlide slide;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const SlideThumbnail({
    required this.slide,
    required this.isSelected,
    required this.onTap,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
          image: slide.backgroundImageFile != null
              ? DecorationImage(
                  image: FileImage(slide.backgroundImageFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // If no background, show a simple white background
            if (slide.backgroundImageFile == null)
              Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
              ),
            
            // Show slide number
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Show an indication if slide has text
            if (slide.texts.isNotEmpty)
              Positioned(
                top: 2,
                left: 2,
                child: Icon(
                  Icons.text_fields,
                  size: 12,
                  color: Colors.teal.withOpacity(0.8),
                ),
              ),
            
            // Show an indication if slide has animations
            if (slide.animations.isNotEmpty)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.movie,
                  size: 12,
                  color: Colors.purple.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SlideThumbnailRow extends StatelessWidget {  // Row of page thumbnails
  final SlideManager slideManager;
  final Function(int) onSlideSelected;

  const SlideThumbnailRow({
    required this.slideManager,
    required this.onSlideSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(
              'Pages:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.teal),
            ),
          ),
          // Thumbnails
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: slideManager.slides.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                return SlideThumbnail(
                  slide: slideManager.slides[index],
                  isSelected: index == slideManager.currentSlideIndex,
                  onTap: () => onSlideSelected(index),
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
