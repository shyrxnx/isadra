import 'package:flutter/material.dart';

class ColorCircle extends StatelessWidget {
  final Color color;
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorCircle({super.key, required this.color, required this.selectedColor, required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: color == selectedColor ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}