import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class SharePointUploader {
  final String clientId = "a66968aa-0b06-46b5-be07-1453aa2b5427";
  final String clientSecret = "PV68Q~yc.Crr8b_SpliE57XQJTh9jIkhRFkfUauc";
  final String tenantId = "65a97312-0e38-4ac7-b923-4e3737fb402e";
  final String redirectUri = "http://localhost:8000/callback";
  final String siteId =
      "phihong666.sharepoint.com,5d15176f-54bb-4c3b-976b-625313f854bf,1419d2ad-d720-409f-b2b9-5c964ac9629e";
  final String driveId =
      "b!bxcVXbtUO0yXa2JTE_hUv63SGRQg159AsrlclkrJYp4SVeWUkLLJR6xfCNOrFGQg";
  late HttpServer _server;

  Future<String> _getUserPicturesPath(String subDirectory) async {
    // 獲取當前使用者的根目錄
    final String userProfile = Platform.environment['USERPROFILE'] ?? '';

    // 根據根目錄構建圖片目錄路徑
    if (userProfile.isNotEmpty) {
      final String picturesPath = path.join(userProfile, 'Pictures', subDirectory);
      return picturesPath;
    } else {
      throw Exception("Unable to find the user profile directory.");
    }
  }

  Future<void> startAuthorization() async {
    final authUrl = Uri.https(
      "login.microsoftonline.com",
      "$tenantId/oauth2/v2.0/authorize",
      {
        "client_id": clientId,
        "response_type": "code",
        "redirect_uri": redirectUri,
        "scope": "https://graph.microsoft.com/.default"
      },
    );

    if (await canLaunch(authUrl.toString())) {
      await launch(authUrl.toString());
    } else {
      print("無法打開瀏覽器");
      return;
    }

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8000);
    await for (HttpRequest request in _server) {
      if (request.uri.path == "/callback") {
        final authCode = request.uri.queryParameters['code'];
        if (authCode != null) {
          print("授權碼獲取成功: $authCode");
          final token = await getAccessToken(authCode);
          if (token != null) {
            print("Access Token 獲取成功，正在上傳/下載檔案...");
            await uploadAllFiles(token); // 上傳所有照片
            await uploadSelectedFiles(token); // 上傳選擇的照片
            await uploadOQCFiles(token); // 上傳OQC report
            await downloadFiles(token); // 下載參考照片
          } else {
            print("無法獲取 Access Token");
          }
        }
        request.response
          ..statusCode = HttpStatus.ok
          ..write("<script>window.close();</script>授權完成，請回到終端機查看結果。")
          ..close();
        _server.close();
        break;
      }
    }
  }

  Future<String?> getAccessToken(String authCode) async {
    final tokenUrl =
        "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token";
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'code': authCode,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      print("無法獲取 Access Token: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  Future<void> uploadAllFiles(String accessToken) async {
    final directoryPath = await _getUserPicturesPath('All');
    final directory = Directory(directoryPath);

    if (!directory.existsSync()) {
      print("資料夾不存在: $directoryPath");
      return;
    }

    // 只選擇檔案，排除資料夾
    final files = directory.listSync().where((entity) => entity is File).toList();

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $directoryPath");
      return;
    }

    for (var fileEntity in files) {
      final file = fileEntity as File;  // 強制轉換為 File 類型
      final fileName = file.path.split(Platform.pathSeparator).last;
      final uploadUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/Jackalope/拍照上傳照片/$fileName:/content";

      try {
        final response = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/octet-stream"
          },
          body: file.readAsBytesSync(), // 讀取檔案內容為二進位數據
        );

        if (response.statusCode == 201) {
          print("檔案上傳成功: $fileName");
        } else {
          print("檔案上傳失敗: $fileName - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $fileName - $e");
      }
    }
  }

  Future<void> uploadSelectedFiles(String accessToken) async {
    final directoryPath = await _getUserPicturesPath('Zerova');
    final directory = Directory(directoryPath);

    if (!directory.existsSync()) {
      print("資料夾不存在: $directoryPath");
      return;
    }

    // 只選擇檔案，排除資料夾
    final files = directory.listSync().where((entity) => entity is File).toList();

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $directoryPath");
      return;
    }

    for (var fileEntity in files) {
      final file = fileEntity as File;  // 強制轉換為 File 類型
      final fileName = file.path.split(Platform.pathSeparator).last;
      final uploadUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/Jackalope/選擇上傳報告的照片/$fileName:/content";

      try {
        final response = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/octet-stream"
          },
          body: file.readAsBytesSync(), // 讀取檔案內容為二進位數據
        );

        if (response.statusCode == 201) {
          print("檔案上傳成功: $fileName");
        } else {
          print("檔案上傳失敗: $fileName - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $fileName - $e");
      }
    }
  }

  Future<void> uploadOQCFiles(String accessToken) async {
    final directoryPath = await _getUserPicturesPath('OQC report');
    final directory = Directory(directoryPath);

    if (!directory.existsSync()) {
      print("資料夾不存在: $directoryPath");
      return;
    }

    // 只選擇檔案，排除資料夾
    final files = directory.listSync().where((entity) => entity is File).toList();

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $directoryPath");
      return;
    }

    for (var fileEntity in files) {
      final file = fileEntity as File;  // 強制轉換為 File 類型
      final fileName = file.path.split(Platform.pathSeparator).last;
      final uploadUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/Jackalope/OQC Report/$fileName:/content";

      try {
        final response = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/octet-stream"
          },
          body: file.readAsBytesSync(), // 讀取檔案內容為二進位數據
        );

        if (response.statusCode == 201) {
          print("檔案上傳成功: $fileName");
        } else {
          print("檔案上傳失敗: $fileName - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $fileName - $e");
      }
    }
  }

  Future<void> downloadFiles(String accessToken) async {
    final directoryPath = await _getUserPicturesPath('Compare Pictures');
    final listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/Jackalope/外觀參考照片:/children";

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