import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import '../config/config_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

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

  static final Set<String> _downloadedModels = {};

  SharePointUploader(
      {required this.uploadOrDownload, required this.sn, required this.model});

  /// Build SharePoint path with factory segment after Jackalope
  /// For Taiwan: "Jackalope/外觀參考照片/..."
  /// For Vietnam: "Jackalope/vn/外觀參考照片/..."
  String _buildSharePointPath(String path) {
    // Path format: "Jackalope/外觀參考照片/..." or "Jackalope/All Photos/..."
    // We need to insert factory segment after "Jackalope/"
    final flavorSegment = ConfigManager.sharePointFlavorSegment;
    if (flavorSegment.isEmpty) {
      return path; // Taiwan: no change
    }
    // Vietnam: insert "vn/" after "Jackalope/"
    return path.replaceFirst('Jackalope/', 'Jackalope/$flavorSegment');
  }
  /*Future<String> _getUserPicturesPath(String subDirectory) async {
    // 獲取當前使用者的根目錄
    final String userProfile = Platform.environment['USERPROFILE'] ?? '';

    // 根據根目錄構建圖片目錄路徑
    if (userProfile.isNotEmpty) {
      final String picturesPath = path.join(userProfile, 'Pictures', subDirectory);
      return picturesPath;
    } else {
      throw Exception("Unable to find the user profile directory.");
    }
  }*/

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
  }) async {
    // Check if in debug mode and bypass SharePoint operations
    if (kDebugMode) {
      print("Debug Mode: Bypassing SharePoint operations");
      _simulateDebugProgress(onProgressUpdate, categoryTranslations);
      return;
    }

    // final token = await getAccessToken(refreshToken : "1.AXIAEnOpZTgOx0q5I043N_tALqpoaaYGC7VGvgcUU6orVCfDAFxyAA.AgABAwEAAABVrSpeuWamRam2jAF1XRQEAwDs_wUA9P8tL7d3tSQwcqZlHcX4D-r5OI1gb2KFFQsjfzH2CNsDN6XsmDHkNBb8OC4J_HVjC8SbftdAp6YNHrO6tjMnbKqiTYISkrRQTOVxQBQfxCbMBlvwJcrcbRXKVoIZuWf8EkQimNIAxWVatTT72TfEc1dKs-rpjnEUj4XR6Vjp4Gb4mC2xbXRbp47Y3nTA4VMIQh_12U9ahZsTaA61qZ8BRpxelQ3QTlKSAxOjrG1dF-kavOnV2DmtABXFUb_RPYe-PUKxaBjvqK5_48FtBjoP15f9foS1I-UHo1OSlnampXWzgACrwAkYRziqlbxKKhTja9nJcUXKZlaYZzjVGgwehji6AcQlPcwx-bfWpcNvZSPYOFt4PeYmkNoYQPlwrJElLesXOM3BvDpcn_-nZdJxa7D8wwpqNGWvPTJgg9Q_oPULOD8yvNGQZ76ufYJMWv6MIADhqLEWHlePlCa7ode9oAcTGhZtJd1gstQ7psueCX6-0k1Dv_v-UhZ51um7RrXdfc_H0ueH-0VKZmgaT_aUQ-G-fphWiN_uCw676LSadHBUP-wOwqQXbSdkOLsfKridjHtoouo6QucQZK5X4hWES8ZnKr9th4TjPduAgQ6qcyfpRZoHtCWOzYLA9oyZDiASTMRzvGBUGdlDrqn_08uz3qi7uByX4I9IsvVfyNGTrNfOhZYiK98lvJa_gmv3d5o5hqgYIt_gjHpBlIrvDcug8oHSG-N22QLV7OoGnxnmm215cg2y-UtArNvXuQg0WDmuqC56ANLNPrNnLMH8VcFeeckNkRy099ifcq3rwWsib__iWjiYrtaYUJgi33DtGMMX6_YmprSq0ySmAop-gkIV8w4GpFV1EiGykb7uqsSCQdKmYQoxExdZaCMbA5t0JQTJ0fI0a-_-seK0S1j6lB2Lav10-qqxLZUiVKOpf5kw8fQL6smLK8wXi5n-rCKB7BNfjBuhOYZf_avp63OuG8FHvvBQCP05i42s8W7txrHQqR-CFz8bsr8c7f3M26yRmUlo15sO20qq3wsll0FoVuYdX4k7fovl6dsmUGZAQF3Klb-fXPCG2J6gOXhDCzxoMBz0GEAyYxho1I2QGOb1BxUhfhHvfFEfg2sUNbi0YXMkYQE6cnpEjmz-ByIGyGXqaJfj4HU38hf5qXF2t-1ZCB8h3e7DE9AGj-yrr_Jmi0mdctlcDYppt8NYHdcYdF1mcPvgtpsch3w3nVpyOCJyusk5OjgxAaY8yiqHMB6wEvjsVsg74AoDg6rZlQXNQJ9f1kpjH9Xn26A2rpILsow4R-X5eCHrUzAFpZjF8kMigFyEKPrb4XJKc739DKO51Q36BmoMZ1LhBUrhMcRipBLVQtMSJMX3J_tNH0ua2gKXbp4tX620vam2D4s2mNJx2tG6kqd4krJAFmOd0_OLtCxwtLp9YmjfJWS-v0B_qE7V3eGsWblkqBg2O6FKjQEX18xrMdKHaLT1qKi_vd7C-xLeKIFErpT-SKAqRi15EH_sCIsUo1GwtF6kslI");
    // if (token != null) {
    //   print("Access Token 獲取成功，正在上傳/下載檔案...");
    //   if (uploadOrDownload == 0) { //Upload
    //     await uploadAllPackagingPhotos(token, (current, total) => onProgressUpdate?.call("配件包照片", current, total)!); //上傳所有配件包照片
    //     await uploadAllAttachmentPhotos(token, (current, total) => onProgressUpdate?.call("外觀檢查照片", current, total)); //上傳所有外觀檢查照片
    //     await uploadOQCReport(token, (current, total) => onProgressUpdate?.call("OQC 報告", current, total)); //上傳OQC report
    //     //await uploadSelectedPackagingPhotos(token); // 上傳選擇的配件包照片
    //     //await uploadSelectedAttachmentPhotos(token); // 上傳選擇的外觀檢查照片
    //   } else if (uploadOrDownload == 1) {  //Donwload
    //     await downloadComparePictures(token); // 下載參考照片
    //   } else {
    //     throw Exception("Didn't contain Upload Or Download");
    //   }
    // } else {
    //   print("無法獲取 Access Token");
    // }
    if (uploadOrDownload == 1 && hasDownloaded(model)) {
      return;
    }

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
          final token = await getAccessToken(authCode: authCode);
          if (token != null) {
            print("Access Token 獲取成功，正在上傳/下載檔案...");
            if (uploadOrDownload == 0) {
              await uploadAllPackagingPhotos(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      categoryTranslations['packageing_photo'] ??
                          'Packageing Photo ',
                      current,
                      total));
              await uploadAllAttachmentPhotos(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      categoryTranslations['appearance_photo'] ??
                          'Appearance Photo ',
                      current,
                      total));
              await uploadOQCReport(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      categoryTranslations['oqc_report'] ?? 'OQC Report ',
                      current,
                      total));
              //await uploadSelectedPackagingPhotos(token); // 上傳選擇的配件包照片
              //await uploadSelectedAttachmentPhotos(token); // 上傳選擇的外觀檢查照片
            } else if (uploadOrDownload == 1) {
              await downloadComparePictures(token); // 下載參考照片
            } else if (uploadOrDownload == 2) {
              await downloadPhonePackagingPictures(token); // 下載參考照片
            } else if (uploadOrDownload == 3) {
              await downloadPhoneAttachmentPictures(token); // 下載參考照片
            } else if (uploadOrDownload == 4) {
              await downloadComparePicturesForSpec(token); // 下載外觀檢查參考照片
            } else if (uploadOrDownload == 5) {
              // 上傳參考照片
              await uploadComparePhotos(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      categoryTranslations['compare_photo'] ?? 'Compare Photo ',
                      current,
                      total));
            } else if (uploadOrDownload == 6) {
              // 刪除比對資料夾
              //await deleteModelFolderFromSharePoint(token); // 刪除比對資料夾
              await deleteTwoFoldersFromSharePoint(token); // 刪除比對資料夾
            } else if (uploadOrDownload == 7) {
              await downloadComparePackagePicturesForSpec(token); // 下載配件包參考照片
            } else if (uploadOrDownload == 8) {
              // 上傳配件包參考照片
              await uploadComparePackagePhotos(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      categoryTranslations['compare_photo'] ?? 'Compare Photo ',
                      current,
                      total));
            } else if (uploadOrDownload == 9) {
              await downloadComparePackagePictures(token); // 下載配件包參考照片
            } else if (uploadOrDownload == 10) {
              await deletePackageFolderFromSharePoint(token); // 刪除配件包參考照片
            } else if (uploadOrDownload == 11) {
              await deleteAttachmentFolderFromSharePoint(token); // 刪除外觀參考照片
            } else {
              throw Exception("Didn't contain Upload Or Download");
            }
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

  /// Simulate progress updates for debug mode
  void _simulateDebugProgress(Function(String, int, int)? onProgressUpdate,
      Map<String, String> categoryTranslations) {
    String operation = '';

    switch (uploadOrDownload) {
      case 0: // Upload
        print("Debug Mode: Simulating upload operations for SN: $sn");
        operation =
            categoryTranslations['packageing_photo'] ?? 'Packaging Photo';
        onProgressUpdate?.call(operation, 1, 1);
        operation =
            categoryTranslations['appearance_photo'] ?? 'Appearance Photo';
        onProgressUpdate?.call(operation, 1, 1);
        operation = categoryTranslations['oqc_report'] ?? 'OQC Report';
        onProgressUpdate?.call(operation, 1, 1);
        break;
      case 1: // Download compare pictures
        print(
            "Debug Mode: Simulating download compare pictures for model: $model");
        break;
      case 2: // Download phone packaging pictures
        print(
            "Debug Mode: Simulating download phone packaging pictures for SN: $sn");
        break;
      case 3: // Download phone attachment pictures
        print(
            "Debug Mode: Simulating download phone attachment pictures for SN: $sn");
        break;
      case 4: // Download compare pictures for spec
        print(
            "Debug Mode: Simulating download compare pictures for spec for model: $model");
        break;
      case 5: // Upload compare photos
        print("Debug Mode: Simulating upload compare photos for model: $model");
        operation = categoryTranslations['compare_photo'] ?? 'Compare Photo';
        onProgressUpdate?.call(operation, 1, 1);
        break;
      case 6: // Delete model folder
        print("Debug Mode: Simulating delete model folder for model: $model");
        break;
      case 7: // Download compare package pictures for spec
        print(
            "Debug Mode: Simulating download compare package pictures for spec for model: $model");
        break;
      case 8: // Upload compare package photos
        print(
            "Debug Mode: Simulating upload compare package photos for model: $model");
        operation = categoryTranslations['compare_photo'] ?? 'Compare Photo';
        onProgressUpdate?.call(operation, 1, 1);
        break;
      case 9: // Download compare package pictures
        print(
            "Debug Mode: Simulating download compare package pictures for model: $model");
        break;
      case 10: // Delete package folder
        print("Debug Mode: Simulating delete package folder for model: $model");
        break;
      case 11: // Delete attachment folder
        print(
            "Debug Mode: Simulating delete attachment folder for model: $model");
        break;
      default:
        print("Debug Mode: Unknown operation: $uploadOrDownload");
        break;
    }

    print("Debug Mode: Operation completed successfully");
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
      return data['access_token'];
    } else {
      print("無法獲取 Access Token: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  Future<void> uploadComparePhotos(
      String accessToken, Function(int, int) onProgressUpdate) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String modelFolderPath =
        path.join(zerovaPath, 'Compare Pictures', model);
    final Directory modelDirectory = Directory(modelFolderPath);

    if (!modelDirectory.existsSync()) {
      print("資料夾不存在: $modelFolderPath");
      return;
    }

    final List<File> files = modelDirectory
        .listSync()
        .whereType<File>()
        .where((file) =>
            file.path.toLowerCase().endsWith('.jpg') ||
            file.path.toLowerCase().endsWith('.jpeg') ||
            file.path.toLowerCase().endsWith('.png'))
        .toList();

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $modelFolderPath");
      return;
    }

    // 統計檔案數量
    int totalFiles = files.length;
    int uploadedFiles = 0;
    print("總共需要上傳 $totalFiles 張比對照片");

    for (var file in files) {
      String relativePath = path.relative(file.path, from: zerovaPath);
      // 將相對路徑中的 "Compare Pictures" 替換成 "外觀參考照片"
      relativePath = relativePath.replaceFirst('Compare Pictures', '外觀參考照片');
      final String sharePointPath =
          _buildSharePointPath("Jackalope/$relativePath");

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
            "比對照片上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
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

  Future<void> uploadComparePackagePhotos(
      String accessToken, Function(int, int) onProgressUpdate) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String modelFolderPath =
        path.join(zerovaPath, 'Compare Package Pictures', model);
    final Directory modelDirectory = Directory(modelFolderPath);

    if (!modelDirectory.existsSync()) {
      print("資料夾不存在: $modelFolderPath");
      return;
    }

    final List<File> files = modelDirectory
        .listSync()
        .whereType<File>()
        .where((file) =>
            file.path.toLowerCase().endsWith('.jpg') ||
            file.path.toLowerCase().endsWith('.jpeg') ||
            file.path.toLowerCase().endsWith('.png'))
        .toList();

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $modelFolderPath");
      return;
    }

    // 統計檔案數量
    int totalFiles = files.length;
    int uploadedFiles = 0;
    print("總共需要上傳 $totalFiles 張比對照片");

    for (var file in files) {
      String relativePath = path.relative(file.path, from: zerovaPath);
      // 將相對路徑中的 "Compare Pictures" 替換成 "外觀參考照片"
      relativePath =
          relativePath.replaceFirst('Compare Package Pictures', '配件包參考照片');
      final String sharePointPath =
          _buildSharePointPath("Jackalope/$relativePath");

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
            "比對照片上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
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
      final String sharePointPath =
          _buildSharePointPath("Jackalope/$relativePath");

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
      final String sharePointPath =
          _buildSharePointPath("Jackalope/$relativePath");

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
      final String sharePointPath =
          _buildSharePointPath("Jackalope/$relativePath");

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
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/外觀參考照片/$model")}:/children";

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
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/外觀參考照片/default")}:/children";

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

    // 根據實際使用的 model 建立儲存路徑
    final String directoryPath =
        path.join(zerovaPath, 'Compare Pictures', modelNameUsed);
    final directory = Directory(directoryPath);

    // 清空舊照片（整個資料夾刪掉再重建）
    if (directory.existsSync()) {
      try {
        directory.deleteSync(recursive: true);
        print("已清空舊照片資料夾: $directoryPath");
      } catch (e) {
        print("清空舊照片失敗: $e");
      }
    }
    directory.createSync(recursive: true);

    if (files.isEmpty) {
      print("參考照片資料夾（$modelNameUsed）中沒有檔案");
      return;
    }

    for (var file in files) {
      final fileName = file['name'];
      final downloadUrl = file['@microsoft.graph.downloadUrl'];

      if (downloadUrl != null) {
        int attempt = 0;
        bool success = false;
        while (attempt < 3 && !success) {
          try {
            final fileResponse = await http.get(Uri.parse(downloadUrl));
            if (fileResponse.statusCode == 200) {
              final filePath = "${directory.path}/$fileName";
              final localFile = File(filePath);
              localFile.writeAsBytesSync(fileResponse.bodyBytes);

              print("檔案下載成功: $fileName");
              success = true;
            } else {
              throw Exception("HTTP ${fileResponse.statusCode}");
            }
          } catch (e) {
            attempt++;
            print("檔案下載失敗 (第 $attempt 次重試): $fileName - $e");
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 2)); // 等 2 秒再重試
            }
          }
        }
        if (!success) {
          print("檔案最終下載失敗: $fileName");
        }
      }
    }
    //記錄這個 model 已經下載過
    _downloadedModels.add(model);
  }

  Future<void> downloadComparePackagePictures(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    String modelNameUsed = model; // 預設使用傳入的 model 名稱

    // 建立初始要查詢的 SharePoint 路徑
    String listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/配件包參考照片/$model")}:/children";

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
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/配件包參考照片/default")}:/children";

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

    // 根據實際使用的 model 建立儲存路徑
    final String directoryPath =
        path.join(zerovaPath, 'Compare Package Pictures', modelNameUsed);
    final directory = Directory(directoryPath);

    // 清空舊照片（整個資料夾刪掉再重建）
    if (directory.existsSync()) {
      try {
        directory.deleteSync(recursive: true);
        print("已清空舊照片資料夾: $directoryPath");
      } catch (e) {
        print("清空舊照片失敗: $e");
      }
    }
    directory.createSync(recursive: true);

    if (files.isEmpty) {
      print("參考照片資料夾（$modelNameUsed）中沒有檔案");
      return;
    }

    for (var file in files) {
      final fileName = file['name'];
      final downloadUrl = file['@microsoft.graph.downloadUrl'];

      if (downloadUrl != null) {
        int attempt = 0;
        bool success = false;
        while (attempt < 3 && !success) {
          try {
            final fileResponse = await http.get(Uri.parse(downloadUrl));

            if (fileResponse.statusCode == 200) {
              final filePath = "${directory.path}/$fileName";
              final localFile = File(filePath);
              localFile.writeAsBytesSync(fileResponse.bodyBytes);
              print("檔案下載成功: $fileName");
              success = true;
            } else {
              throw Exception("HTTP ${fileResponse.statusCode}");
            }
          } catch (e) {
            attempt++;
            print("檔案下載失敗 (第 $attempt 次重試): $fileName - $e");
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 2)); // 等 2 秒再重試
            }
          }
        }
        if (!success) {
          print("檔案最終下載失敗: $fileName");
        }
      }
    }
    //記錄這個 model 已經下載過
    _downloadedModels.add(model);
  }

  Future<void> downloadComparePicturesForSpec(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    String modelNameUsed = model; // 預設使用傳入的 model 名稱

    // 建立初始要查詢的 SharePoint 路徑
    String listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/外觀參考照片/$model")}:/children";

    // 發送查詢請求
    var response = await http.get(
      Uri.parse(listFilesUrl),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode != 200) {
      print("找不到目錄 $model");
      return;
    }

    // 成功取得檔案清單
    final data = json.decode(response.body);
    final List files = data['value'];

    // 根據實際使用的 model 建立儲存路徑
    final String directoryPath =
        path.join(zerovaPath, 'Compare Pictures', modelNameUsed);
    final directory = Directory(directoryPath);

    // 清空舊照片（整個資料夾刪掉再重建）
    if (directory.existsSync()) {
      try {
        directory.deleteSync(recursive: true);
        print("已清空舊照片資料夾: $directoryPath");
      } catch (e) {
        print("清空舊照片失敗: $e");
      }
    }
    directory.createSync(recursive: true);

    if (files.isEmpty) {
      print("參考照片資料夾（$modelNameUsed）中沒有檔案");
      return;
    }

    for (var file in files) {
      final fileName = file['name'];
      final downloadUrl = file['@microsoft.graph.downloadUrl'];

      if (downloadUrl != null) {
        int attempt = 0;
        bool success = false;
        while (attempt < 3 && !success) {
          try {
            final fileResponse = await http.get(Uri.parse(downloadUrl));
            if (fileResponse.statusCode == 200) {
              final filePath = "${directory.path}/$fileName";
              final localFile = File(filePath);
              localFile.writeAsBytesSync(fileResponse.bodyBytes);

              print("檔案下載成功: $fileName");
              success = true;
            } else {
              throw Exception("HTTP ${fileResponse.statusCode}");
            }
          } catch (e) {
            attempt++;
            print("檔案下載失敗 (第 $attempt 次重試): $fileName - $e");
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 2)); // 等 2 秒再重試
            }
          }
        }
        if (!success) {
          print("檔案最終下載失敗: $fileName");
        }
      }
    }
  }

  Future<void> downloadComparePackagePicturesForSpec(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    String modelNameUsed = model; // 預設使用傳入的 model 名稱

    // 建立初始要查詢的 SharePoint 路徑
    String listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/配件包參考照片/$model")}:/children";

    // 發送查詢請求
    var response = await http.get(
      Uri.parse(listFilesUrl),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode != 200) {
      print("找不到目錄 $model");
      return;
    }

    // 成功取得檔案清單
    final data = json.decode(response.body);
    final List files = data['value'];

    // 根據實際使用的 model 建立儲存路徑
    final String directoryPath =
        path.join(zerovaPath, 'Compare Package Pictures', modelNameUsed);
    final directory = Directory(directoryPath);

    // 清空舊照片（整個資料夾刪掉再重建）
    if (directory.existsSync()) {
      try {
        directory.deleteSync(recursive: true);
        print("已清空舊照片資料夾: $directoryPath");
      } catch (e) {
        print("清空舊照片失敗: $e");
      }
    }
    directory.createSync(recursive: true);

    if (files.isEmpty) {
      print("參考照片資料夾（$modelNameUsed）中沒有檔案");
      return;
    }

    for (var file in files) {
      final fileName = file['name'];
      final downloadUrl = file['@microsoft.graph.downloadUrl'];

      if (downloadUrl != null) {
        int attempt = 0;
        bool success = false;
        while (attempt < 3 && !success) {
          try {
            final fileResponse = await http.get(Uri.parse(downloadUrl));
            if (fileResponse.statusCode == 200) {
              final filePath = "${directory.path}/$fileName";
              final localFile = File(filePath);
              localFile.writeAsBytesSync(fileResponse.bodyBytes);

              print("檔案下載成功: $fileName");
              success = true;
            } else {
              throw Exception("HTTP ${fileResponse.statusCode}");
            }
          } catch (e) {
            attempt++;
            print("檔案下載失敗 (第 $attempt 次重試): $fileName - $e");
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 2)); // 等 2 秒再重試
            }
          }
        }
        if (!success) {
          print("檔案最終下載失敗: $fileName");
        }
      }
    }
  }

  Future<void> downloadPhoneAttachmentPictures(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String directoryPath =
        path.join(zerovaPath, 'All Photos/$sn/Attachment');
    final listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/Photos/$sn/Attachment")}:/children";

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
          int attempt = 0;
          bool success = false;
          while (attempt < 3 && !success) {
            try {
              final fileResponse = await http.get(Uri.parse(downloadUrl));
              if (fileResponse.statusCode == 200) {
                final filePath = "${directory.path}/$fileName";
                final localFile = File(filePath);
                localFile.writeAsBytesSync(fileResponse.bodyBytes);

                print("檔案下載成功: $fileName");
                success = true;
              } else {
                throw Exception("HTTP ${fileResponse.statusCode}");
              }
            } catch (e) {
              attempt++;
              print("檔案下載失敗 (第 $attempt 次重試): $fileName - $e");
              if (attempt < 3) {
                await Future.delayed(Duration(seconds: 2)); // 等 2 秒再重試
              }
            }
          }
          if (!success) {
            print("檔案最終下載失敗: $fileName");
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
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/${_buildSharePointPath("Jackalope/Photos/$sn/Packaging")}:/children";

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
          int attempt = 0;
          bool success = false;
          while (attempt < 3 && !success) {
            try {
              final fileResponse = await http.get(Uri.parse(downloadUrl));
              if (fileResponse.statusCode == 200) {
                final filePath = "${directory.path}/$fileName";
                final localFile = File(filePath);
                localFile.writeAsBytesSync(fileResponse.bodyBytes);

                print("檔案下載成功: $fileName");
                success = true;
              } else {
                throw Exception("HTTP ${fileResponse.statusCode}");
              }
            } catch (e) {
              attempt++;
              print("檔案下載失敗 (第 $attempt 次重試): $fileName - $e");
              if (attempt < 3) {
                await Future.delayed(Duration(seconds: 2)); // 等 2 秒再重試
              }
            }
          }
          if (!success) {
            print("檔案最終下載失敗: $fileName");
          }
        }
      }
    } else {
      print("無法取得檔案清單: ${response.statusCode} ${response.body}");
    }
  }

  Future<void> deleteFilesFromSharePoint(
      String accessToken, List<String> deletedFiles) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();

    for (var localFilePath in deletedFiles) {
      // 把本機完整路徑轉成 SharePoint 路徑
      String relativePath = path.relative(localFilePath, from: zerovaPath);

      // 將路徑中的 "Compare Pictures" 替換成 "外觀參考照片"
      relativePath = relativePath.replaceFirst('Compare Pictures', '外觀參考照片');

      final String sharePointPath =
          _buildSharePointPath("Jackalope/$relativePath");

      final String deleteUrl =
          "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/$sharePointPath";

      try {
        final response = await http.delete(
          Uri.parse(deleteUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        );

        if (response.statusCode == 204) {
          print("檔案刪除成功: $sharePointPath");
        } else if (response.statusCode == 404) {
          print("檔案不存在（無法刪除）: $sharePointPath");
        } else {
          print(
              "檔案刪除失敗: $sharePointPath - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("刪除檔案發生錯誤: $sharePointPath - $e");
      }
    }
  }

  Future<void> deleteTwoFoldersFromSharePoint(String accessToken) async {
    final String folderPath1 = _buildSharePointPath("Jackalope/外觀參考照片/$model");
    final String folderPath2 = _buildSharePointPath("Jackalope/配件包參考照片/$model");

    final String batchUrl = "https://graph.microsoft.com/v1.0/\$batch";

    final body = {
      "requests": [
        {
          "id": "1",
          "method": "DELETE",
          "url": "/sites/$siteId/drives/$driveId/items/root:/$folderPath1"
        },
        {
          "id": "2",
          "method": "DELETE",
          "url": "/sites/$siteId/drives/$driveId/items/root:/$folderPath2"
        }
      ]
    };

    int attempt = 0;
    bool success = false;
    while (attempt < 3 && !success) {
      try {
        final response = await http.post(
          Uri.parse(batchUrl),
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          success = true;
          print("批量刪除請求已發送");
          print(response.body); // 會有兩個 DELETE 的結果
        } else {
          attempt++;
          print(
              "批量刪除失敗 (第 $attempt 次重試): ${response.statusCode} ${response.body}");
          if (attempt < 3) await Future.delayed(Duration(seconds: 2));
        }
      } catch (e) {
        attempt++;
        print("批量刪除發生錯誤 (第 $attempt 次重試): $e");
        if (attempt < 3) await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  Future<void> deletePackageFolderFromSharePoint(String accessToken) async {
    final String folderPath = _buildSharePointPath("Jackalope/配件包參考照片/$model");

    // Step 1: 從 SharedPreferences 撈刪除清單
    final prefs = await SharedPreferences.getInstance();
    List<String> fileNamesToDelete =
        prefs.getStringList("deleted_package_photos") ?? [];

    if (fileNamesToDelete.isEmpty) {
      print("SharedPreferences 沒有要刪的檔案清單");
      return;
    }

    // Step 2: 列出資料夾內檔案
    final String listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/$folderPath:/children";

    try {
      final listResponse = await http.get(
        Uri.parse(listFilesUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );

      if (listResponse.statusCode != 200) {
        print("取得資料夾檔案清單失敗: ${listResponse.statusCode} ${listResponse.body}");
        return;
      }

      final data = jsonDecode(listResponse.body);
      final List items = data['value'];

      if (items.isEmpty) {
        print("資料夾內沒有檔案: $folderPath");
        // 清空清單避免下次重複
        await prefs.remove("deleted_package_photos");
        return;
      }

      // Step 3: 篩選要刪除的檔案 ID（防呆：檔案不存在就移除）
      final List<String> fileIdsToDelete = [];
      final List<String> actuallyDeletedFileNames = [];

      for (var fileName in List<String>.from(fileNamesToDelete)) {
        final fileItem = items.firstWhere(
          (item) => item['name'] == fileName,
          orElse: () => null,
        );

        if (fileItem != null) {
          fileIdsToDelete.add(fileItem['id']);
          actuallyDeletedFileNames.add(fileName);
        } else {
          print("找不到檔案，跳過: $fileName");
          fileNamesToDelete.remove(fileName); // 從清單移除不存在的檔案
        }
      }

      if (fileIdsToDelete.isEmpty) {
        print("沒有符合條件的檔案可刪除");
        await prefs.setStringList("deleted_package_photos", fileNamesToDelete);
        return;
      }

      // Step 4: 分批（每批最多 20 個檔案）
      for (var i = 0; i < fileIdsToDelete.length; i += 20) {
        final batch = fileIdsToDelete.skip(i).take(20).toList();
        final batchRequests = {
          "requests": List.generate(batch.length, (index) {
            return {
              "id": "${i + index}",
              "method": "DELETE",
              "url": "/sites/$siteId/drives/$driveId/items/${batch[index]}"
            };
          }),
        };

        // ===== 批次重試機制 =====
        int attempt = 0;
        bool success = false;
        while (attempt < 3 && !success) {
          final batchResponse = await http.post(
            Uri.parse("https://graph.microsoft.com/v1.0/\$batch"),
            headers: {
              "Authorization": "Bearer $accessToken",
              "Content-Type": "application/json",
            },
            body: jsonEncode(batchRequests),
          );

          if (batchResponse.statusCode == 200) {
            success = true;
            print("批次刪除完成: 第 ${i ~/ 20 + 1} 批");
          } else {
            attempt++;
            print(
                "批次刪除失敗 (第 $attempt 次重試): ${batchResponse.statusCode} ${batchResponse.body}");
            if (attempt < 3)
              await Future.delayed(Duration(seconds: 2)); // =====  重試等待 =====
          }
        }
        if (!success) {
          print("批次刪除最終失敗: 第 ${i ~/ 20 + 1} 批"); // ===== 改動 3: 最終失敗 log =====
        }
      }

      // Step 5: 刪除已處理過的檔案紀錄
      fileNamesToDelete
          .removeWhere((name) => actuallyDeletedFileNames.contains(name));

      if (fileNamesToDelete.isEmpty) {
        await prefs.remove("deleted_package_photos");
        print("SharedPreferences 刪除清單已清空");
      } else {
        await prefs.setStringList("deleted_package_photos", fileNamesToDelete);
        print("更新 SharedPreferences 清單，剩餘未刪檔案: $fileNamesToDelete");
      }
    } catch (e) {
      print("刪除資料夾內檔案時發生錯誤: $folderPath - $e");
    }
  }

  Future<void> deleteAttachmentFolderFromSharePoint(String accessToken) async {
    final String folderPath = _buildSharePointPath("Jackalope/外觀參考照片/$model");

    // Step 1: 從 SharedPreferences 撈刪除清單
    final prefs = await SharedPreferences.getInstance();
    List<String> fileNamesToDelete =
        prefs.getStringList("deleted_attachment_photos") ?? [];

    if (fileNamesToDelete.isEmpty) {
      print("SharedPreferences 沒有要刪的檔案清單");
      return;
    }

    // Step 2: 列出資料夾內檔案
    final String listFilesUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/root:/$folderPath:/children";

    try {
      final listResponse = await http.get(
        Uri.parse(listFilesUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );

      if (listResponse.statusCode != 200) {
        print("取得資料夾檔案清單失敗: ${listResponse.statusCode} ${listResponse.body}");
        return;
      }

      final data = jsonDecode(listResponse.body);
      final List items = data['value'];

      if (items.isEmpty) {
        print("資料夾內沒有檔案: $folderPath");
        // 清空清單避免下次重複
        await prefs.remove("deleted_attachment_photos");
        return;
      }

      // Step 3: 篩選要刪除的檔案 ID（防呆：檔案不存在就移除）
      final List<String> fileIdsToDelete = [];
      final List<String> actuallyDeletedFileNames = [];

      for (var fileName in List<String>.from(fileNamesToDelete)) {
        final fileItem = items.firstWhere(
          (item) => item['name'] == fileName,
          orElse: () => null,
        );

        if (fileItem != null) {
          fileIdsToDelete.add(fileItem['id']);
          actuallyDeletedFileNames.add(fileName);
        } else {
          print("找不到檔案，跳過: $fileName");
          fileNamesToDelete.remove(fileName); // 從清單移除不存在的檔案
        }
      }

      if (fileIdsToDelete.isEmpty) {
        print("沒有符合條件的檔案可刪除");
        await prefs.setStringList(
            "deleted_attachment_photos", fileNamesToDelete);
        return;
      }

      // Step 4: 分批（每批最多 20 個檔案）
      for (var i = 0; i < fileIdsToDelete.length; i += 20) {
        final batch = fileIdsToDelete.skip(i).take(20).toList();
        final batchRequests = {
          "requests": List.generate(batch.length, (index) {
            return {
              "id": "${i + index}",
              "method": "DELETE",
              "url": "/sites/$siteId/drives/$driveId/items/${batch[index]}"
            };
          }),
        };
        // ===== 批次重試機制 =====
        int attempt = 0;
        bool success = false;
        while (attempt < 3 && !success) {
          final batchResponse = await http.post(
            Uri.parse("https://graph.microsoft.com/v1.0/\$batch"),
            headers: {
              "Authorization": "Bearer $accessToken",
              "Content-Type": "application/json",
            },
            body: jsonEncode(batchRequests),
          );

          if (batchResponse.statusCode == 200) {
            success = true;
            print("批次刪除完成: 第 ${i ~/ 20 + 1} 批");
          } else {
            attempt++;
            print(
                "批次刪除失敗 (第 $attempt 次重試): ${batchResponse.statusCode} ${batchResponse.body}");
            if (attempt < 3)
              await Future.delayed(Duration(seconds: 2)); // ===== 重試等待 =====
          }
        }
        if (!success) {
          print("批次刪除最終失敗: 第 ${i ~/ 20 + 1} 批"); // ===== 最終失敗 log =====
        }
      }

      // Step 5: 刪除已處理過的檔案紀錄
      fileNamesToDelete
          .removeWhere((name) => actuallyDeletedFileNames.contains(name));

      if (fileNamesToDelete.isEmpty) {
        await prefs.remove("deleted_attachment_photos");
        print("SharedPreferences 刪除清單已清空");
      } else {
        await prefs.setStringList(
            "deleted_attachment_photos", fileNamesToDelete);
        print("更新 SharedPreferences 清單，剩餘未刪檔案: $fileNamesToDelete");
      }
    } catch (e) {
      print("刪除資料夾內檔案時發生錯誤: $folderPath - $e");
    }
  }

  Future<void> deleteModelFolderFromSharePoint(String accessToken) async {
    final String folderPath = _buildSharePointPath("Jackalope/外觀參考照片/$model");

    final String deleteUrl =
        "https://graph.microsoft.com/v1.0/sites/$siteId/drives/$driveId/items/root:/$folderPath";

    try {
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );

      if (response.statusCode == 204) {
        print("資料夾刪除成功: $folderPath");
      } else if (response.statusCode == 404) {
        print("資料夾不存在（無法刪除）: $folderPath");
      } else {
        print("資料夾刪除失敗: $folderPath - ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("刪除資料夾發生錯誤: $folderPath - $e");
    }
  }
/*
  Future<void> uploadSelectedPackagingPhotos(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String snFolderPath = path.join(zerovaPath, 'Selected Photos', SN);
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
      if (packagingDirectory.existsSync()) ...packagingDirectory.listSync(recursive: true).whereType<File>(), // Packaging 內的檔案
    ];

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $snFolderPath");
      return;
    }

    for (var file in files) {
      final String relativePath = path.relative(file.path, from: zerovaPath);
      final String sharePointPath = _buildSharePointPath("Jackalope/$relativePath");

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

        if (response.statusCode == 201) {
          print("檔案上傳成功: $relativePath");
        } else {
          print("檔案上傳失敗: $relativePath - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $relativePath - $e");
      }
    }
  }
  Future<void> uploadSelectedAttachmentPhotos(String accessToken) async {
    final String zerovaPath = await _getOrCreateUserZerovaPath();
    final String snFolderPath = path.join(zerovaPath, 'Selected Photos', SN);
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
      if (attachmentDirectory.existsSync()) ...attachmentDirectory.listSync(recursive: true).whereType<File>(), // Attachment 內的檔案
    ];

    if (files.isEmpty) {
      print("資料夾中沒有檔案: $snFolderPath");
      return;
    }

    for (var file in files) {
      final String relativePath = path.relative(file.path, from: zerovaPath);
      final String sharePointPath = _buildSharePointPath("Jackalope/$relativePath");

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

        if (response.statusCode == 201) {
          print("檔案上傳成功: $relativePath");
        } else {
          print("檔案上傳失敗: $relativePath - ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("檔案上傳失敗: $relativePath - $e");
      }
    }
  }
*/
}
