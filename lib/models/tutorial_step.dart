import 'package:flutter/material.dart';

class TutorialStep {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color color;

  TutorialStep({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.color,
  });
}

class TutorialSection {
  final String title;
  final String description;
  final List<TutorialStep> steps;
  final IconData icon;
  final Color color;

  TutorialSection({
    required this.title,
    required this.description,
    required this.steps,
    required this.icon,
    required this.color,
  });
}
