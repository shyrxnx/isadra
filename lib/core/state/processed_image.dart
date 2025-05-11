import 'package:flutter/material.dart';

class ProcessedImageProvider extends ChangeNotifier {
  String? _maskImageUrl;
  String? _textureImageUrl;
  String? _originalImageUrl;

  String? get maskImageUrl => _maskImageUrl;
  String? get textureImageUrl => _textureImageUrl;
  String? get originalImageUrl => _originalImageUrl;

  void setProcessedImageUrls({
    String? maskUrl,
    String? textureUrl,
    String? originalUrl,
  }) {
    _maskImageUrl = maskUrl;
    _textureImageUrl = textureUrl;
    _originalImageUrl = originalUrl;
    notifyListeners();
  }

  void clearProcessedImageUrls() {
    _maskImageUrl = null;
    _textureImageUrl = null;
    _originalImageUrl = null;
    notifyListeners();
  }
}