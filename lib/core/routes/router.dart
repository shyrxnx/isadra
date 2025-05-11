import 'package:flutter/material.dart';
import '../../views/screens/home/home_screen.dart';
import '../../views/screens/animation/animation_screen.dart';
import '../../views/screens/storybook/storybook_screen.dart';
import '../../views/screens/settings/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/animation':
        return MaterialPageRoute(builder: (_) => const AnimationScreen());
      case '/storybook':
        return MaterialPageRoute(builder: (_) => const StorybookScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
