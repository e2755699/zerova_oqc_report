import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  static Map<String, dynamic>? _config;
  static const String _factoryKey = 'user_selected_factory';
  static String? _cachedFactory;

  static Future<void> initialize() async {
    try {
      // 首先尝试从环境变量获取
      _config = {
        'clientId': Platform.environment['AZURE_CLIENT_ID'],
        'clientSecret': Platform.environment['AZURE_CLIENT_SECRET'],
        'tenantId': Platform.environment['AZURE_TENANT_ID'],
        'redirectUri': Platform.environment['AZURE_REDIRECT_URI'],
        'siteId': Platform.environment['SHAREPOINT_SITE_ID'],
        'driveId': Platform.environment['SHAREPOINT_DRIVE_ID'],
      };

      // 如果环境变量不存在，尝试从配置文件读取
      if (_config!.values.any((value) => value == null)) {
        try {
          final jsonString = await rootBundle.loadString('assets/config.json');
          _config = json.decode(jsonString);
        } catch (e) {
          print('Error loading config from assets: $e');
          // 如果从assets加载失败，尝试从当前目录读取
          final configFile = File('config.json');
          if (await configFile.exists()) {
            final jsonString = await configFile.readAsString();
            _config = json.decode(jsonString);
          }
        }
      }

      // 验证所有必需的配置都存在
      if (_config!.values.any((value) => value == null)) {
        throw Exception('Missing required configuration values');
      }

      // Initialize cached factory
      _cachedFactory = await getFactory();
    } catch (e) {
      throw Exception('Failed to load configuration: $e');
    }
  }

  /// Get factory with priority: user selection (SharedPreferences) > default 'tw'
  static Future<String> getFactory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userFactory = prefs.getString(_factoryKey);
      if (userFactory != null && (userFactory == 'tw' || userFactory == 'vn')) {
        return userFactory;
      }
    } catch (e) {
      print('Error reading factory from SharedPreferences: $e');
    }
    return 'tw';
  }

  /// Set factory and persist to SharedPreferences
  static Future<void> setFactory(String factory) async {
    if (factory != 'tw' && factory != 'vn') {
      throw ArgumentError('Factory must be either "tw" or "vn"');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_factoryKey, factory);
      _cachedFactory = factory;
      print('Factory set to: $factory');
    } catch (e) {
      print('Error saving factory to SharedPreferences: $e');
      throw e;
    }
  }

  /// Get current factory synchronously (uses cached value or fallback)
  /// For async contexts, prefer getFactory()
  /// Defaults to 'tw' if not set
  static String get currentFactory {
    return _cachedFactory ?? 'tw';
  }

  /// Refresh cached factory (call after setFactory or when needed)
  static Future<void> refreshFactory() async {
    _cachedFactory = await getFactory();
  }

  /// Check if current factory is Taiwan
  static bool get isTaiwan => currentFactory == 'tw';

  /// Check if current factory is Vietnam
  static bool get isVietnam => currentFactory == 'vn';

  /// Get API base URL based on factory
  static String get apiBaseUrl {
    if (isVietnam) {
      return 'http://172.21.1.110:5000/zapi';
    }
    // Default to Taiwan
    return 'http://api.ztmn.com/zapi';
  }

  /// Get SharePoint path segment after Jackalope based on factory
  /// Returns empty string for Taiwan, 'vn/' for Vietnam
  /// This will be inserted after 'Jackalope/' in the path
  static String get sharePointFlavorSegment {
    if (isVietnam) {
      return 'vn/';
    }
    return '';
  }

  static String get clientId => _config?['clientId'] ?? '';
  static String get clientSecret => _config?['clientSecret'] ?? '';
  static String get tenantId => _config?['tenantId'] ?? '';
  static String get redirectUri => _config?['redirectUri'] ?? '';
  static String get siteId => _config?['siteId'] ?? '';
  static String get driveId => _config?['driveId'] ?? '';
}
