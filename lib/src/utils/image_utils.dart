import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;

class ImageUtils {
  /// 从目录加载并分组图片
  static Future<List<pw.Widget>> loadAndGroupImages(String directoryPath,
      {int imagesPerRow = 5, double imageHeight = 200}) async {
    try {
      final directory = Directory(directoryPath);
      final images = <pw.Widget>[];

      if (await directory.exists()) {
        final imageFiles = directory
            .listSync()
            .where((file) =>
                file.path.toLowerCase().endsWith('.jpg') ||
                file.path.toLowerCase().endsWith('.jpeg') ||
                file.path.toLowerCase().endsWith('.png'))
            .toList();

        // 将图片分组
        for (var i = 0; i < (imageFiles.length / imagesPerRow).ceil(); i++) {
          final rowImages = <pw.Widget>[];
          for (var j = 0;
              j < imagesPerRow && i * imagesPerRow + j < imageFiles.length;
              j++) {
            final image =
                await imageFromPath(imageFiles[i * imagesPerRow + j].path);
            if (image != null) {
              rowImages.add(
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(5),
                    height: imageHeight,
                    child: pw.Image(
                      image,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              );
            }
          }
          if (rowImages.isNotEmpty) {
            images.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: rowImages,
              ),
            );
          }
        }
      }
      return images;
    } catch (e) {
      print('Error loading images: $e');
      return [];
    }
  }

  /// 从文件路径加载图片
  static Future<pw.ImageProvider?> imageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return null;
  }
}
