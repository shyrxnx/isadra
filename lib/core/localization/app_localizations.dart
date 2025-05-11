import 'package:flutter/material.dart';
import 'translations.dart';

class AppLocalizations {
  final Map<String, String> _localizedValues;

  AppLocalizations(this._localizedValues);

  // Helper method to get translations
  String translate(String key) {
    return _localizedValues[key] ?? key; // Fallback to key if translation not found
  }

  // Static method to get instance from context
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(
      translations['en']!,
    );
  }
}

// Extension method for BuildContext to easily access translations
extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  
  // Shorthand method for translation
  String tr(String key) => loc.translate(key);
}
