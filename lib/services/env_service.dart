import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

class EnvService {
  static Map<String, String>? _envVars;
  
  static Future<void> _loadEnvVars() async {
    if (_envVars != null) return;
    
    try {
      // For Flutter web, load from web root where .env is copied during build
      _envVars = await _loadFromWebFile();
    } catch (e) {
      AppLogger.warning('Failed to load .env from web root, trying fallback: $e');
      try {
        // Fallback to assets
        _envVars = await _loadFromAssets();
      } catch (e2) {
        // Final fallback to default value
        _envVars = {'LOADER_HEIGHT': '250'};
        AppLogger.warning('Failed to load .env from assets, using default: $e2');
      }
    }
  }
  
  static Future<Map<String, String>> _loadFromAssets() async {
    final Map<String, String> envVars = {};
    
    try {
      AppLogger.info('Trying to load .env from assets...');
      final String envContent = await rootBundle.loadString('.env');
      AppLogger.info('Successfully loaded .env from assets');
      final lines = envContent.split('\n');
      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('#')) {
          final equalIndex = trimmedLine.indexOf('=');
          if (equalIndex > 0) {
            final key = trimmedLine.substring(0, equalIndex).trim();
            final value = trimmedLine.substring(equalIndex + 1).trim();
            envVars[key] = value;
            AppLogger.debug('Loaded env var from assets: $key = $value');
          }
        }
      }
      return envVars;
    } catch (e) {
      AppLogger.warning('Failed to load .env from assets: $e');
      throw Exception('Failed to load .env from assets: $e');
    }
  }
  
  static Future<Map<String, String>> _loadFromWebFile() async {
    final Map<String, String> envVars = {};
    
    try {
      // For Flutter web production, read from web root
      final response = await http.get(Uri.parse('/.env'));
      if (response.statusCode == 200) {
        AppLogger.info('Successfully loaded .env from web root');
        final lines = response.body.split('\n');
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('#')) {
            final equalIndex = trimmedLine.indexOf('=');
            if (equalIndex > 0) {
              final key = trimmedLine.substring(0, equalIndex).trim();
              final value = trimmedLine.substring(equalIndex + 1).trim();
              envVars[key] = value;
              AppLogger.debug('Loaded env var: $key = $value');
            }
          }
        }
        return envVars;
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to load .env from web root');
      }
    } catch (e) {
      AppLogger.warning('Failed to load .env from web root: $e');
      throw Exception('Failed to load .env from web file: $e');
    }
  }
  
  static Future<double> getLoaderHeight() async {
    await _loadEnvVars();
    final heightStr = _envVars?['LOADER_HEIGHT'] ?? '250';
    return double.tryParse(heightStr) ?? 250.0;
  }
}