import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

class ImageUtils {
  /// 从目录加载并分组图片
  static Future<List<pw.Widget>> loadAndGroupImages(String directoryPath,
      {int imagesPerRow = 2, double imageHeight = 200}) async {
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

        // 计算总行数
        final totalRows = (imageFiles.length / imagesPerRow).ceil();

        // 创建表格行
        for (var i = 0; i < totalRows; i++) {
          final tableCells = <pw.Widget>[];

          // 填充每一行的单元格
          for (var j = 0; j < imagesPerRow; j++) {
            final imageIndex = i * imagesPerRow + j;

            if (imageIndex < imageFiles.length) {
              // 有图片的单元格
              final image = await imageFromPath(imageFiles[imageIndex].path);
              if (image != null) {
                tableCells.add(
                  pw.Expanded(
                    child: pw.Container(
                      height: imageHeight,
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Image(
                        image,
                        // Use contain to preserve aspect ratio and avoid cropping
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                );
              }
            } else {
              // 空白单元格填充
              tableCells.add(
                pw.Expanded(
                  child: pw.Container(
                    height: imageHeight,
                    padding: const pw.EdgeInsets.all(5),
                  ),
                ),
              );
            }
          }

          // 将行添加到表格中
          if (tableCells.isNotEmpty) {
            images.add(
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: tableCells,
                  ),
                ],
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
