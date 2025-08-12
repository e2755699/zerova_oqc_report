import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/utils/image_path_helper.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

class ImagePickerPageNew extends StatefulWidget {
  final int packagingOrAttachment;
  final String sn;

  const ImagePickerPageNew({
    super.key,
    required this.packagingOrAttachment,
    required this.sn,
  });

  @override
  State<ImagePickerPageNew> createState() => _ImagePickerPageNewState();
}

class _ImagePickerPageNewState extends State<ImagePickerPageNew>
    with ImagePageHelper {
  List<String> _imagePaths = [];
  List<bool> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _initializeImages();
  }

  Future<void> _initializeImages() async {
    await _loadImages(); // 確保圖片加載完成
    setState(() {});
  }

  Future<void> _loadImages() async {
    try {
      final String picturesPath;

      if (widget.packagingOrAttachment == 0) {
        // Packaging
        picturesPath = await getUserAllPhotosPackagingPath(widget.sn);
      } else if (widget.packagingOrAttachment == 1) {
        // Attachment
        picturesPath = await getUserAllPhotosAttachmentPath(widget.sn);
      } else {
        throw Exception("Didn't contain Packaging Or Attachment");
      }
      final directory = Directory(picturesPath);

      if (!directory.existsSync()) {
        _showError("Directory does not exist: ${directory.path}");
        return;
      }

      final files = directory.listSync();
      final imagePaths = <String>[];

      for (var file in files) {
        if (file is File && _isImage(file)) {
          imagePaths.add(file.path);
        }
      }

      setState(() {
        _imagePaths = imagePaths;
        _selectedImages = List.generate(imagePaths.length, (_) => false);
      });
    } catch (e) {
      _showError("Error loading images: $e");
    }
  }

  bool _isImage(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
  }

  Future<void> _saveSelectedImages() async {
    final String saveImagesPath;

    if (widget.packagingOrAttachment == 0) {
      // Packaging
      saveImagesPath = await getUserSelectedPhotosPackagingPath(widget.sn);
    } else if (widget.packagingOrAttachment == 1) {
      // Attachment
      saveImagesPath = await getUserSelectedPhotosAttachmentPath(widget.sn);
    } else {
      throw Exception("Didn't contain Packaging Or Attachment");
    }

    final targetDirectory = Directory(saveImagesPath);

    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    for (int i = 0; i < _selectedImages.length; i++) {
      if (_selectedImages[i]) {
        final selectedFile = File(_imagePaths[i]);
        final fileName = selectedFile.uri.pathSegments.last;
        final targetFile = File('${targetDirectory.path}\\$fileName');
        await selectedFile.copy(targetFile.path);
        print('Image saved: ${targetFile.path}');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('images_saved'))),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: context.tr('select_image'),
      body: Center(
        child: _imagePaths.isEmpty
            ? const CircularProgressIndicator()
            : SizedBox(
          width: MediaQuery.of(context).size.width, // 填滿寬度
          height: MediaQuery.of(context).size.height, // 填滿高度
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return _imagePaths.isNotEmpty
                  ? GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 每行顯示 5 張圖片
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _imagePaths.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      //print('點了圖片，準備傳回: ${_imagePaths[index]}');
                      Navigator.pop(context, _imagePaths[index]);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(_imagePaths[index]),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                          const Icon(Icons.error),
                        ),
                        /*Positioned(
                          top: 8,
                          right: 8,
                          child: Checkbox(
                            value: _selectedImages[index],
                            onChanged: (bool? value) {
                              dialogSetState(() {
                                _selectedImages[index] = value!;
                              });
                              setState(() {}); // 確保外部狀態也更新
                            },
                          ),
                        ),*/
                      ],
                    ),
                  );
                },
              )
                  : Center(
                child: Text(context.tr('no_images_found')),
              );
            },
          ),
        ),
      ),
      /*floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'select_all',
            onPressed: () {
              setState(() {
                _selectedImages = List<bool>.filled(_selectedImages.length, true);
              });
            },
            icon: const Icon(Icons.select_all),
            label: Text(context.tr('select_all')),
            backgroundColor: AppColors.fabColor,
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'deselect_all',
            onPressed: () {
              setState(() {
                _selectedImages = List<bool>.filled(_selectedImages.length, false);
              });
            },
            icon: const Icon(Icons.deselect),
            label: Text(context.tr('deselect_all')),
            backgroundColor: AppColors.fabColor,
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'save_selected',
            onPressed: () async {
              await _saveSelectedImages(); // 儲存所選影像
              Navigator.of(context).pop(); // 返回前一頁
            },
            icon: const Icon(Icons.save),
            label: Text(context.tr('save_selected_images')),
            backgroundColor: AppColors.fabColor,
          ),
        ],
      ),*/

    );
  }
}
