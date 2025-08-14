import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/utils/image_path_helper.dart';
import 'package:zerova_oqc_report/src/widget/camera/image_picker_page.dart';
import 'package:zerova_oqc_report/src/widget/camera/image_picker_page_new.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' as path;

class CameraPage extends StatefulWidget {
  final int packagingOrAttachment; // 0:Packaging  1:Attachment
  final String sn;
  final String model;

  const CameraPage({
    super.key,
    required this.packagingOrAttachment,
    required this.sn,
    required this.model,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with ImagePageHelper {
  String _cameraInfo = 'Unknown';
  String? _pickedPhotoPath; // 右邊顯示的照片
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;
  bool _previewPaused = false;
  Size? _previewSize;
  final MediaSettings _mediaSettings = const MediaSettings(
    resolutionPreset: ResolutionPreset.max,
    fps: 15,
    videoBitrate: 200000,
    audioBitrate: 32000,
    enableAudio: true,
  );
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  String? _selectedImagePath;
  List<String> _imagePaths = [];
  Map<String, String> _pickedPhotoMap = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _fetchCameras().then((_) => _initializeCamera());
    if(widget.packagingOrAttachment == 1) {
      //bill7
      SharePointUploader(uploadOrDownload: 3, sn: widget.sn, model: '').startAuthorization(
        categoryTranslations: {
          //"packageing_photo": "Packageing Photo ",
          "appearance_photo": "Appearance Photo ",
          //"oqc_report": "OQC Report ",
        },
      );
      _loadImages();
    }
    else if(widget.packagingOrAttachment == 0) {
      //bill8
      SharePointUploader(uploadOrDownload: 2, sn: widget.sn, model: '').startAuthorization(
        categoryTranslations: {
          "packageing_photo": "Packageing Photo ",
          //"appearance_photo": "Appearance Photo ",
          //"oqc_report": "OQC Report ",
        },
      );
      _loadPackageImages();
    }
    _loadPickedPhotoMap();  // ← 加這個
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;
    super.dispose();
  }

  /// Fetches list of available cameras from camera_windows plugin.
  Future<void> _fetchCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraIndex = _cameraIndex % cameras.length;
        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }

    if (mounted) {
      setState(() {
        _cameraIndex = cameraIndex;
        _cameras = cameras;
        _cameraInfo = cameraInfo;
      });
    }
  }

  Future<void> _loadImages() async {
    final String picturesPath = await getUserComparePath(widget.model);
    final directory = Directory(picturesPath);
    final List<FileSystemEntity> files = directory.listSync();

    // Filter out the images from the directory (e.g., .jpg, .png)
    final imageFiles = files
        .where((file) {
      if (file is File) {
        final ext = file.path.toLowerCase();
        return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png');
      }
      return false;
    })
        .map((file) => file.path)
        .toList();

    if (mounted) {
      setState(() {
        _imagePaths = imageFiles;
        // 如果還沒選過，預設選第一張比對圖
        if (_selectedImagePath == null && imageFiles.isNotEmpty) {
          _selectedImagePath = imageFiles.first;
        }
      });
    }
  }

  Future<void> _loadPackageImages() async {
    final String picturesPath = await getUserComparePackagePath(widget.model);
    final directory = Directory(picturesPath);
    final List<FileSystemEntity> files = directory.listSync();

    // Filter out the images from the directory (e.g., .jpg, .png)
    final imageFiles = files
        .where((file) {
      return file is File &&
          (file.path.endsWith('.jpg') ||
              file.path.endsWith('.jpeg') ||
              file.path.endsWith('.png'));
    })
        .map((file) => file.path)
        .toList();

    if (mounted) {
      setState(() {
        _imagePaths = imageFiles;
        // 如果還沒選過，預設選第一張比對圖
        if (_selectedImagePath == null && imageFiles.isNotEmpty) {
          _selectedImagePath = imageFiles.first;
        }
      });
    }
  }

  Future<void> _loadPickedPhotoMap() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'pickedPhotoMap_${widget.model}_${widget.sn}';  // 和外面判斷用同一個 key
    final encoded = prefs.getString(key);
    if (encoded != null) {
      setState(() {
        final decoded = jsonDecode(encoded);
        _pickedPhotoMap = Map<String, String>.from(decoded);
      });
    }
  }

  Future<void> _savePickedPhotoMap() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_pickedPhotoMap);
    final key = 'pickedPhotoMap_${widget.model}_${widget.sn}';
    await prefs.setString(key, encoded);
  }

  Future<void> _initializeCamera() async {
    assert(!_initialized);

    if (_cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCameraWithSettings(
        camera,
        _mediaSettings,
      );

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      _previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );

      if (mounted) {
        setState(() {
          _initialized = true;
          _cameraId = cameraId;
          _cameraIndex = cameraIndex;
          _cameraInfo = 'Capturing camera: ${camera.name}';
        });
      }
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }

      // Reset state.
      if (mounted) {
        setState(() {
          _initialized = false;
          _cameraId = -1;
          _cameraIndex = 0;
          _previewSize = null;
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0 && _initialized) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);

        if (mounted) {
          setState(() {
            _initialized = false;
            _cameraId = -1;
            _previewSize = null;
            _previewPaused = false;
            _cameraInfo = 'Camera disposed';
          });
        }
      } on CameraException catch (e) {
        if (mounted) {
          setState(() {
            _cameraInfo =
                'Failed to dispose camera: ${e.code}: ${e.description}';
          });
        }
      }
    }
  }

  Widget _buildPreview() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(3.14159), // 翻轉畫面
      child: CameraPlatform.instance.buildPreview(_cameraId),
    );
  }

  Future<void> _takePicture() async {
    if (_initialized && _cameraId >= 0) {
      if (!_previewPaused) {
        await CameraPlatform.instance.pausePreview(_cameraId);
        final XFile file = await CameraPlatform.instance.takePicture(_cameraId);

        final String saveImagesPath;

        if (widget.packagingOrAttachment == 0) {
          // Packaging
          saveImagesPath = await getUserAllPhotosPackagingPath(widget.sn);
        } else if (widget.packagingOrAttachment == 1) {
          // Attachment
          saveImagesPath = await getUserAllPhotosAttachmentPath(widget.sn);
        } else {
          throw Exception("Didn't contain Packaging Or Attachment");
        }

        final directory = Directory(saveImagesPath);
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        final String newPath = '${directory.path}/${file.name}';
        final File savedFile = File(file.path);
        await savedFile.rename(newPath);

        _showInSnackBar('Picture saved to: $newPath');
      } else {
        await CameraPlatform.instance.resumePreview(_cameraId);
        if (_selectedImagePath != null && _imagePaths.isNotEmpty) {
          final currentIndex = _imagePaths.indexOf(_selectedImagePath!);

          if (currentIndex + 1 < _imagePaths.length) {
            final nextIndex = currentIndex + 1;

            setState(() {
              _selectedImagePath = _imagePaths[nextIndex];
            });
          }
        }
      }
      if (mounted) {
        setState(() {
          _previewPaused = !_previewPaused;
        });
      }
    }
  }

  Future<void> _togglePreview() async {
    if (_initialized && _cameraId >= 0) {
      if (!_previewPaused) {
        await CameraPlatform.instance.pausePreview(_cameraId);
      } else {
        await CameraPlatform.instance.resumePreview(_cameraId);
      }
      if (mounted) {
        setState(() {
          _previewPaused = !_previewPaused;
        });
      }
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error: ${event.description}')));

      // Dispose camera on camera error as it can not be used anymore.
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      _showInSnackBar('Camera is closing');
    }
  }

  void _showInSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> printOldSelectedPhoto(String model, String sn) async {
    final prefs = await SharedPreferences.getInstance();

    final key = 'pickedPhotoMap_${model}_$sn';

    final encoded = prefs.getString(key);

    print('🔍 查詢 SharedPreferences: key = $key');
    if (encoded != null && encoded.isNotEmpty) {
      final Map<String, dynamic> decoded = jsonDecode(encoded);
      if (decoded.isNotEmpty) {
        print('📷 舊的參考照片與已選照片對應:');
        decoded.forEach((comparePhotoPath, pickedPhotoPath) {
          print('  比對照片: $comparePhotoPath');
          print('  選擇照片: $pickedPhotoPath');
        });
      } else {
        print('⚠️ Map 內部沒有任何資料');
      }
    } else {
      print('⚠️ 沒有找到舊的參考照片');
    }
  }

  Future<void> savePickedPhotoToLocalFolder(
      String originalPath,
      String sn,
      int packagingOrAttachment,
      ) async {
    print('📁 originalPath：$originalPath');
    final originalFile = File(originalPath);
    final fileName = p.basename(originalPath); // 像是 123.jpg

    final folderType = packagingOrAttachment == 0 ? 'Packaging' : 'Attachment';

    final String picturesPath = await getOrCreateUserZerovaPath();
    final String allPhotosPackagingPath =
    path.join(picturesPath, 'Selected Photos', sn, folderType);

    final targetDir = Directory(allPhotosPackagingPath);

    await printOldSelectedPhoto(widget.model, sn);

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final newFile = File(p.join(targetDir.path, fileName));
    await originalFile.copy(newFile.path);

    print('✅ 已儲存 $fileName 到 ${targetDir.path}');
    print('📁 新檔案完整路徑：${newFile.path}');  // <--- 這行是你要的印出新路徑
  }





  Future<bool> _onWillPop() async {
    // 假設你有 _pickedPhotoMap 紀錄選擇狀態
    bool allSelected = _imagePaths.every((path) => _pickedPhotoMap.containsKey(path));

    if (allSelected) {
      return true;
    } else {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.tr('check_photo_message'), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(context.tr('return_page_message')),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.tr('no')),),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.tr('yes')),),
          ],
        ),
      );
      return confirm ?? false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,  // 攔截返回事件
        child: MainLayout(
      title: context.tr('camera'),
      leading: FittedBox(
        fit: BoxFit.cover,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () async {
            bool shouldPop = await _onWillPop();
            if (shouldPop) {
              context.pop();
            }
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          if (_cameras.isEmpty)
            ElevatedButton(
              onPressed: _fetchCameras,
              child: Text(context.tr('recheck_cameras')),
            ),
          if (_cameras.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  // 左邊：比對用圖片
                  if (_selectedImagePath != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 500),
                          child: Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                  // 右邊：選的圖片
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 500),
                        child: _pickedPhotoMap[_selectedImagePath] != null
                            ? Image.file(
                          File(_pickedPhotoMap[_selectedImagePath]!),
                          fit: BoxFit.contain,
                        )
                            : Center(child: Text(context.tr('no_photo_selected'))),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 按鈕區塊
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //if (widget.packagingOrAttachment != 0)
                DropdownButton<String>(
                  hint: Text(context.tr('select_image')),
                  value: _selectedImagePath,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedImagePath = newValue;
                    });
                  },
                  items: _imagePaths.map<DropdownMenuItem<String>>((String path) {
                    final fileName = path.split('\\').last;
                    final hasPicked = _pickedPhotoMap[path] != null;

                    return DropdownMenuItem<String>(
                      value: path,
                      child: Row(
                        children: [
                          if (hasPicked)
                            const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          if (hasPicked)
                            const SizedBox(width: 6),
                          Text(fileName),
                        ],
                      ),
                    );
                  }).toList(),

                ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePickerPageNew(
                        packagingOrAttachment: widget.packagingOrAttachment,
                        sn: widget.sn,
                        model: widget.model,
                      ),
                    ),
                  );

                  if (result != null && mounted && _selectedImagePath != null) {
                    // 1. 先取出舊的照片路徑（如果有）
                    final oldPhotoPath = _pickedPhotoMap[_selectedImagePath!];

                    // 2. 如果舊照片存在，就刪除本地舊照片檔案
                    if (oldPhotoPath != null) {
                      // 先檢查是否有其他參考照片還在用這個檔案
                      bool isStillUsedElsewhere = _pickedPhotoMap.entries.any((entry) {
                        return entry.key != _selectedImagePath && entry.value == oldPhotoPath;
                      });

                      if (!isStillUsedElsewhere) {
                        // 把路徑中的 "All Photos" 換成 "Selected Photos"
                        final selectedPhotoPath = oldPhotoPath.replaceFirst(
                            'All Photos', 'Selected Photos');

                        final oldFile = File(selectedPhotoPath);
                        if (await oldFile.exists()) {
                          await oldFile.delete();
                          print('🗑️ 已刪除舊照片（Selected Photos資料夾）: $selectedPhotoPath');
                        } else {
                          print('⚠️ Selected Photos資料夾找不到要刪除的檔案: $selectedPhotoPath');
                        }
                      }
                    }

                    // 3. 更新 _pickedPhotoMap（用新的照片路徑）
                    setState(() {
                      _pickedPhotoMap[_selectedImagePath!] = result;
                    });

                    // 4. 寫入 SharedPreferences
                    await _savePickedPhotoMap();

                    // 5. 把新的照片複製到本地資料夾
                    await savePickedPhotoToLocalFolder(result, widget.sn, widget.packagingOrAttachment);
                  }

                },
                icon: const Icon(Icons.photo_library),
                label: Text(context.tr('select_image')),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
