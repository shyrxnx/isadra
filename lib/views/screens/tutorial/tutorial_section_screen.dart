import 'package:flutter/material.dart';
import '../../../models/tutorial_step.dart';
import '../../../core/mixins/sound_mixin.dart';
import 'tutorial_step_screen.dart';

class TutorialSectionScreen extends StatelessWidget with SoundMixin {
  final TutorialSection section;

  const TutorialSectionScreen({Key? key, required this.section}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
        backgroundColor: section.color,
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
            // Section header
            _buildSectionHeader(context),
            // Tutorial steps
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: section.steps.length,
                itemBuilder: (context, index) {
                  final step = section.steps[index];
                  return _buildTutorialStepCard(context, step, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: section.color,
            child: Icon(
              section.icon,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            section.description,
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

  Widget _buildTutorialStepCard(BuildContext context, TutorialStep step, int index) {
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
              builder: (context) => TutorialStepScreen(
                section: section,
                initialStep: index,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Step number in a circle
              CircleAvatar(
                radius: 20,
                backgroundColor: step.color,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Step title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
