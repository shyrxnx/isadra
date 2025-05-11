// This file contains all the translations for the app

const Map<String, Map<String, String>> translations = {
  // English translations only
  'en': {
    // Common
    'app_name': 'ISADRA App',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'create': 'Create',
    'loading': 'Loading...',
    
    // Navigation
    'home': 'Home',
    'animation': 'Animation',
    'storybook': 'Storybook',
    'settings': 'Settings',
    
    // Home Screen
    'welcome': 'Welcome to ISADRA',
    'get_started': 'Get Started',
    
    // Animation Screen
    'create_animation': 'Create Animation',
    'my_animations': 'My Animations',
    'animation_settings': 'Animation Settings',
    
    // Storybook Screen
    'storybooks': 'Storybooks',
    'storybook_count': '{count} storybooks',
    'no_storybooks': 'No storybooks yet!',
    'create_storybook': 'Create Storybook',
    'slides': 'slides',
    'created': 'Created',
    
    // Settings Screen
    'account_settings': 'Account Settings',
    'storybook_settings': 'Storybook Settings',
    'sound': 'Sound',
    'report': 'Report',
    'language': 'Language',
    'tutorial_help': 'Tutorial / Help',
    'about': 'About',
    
    // Tutorial
    'tutorial_welcome': 'Welcome to ISADRA!',
    'tutorial_intro': 'Let\'s learn how to use the app and have fun with animations and storybooks!',
    'start_tutorial': 'Start Tutorial',
    'quick_help': 'Quick Help',
    'home_help': 'Take pictures, draw, and start creating animations.',
    'animation_help': 'View your animations and create new ones.',
    'storybook_help': 'Create and read your own storybooks.',
    'settings_help': 'Change language, sound, and other settings.',
    
    // Language Settings
    'language_settings': 'Language Settings',
    'select_language': 'Select Language:',
    'selected_language': 'Selected Language: {language}',
    
    // Sound Settings
    'sound_settings': 'Sound Settings',
    'select_sound': 'Select Sound:',
    'sound_on_off': 'Sound:',
  },
};

// Helper function to format strings with parameters
String formatString(String template, Map<String, String> params) {
  String result = template;
  params.forEach((key, value) {
    result = result.replaceAll('{$key}', value);
  });
  return result;
}
