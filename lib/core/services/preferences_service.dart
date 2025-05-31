import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _termsAcceptedKey = 'terms_accepted';
  
  // Singleton pattern
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();
  
  /// Check if the terms and conditions have been accepted
  Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }
  
  /// Save that the user has accepted the terms and conditions
  Future<void> setTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, true);
  }
}
