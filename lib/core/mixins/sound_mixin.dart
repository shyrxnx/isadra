import 'package:flutter/material.dart';
import '/core/services/sound_service.dart';

mixin SoundMixin {
  void playButtonSound(BuildContext context) {
    // Play sound immediately without awaiting
    SoundService().playButtonSound(context);
  }

  void playNavigationSound(BuildContext context) {
    // Play sound immediately without awaiting
    SoundService().playNavigationSound(context);
  }
}
