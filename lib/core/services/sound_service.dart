import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/state/sound_state.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  // Use multiple audio players to avoid delays between sound playbacks
  final Map<String, AudioPlayer> _audioPlayers = {};
  
  // Preload the sounds for immediate playback
  final Map<String, Source> _preloadedSounds = {};

  factory SoundService() {
    return _instance;
  }

  SoundService._internal() {
    // Initialize with a default player
    _audioPlayers['default'] = AudioPlayer();
  }

  // Preload sounds for faster playback
  Future<void> preloadSounds(List<String> soundPaths) async {
    for (final path in soundPaths) {
      if (!_preloadedSounds.containsKey(path)) {
        _preloadedSounds[path] = AssetSource(path);
      }
    }
  }

  void playButtonSound(BuildContext context) {
    final soundState = Provider.of<SoundState>(context, listen: false);
    
    if (soundState.isSoundEnabled && soundState.selectedSound.isNotEmpty) {
      _playSound(soundState.selectedSound);
    }
  }

  void playNavigationSound(BuildContext context) {
    final soundState = Provider.of<SoundState>(context, listen: false);
    
    if (soundState.isSoundEnabled && soundState.selectedSound.isNotEmpty) {
      _playSound(soundState.selectedSound);
    }
  }

  // Play sound immediately without waiting
  void _playSound(String soundPath) {
    // Get an available player or create a new one
    final String playerId = _getAvailablePlayerId();
    final player = _audioPlayers[playerId]!;
    
    // Get preloaded sound or create a new source
    final source = _preloadedSounds[soundPath] ?? AssetSource(soundPath);
    
    // Play the sound immediately without awaiting
    player.play(source);
  }

  // Get an available player or create a new one
  String _getAvailablePlayerId() {
    // Use a simple round-robin approach for multiple players
    final String playerId = 'player_${_audioPlayers.length % 5}';
    
    if (!_audioPlayers.containsKey(playerId)) {
      _audioPlayers[playerId] = AudioPlayer();
    }
    
    return playerId;
  }

  void dispose() {
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    _preloadedSounds.clear();
  }
}
