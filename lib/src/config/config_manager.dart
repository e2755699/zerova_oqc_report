import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class ConfigManager {
  static Map<String, dynamic>? _config;

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
    } catch (e) {
      throw Exception('Failed to load configuration: $e');
    }
  }

  static String get factory => _config?['factory'] ?? 'tw';
  static String get clientId => _config?['clientId'] ?? '';
  static String get clientSecret => _config?['clientSecret'] ?? '';
  static String get tenantId => _config?['tenantId'] ?? '';
  static String get redirectUri => _config?['redirectUri'] ?? '';
  static String get siteId => _config?['siteId'] ?? '';
  static String get driveId => _config?['driveId'] ?? '';
}
