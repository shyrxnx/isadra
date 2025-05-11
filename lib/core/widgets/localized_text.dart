import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

/// A widget that displays text with automatic localization
class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Map<String, String>? params;

  const LocalizedText(
    this.textKey, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.params,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String translatedText = context.tr(textKey);
    
    // Apply parameters if provided
    if (params != null && params!.isNotEmpty) {
      params!.forEach((key, value) {
        translatedText = translatedText.replaceAll('{$key}', value);
      });
    }
    
    return Text(
      translatedText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
