import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> startAuthorization({Function(String, int, int)? onProgressUpdate}) async {
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
            if (uploadOrDownload == 0) { //Upload
              await uploadAllPackagingPhotos(token, (current, total) => onProgressUpdate?.call("配件包照片", current, total)!); //上傳所有配件包照片
              await uploadAllAttachmentPhotos(token, (current, total) => onProgressUpdate?.call("外觀檢查照片", current, total)); //上傳所有外觀檢查照片
              await uploadOQCReport(token, (current, total) => onProgressUpdate?.call("OQC 報告", current, total)); //上傳OQC report
              //await uploadSelectedPackagingPhotos(token); // 上傳選擇的配件包照片
              //await uploadSelectedAttachmentPhotos(token); // 上傳選擇的外觀檢查照片
            } else if (uploadOrDownload == 1) {  //Donwload
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

  Future<void> uploadAllPackagingPhotos(String accessToken, Function(int, int) onProgressUpdate) async {
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
      if (packagingDirectory.existsSync()) ...packagingDirectory.listSync(recursive: true).whereType<File>(), // Packaging 內的檔案
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
        print("配件包照片上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
        uploadedFiles++;
        onProgressUpdate(uploadedFiles, totalFiles);

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
  Future<void> uploadAllAttachmentPhotos(String accessToken, Function(int, int) onProgressUpdate) async {
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
      if (attachmentDirectory.existsSync()) ...attachmentDirectory.listSync(recursive: true).whereType<File>(), // Attachment 內的檔案
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
        print("外觀檢查照片上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
        uploadedFiles++;
        onProgressUpdate(uploadedFiles, totalFiles);

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
  Future<void> uploadOQCReport(String accessToken, Function(int, int) onProgressUpdate) async {
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
        print("OQC Report上傳進度: ${uploadedFiles + 1}/$totalFiles (${progress.toStringAsFixed(2)}%)");
        uploadedFiles++;
        onProgressUpdate(uploadedFiles, totalFiles);

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
