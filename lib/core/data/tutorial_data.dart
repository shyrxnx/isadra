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
            title: 'Creating or Adding Figures',
            description: 'You have multiple options: take a photo with the camera, upload an existing photo from your gallery, or use the built-in canvas to draw. Note: The app works best with human-like figures, not stick figures.',
            imagePath: 'assets/tutorial/home_camera.png',
            icon: Icons.add_a_photo,
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
            description: 'After adding a figure, you will complete pose annotation by placing points on the figure, then select from various animation options to bring it to life.',
            imagePath: 'assets/tutorial/home_animate.png',
            icon: Icons.movie,
            color: Colors.blue.shade500,
          ),
        ],
      ),
      
      // Animation Section
      TutorialSection(
        title: 'Creating Animations',
        description: 'Animate human-like figures in your photos',
        icon: Icons.movie,
        color: Colors.purple,
        steps: [
          TutorialStep(
            title: 'Step 1: Adding Figures',
            description: 'Start by either taking a photo with the camera, uploading an existing photo from your gallery, or using the built-in canvas to draw a human-like figure.',
            imagePath: 'assets/tutorial/animation_list.png',
            icon: Icons.add_a_photo,
            color: Colors.purple.shade300,
          ),
          TutorialStep(
            title: 'Step 2: Pose Annotation',
            description: 'After adding your figure, you will be directed to the pose annotation picker where you can choose to either manually place points or drag points to mark the figure key positions.',
            imagePath: 'assets/tutorial/animation_create.png',
            icon: Icons.touch_app,
            color: Colors.purple.shade400,
          ),
          TutorialStep(
            title: 'Step 3: Animation Selection',
            description: 'After saving your pose annotations, choose from various animation options to bring your figure to life.',
            imagePath: 'assets/tutorial/animation_share.png',
            icon: Icons.animation,
            color: Colors.purple.shade500,
          ),
          TutorialStep(
            title: 'Important Note',
            description: 'Remember that only one character can be animated at a time, and an active internet connection is required for animation features to work properly.',
            imagePath: 'assets/tutorial/animation_share.png',
            icon: Icons.info,
            color: Colors.purple.shade600,
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
            description: 'Tap the "+" or ">" button in the slide navigation to add more slides, up to a maximum of 20 slides per storybook.',
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
