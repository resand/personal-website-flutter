import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_types.dart';

class PreferencesService {
  static SharedPreferences? _prefs;
  
  // Keys for stored preferences
  static const String _languageKey = 'selected_language';
  static const String _themeKey = 'selected_theme';
  
  // Initialize preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Language persistence
  static Future<void> saveLanguage(String locale) async {
    await _prefs?.setString(_languageKey, locale);
  }
  
  static String? getSavedLanguage() {
    return _prefs?.getString(_languageKey);
  }
  
  // Theme persistence
  static Future<void> saveTheme(ThemeModeType theme) async {
    String themeString;
    switch (theme) {
      case ThemeModeType.light:
        themeString = 'light';
        break;
      case ThemeModeType.dark:
        themeString = 'dark';
        break;
      case ThemeModeType.auto:
        themeString = 'auto';
        break;
    }
    await _prefs?.setString(_themeKey, themeString);
  }
  
  static ThemeModeType? getSavedTheme() {
    final savedTheme = _prefs?.getString(_themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          return ThemeModeType.light;
        case 'dark':
          return ThemeModeType.dark;
        case 'auto':
          return ThemeModeType.auto;
        default:
          return null;
      }
    }
    return null;
  }
  
  // Clear all preferences
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}