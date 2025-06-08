import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';

class PhotoManagerTab extends StatefulWidget {
  final String selectedModel;

  const PhotoManagerTab({required this.selectedModel, Key? key}) : super(key: key);

  @override
  _PhotoManagerTabState createState() => _PhotoManagerTabState();
}

class _PhotoManagerTabState extends State<PhotoManagerTab> {
  List<File> imageFiles = [];
  List<String> deletedFiles = [];
  Map<String, bool> selectedImages = {};

  String? modelPath;

  @override
  void initState() {
    super.initState();
    initModelPathAndImages();
  }

  @override
  void didUpdateWidget(PhotoManagerTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedModel != widget.selectedModel) {
      initModelPathAndImages(); // 如果 model 有變，重新載入
    }
  }

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

    // 如果資料夾不存在，直接建立
    if (!await directory.exists()) {
      print("找不到 $model 資料夾，建立中...");
      await directory.create(recursive: true);
    }

    return comparePath;
  }

  Future<void> initModelPathAndImages() async {
    modelPath = await getUserComparePath(widget.selectedModel);
    await loadImages();
  }

  void downloadImages() {
    SharePointUploader(uploadOrDownload: 4, sn: '', model: widget.selectedModel).startAuthorization(
      categoryTranslations: {
        "packageing_photo": "Packageing Photo ",
        "appearance_photo": "Appearance Photo ",
        "oqc_report": "OQC Report ",
      },
    );
  }

  Future<void> loadImages() async {
    if (modelPath == null) {
      // 還沒準備好
      return;
    }
    final dir = Directory(modelPath!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) {
      final ext = path.extension(file.path).toLowerCase();
      return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
    })
        .toList();


    setState(() {
      imageFiles = files;
      selectedImages = {for (var file in files) file.path: false};
    });
  }

  Future<void> addImages() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image);
    if (result != null) {
      for (var file in result.files) {
        final newPath = path.join(modelPath!, path.basename(file.path!));
        await File(file.path!).copy(newPath);
      }
      await loadImages();
    }
  }

  Future<void> deleteSelectedImages() async {
    for (var fileEntry in selectedImages.entries) {
      if (fileEntry.value) {
        await File(fileEntry.key).delete();
        deletedFiles.add(path.basename(fileEntry.key));  // 累積刪除的檔名
      }
    }
    await loadImages();
    print("累積刪除的檔案: $deletedFiles");
  }

  void selectAllImages() {
    setState(() {
      for (var file in imageFiles) {
        selectedImages[file.path] = true;
      }
    });
  }

  void deselectAllImages() {
    setState(() {
      for (var file in imageFiles) {
        selectedImages[file.path] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '比對照片',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Spacer(),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: downloadImages,
                      icon: Icon(Icons.cloud_download),
                      label: Text('下載照片'),
                    ),
                    ElevatedButton.icon(
                      onPressed: addImages,
                      icon: Icon(Icons.add),
                      label: Text('新增照片'),
                    ),
                    /*ElevatedButton.icon(
                      onPressed: deleteSelectedImages,
                      icon: Icon(Icons.delete),
                      label: Text('刪除照片'),
                    ),
                    ElevatedButton.icon(
                      onPressed: selectAllImages,
                      icon: Icon(Icons.select_all),
                      label: Text('一鍵全選'),
                    ),
                    ElevatedButton.icon(
                      onPressed: deselectAllImages,
                      icon: Icon(Icons.deselect), // Flutter >=3.3
                      label: Text('取消全選'),
                    ),*/
                  ],
                ),

              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: imageFiles.length,
                itemBuilder: (context, index) {
                  final file = imageFiles[index];
                  final path = file.path;

                  return StatefulBuilder(
                    builder: (context, setInnerState) {
                      bool isHovering = false;
                      return MouseRegion(
                        onEnter: (_) => setInnerState(() => isHovering = true),
                        onExit: (_) => setInnerState(() => isHovering = false),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.black87,
                                child: Stack(
                                  children: [
                                    InteractiveViewer(child: Image.file(file)),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 500),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      isHovering
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      BlendMode.lighten,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(file, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                //照片勾選框
                                /*Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Checkbox(
                                    value: selectedImages[path] ?? false,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedImages[path] = val!;
                                      });
                                    },
                                    activeColor: Colors.red,
                                    checkColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2)),
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}
