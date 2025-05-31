import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/mixins/sound_mixin.dart';
import 'sound_settings.dart';
import 'report_settings.dart';
import 'tutorial_settings.dart';
import 'about_settings.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatelessWidget with SoundMixin {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  _SettingsItem(
                    icon: Icons.volume_up,
                    text: context.tr('sound'),
                    onTap: () {
                      playNavigationSound(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SoundSettings()),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.feedback,
                    text: context.tr('report'),
                    onTap: () {
                      playNavigationSound(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReportSettings()),
                      );
                    },
                  ),

                  _SettingsItem(
                    icon: Icons.help,
                    text: context.tr('tutorial_help'),
                    onTap: () {
                      playNavigationSound(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TutorialSettings()),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.info,
                    text: context.tr('about'),
                    onTap: () {
                      playNavigationSound(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutSettings()),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.security,
                    text: context.tr('terms_and_conditions') ?? 'Terms & Conditions',
                    onTap: () {
                      playNavigationSound(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 18),
      onTap: onTap,
    );
  }
}
