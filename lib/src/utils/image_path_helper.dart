import 'dart:io';
import 'package:path/path.dart' as path;

mixin ImagePageHelper {
  Future<String> getOrCreateUserZerovaPath() async {
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

  Future<String> getUserComparePath(String model) async {
    final String picturesPath = await getOrCreateUserZerovaPath();

    // 先嘗試用 model 建立路徑
    String comparePath = path.join(picturesPath, 'Compare Pictures', model);
    final directory = Directory(comparePath);

    // 如果資料夾不存在，改用 default
    if (!await directory.exists()) {
      print("找不到 $model 資料夾，改用 default");
      comparePath = path.join(picturesPath, 'Compare Pictures', 'default');
      final defaultDir = Directory(comparePath);
      if (!await defaultDir.exists()) {
        // 如果 default 也不存在，則建立 default 資料夾
        await defaultDir.create(recursive: true);
      }
    }

    return comparePath;
  }
  /*Future<String> getUserComparePath() async {
    final String picturesPath = await getOrCreateUserZerovaPath();
    final String comparePath = path.join(picturesPath, 'Compare Pictures');

    // 檢查資料夾是否存在，若不存在則建立
    final directory = Directory(comparePath);
    if (!await directory.exists()) {
      await directory.create(
          recursive: true); // recursive 為 true 會自動建立所有必要的父資料夾
    }

    return comparePath;
  }*/
  Future<String> getUserAllPhotosPackagingPath(String sn) async {
    final String picturesPath = await getOrCreateUserZerovaPath();
    final String allPhotosPackagingPath =
    path.join(picturesPath, 'All Photos', sn, 'Packaging');

    // 檢查資料夾是否存在，若不存在則建立
    final directory = Directory(allPhotosPackagingPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return allPhotosPackagingPath;
  }

  Future<String> getUserAllPhotosAttachmentPath(String sn) async {
    final String picturesPath = await getOrCreateUserZerovaPath();
    final String allPhotosAttachmentPath =
    path.join(picturesPath, 'All Photos', sn, 'Attachment');

    // 檢查資料夾是否存在，若不存在則建立
    final directory = Directory(allPhotosAttachmentPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return allPhotosAttachmentPath;
  }

  Future<String> getUserSelectedPhotosPackagingPath(String sn) async {
    final String picturesPath = await getOrCreateUserZerovaPath();
    final String selectedPhotosPackagingPath =
    path.join(picturesPath, 'Selected Photos', sn, 'Packaging');

    // 檢查資料夾是否存在，若不存在則建立
    final directory = Directory(selectedPhotosPackagingPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return selectedPhotosPackagingPath;
  }

  Future<String> getUserSelectedPhotosAttachmentPath(String sn) async {
    final String picturesPath = await getOrCreateUserZerovaPath();
    final String selectedPhotosAttachmentPath =
    path.join(picturesPath, 'Selected Photos', sn, 'Attachment');

    // 檢查資料夾是否存在，若不存在則建立
    final directory = Directory(selectedPhotosAttachmentPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return selectedPhotosAttachmentPath;
  }
}
