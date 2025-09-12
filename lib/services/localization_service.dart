import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui';
import '../models/website_config.dart';
import 'preferences_service.dart';
import 'package:logger/logger.dart';

class LocalizationService {
  static final Logger _logger = Logger();
  static String? _currentLocale;
  static MyWebsiteConfig? _cachedConfig;

  static Future<String> get currentLocale async {
    if (_currentLocale != null) return _currentLocale!;
    
    // Check for saved locale first
    final savedLocale = PreferencesService.getSavedLanguage();
    if (savedLocale != null && supportedLocales.contains(savedLocale)) {
      _currentLocale = savedLocale;
      return _currentLocale!;
    }
    
    // Auto-detect locale based on system locale
    _currentLocale = _detectSystemLocale();
    return _currentLocale!;
  }

  static String _detectSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    final languageCode = systemLocale.languageCode.toLowerCase();
    final countryCode = systemLocale.countryCode?.toLowerCase();
    
    // Spanish-speaking regions use default
    final spanishRegions = ['mx', 'co', 'ar', 'pe', 've', 'cl', 'ec', 'gt', 'cu', 'bo', 'do', 'hn', 'py', 'sv', 'ni', 'cr', 'pa', 'uy', 'gq'];
    
    if (languageCode == 'es' || (countryCode != null && spanishRegions.contains(countryCode))) {
      return 'default'; // Spanish/Castellano
    }
    
    // Everything else defaults to English
    return 'english';
  }

  // Supported locales - can be extended dynamically
  static const List<String> supportedLocales = ['default', 'english'];
  
  static MyWebsiteConfig? get cachedConfig => _cachedConfig;

  static Future<void> setLocale(String locale) async {
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale: $locale');
    }
    
    _currentLocale = locale;
    _cachedConfig = null; // Clear cache to reload config
    
    // Persist the locale selection
    await PreferencesService.saveLanguage(locale);
  }

  static void clearCache() {
    _cachedConfig = null;
  }

  static Future<MyWebsiteConfig> loadConfig({bool forceReload = false}) async {
    if (_cachedConfig != null && _currentLocale != null && !forceReload) {
      return _cachedConfig!;
    }

    final currentLang = await currentLocale;
    
    final configFileName = currentLang == 'default' 
      ? 'website_config_default.json'
      : 'website_config_english.json';
    
    final String configPath = 'assets/config/$configFileName';
    
    try {
      final String configString = await rootBundle.loadString(configPath);
      final Map<String, dynamic> configJson = json.decode(configString);
      _cachedConfig = MyWebsiteConfig.fromJson(configJson);
      return _cachedConfig!;
    } catch (e, stackTrace) {
      _logger.e('Error loading config from $configPath: $e');
      _logger.e('Stack trace: $stackTrace');
      
      // Fallback to default language if current language fails
      if (currentLang != 'default') {
        try {
          const String fallbackPath = 'assets/config/website_config_default.json';
          final String configString = await rootBundle.loadString(fallbackPath);
          final Map<String, dynamic> configJson = json.decode(configString);
          _cachedConfig = MyWebsiteConfig.fromJson(configJson);
          return _cachedConfig!;
        } catch (fallbackError, fallbackStackTrace) {
          _logger.e('Error loading fallback config: $fallbackError');
          _logger.e('Fallback stack trace: $fallbackStackTrace');
          rethrow;
        }
      }
      rethrow;
    }
  }

  // Generic method to get language info from config
  static Future<LanguageInfo> _getLanguageInfo(String locale) async {
    try {
      final configFileName = _getConfigFileName(locale);
      final String configPath = 'assets/config/$configFileName';
      final String configString = await rootBundle.loadString(configPath);
      final Map<String, dynamic> configJson = json.decode(configString);
      final config = MyWebsiteConfig.fromJson(configJson);
      
      return config.languageInfo;
    } catch (e) {
      // Fallback language info if config loading fails
      return LanguageInfo(
        code: locale.toUpperCase(),
        name: locale == 'default' ? 'Español' : 'English',
      );
    }
  }

  // Helper method to get config file name for a locale
  static String _getConfigFileName(String locale) {
    return locale == 'default' 
      ? 'website_config_default.json'
      : 'website_config_english.json';
  }

  // Get language name for a specific locale
  static Future<String> getLanguageName(String locale) async {
    final languageInfo = await _getLanguageInfo(locale);
    return languageInfo.name;
  }

  // Get language code for a specific locale
  static Future<String> getLanguageCode(String locale) async {
    final languageInfo = await _getLanguageInfo(locale);
    return languageInfo.code;
  }
  
  // Get language name for a specific locale (alias for consistency)
  static Future<String> getLanguageNameForLocale(String locale) async {
    return getLanguageName(locale);
  }
}