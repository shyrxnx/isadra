import 'package:flutter/material.dart';

class SoundState extends ChangeNotifier {
  bool _isSoundEnabled = false; // Sound disabled by default
  String _selectedSound = 'assets/audio/bell_button.mp3'; // Default sound

  final List<SoundOption> _soundOptions = [
    SoundOption(
      assetPath: 'assets/audio/bell_button.mp3',
      displayName: 'Bell',
      color: Colors.blue, // Added color
    ),
    SoundOption(
      assetPath: 'assets/audio/future_button.mp3',
      displayName: 'Future',
      color: Colors.red, // Added color
    ),
    SoundOption(
      assetPath: 'assets/audio/game_button.mp3',
      displayName: 'Game',
      color: Colors.orange, // Added color
    ),
    SoundOption(
      assetPath: 'assets/audio/lively_button.mp3',
      displayName: 'Lively',
      color: Colors.purple, // Added color
    ),
    SoundOption(
      assetPath: 'assets/audio/pop_button.mp3',
      displayName: 'Pop',
      color: Colors.yellow, // Added color
    ),
    SoundOption(
      assetPath: 'assets/audio/typewriter_button.mp3',
      displayName: 'Typewriter',
      color: Colors.brown, // Added color
    ),
  ];

  bool get isSoundEnabled => _isSoundEnabled;
  String get selectedSound => _selectedSound;
  List<SoundOption> get soundOptions => List.unmodifiable(_soundOptions);

  void toggleSound(bool value) {
    _isSoundEnabled = value;
    notifyListeners();
  }

  void selectSound(String assetPath) {
    _selectedSound = assetPath;
    notifyListeners();
  }
}

class SoundOption {
  final String assetPath;
  final String displayName;
  final Color color; // Added color

  SoundOption({
    required this.assetPath,
    required this.displayName,
    required this.color, // Initialize color
  });
}