import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import '../config/config_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class SharePointUploader {
  final String clientId = ConfigManager.clientId;
  final String clientSecret = ConfigManager.clientSecret;
  final String tenantId = ConfigManager.tenantId;
  final String redirectUri = ConfigManager.redirectUri;
  final String siteId = ConfigManager.siteId;
  final String driveId = ConfigManager.driveId;
  late HttpServer _server;

  final int uploadOrDownload;
  final String sn;
  final String model;

  // Token管理相關
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  static const String _tokenKey = 'sharepoint_access_token';
  static const String _refreshTokenKey = 'sharepoint_refresh_token';
  static const String _expiryKey = 'sharepoint_token_expiry';

  // 安全存儲實例
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  static final Set<String> _downloadedModels = {};

  SharePointUploader(
      {required this.uploadOrDownload, required this.sn, required this.model});

  bool hasDownloaded(String model) {
    if (_downloadedModels.contains(model)) {
      print("已下載過 $model，不再重複下載");
      print("目前已下載過的 models: ${_downloadedModels.join(', ')}");
      return true;
    }
    return false;
  }

  Future<String> _getOrCreateUserZerovaPath() async {
    final String userProfile = Platform.environment['USERPROFILE'] ?? '';

    if (userProfile.isNotEmpty) {
      final String zerovaPath = path.join(userProfile, 'Pictures', 'Zerova');
      // 如果資料夾不存在，則建立它
      final Directory dir = Directory(zerovaPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return zerovaPath;
    } else {
      throw Exception("Unable to find the user profile directory.");
    }
  }

  Future<void> startAuthorization({
    Function(String, int, int)? onProgressUpdate,
    required Map<String, String> categoryTranslations,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    if (uploadOrDownload == 1 && hasDownloaded(model)) {
      return;
    }

    String? token = await getValidAccessToken();
    if (token != null) {
      print("使用現有Token進行操作...");
      await _executeOperations(token, onProgressUpdate, categoryTranslations);
      return;
    }

    await _performOAuthFlow(onProgressUpdate, categoryTranslations, timeout);
  }

  Future<void> _performOAuthFlow(
    Function(String, int, int)? onProgressUpdate,
    Map<String, String> categoryTranslations,
    Duration timeout,
  ) async {
    try {
      final authUrl = Uri.https(
        "login.microsoftonline.com",
        "$tenantId/oauth2/v2.0/authorize",
        {
          "client_id": clientId,
          "response_type": "code",
          "redirect_uri": redirectUri,
          "scope": "https://graph.microsoft.com/.default offline_access",
          "state": DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      if (await canLaunch(authUrl.toString())) {
        await launch(authUrl.toString());
      } else {
        throw Exception("無法打開瀏覽器進行授權");
      }

      HttpServer? server;
      for (int port = 8000; port <= 8010; port++) {
        try {
          server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
          _server = server;
          print("本地服務器啟動在端口: $port");
          break;
        } catch (e) {
          if (port == 8010) {
            throw Exception("無法綁定任何可用端口 (8000-8010)");
          }
        }
      }

      final completer = Completer<void>();
      late Timer timeoutTimer;

      timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException("OAuth授權超時", timeout));
          _server.close();
        }
      });

      _server.listen((HttpRequest request) async {
        if (request.uri.path == "/callback") {
          timeoutTimer.cancel();

          final authCode = request.uri.queryParameters['code'];
          final error = request.uri.queryParameters['error'];
          final state = request.uri.queryParameters['state'];

          if (error != null) {
            completer.completeError(Exception("OAuth授權錯誤: $error"));
          } else if (authCode != null) {
            try {
              final token = await getAccessToken(authCode: authCode);
              if (token != null) {
                await _saveTokens();
                await _executeOperations(
                    token, onProgressUpdate, categoryTranslations);
                completer.complete();
              } else {
                completer.completeError(Exception("無法獲取 Access Token"));
              }
            } catch (e) {
              completer.completeError(e);
            }
          } else {
            completer.completeError(Exception("無效的授權回調"));
          }

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..write("""
              <!DOCTYPE html>
              <html>
              <head><title>授權完成</title></head>
              <body>
                <h2>授權完成</h2>
                <p>您可以關閉此頁面並回到應用程式。</p>
                <script>
                  setTimeout(() => window.close(), 2000);
                </script>
              </body>
              </html>
            """)
            ..close();

          await _server.close();
        }
      });

      await completer.future;
    } catch (e) {
      print("OAuth授權失敗: $e");
      rethrow;
    }
  }

  Future<void> _executeOperations(
    String token,
    Function(String, int, int)? onProgressUpdate,
    Map<String, String> categoryTranslations,
  ) async {
    if (uploadOrDownload == 0) {
      await uploadAllPackagingPhotos(
          token,
          (current, total) => onProgressUpdate?.call(
              categoryTranslations['packageing_photo'] ?? 'Packageing Photo',
              current,
              total));
      await uploadAllAttachmentPhotos(
          token,
          (current, total) => onProgressUpdate?.call(
              categoryTranslations['appearance_photo'] ?? 'Appearance Photo',
              current,
              total));
      await uploadOQCReport(
          token,
          (current, total) => onProgressUpdate?.call(
              categoryTranslations['oqc_report'] ?? 'OQC Report',
              current,
              total));
    } else if (uploadOrDownload == 1) {
      await downloadComparePictures(token);
    } else if (uploadOrDownload == 2) {
      await downloadPhonePackagingPictures(token);
    } else if (uploadOrDownload == 3) {
      await downloadPhoneAttachmentPictures(token);
    } else {
      throw Exception("Didn't contain Upload Or Download");
    }
  }

  Future<String?> getAccessToken(
      {String? authCode, String? refreshToken}) async {
    final tokenUrl =
        "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token";
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'scope': 'offline_access https://graph.microsoft.com/.default',
        'grant_type': authCode != null ? 'authorization_code' : 'refresh_token',
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        if (authCode != null) 'code': authCode,
        if (refreshToken != null) 'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      // 只有在使用authorization_code時才會返回refresh_token
      if (data['refresh_token'] != null) {
        _refreshToken = data['refresh_token'];
      }
      final expiresIn = data['expires_in'] ?? 3600; // 預設1小時
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      return _accessToken;
    } else {
      print("無法獲取 Access Token: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  /// 儲存Token到安全存儲
  Future<void> _saveTokens() async {
    if (_accessToken != null) {
      await _secureStorage.write(key: _tokenKey, value: _accessToken!);
    }
    if (_refreshToken != null) {
      // 直接存儲refresh token，flutter_secure_storage會自動加密
      await _secureStorage.write(key: _refreshTokenKey, value: _refreshToken!);
    }
    if (_tokenExpiry != null) {
      await _secureStorage.write(
          key: _expiryKey, value: _tokenExpiry!.toIso8601String());
    }
  }

  /// 從安全存儲載入Token
  Future<void> _loadTokens() async {
    _accessToken = await _secureStorage.read(key: _tokenKey);
    _refreshToken = await _secureStorage.read(key: _refreshTokenKey);

    final expiryString = await _secureStorage.read(key: _expiryKey);
    if (expiryString != null) {
      _tokenExpiry = DateTime.parse(expiryString);
    }
  }

  /// 清除所有存儲的Token
  Future<void> clearStoredTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiryKey);
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
  }

  /// 檢查Token是否有效
  bool _isTokenValid() {
    return _accessToken != null &&
        _tokenExpiry != null &&
        _tokenExpiry!
            .isAfter(DateTime.now().add(Duration(minutes: 5))); // 提前5分鐘刷新
  }

  /// 獲取有效的Access Token（自動刷新）
  Future<String?> getValidAccessToken() async {
    await _loadTokens();

    // 如果token有效，直接返回
    if (_isTokenValid()) {
      return _accessToken;
    }

    // 嘗試使用refresh token獲取新token
    if (_refreshToken != null) {
      final newToken = await getAccessToken(refreshToken: _refreshToken);
      if (newToken != null) {
        await _saveTokens();
        return newToken;
      }
    }

    // 需要重新授權
    return null;
  }

  Future<void> uploadAllPackagingPhotos(
      String accessToken, Function(int, int) onProgressUpdate) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String snFolderPath = path.join(zerovaPath, 'All Photos', sn);
    final String packagingFolderPath = path.join(snFolderPath, 'Packaging');
    final Directory snDirectory = Directory(snFolderPath);
    final Directory packagingDirectory = Directory(packagingFolderPath);

    if (!snDirectory.existsSync()) {
      print("資料夾不存在: $snFolderPath");
      return;
    }

    // 取得 SN 及其底下 Packaging 內的所有檔案
    final List<File> files = [
      ...snDirectory.listSync().whereType<File>(), // 只包含 SN 目錄內的檔案
      if (packagingDirectory.existsSync())
        ...packagingDirectory
            .listSync(recursive: true)
            .whereType<File>(), // Packaging 內的檔案
    ];

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $snFolderPath");
      return;
    }

    // 統計檔案數量
    int totalFiles = files.length;
    int uploadedFiles = 0;
    print("總共需要上傳 $totalFiles 張配件包照片");

    for (var file in files) {
      final String relativePath = path.relative(file.path, from: zerovaPath);
      final String sharePointPath = "Jackalope/$relativePath";

      final String uploadUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/$sharePointPath:/content";

      try {
        final response = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/octet-stream"
          },
          body: file.readAsBytesSync(),
        );

        // 顯示進度
        double progress = (uploadedFiles + 1) / totalFiles * 100;
        print(
            "配件包照片上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
        uploadedFiles++;
        onProgressUpdate(uploadedFiles, totalFiles);

        if (response.statusCode == 201) {
          print("檔案上傳成功: $relativePath");
        } else {
          print(
              "檔案上傳失敗: $relativePath - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $relativePath - $e");
      }
    }
  }

  Future<void> uploadAllAttachmentPhotos(
      String accessToken, Function(int, int) onProgressUpdate) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String snFolderPath = path.join(zerovaPath, 'All Photos', sn);
    final String attachmentFolderPath = path.join(snFolderPath, 'Attachment');
    final Directory snDirectory = Directory(snFolderPath);
    final Directory attachmentDirectory = Directory(attachmentFolderPath);

    if (!snDirectory.existsSync()) {
      print("資料夾不存在: $snFolderPath");
      return;
    }

    // 取得 SN 及其底下 Attachment 內的所有檔案
    final List<File> files = [
      ...snDirectory.listSync().whereType<File>(), // 只包含 SN 目錄內的檔案
      if (attachmentDirectory.existsSync())
        ...attachmentDirectory
            .listSync(recursive: true)
            .whereType<File>(), // Attachment 內的檔案
    ];

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $snFolderPath");
      return;
    }

    // 統計檔案數量
    int totalFiles = files.length;
    int uploadedFiles = 0;
    print("總共需要上傳 $totalFiles 張外觀檢查照片");

    for (var file in files) {
      final String relativePath = path.relative(file.path, from: zerovaPath);
      final String sharePointPath = "Jackalope/$relativePath";

      final String uploadUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/$sharePointPath:/content";

      try {
        final response = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/octet-stream"
          },
          body: file.readAsBytesSync(),
        );

        // 顯示進度
        double progress = (uploadedFiles + 1) / totalFiles * 100;
        print(
            "外觀檢查照片上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
        uploadedFiles++;
        onProgressUpdate(uploadedFiles, totalFiles);

        if (response.statusCode == 201) {
          print("檔案上傳成功: $relativePath");
        } else {
          print(
              "檔案上傳失敗: $relativePath - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $relativePath - $e");
      }
    }
  }

  Future<void> uploadOQCReport(
      String accessToken, Function(int, int) onProgressUpdate) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String snFolderPath = path.join(zerovaPath, 'OQC Report', sn);
    final Directory snDirectory = Directory(snFolderPath);

    if (!snDirectory.existsSync()) {
      print("資料夾不存在: $snFolderPath");
      return;
    }

    // 取得 SN 內的所有檔案
    final List<File> files = [
      ...snDirectory.listSync().whereType<File>(), // 只包含 SN 目錄內的檔案
    ];

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $snFolderPath");
      return;
    }
    // 統計檔案數量
    int totalFiles = files.length;
    int uploadedFiles = 0;
    print("總共需要上傳 $totalFiles 份OQC Report");

    for (var file in files) {
      final String relativePath = path.relative(file.path, from: zerovaPath);
      final String sharePointPath = "Jackalope/$relativePath";

      final String uploadUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/$sharePointPath:/content";

      try {
        final response = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/octet-stream"
          },
          body: file.readAsBytesSync(),
        );

        // 顯示進度
        double progress = (uploadedFiles + 1) / totalFiles * 100;
        print(
            "OQC Report上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
        uploadedFiles++;
        onProgressUpdate(uploadedFiles, totalFiles);

        if (response.statusCode == 201) {
          print("檔案上傳成功: $relativePath");
        } else {
          print(
              "檔案上傳失敗: $relativePath - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $relativePath - $e");
      }
    }
  }

  Future<void> downloadComparePictures(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    String modelNameUsed = model; // 預設使用傳入的 model 名稱

    // 建立初始要查詢的 SharePoint 路徑
    String listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/Jackalope/外觀參考照片/$model:/children";

    // 發送查詢請求
    var response = await http.get(
      Uri.parse(listFilesUrl),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    // 如果找不到該 model 資料夾，改抓 default
    if (response.statusCode == 404) {
      print("找不到目錄 $model，改用 default");

      modelNameUsed = "default";
      listFilesUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/Jackalope/外觀參考照片/default:/children";

      response = await http.get(
        Uri.parse(listFilesUrl),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode != 200) {
        print("default 資料夾也找不到: ${response.statusCode} ${response.body}");
        return;
      }
    }

    // 成功取得檔案清單
    final data = json.decode(response.body);
    final List files = data['value'];

    if (files.isEmpty) {
      print("參考照片資料夾（$modelNameUsed）中沒有檔案");
      return;
    }

    // 根據實際使用的 model 建立儲存路徑
    final String directoryPath =
        path.join(zerovaPath, 'Compare Pictures', modelNameUsed);
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    for (var file in files) {
      final fileName = file['name'];
      final downloadUrl = file['@microsoft.graph.downloadUrl'];

      if (downloadUrl != null) {
        try {
          final fileResponse = await http.get(Uri.parse(downloadUrl));
          final filePath = "${directory.path}/$fileName";
          final localFile = File(filePath);
          localFile.writeAsBytesSync(fileResponse.bodyBytes);

          print("檔案下載成功: $fileName");
        } catch (e) {
          print("檔案下載失敗: $fileName - $e");
        }
      }
    }
    //記錄這個 model 已經下載過
    _downloadedModels.add(model);
  }

  Future<void> downloadPhoneAttachmentPictures(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String directoryPath =
        path.join(zerovaPath, 'All Photos/$sn/Attachment');
    final listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/Jackalope/Photos/$sn/Attachment:/children";

    final response = await http.get(
      Uri.parse(listFilesUrl),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List files = data['value'];

      if (files.isEmpty) {
        print("測試用資料夾中沒有檔案");
        return;
      }

      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true); // 建立目標資料夾
      }

      for (var file in files) {
        final fileName = file['name'];
        final downloadUrl = file['@microsoft.graph.downloadUrl'];

        if (downloadUrl != null) {
          try {
            final fileResponse = await http.get(Uri.parse(downloadUrl));
            final filePath = "${directory.path}/$fileName";
            final localFile = File(filePath);
            localFile.writeAsBytesSync(fileResponse.bodyBytes);

            print("檔案下載成功: $fileName");
          } catch (e) {
            print("檔案下載失敗: $fileName - $e");
          }
        }
      }
    } else {
      print("無法取得檔案清單: ${response.statusCode} ${response.body}");
    }
  }

  Future<void> downloadPhonePackagingPictures(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String directoryPath =
        path.join(zerovaPath, 'All Photos/$sn/Packaging');
    final listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/Jackalope/Photos/$sn/Packaging:/children";

    final response = await http.get(
      Uri.parse(listFilesUrl),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List files = data['value'];

      if (files.isEmpty) {
        print("測試用資料夾中沒有檔案");
        return;
      }

      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true); // 建立目標資料夾
      }

      for (var file in files) {
        final fileName = file['name'];
        final downloadUrl = file['@microsoft.graph.downloadUrl'];

        if (downloadUrl != null) {
          try {
            final fileResponse = await http.get(Uri.parse(downloadUrl));
            final filePath = "${directory.path}/$fileName";
            final localFile = File(filePath);
            localFile.writeAsBytesSync(fileResponse.bodyBytes);

            print("檔案下載成功: $fileName");
          } catch (e) {
            print("檔案下載失敗: $fileName - $e");
          }
        }
      }
    } else {
      print("無法取得檔案清單: ${response.statusCode} ${response.body}");
    }
  }
}
