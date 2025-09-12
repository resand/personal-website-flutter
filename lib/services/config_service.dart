import '../models/website_config.dart';
import 'localization_service.dart';

class ConfigService {
  static Future<MyWebsiteConfig> loadConfig({bool forceReload = false}) async {
    return await LocalizationService.loadConfig(forceReload: forceReload);
  }

  static MyWebsiteConfig? get config => LocalizationService.cachedConfig;

  static void clearCache() {
    LocalizationService.clearCache();
  }
}