import 'package:flutter/material.dart';
import '../../../core/data/tutorial_data.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/mixins/sound_mixin.dart';
import '../../screens/tutorial/tutorial_main_screen.dart';
import '../../screens/tutorial/tutorial_section_screen.dart';

class TutorialSettings extends StatelessWidget with SoundMixin {
  const TutorialSettings({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the tutorial sections
    final tutorialSections = TutorialData.getTutorialSections();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tutorial_help')),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: const Color(0xFFA8D97F),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Friendly mascot icon
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: Colors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Welcome text
              Text(
                context.tr('tutorial_welcome'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('tutorial_intro'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Start tutorial button
              ElevatedButton.icon(
                onPressed: () {
                  playButtonSound(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TutorialMainScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.play_circle_filled, size: 30),
                label: Text(
                  context.tr('start_tutorial'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Quick help options
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('quick_help'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildQuickHelpItem(
                        context,
                        Icons.home,
                        context.tr('home_help'),
                        Colors.blue,
                            () {
                          // Navigate to the home help section
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TutorialSectionScreen(section: tutorialSections[0]),
                            ),
                          );
                        },
                      ),
                      _buildQuickHelpItem(
                        context,
                        Icons.movie,
                        context.tr('animation_help'),
                        Colors.purple,
                            () {
                          // Navigate to the animation help section
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TutorialSectionScreen(section: tutorialSections[1]),
                            ),
                          );
                        },
                      ),
                      _buildQuickHelpItem(
                        context,
                        Icons.menu_book,
                        context.tr('storybook_help'),
                        Colors.orange,
                            () {
                          // Navigate to the storybook help section
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TutorialSectionScreen(section: tutorialSections[2]),
                            ),
                          );
                        },
                      ),
                      _buildQuickHelpItem(
                        context,
                        Icons.settings,
                        context.tr('settings_help'),
                        Colors.green,
                            () {
                          // Navigate to the settings help section
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TutorialSectionScreen(section: tutorialSections[3]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelpItem(BuildContext context, IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap action
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}