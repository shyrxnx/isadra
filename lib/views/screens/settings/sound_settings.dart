import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '/core/state/sound_state.dart';
import '/core/localization/app_localizations.dart';
import '/core/widgets/localized_text.dart';

class SoundSettings extends StatelessWidget {
  const SoundSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LocalizedText('sound_settings'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: const Color(0xFFA8D97F),
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SoundState>(
          builder: (context, soundState, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LocalizedText(
                  'select_sound',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      // Grayed-out and unclickable content
                      AbsorbPointer(
                        absorbing: !soundState.isSoundEnabled,
                        child: Opacity(
                          opacity: soundState.isSoundEnabled ? 1.0 : 0.5,
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: soundState.soundOptions.map((option) {
                              return SoundOptionWidget(
                                soundOption: option,
                                isSelected: soundState.selectedSound == option.assetPath,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // The "Sound On/Off" switch remains clickable
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LocalizedText('sound_on_off'),
                    Switch(
                      value: soundState.isSoundEnabled,
                      onChanged: (value) {
                        soundState.toggleSound(value);
                      },
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class SoundOptionWidget extends StatelessWidget {
  final SoundOption soundOption;
  final bool isSelected;

  SoundOptionWidget({required this.soundOption, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final audioPlayer = AudioPlayer();
        if (Provider.of<SoundState>(context, listen: false).isSoundEnabled) {
          await audioPlayer.play(AssetSource(soundOption.assetPath));
          Provider.of<SoundState>(context, listen: false).selectSound(soundOption.assetPath);
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.green[200] : soundOption.color, // Use soundOption.color
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.music_note, size: 50, color: Colors.white,), // Added color: Colors.white to make icon visible
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(soundOption.displayName),
          Radio<String>(
            value: soundOption.assetPath,
            groupValue: Provider.of<SoundState>(context).selectedSound,
            onChanged: (String? value) {
              if (value != null && Provider.of<SoundState>(context, listen: false).isSoundEnabled) {
                Provider.of<SoundState>(context, listen: false).selectSound(value);
              }
            },
          ),
        ],
      ),
    );
  }
}