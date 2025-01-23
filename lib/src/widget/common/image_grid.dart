import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/image_preview_dialog.dart';

class ImageGrid extends StatefulWidget {
  final String imagePath;
  final int rows;
  final int columns;
  final double cellHeight;

  const ImageGrid({
    super.key,
    required this.imagePath,
    this.rows = 2,
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

  void _loadImages() {
    final directory = Directory(widget.imagePath);
    if (directory.existsSync()) {
      final files = directory.listSync()
          .where((file) => file.path.toLowerCase().endsWith('.jpg') || 
                          file.path.toLowerCase().endsWith('.jpeg') || 
                          file.path.toLowerCase().endsWith('.png'))
          .map((file) => file.path)
          .take(widget.rows * widget.columns)
          .toList();
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
    return Table(
      border: TableBorder.all(),
      children: List.generate(
        widget.rows,
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
                    child: Image.file(
                      File(_imagePaths[index]),
                      fit: BoxFit.contain,
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