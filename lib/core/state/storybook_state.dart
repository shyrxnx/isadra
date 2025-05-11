import 'package:flutter/material.dart';

class StorybookState extends ChangeNotifier {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void toggleStorybook(bool value) {
    _isEnabled = value;
    notifyListeners(); // Notify all listeners about the state change
  }
}
