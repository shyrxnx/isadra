import 'package:flutter/material.dart';

/// Professional color palette for the application
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF3366FF);
  static const Color primaryLight = Color(0xFF5C85FF);
  static const Color primaryDark = Color(0xFF2952CC);
  
  // Secondary colors
  static const Color secondary = Color(0xFF00BFA5);
  static const Color secondaryLight = Color(0xFF33CFBA);
  static const Color secondaryDark = Color(0xFF009984);

  // Accent colors
  static const Color accent = Color(0xFFFF6D00);
  static const Color accentLight = Color(0xFFFF8A33);
  static const Color accentDark = Color(0xFFCC5700);
  
  // Neutral colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF3366FF),
    Color(0xFF00BFA5),
    Color(0xFFFF6D00),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFFFC107),
  ];

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
