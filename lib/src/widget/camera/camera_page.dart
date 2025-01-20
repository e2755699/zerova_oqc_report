import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

/// Example app for Camera Windows plugin.
class CameraPage extends StatefulWidget {
  /// Default Constructor
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

Future<String> _getUserPicturesPath() async {
  // 獲取當前使用者的根目錄
  final String userProfile = Platform.environment['USERPROFILE'] ?? '';

  // 根據根目錄構建圖片目錄路徑
  if (userProfile.isNotEmpty) {
    final String picturesPath = path.join(userProfile, 'Pictures');
    return picturesPath;
  } else {
    throw Exception("Unable to find the user profile directory.");
  }
}

Future<String> _getUserComparePath() async {
  final String picturesPath = await _getUserPicturesPath();
  final String comparePath = path.join(picturesPath, 'Compare Pictures');

  // 檢查資料夾是否存在，若不存在則建立
  final directory = Directory(comparePath);
  if (!await directory.exists()) {
    await directory.create(recursive: true); // recursive 為 true 會自動建立所有必要的父資料夾
  }

  return comparePath;
}

Future<String> _getUserZerovaPath() async {
  final String picturesPath = await _getUserPicturesPath();
  final String zerovaPath = path.join(picturesPath, 'Zerova');

  // 檢查資料夾是否存在，若不存在則建立
  final directory = Directory(zerovaPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  return zerovaPath;
}


class _CameraPageState extends State<CameraPage> {
  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;
  bool _previewPaused = false;
  Size? _previewSize;
  MediaSettings _mediaSettings = const MediaSettings(
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

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _fetchCameras().then((_) => _initializeCamera());
    _loadImages();
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
    final String picturesPath = await _getUserComparePath();
    final directory = Directory(picturesPath);
    final List<FileSystemEntity> files = directory.listSync();

    // Filter out the images from the directory (e.g., .jpg, .png)
    final imageFiles = files.where((file) {
      return file is File && (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg') || file.path.endsWith('.png'));
    }).map((file) => file.path).toList();

    if (mounted) {
      setState(() {
        _imagePaths = imageFiles;
      });
    }
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
        _showInSnackBar('Picture captured to: ${file.path}');
      } else {
        await CameraPlatform.instance.resumePreview(_cameraId);
      }
      if (mounted) {
        setState(() {
          _previewPaused = !_previewPaused;
        });
      }
    }
    /*final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
    _showInSnackBar('Picture captured to: ${file.path}');*/
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Camera'),
        ),
        body: ListView(
          children: <Widget>[
            // if (_cameras.isEmpty)
            //   ElevatedButton(
            //     onPressed: _fetchCameras,
            //     child: const Text('Re-check available cameras'),
            //   ),
            // if (_cameras.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DropdownButton<String>(
                    hint: const Text('Select Image'),
                    value: _selectedImagePath,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedImagePath = newValue;
                      });
                    },
                    items: _imagePaths.map<DropdownMenuItem<String>>((String path) {
                      return DropdownMenuItem<String>(
                        value: path,
                        child: Text(path.split('\\').last),
                      );
                    }).toList(),
                  ),
                  /*ElevatedButton(
                    onPressed: _initialized
                        ? _disposeCurrentCamera
                        : _initializeCamera,
                    child: Text(_initialized ? '關閉相機' : '開啟相機'),
                  ),
                  const SizedBox(width: 5),*/
                  ElevatedButton(
                    onPressed: _initialized ? _takePicture : null,
                    child: Text(
                      _previewPaused ? '下一張照片' : '拍照', // 根據預覽是否暫停顯示不同文字
                    ),
                  ),
                  const SizedBox(width: 5),
                  Builder(
                    builder: (BuildContext context) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ImagePickerScreen()),
                          );
                        },
                        child: const Text('瀏覽照片'),
                      );
                    },
                  ),

                  const SizedBox(width: 5),
                ],
              ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  if (_selectedImagePath != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  if (_initialized && _previewSize != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 500),
                          child: AspectRatio(
                            aspectRatio: _previewSize!.width / _previewSize!.height,
                            child: _buildPreview(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  List<String> _imagePaths = [];
  List<bool> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
    // 在初始化時直接顯示選擇對話框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImageSelectionDialog();
    });
  }

  Future<void> _loadImages() async {
    try {
      // 獲取用戶的圖片目錄
      final String picturesPath = await _getUserPicturesPath();
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
    final String zerovaPath = await _getUserZerovaPath();
    final targetDirectory = Directory(zerovaPath);

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showImageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // 移除邊距，確保對話框填滿
          child: Container(
            width: MediaQuery.of(context).size.width, // 填滿寬度
            height: MediaQuery.of(context).size.height, // 填滿高度
            child: Column(
              children: [
                // 頂部標題欄
                AppBar(
                  title: const Text('Select Multiple Images'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(); // 關閉對話框
                        Navigator.of(context).pop(); // 返回上一頁（Camera 頁面）
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter dialogSetState) {
                      return _imagePaths.isNotEmpty
                          ? GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // 每行顯示 5 張圖片
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(_imagePaths[index]),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
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
                          );
                        },
                      )
                          : const Center(
                        child: Text(
                            'No images found in the specified directory.'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 關閉對話框
                          Navigator.of(context).pop(); // 返回上一頁（Camera 頁面）
                        },
                        child: const Text('Close'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _saveSelectedImages(); // 儲存所選影像
                          Navigator.of(context).pop(); // 關閉對話框
                          Navigator.of(context).pop(); // 返回上一頁（Camera 頁面）
                        },
                        child: const Text('Save Selected Images'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Multiple Images'),
      ),
      body: Center(
        child: _imagePaths.isEmpty
            ? const CircularProgressIndicator()
            : const Text('Images loaded.'),
      ),
    );
  }
} 