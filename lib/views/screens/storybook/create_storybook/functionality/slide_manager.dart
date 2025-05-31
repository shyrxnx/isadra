import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../models/storybook.dart';

class StorySlide {
  File? backgroundImageFile;
  String? backgroundImagePath; // Store the path for serialization
  List<AnimationOverlayData> animations;
  List<TextOverlayData> texts;
  int duration;

  StorySlide({
    this.backgroundImageFile,
    this.backgroundImagePath,
    List<AnimationOverlayData>? animations,
    List<TextOverlayData>? texts,
    this.duration = 5,
  }) : 
    animations = animations ?? [],
    texts = texts ?? [];

  Map<String, dynamic> toJson() {
    return {
      'backgroundImagePath': backgroundImageFile?.path ?? backgroundImagePath,
      'animations': animations.map((anim) => anim.toJson()).toList(),
      'texts': texts.map((text) => text.toJson()).toList(),
      'duration': duration,
    };
  }

  factory StorySlide.fromJson(Map<String, dynamic> json) {
    final bgPath = json['backgroundImagePath'] as String?;
    return StorySlide(
      backgroundImagePath: bgPath,
      backgroundImageFile: bgPath != null ? File(bgPath) : null,
      animations: (json['animations'] as List).map((animJson) => 
        AnimationOverlayData.fromJson(animJson)).toList(),
      texts: (json['texts'] as List).map((textJson) => 
        TextOverlayData.fromJson(textJson)).toList(),
      duration: json['duration'] as int,
    );
  }
}

class SlideManager extends ChangeNotifier {
  // Maximum number of slides allowed per storybook
  static const int maxSlides = 20;
  
  List<StorySlide> _slides = [];
  int _currentSlideIndex = 0;
  bool _hasChanges = false;

  SlideManager() {
    _slides.add(StorySlide());  // Add initial slide
    _hasChanges = false; // New storybook starts with no changes
  }
  
  // Constructor to initialize from an existing storybook
  factory SlideManager.fromStorybook(Storybook storybook) {
    final manager = SlideManager();
    // Clear the default slide
    manager._slides.clear();
    // Add all slides from the storybook
    manager._slides.addAll(storybook.slides);
    // Start with no changes since we're loading an existing storybook
    manager._hasChanges = false;
    return manager;
  }
  bool _isPlaying = false;
  Timer? _slideTimer;

  List<StorySlide> get slides => _slides;
  int get currentSlideIndex => _currentSlideIndex;
  StorySlide get currentSlide => _slides[_currentSlideIndex];
  bool get isPlaying => _isPlaying;
  bool get hasChanges => _hasChanges;
  bool get canAddMoreSlides => _slides.length < maxSlides;
  
  // Check if a slide is empty (no background, animations, or text)
  bool isSlideEmpty(int slideIndex) {
    if (slideIndex < 0 || slideIndex >= _slides.length) return true;
    
    final slide = _slides[slideIndex];
    return slide.backgroundImageFile == null && 
           slide.animations.isEmpty && 
           slide.texts.isEmpty;
  }
  
  // Check if the current slide is empty
  bool get isCurrentSlideEmpty => isSlideEmpty(_currentSlideIndex);
  
  // Reset the changes flag, typically called after saving
  void resetChanges() {
    _hasChanges = false;
    notifyListeners();
  }

  void updateSlideDuration(Duration duration) {
    _slides[_currentSlideIndex].duration = duration.inSeconds;
    _hasChanges = true;
    notifyListeners();
  }

  void startPresentation() {
    if (_slides.isEmpty) return;
    _isPlaying = true;
    _currentSlideIndex = 0;
    _scheduleNextSlide();
    notifyListeners();
  }

  void stopPresentation() {
    _isPlaying = false;
    _slideTimer?.cancel();
    _slideTimer = null;
    notifyListeners();
  }

  void _scheduleNextSlide() {
    _slideTimer?.cancel();
    _slideTimer = Timer(Duration(seconds: currentSlide.duration), () {
      if (!_isPlaying) return;
      
      if (_currentSlideIndex < _slides.length - 1) {
        _currentSlideIndex++;
        _scheduleNextSlide();
        notifyListeners();
      } else {
        stopPresentation();
      }
    });
  }

  void addNewSlide() {
    // Check if slide limit has been reached
    if (_slides.length >= maxSlides) {
      // Don't add more slides if limit reached
      return;
    }
    
    // Check if current slide is empty
    if (isCurrentSlideEmpty) {
      // Don't add more slides if current one is empty
      return;
    }
    
    _slides.add(StorySlide());
    _currentSlideIndex = _slides.length - 1;
    _hasChanges = true;
    notifyListeners();
  }

  void goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      _currentSlideIndex--;
      // If in presentation mode, reset the timer for the new slide
      if (_isPlaying) {
        _scheduleNextSlide();
      }
      notifyListeners();
    }
  }

  void goToNextSlide() {
    if (_currentSlideIndex < _slides.length - 1) {
      _currentSlideIndex++;
      // If in presentation mode, reset the timer for the new slide
      if (_isPlaying) {
        _scheduleNextSlide();
      }
      notifyListeners();
    } else {
      addNewSlide(); // Optionally add a new slide at the end
    }
  }

  void goToSlide(int index) {
    if (index >= 0 && index < _slides.length && index != _currentSlideIndex) {
      _currentSlideIndex = index;
      // If in presentation mode, reset the timer for the new slide
      if (_isPlaying) {
        _scheduleNextSlide();
      }
      notifyListeners();
    }
  }

  void updateCurrentBackground(File? file) {
    _slides[_currentSlideIndex].backgroundImageFile = file;
    _slides[_currentSlideIndex].backgroundImagePath = file?.path;
    _hasChanges = true;
    notifyListeners();
  }

  void addCurrentAnimation(File file) {
    // Create a new instance with default position
    final newAnimation = AnimationOverlayData(
      file: file,
      position: OverlayPosition(
        x: 100,  // Default starting position
        y: 100,
        scale: 1.0,
      ),
    );
    _slides[_currentSlideIndex].animations.add(newAnimation);
    _hasChanges = true;
    notifyListeners();
  }

  void updateAnimationPosition(int index, double x, double y, double scale) {
    if (index < 0 || index >= _slides[_currentSlideIndex].animations.length) return;
    _slides[_currentSlideIndex].animations[index].position = OverlayPosition(
      x: x,
      y: y,
      scale: scale,
    );
    _hasChanges = true;
    notifyListeners();
  }

  void updateTextPosition(int index, double x, double y, double scale) {
    if (index < 0 || index >= _slides[_currentSlideIndex].texts.length) return;
    _slides[_currentSlideIndex].texts[index].position = OverlayPosition(
      x: x,
      y: y,
      scale: scale,
    );
    _hasChanges = true;
    notifyListeners();
  }

  void removeCurrentAnimation(int index) {
    _slides[_currentSlideIndex].animations.removeAt(index);
    _hasChanges = true;
    notifyListeners();
  }

  void addCurrentText(TextOverlayData textData) {
    _slides[_currentSlideIndex].texts.add(textData);
    _hasChanges = true;
    notifyListeners();
  }

  void removeCurrentText(int index) {
    _slides[_currentSlideIndex].texts.removeAt(index);
    _hasChanges = true;
    notifyListeners();
  }

  void removeSlide(int index) {
    if (index < 0 || index >= _slides.length) return;
    _slides.removeAt(index);
    if (_currentSlideIndex >= _slides.length) {
      _currentSlideIndex = _slides.length - 1;
    }
    _hasChanges = true;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'slides': _slides.map((slide) => slide.toJson()).toList(),
      'currentSlideIndex': _currentSlideIndex,
      'isPlaying': _isPlaying,
    };
  }

  factory SlideManager.fromJson(Map<String, dynamic> json) {
    final slideManager = SlideManager();
    slideManager._slides = (json['slides'] as List).map((slideJson) => 
      StorySlide.fromJson(slideJson)).toList();
    slideManager._currentSlideIndex = json['currentSlideIndex'] as int;
    slideManager._isPlaying = json['isPlaying'] as bool;
    return slideManager;
  }
}

class OverlayPosition {
  final double x;
  final double y;
  final double scale;

  OverlayPosition({
    required this.x,
    required this.y,
    this.scale = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'scale': scale,
    };
  }

  factory OverlayPosition.fromJson(Map<String, dynamic> json) {
    return OverlayPosition(
      x: json['x'] as double,
      y: json['y'] as double,
      scale: json['scale'] as double,
    );
  }
}

class AnimationOverlayData {
  final File file;
  final String id;
  OverlayPosition position;

  AnimationOverlayData({
    required this.file,
    String? id,
    OverlayPosition? position,
  }) : id = id ?? DateTime.now().toIso8601String(),
       position = position ?? OverlayPosition(x: 100, y: 100);

  Map<String, dynamic> toJson() => {
    'filePath': file.path,
    'id': id,
    'position': position.toJson(),
  };

  factory AnimationOverlayData.fromJson(Map<String, dynamic> json) {
    return AnimationOverlayData(
      file: File(json['filePath'] as String),
      id: json['id'] as String,
      position: OverlayPosition.fromJson(json['position'] as Map<String, dynamic>),
    );
  }
}

class TextOverlayData {
  final String text;
  final Color color;
  final String id;
  final int fontStyle; // 0=Default, 1=Playful, 2=Bold, 3=Fancy
  final double fontSize;
  final bool isBold;
  OverlayPosition position;

  TextOverlayData({
    required this.text,
    required this.color,
    String? id,
    OverlayPosition? position,
    this.fontStyle = 0,
    this.fontSize = 24,
    this.isBold = false,
  }) : id = id ?? DateTime.now().toIso8601String(),
       position = position ?? OverlayPosition(x: 100, y: 100);

  Map<String, dynamic> toJson() => {
    'text': text,
    'color': color.value,
    'id': id,
    'position': position.toJson(),
    'fontStyle': fontStyle,
    'fontSize': fontSize,
    'isBold': isBold,
  };

  factory TextOverlayData.fromJson(Map<String, dynamic> json) {
    return TextOverlayData(
      text: json['text'] as String,
      color: Color(json['color'] as int),
      id: json['id'] as String,
      position: OverlayPosition.fromJson(json['position'] as Map<String, dynamic>),
      fontStyle: json['fontStyle'] as int? ?? 0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24,
      isBold: json['isBold'] as bool? ?? false,
    );
  }
}