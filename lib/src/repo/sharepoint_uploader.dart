import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import '../config/config_manager.dart';

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

  SharePointUploader({required this.uploadOrDownload, required this.sn});
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

  Future<void> startAuthorization(
      {Function(String, int, int)? onProgressUpdate}) async {
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
              //Upload
              await uploadAllPackagingPhotos(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      "配件包照片", current, total)!); //上傳所有配件包照片
              await uploadAllAttachmentPhotos(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      "外觀檢查照片", current, total)); //上傳所有外觀檢查照片
              await uploadOQCReport(
                  token,
                  (current, total) => onProgressUpdate?.call(
                      "OQC 報告", current, total)); //上傳OQC report
              //await uploadSelectedPackagingPhotos(token); // 上傳選擇的配件包照片
              //await uploadSelectedAttachmentPhotos(token); // 上傳選擇的外觀檢查照片
            } else if (uploadOrDownload == 1) {
              //Donwload
              await downloadComparePictures(token); // 下載參考照片
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
    final String directoryPath = path.join(zerovaPath, 'Compare Pictures');
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
