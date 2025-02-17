import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/utils/image_path_helper.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

class ImagePickerPage extends StatefulWidget {
  final int packagingOrAttachment;
  final String sn;

  const ImagePickerPage({
    super.key,
    required this.packagingOrAttachment,
    required this.sn,
  });

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage>
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
      const SnackBar(content: Text('Selected images have been saved!')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Select Multiple Images',
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
                                  dialogSetState(() {
                                    _selectedImages[index] =
                                        !_selectedImages[index];
                                  });
                                  setState(() {}); // 確保外部狀態也更新
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
                                    Positioned(
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
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                                'No images found in the specified directory.'),
                            //child: CircularProgressIndicator(), // 顯示加載中的進度條
                          );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _saveSelectedImages(); // 儲存所選影像
          Navigator.of(context).pop(); // 關閉對話框
        },
        icon: const Icon(Icons.save),
        label: Text("Save Selected Image"),
        backgroundColor: AppColors.fabColor,
      ),
    );
  }
}
