import 'package:flutter/material.dart';
import '../../models/tutorial_step.dart';

class TutorialData {
  static List<TutorialSection> getTutorialSections() {
    return [
      // Home Section
      TutorialSection(
        title: 'Welcome to ISADRA!',
        description: 'Let\'s learn how to use the app and have fun!',
        icon: Icons.home,
        color: Colors.blue,
        steps: [
          TutorialStep(
            title: 'Taking a Picture',
            description: 'Tap the camera button to take a picture of yourself or your friends! You can also choose a picture from your gallery.',
            imagePath: 'assets/tutorial/home_camera.png',
            icon: Icons.camera_alt,
            color: Colors.blue.shade300,
          ),
          TutorialStep(
            title: 'Drawing',
            description: 'Tap the pencil button to draw your own pictures! You can choose different colors and brush sizes.',
            imagePath: 'assets/tutorial/home_draw.png',
            icon: Icons.brush,
            color: Colors.blue.shade400,
          ),
          TutorialStep(
            title: 'Creating Animations',
            description: 'Take a picture and tap "Create Animation" to make your pictures move and dance!',
            imagePath: 'assets/tutorial/home_animate.png',
            icon: Icons.movie,
            color: Colors.blue.shade500,
          ),
        ],
      ),
      
      // Animation Section
      TutorialSection(
        title: 'Fun with Animations!',
        description: 'Make your pictures move and dance!',
        icon: Icons.movie,
        color: Colors.purple,
        steps: [
          TutorialStep(
            title: 'Your Animations',
            description: 'Here you can see all the animations you\'ve made. Tap on one to watch it!',
            imagePath: 'assets/tutorial/animation_list.png',
            icon: Icons.list,
            color: Colors.purple.shade300,
          ),
          TutorialStep(
            title: 'Creating New Animations',
            description: 'Tap the "+" button to create a new animation from your pictures.',
            imagePath: 'assets/tutorial/animation_create.png',
            icon: Icons.add_circle,
            color: Colors.purple.shade400,
          ),
          TutorialStep(
            title: 'Sharing Animations',
            description: 'Tap the share button to send your cool animations to friends and family!',
            imagePath: 'assets/tutorial/animation_share.png',
            icon: Icons.share,
            color: Colors.purple.shade500,
          ),
        ],
      ),
      
      // Storybook Section
      TutorialSection(
        title: 'Create Amazing Stories!',
        description: 'Make your own storybooks with pictures and animations!',
        icon: Icons.menu_book,
        color: Colors.orange,
        steps: [
          TutorialStep(
            title: 'Your Storybooks',
            description: 'Here you can see all the storybooks you\'ve made. Tap on one to read it!',
            imagePath: 'assets/tutorial/storybook_list.png',
            icon: Icons.book,
            color: Colors.orange.shade300,
          ),
          TutorialStep(
            title: 'Creating New Storybooks',
            description: 'Tap the "+" button to create a new storybook with your own pictures and animations!',
            imagePath: 'assets/tutorial/storybook_create.png',
            icon: Icons.add_circle,
            color: Colors.orange.shade400,
          ),
          TutorialStep(
            title: 'Adding Pages',
            description: 'Tap "Add Page" to add more pages to your storybook. You can add as many as you want!',
            imagePath: 'assets/tutorial/storybook_add_page.png',
            icon: Icons.add_box,
            color: Colors.orange.shade500,
          ),
          TutorialStep(
            title: 'Reading Mode',
            description: 'Tap "Read" to see your storybook like a real book! Swipe to turn the pages.',
            imagePath: 'assets/tutorial/storybook_read.png',
            icon: Icons.auto_stories,
            color: Colors.orange.shade600,
          ),
        ],
      ),
      
      // Settings Section
      TutorialSection(
        title: 'Customize Your App!',
        description: 'Change how the app looks and works!',
        icon: Icons.settings,
        color: Colors.green,
        steps: [
          TutorialStep(
            title: 'Sound Settings',
            description: 'Turn sounds on or off, and choose which sounds you like best!',
            imagePath: 'assets/tutorial/settings_sound.png',
            icon: Icons.volume_up,
            color: Colors.green.shade300,
          ),
          TutorialStep(
            title: 'Language Settings',
            description: 'Change the language to English or Filipino!',
            imagePath: 'assets/tutorial/settings_language.png',
            icon: Icons.language,
            color: Colors.green.shade400,
          ),
          TutorialStep(
            title: 'Help and Tutorials',
            description: 'Come back here anytime you need help using the app!',
            imagePath: 'assets/tutorial/settings_help.png',
            icon: Icons.help,
            color: Colors.green.shade500,
          ),
        ],
      ),
      
      // Navigation Section
      TutorialSection(
        title: 'Moving Around the App',
        description: 'Learn how to go to different parts of the app!',
        icon: Icons.navigation,
        color: Colors.red,
        steps: [
          TutorialStep(
            title: 'Bottom Navigation',
            description: 'Tap the buttons at the bottom to go to different parts of the app!',
            imagePath: 'assets/tutorial/navigation_bottom.png',
            icon: Icons.swap_horiz,
            color: Colors.red.shade300,
          ),
          TutorialStep(
            title: 'Back Button',
            description: 'Tap the back arrow at the top left to go back to the previous screen.',
            imagePath: 'assets/tutorial/navigation_back.png',
            icon: Icons.arrow_back,
            color: Colors.red.shade400,
          ),
          TutorialStep(
            title: 'Home Button',
            description: 'Tap the home button at the bottom to go back to the main screen.',
            imagePath: 'assets/tutorial/navigation_home.png',
            icon: Icons.home,
            color: Colors.red.shade500,
          ),
        ],
      ),
    ];
  }
}
