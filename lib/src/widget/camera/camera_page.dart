import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/utils/image_path_helper.dart';
import 'package:zerova_oqc_report/src/widget/camera/image_picker_page.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';

class CameraPage extends StatefulWidget {
  final int packagingOrAttachment; // 0:Packaging  1:Attachment
  final String sn;

  const CameraPage({
    super.key,
    required this.packagingOrAttachment,
    required this.sn,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with ImagePageHelper {
  String _cameraInfo = 'Unknown';
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
    final String picturesPath = await getUserComparePath();
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: context.tr('camera'),
      body: ListView(
        children: <Widget>[
          if (_cameras.isEmpty)
            ElevatedButton(
              onPressed: _fetchCameras,
              child: const Text('Re-check available cameras'),
            ),
          if (_cameras.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (widget.packagingOrAttachment != 0)
                  DropdownButton<String>(
                    hint: const Text('Select Image'),
                    value: _selectedImagePath,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedImagePath = newValue;
                      });
                    },
                    items: _imagePaths
                        .map<DropdownMenuItem<String>>((String path) {
                      return DropdownMenuItem<String>(
                        value: path,
                        child: Text(path.split('\\').last),
                      );
                    }).toList(),
                  ),
                ElevatedButton.icon(
                  onPressed: _initialized ? _takePicture : null,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(
                    _previewPaused ? '下一張照片' : '拍照',
                  ),
                ),
                const SizedBox(width: 5),
                Builder(
                  builder: (BuildContext context) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePickerPage(
                              packagingOrAttachment:
                                  widget.packagingOrAttachment,
                              sn: widget.sn,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('瀏覽照片'),
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: <Widget>[
                if (_selectedImagePath != null && _previewSize != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        constraints: const BoxConstraints(
                            maxHeight: 500), // 與相機畫面相同的最大高度
                        child: AspectRatio(
                          aspectRatio: _previewSize!.width /
                              _previewSize!.height, // 保持相機畫面比例
                          child: Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.contain, // 確保圖片完整顯示，不被裁切
                          ),
                        ),
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
                          aspectRatio:
                              _previewSize!.width / _previewSize!.height,
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
    );
  }
}
