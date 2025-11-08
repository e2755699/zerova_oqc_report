import '../config/config_manager.dart';

/// Flavor configuration manager
/// Supports 'tw' (Taiwan) and 'vn' (Vietnam) flavors
/// Factory is read from config.json, with fallback to environment variable
class FlavorConfig {
  static const String _flavorKey = 'FLAVOR';

  /// Get current flavor from config.json or environment variable
  /// Defaults to 'tw' if not set
  static String get currentFlavor {
    // First try to get from config.json (via ConfigManager)
    // Note: ConfigManager must be initialized before using this
    try {
      final configFactory = ConfigManager.factory.toLowerCase();
      if (configFactory == 'tw' || configFactory == 'vn') {
        return configFactory;
      }
    } catch (e) {
      // ConfigManager not initialized or factory not in config, fallback to environment
    }

    // Fallback to environment variable (for backward compatibility)
    const flavor = String.fromEnvironment(_flavorKey, defaultValue: 'tw');
    return flavor.toLowerCase();
  }

  /// Check if current flavor is Taiwan
  static bool get isTaiwan => currentFlavor == 'tw';

  /// Check if current flavor is Vietnam
  static bool get isVietnam => currentFlavor == 'vn';

  /// Get API base URL based on flavor
  static String get apiBaseUrl {
    if (isVietnam) {
      return 'http://172.21.1.110:5000/zapi';
    }
    // Default to Taiwan
    return 'http://api.ztmn.com/zapi';
  }

  /// Get SharePoint path segment after Jackalope based on flavor
  /// Returns empty string for Taiwan, 'vn/' for Vietnam
  /// This will be inserted after 'Jackalope/' in the path
  static String get sharePointFlavorSegment {
    if (isVietnam) {
      return 'vn/';
    }
    return '';
  }
}
