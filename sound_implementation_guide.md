# Sound Implementation Guide for Isadra App

This guide explains how to use the newly implemented sound functionality throughout the Isadra app.

## Overview

The sound system allows for playing sounds when:
1. Navigating between screens
2. Pressing buttons or interacting with UI elements

Users can select their preferred sound in the Sound Settings screen and toggle sounds on/off.

## How to Use Sound in Your Screens

### 1. For Navigation Sounds

To add sound when navigating between screens, use the `playNavigationSound` method from the `SoundMixin`:

```dart
// First, add the mixin to your State class
class _YourScreenState extends State<YourScreen> with SoundMixin {
  
  // Then call the method before navigation
  void _navigateToAnotherScreen() {
    playNavigationSound(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnotherScreen()),
    );
  }
}
```

### 2. For Button Sounds

#### Option 1: Use the pre-made sound button widgets

```dart
// Import the sound button widgets
import '/core/widgets/sound_button.dart';

// Replace standard buttons with sound buttons
SoundButton(
  onPressed: () {
    // Your action here
  },
  child: Text('Click Me'),
)

// For icon buttons
SoundIconButton(
  icon: Icons.add,
  onPressed: () {
    // Your action here
  },
)

// For text buttons
SoundTextButton(
  onPressed: () {
    // Your action here
  },
  child: Text('Text Button'),
)

// For clickable areas
SoundGestureDetector(
  onTap: () {
    // Your action here
  },
  child: YourWidget(),
)
```

#### Option 2: Add sound to existing buttons

```dart
// Add the SoundMixin to your State class
class _YourScreenState extends State<YourScreen> with SoundMixin {
  
  // Then call playButtonSound before your action
  ElevatedButton(
    onPressed: () {
      playButtonSound(context);
      // Your action here
    },
    child: Text('Button'),
  )
}
```

## How It Works

1. The `SoundState` class manages the selected sound and whether sounds are enabled.
2. The `SoundService` handles playing the sounds using the AudioPlayer package.
3. The `SoundMixin` provides convenient methods to play sounds.
4. The sound button widgets are wrappers around standard Flutter widgets that play sounds when pressed.

## Available Sounds

The following sounds are available:
- Bell
- Future
- Game
- Lively
- Pop
- Typewriter

Users can select their preferred sound in the Sound Settings screen.
