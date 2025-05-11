import 'package:flutter/material.dart';
import '../../../core/data/tutorial_data.dart';
import '../../../models/tutorial_step.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/mixins/sound_mixin.dart';
import 'tutorial_section_screen.dart';

class TutorialMainScreen extends StatelessWidget with SoundMixin {
  const TutorialMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tutorialSections = TutorialData.getTutorialSections();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('tutorial_help')),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Friendly mascot and welcome message
            _buildWelcomeHeader(context),
            const SizedBox(height: 20),
            // Tutorial sections
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tutorialSections.length,
                itemBuilder: (context, index) {
                  final section = tutorialSections[index];
                  return _buildTutorialSectionCard(context, section);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Mascot icon (could be replaced with an actual mascot image)
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.school,
              size: 60,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('tutorial_welcome'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('tutorial_intro'),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSectionCard(BuildContext context, TutorialSection section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          playButtonSound(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorialSectionScreen(section: section),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Section icon
              CircleAvatar(
                radius: 30,
                backgroundColor: section.color,
                child: Icon(
                  section.icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Section title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.teal,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
