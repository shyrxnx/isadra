import 'package:flutter/material.dart';
import '../../models/tutorial_step.dart';

class TutorialData {
  static List<TutorialSection> getTutorialSections() {
    return [
      // Home Section
      TutorialSection(
        title: 'Welcome to ISADRA!',
        description: 'An interactive storytelling app for creating animations and storybooks',
        icon: Icons.home,
        color: Colors.blue,
        steps: [
          TutorialStep(
            title: 'Taking a Picture',
            description: 'Tap the camera button to take a picture of human figures. Note: The app recognizes human figures only, not stick figures.',
            imagePath: 'assets/tutorial/home_camera.png',
            icon: Icons.camera_alt,
            color: Colors.blue.shade300,
          ),
          TutorialStep(
            title: 'Single Character Focus',
            description: 'ISADRA can only animate one character at a time. Make sure your photo includes just one person for best results.',
            imagePath: 'assets/tutorial/home_draw.png',
            icon: Icons.person,
            color: Colors.blue.shade400,
          ),
          TutorialStep(
            title: 'Creating Animations',
            description: 'Take a picture and tap "Create Animation" to make your human figures move and animate!',
            imagePath: 'assets/tutorial/home_animate.png',
            icon: Icons.movie,
            color: Colors.blue.shade500,
          ),
        ],
      ),
      
      // Animation Section
      TutorialSection(
        title: 'Creating Animations',
        description: 'Animate human figures in your photos',
        icon: Icons.movie,
        color: Colors.purple,
        steps: [
          TutorialStep(
            title: 'Your Animations',
            description: 'View all your created animations. Remember that only one character can be animated at a time.',
            imagePath: 'assets/tutorial/animation_list.png',
            icon: Icons.list,
            color: Colors.purple.shade300,
          ),
          TutorialStep(
            title: 'Creating New Animations',
            description: 'Tap the "+" button to create a new animation. Make sure your photo contains a clear human figure (not stick figures).',
            imagePath: 'assets/tutorial/animation_create.png',
            icon: Icons.add_circle,
            color: Colors.purple.shade400,
          ),
          TutorialStep(
            title: 'Internet Requirement',
            description: 'An active internet connection is required for animation features to work properly.',
            imagePath: 'assets/tutorial/animation_share.png',
            icon: Icons.wifi,
            color: Colors.purple.shade500,
          ),
        ],
      ),
      
      // Storybook Section
      TutorialSection(
        title: 'Create Digital Storybooks',
        description: 'Design and build interactive storybooks with a maximum of 20 slides each',
        icon: Icons.menu_book,
        color: Colors.orange,
        steps: [
          TutorialStep(
            title: 'Your Storybooks',
            description: 'Browse your created storybooks. You can create up to 20 storybooks total. Long-press a storybook to delete it.',
            imagePath: 'assets/tutorial/storybook_list.png',
            icon: Icons.book,
            color: Colors.orange.shade300,
          ),
          TutorialStep(
            title: 'Creating New Storybooks',
            description: 'Tap the "+" button to create a new storybook. Each storybook can have up to 20 slides.',
            imagePath: 'assets/tutorial/storybook_create.png',
            icon: Icons.add_circle,
            color: Colors.orange.shade400,
          ),
          TutorialStep(
            title: 'Adding Slides',
            description: 'Tap the "+" button in the slide navigation to add more slides, up to a maximum of 20 slides per storybook.',
            imagePath: 'assets/tutorial/storybook_add_page.png',
            icon: Icons.add_box,
            color: Colors.orange.shade500,
          ),
          TutorialStep(
            title: 'Presentation Mode',
            description: 'Tap the play button to view your storybook in presentation mode with timed slide transitions.',
            imagePath: 'assets/tutorial/storybook_read.png',
            icon: Icons.auto_stories,
            color: Colors.orange.shade600,
          ),
        ],
      ),
      
      // Settings Section
      TutorialSection(
        title: 'App Settings',
        description: 'Adjust app settings and learn about limitations',
        icon: Icons.settings,
        color: Colors.green,
        steps: [
          TutorialStep(
            title: 'Sound Settings',
            description: 'Control sound effects within the app. You can toggle sounds on or off based on your preference.',
            imagePath: 'assets/tutorial/settings_sound.png',
            icon: Icons.volume_up,
            color: Colors.green.shade300,
          ),
          TutorialStep(
            title: 'About ISADRA',
            description: 'View important information about the app, including its purpose, scope, limitations, and the development team.',
            imagePath: 'assets/tutorial/settings_help.png',
            icon: Icons.info,
            color: Colors.green.shade500,
          ),
        ],
      ),
    ];
  }
}
