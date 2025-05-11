# Language Implementation Guide for Isadra App

This guide explains how to use the newly implemented language system throughout the Isadra app.

## Overview

The language system allows for:
1. Switching between English and Filipino languages
2. Automatic translation of text throughout the app
3. Persistent language selection (saved between app sessions)

## How to Use Localization in Your Screens

### 1. Import Required Files

```dart
import '/core/localization/app_localizations.dart';
import '/core/widgets/localized_text.dart';
```

### 2. Using the LocalizedText Widget

The easiest way to display translated text is to use the `LocalizedText` widget:

```dart
// Simple text
LocalizedText('home'),

// With styling
LocalizedText(
  'welcome',
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

// With parameters
LocalizedText(
  'storybook_count',
  params: {'count': storybooks.length.toString()},
),
```

### 3. Using the Translation Extension

For more flexibility, you can use the context extension method:

```dart
// Simple translation
Text(context.tr('home')),

// With string interpolation
Text('${context.tr('created')}: $dateString'),
```

### 4. Updating Existing Screens

To update an existing screen:

1. Import the required files
2. Replace all hardcoded strings with translation keys
3. Use either the `LocalizedText` widget or the `context.tr()` method

## Adding New Translations

All translations are stored in `lib/core/localization/translations.dart`.

To add a new translation:

1. Add a new key-value pair to both the English ('en') and Filipino ('fil') maps
2. Use the same key in your widgets

Example:
```dart
// In translations.dart
'en': {
  // ... existing translations
  'my_new_text': 'My New Text',
},
'fil': {
  // ... existing translations
  'my_new_text': 'Ang Aking Bagong Teksto',
},

// In your widget
LocalizedText('my_new_text'),
```

## Using Parameters in Translations

For dynamic content, use parameters with curly braces:

```dart
// In translations.dart
'en': {
  'items_count': '{count} items',
},
'fil': {
  'items_count': '{count} mga item',
},

// In your widget
LocalizedText(
  'items_count',
  params: {'count': items.length.toString()},
),
```

## Language State

The `LanguageState` provider manages the current language. You can access it using:

```dart
final languageState = Provider.of<LanguageState>(context);

// Get current language code
String currentCode = languageState.selectedLanguageCode;

// Change language
languageState.setLanguage('fil'); // Switch to Filipino
languageState.setLanguage('en');  // Switch to English
```

## Example: Converting a Screen

Here's an example of converting a screen to use localization:

```dart
// Before
Text('Welcome to Isadra'),

// After
LocalizedText('welcome'),
```

The language settings are automatically saved between app sessions using SharedPreferences.
