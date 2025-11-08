import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/utils/image_path_helper.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ImagePickerPageNew extends StatefulWidget {
  final int packagingOrAttachment;
  final String sn;
  final String model; // 加這個

  const ImagePickerPageNew({
    super.key,
    required this.packagingOrAttachment,
    required this.sn,
    required this.model,
  });

  @override
  State<ImagePickerPageNew> createState() => _ImagePickerPageNewState();
}

class _ImagePickerPageNewState extends State<ImagePickerPageNew>
    with ImagePageHelper {
  List<String> _imagePaths = [];
  List<bool> _selectedImages = [];
  Map<String, String> _pickedPhotoMap = {}; // 已選照片 Map

  @override
  void initState() {
    super.initState();
    _initializeImages();
    _loadPickedPhotoMap(); // 讀取已選過的照片記錄
  }

  Future<void> _initializeImages() async {
    await _loadImages(); // 確保圖片加載完成
    setState(() {});
  }

  Future<void> _loadPickedPhotoMap() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'pickedPhotoMap_${widget.model}_${widget.sn}'; // 如果 CameraPage 還有 model 也一起加
    final encoded = prefs.getString(key);

    //print('🔍 讀取 SharedPreferences key = $key');
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      _pickedPhotoMap = Map<String, String>.from(decoded);
      //print('✅ 讀到的 pickedPhotoMap:');
      print(const JsonEncoder.withIndent('  ').convert(_pickedPhotoMap));
    } else {
      //print('⚠️ SharedPreferences 沒有資料');
    }
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
                  final imagePath = _imagePaths[index];
                  final bool isPicked = _pickedPhotoMap.values.contains(imagePath);

                  //print('📷 檢查圖片: $imagePath');
                  //print('   ↳ pickedPhotoMap.values = ${_pickedPhotoMap.values}');
                  //print('   ↳ 已選過? $isPicked');

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, _imagePaths[index]);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                        ),
                        if (isPicked)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green, // 底
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2), // 讓白底比勾勾大一點
                              child: Icon(
                                Icons.check, // 勾
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          )
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
    );
  }
}
