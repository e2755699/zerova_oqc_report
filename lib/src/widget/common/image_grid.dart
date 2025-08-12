import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/image_preview_dialog.dart';
import 'package:path/path.dart' as path;

class ImageGrid extends StatefulWidget {
  final String imagePath;
  final int columns;
  final double cellHeight;

  const ImageGrid({
    super.key,
    required this.imagePath,
    this.columns = 4,
    this.cellHeight = 100,
  });

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  final List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  didUpdateWidget(ImageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadImages();
  }

  Future<String> _getPicturesPath() async {
    if (Platform.isMacOS) {
      // macOS 路徑
      return path.join(
          Platform.environment['HOME'] ?? '', 'Pictures', 'Zerova');
    } else if (Platform.isWindows) {
      // Windows 路徑
      return path.join(
          Platform.environment['USERPROFILE'] ?? '', 'Pictures', 'Zerova');
    } else {
      // 其他系統（如 Linux）
      return path.join(
          Platform.environment['HOME'] ?? '', 'Pictures', 'Zerova');
    }
  }

  void _loadImages() async {
    setState(() {
      _imagePaths.clear();
    });
    final picturesPath = await _getPicturesPath();
    final directory = Directory(path.join(picturesPath, widget.imagePath));

    if (directory.existsSync()) {
      final files = directory
          .listSync()
          .where((file) =>
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg') ||
              file.path.toLowerCase().endsWith('.png'))
          .map((file) => file.path)
          .toList();

      // 🖨️ 偵錯輸出：列出所有找到的檔案路徑
      //print("📂 掃描資料夾: ${directory.path}");
      if (files.isEmpty) {
        //print("⚠️ 沒有找到任何圖片檔案");
      } else {
        for (var f in files) {
          //print("✅ 找到圖片: $f");
        }
      }

      setState(() {
        _imagePaths.clear();
        _imagePaths.addAll(files);
      });
    }
  }

  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewDialog(imagePath: imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    var rows = _imagePaths.isNotEmpty
        ? (_imagePaths.length / widget.columns).ceil()
        : 2;
    return Table(
      border: TableBorder.all(),
      children: List.generate(
        rows,
        (rowIndex) => TableRow(
          children: List.generate(
            widget.columns,
            (colIndex) {
              final index = rowIndex * widget.columns + colIndex;
              if (index < _imagePaths.length) {
                return GestureDetector(
                  onTap: () => _showImagePreview(_imagePaths[index]),
                  child: Container(
                    height: widget.cellHeight,
                    padding: const EdgeInsets.all(8),
                    child: Builder(
                      builder: (context) {
                        final filePath = _imagePaths[index];
                        //print("📷 嘗試載入圖片: $filePath");
                        return Image.file(
                          File(filePath),
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),

                );
              }
              return SizedBox(height: widget.cellHeight);
            },
          ),
        ),
      ),
    );
  }
}
