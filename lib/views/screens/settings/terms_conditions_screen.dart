import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/mixins/sound_mixin.dart';
import '../../../core/services/preferences_service.dart';

class TermsConditionsScreen extends StatelessWidget with SoundMixin {
  final bool isFirstLaunch;

  const TermsConditionsScreen({
    this.isFirstLaunch = false,
    super.key,
  });

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFirstLaunch) 
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      playNavigationSound(context);
                      Navigator.pop(context);
                    },
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          context.tr('terms_and_conditions') ?? 'Terms and Conditions',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('protection_of_minors') ?? 'Protection of Minors',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                context.tr('protection_of_minors_content') ?? 
                                'ISADRA is designed with child safety in mind. We ask that parents and guardians monitor their child\'s use of this app. Please be aware of the following:\n\n'
                                '1. Children should be supervised when using the app\'s drawing and creation features.\n\n'
                                '2. Parents/guardians are responsible for monitoring the content their child creates within the app.\n\n'
                                '3. We encourage parents to regularly review their child\'s storybooks and drawings for appropriate content.\n\n'
                                '4. The app does not actively monitor or screen the content created by users.\n\n'
                                '5. If inappropriate content is created, parents should guide their children on proper usage and delete such content.\n\n'
                                'By continuing to use this application, you acknowledge that you understand these terms and will take appropriate measures to ensure the safety of minors using this app.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isFirstLaunch)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          playButtonSound(context);
                          await PreferencesService().setTermsAccepted();
                          if (context.mounted) {
                            Navigator.of(context).pop(true); // Return true to indicate acceptance
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          context.tr('accept_and_continue') ?? 'Accept and Continue',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
