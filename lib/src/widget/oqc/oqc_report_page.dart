import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'package:zerova_oqc_report/src/utils/window_size_manager.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/appearance_structure_inspection_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/attachment_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/basic_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/protection_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/input_output_characteristics_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/model_name_and_serial_number_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/package_list_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/hipot_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/psu_serial_numbers_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/signature_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/software_version.dart';
import 'package:zerova_oqc_report/src/report/pdf_generator.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';
import 'package:zerova_oqc_report/src/widget/upload/upload.dart';
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';
import 'package:zerova_oqc_report/src/report/spec/psu_serial_numbers_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/FailCountStore.dart';
import 'package:zerova_oqc_report/src/widget/oqc/oqc_model.dart';
import 'package:zerova_oqc_report/src/report/spec/new_package_list_spec.dart.dart';
import 'package:zerova_oqc_report/src/widget/common/table_failorpass.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerova_oqc_report/src/utils/image_path_helper.dart';

class OqcReportPage extends StatefulWidget {
  const OqcReportPage({
    super.key,
    required this.oqcModel,
  });

  final OqcModel oqcModel;

  @override
  State<OqcReportPage> createState() => _OqcReportPageState();
}

class _OqcReportPageState extends State<OqcReportPage>
    with WindowListener, ImagePageHelper {
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _picController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void onWindowResize() {
    WindowSizeManager.updateSize(MediaQuery.of(context).size);
    setState(() {});
  }

  Future<void> _generateAndUploadPdf() async {
    try {
      // 生成 PDF
      final pdf = await PdfGenerator.generateOqcReport(
        modelName: widget.oqcModel.model,
        serialNumber: widget.oqcModel.sn,
        pic: _picController.text,
        date: _dateController.text,
        context: context,
        psuSerialNumbers: widget.oqcModel.psuSerialNumbers,
        softwareVersion: widget.oqcModel.softwareVersion,
        testFunction: widget.oqcModel.testFunction,
        inputOutputCharacteristics: widget.oqcModel.inputOutputCharacteristics,
        protectionTestResults: widget.oqcModel.protectionTestResults,
        packageListResult: widget.oqcModel.packageListResult,
        inputOutputSpec: globalInputOutputSpec, // 傳遞 spec 參數
      );

      // 獲取用戶的 Pictures/OQC report 目錄

      var userProfile = Platform.environment['USERPROFILE'] ?? '';
      if (Platform.isMacOS) {
        // macOS 路徑
        userProfile = Platform.environment['HOME'] ?? '';
      } else if (Platform.isWindows) {
        // Windows 路徑
        userProfile = Platform.environment['USERPROFILE'] ?? '';
      } else {
        // 其他系統（如 Linux）
        userProfile = Platform.environment['HOME'] ?? '';
      }

      if (userProfile.isEmpty) {
        throw Exception('無法獲取用戶目錄');
      }
      var filePath = path.join(
          userProfile, 'Pictures', 'Zerova', 'OQC Report', widget.oqcModel.sn);
      final Directory dir = Directory(filePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      // 保存 PDF 文件
      final file = File(
          "$filePath/oqc_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      // 顯示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('報告已生成並上傳')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錯誤：$e')),
        );
      }
    }
  }

  /// Function to handle PDF generation and upload process (for byPass functionality)
  Future<void> _handlePdfGenerationAndUpload() async {
    await _generateAndUploadPdf();
    //bill3
    startUpload(context);
    if (globalPsuSerialNumSpec != null) {
      final success = await FirebaseService().addOrUpdateSpec(
        model: widget.oqcModel.model, // 你需要確保這裡有正確的 model 名稱
        tableName: 'PsuSerialNumSpec',
        spec: globalPsuSerialNumSpec!.toJson(),
      );

      if (success) {
        print('✅ 規格已成功上傳 Firebase');
      } else {
        print('❌ 上傳失敗，請檢查網路或 API Key');
      }
    } else {
      print('⚠️ 尚未設定 globalPsuSerialNumSpec');
    }
    if (globalInputOutputSpec != null) {
      final success = await FirebaseService().addOrUpdateSpec(
        model: widget.oqcModel.model, // 你需要確保這裡有正確的 model 名稱
        tableName: 'InputOutputCharacteristics',
        spec: globalInputOutputSpec!.toJson(),
      );

      if (success) {
        print('✅ 規格已成功上傳 ');
      } else {
        print('❌ 上傳失敗，請檢查網路或 API Key');
      }
    } else {
      print('⚠️ 尚未設定 globalInputOutputSpec');
    }
    if (globalBasicFunctionTestSpec != null) {
      final success = await FirebaseService().addOrUpdateSpec(
        model: widget.oqcModel.model, // 你需要確保這裡有正確的 model 名稱
        tableName: 'BasicFunctionTest',
        spec: globalBasicFunctionTestSpec!.toJson(),
      );

      if (success) {
        print('✅ 規格已成功上傳 Firebase');
      } else {
        print('❌ 上傳失敗，請檢查網路或 API Key');
      }
    } else {
      print('⚠️ 尚未設定 globalBasicFunctionTestSpec');
    }
    if (globalHipotTestSpec != null) {
      final success = await FirebaseService().addOrUpdateSpec(
        model: widget.oqcModel.model, // 你需要確保這裡有正確的 model 名稱
        tableName: 'HipotTestSpec',
        spec: globalHipotTestSpec!.toJson(),
      );

      if (success) {
        print('✅ 規格已成功上傳 Firebase');
      } else {
        print('❌ 上傳失敗，請檢查網路或 API Key');
      }
    } else {
      print('⚠️ 尚未設定 globalHipotTestSpec');
    }

    var PackageListdata = PackageListSpecGlobal.get();

    if (PackageListdata != null) {
      final success = await uploadPackageListSpec(
        model: widget.oqcModel.model,
        tableName: 'PackageListSpec',
        packageListResult: PackageListdata,
      );

      if (success) {
        print('✅ 規格已成功上傳 Firebase');
      } else {
        print('❌ 上傳失敗，請檢查網路或 API Key');
      }
    } else {
      print('⚠️ 尚未設定 globalPackageListSpec');
    }

    //bill9
    deleteOQCField(widget.oqcModel.model, widget.oqcModel.sn);

    final tableNames = [
      'AppearanceStructureInspectionFunction',
      'InputOutputCharacteristics',
      'BasicFunctionTest',
      'HipotTestSpec',
    ];

    for (final tableName in tableNames) {
      final failCount = FailCountStore.getCount(tableName);

      // 如果有值就上傳
      if (failCount != null) {
        // failCount 是 int，不會是 null，這裡可改成 failCount > 0 或 failCount >= 0 視需求
        final success = await FirebaseService().addOrUpdateFailCount(
          model: widget.oqcModel.model,
          serialNumber: widget.oqcModel.sn,
          tableName: tableName,
          failCount: failCount,
        );

        if (success) {
          print('✅ $tableName 規格已成功上傳 Firebase');
        } else {
          print('❌ $tableName 上傳失敗，請檢查網路或 API Key');
        }
      } else {
        print('⚠️ 尚未設定 $tableName');
      }
    }
  }

  void startUpload(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 防止意外關閉
      builder: (BuildContext dialogContext) {
        return UploadProgressDialog.create(
          uploadOrDownload: 0,
          sn: widget.oqcModel.sn,
          model: widget.oqcModel.model,
        );
      },
    );
  }

  Future<bool> deleteOQCField(String model, String sn) async {
    const String projectId = 'oqcreport-87e5a';
    const String apiKey = 'AIzaSyBzlul4mftI7HHJnj48I2aUs2nV154x0iI';

    if (model.trim().isEmpty || sn.trim().isEmpty) {
      print("❌ [deleteOQCField] model 或 sn 為空");
      return false;
    }

    final encodedModel = Uri.encodeComponent(model.trim());
    final encodedSn = Uri.encodeComponent(sn.trim());

    final docUrl =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/todo/$encodedModel?key=$apiKey';

    try {
      // 先取得整個 document
      final getResponse = await http.get(Uri.parse(docUrl));
      if (getResponse.statusCode != 200) {
        print(
            "❌ [deleteOQCField] 取得文件失敗：${getResponse.statusCode}, ${getResponse.body}");
        return false;
      }

      final docData = json.decode(getResponse.body);
      final fields = docData['fields'] as Map<String, dynamic>?;

      if (fields == null || fields.isEmpty) {
        print("⚠️ [deleteOQCField] 文件已無欄位");
        return true;
      }

      if (fields.length == 1 && fields.containsKey(sn)) {
        // 如果是最後一筆，直接刪除整個 document
        final deleteResponse = await http.delete(Uri.parse(docUrl));
        if (deleteResponse.statusCode == 200) {
          print("✅ [deleteOQCField] 已刪除整個 document：$model");
          return true;
        } else {
          print(
              "❌ [deleteOQCField] 刪除整個 document 失敗：${deleteResponse.statusCode}, ${deleteResponse.body}");
          return false;
        }
      } else {
        // 只刪除指定欄位
        final patchUrl = '$docUrl&updateMask.fieldPaths=$encodedSn';

        final body = json.encode({
          "fields": {
            // 空代表移除該欄位
          }
        });

        final patchResponse = await http.patch(
          Uri.parse(patchUrl),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (patchResponse.statusCode == 200) {
          print("✅ [deleteOQCField] 已刪除欄位：$sn");
          return true;
        } else {
          print(
              "❌ [deleteOQCField] 刪除欄位失敗：${patchResponse.statusCode}, ${patchResponse.body}");
          return false;
        }
      }
    } catch (e) {
      print("❌ [deleteOQCField] 發生例外：$e");
      return false;
    }
  }

  Future<bool> areAllPhotosSelected(String sn) async {
    // 1. 讀取配件包照片清單 (外部可直接呼叫 getUserComparePackagePath)
    final packagePath = await getUserComparePackagePath(widget.oqcModel.model);
    final packageDir = Directory(packagePath);
    final packageFiles = packageDir.existsSync()
        ? packageDir
            .listSync()
            .whereType<File>()
            .where((f) => isImageFile(f.path))
            .map((f) => f.path)
            .toList()
        : <String>[];

    // 2. 讀取外觀檢查照片清單 (getUserComparePath)
    final appearancePath = await getUserComparePath(widget.oqcModel.model);
    final appearanceDir = Directory(appearancePath);
    final appearanceFiles = appearanceDir.existsSync()
        ? appearanceDir
            .listSync()
            .whereType<File>()
            .where((f) => isImageFile(f.path))
            .map((f) => f.path)
            .toList()
        : <String>[];

    // 3. 讀取 SharedPreferences 的已選擇照片Map
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('pickedPhotoMap');
    Map<String, String> pickedMap = {};
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      pickedMap = Map<String, String>.from(decoded);
    }

    // 4. 判斷配件包照片全部都有被選
    bool allPackageSelected =
        packageFiles.every((p) => pickedMap.containsKey(p));

    // 5. 判斷外觀檢查照片全部都有被選
    bool allAppearanceSelected =
        appearanceFiles.every((p) => pickedMap.containsKey(p));

    return allPackageSelected && allAppearanceSelected;
  }

// 輔助判斷是否是圖片格式
  bool isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png');
  }

  /// 讀取 SharedPreferences 的已選擇照片Map

  Future<Map<String, String>> loadPickedPhotoMap(
      String model, String sn) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'pickedPhotoMap_${model}_$sn'; // 用 model+sn 當 key
    final encoded = prefs.getString(key);
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      return Map<String, String>.from(decoded);
    }
    return {};
  }

  /// 判斷配件包照片是否全部選擇
  Future<bool> areAllPackagePhotosSelected(String model, String sn) async {
    final packagePath = await getUserComparePackagePath(model);
    final packageDir = Directory(packagePath);
    final packageFiles = packageDir.existsSync()
        ? packageDir
            .listSync()
            .whereType<File>()
            .where((f) => isImageFile(f.path))
            .map((f) => f.path)
            .toList()
        : <String>[];

    final pickedMap = await loadPickedPhotoMap(model, sn);

    return packageFiles.every((p) => pickedMap.containsKey(p));
  }

  /// 判斷外觀檢查照片是否全部選擇
  Future<bool> areAllAppearancePhotosSelected(String model, String sn) async {
    final appearancePath = await getUserComparePath(model);
    final appearanceDir = Directory(appearancePath);
    final appearanceFiles = appearanceDir.existsSync()
        ? appearanceDir
            .listSync()
            .whereType<File>()
            .where((f) => isImageFile(f.path))
            .map((f) => f.path)
            .toList()
        : <String>[];
    print('📦 需要比對的 appearanceFiles:');
    appearanceFiles.forEach(print);

    final pickedMap = await loadPickedPhotoMap(model, sn);

    print('✅ pickedMap keys:');
    pickedMap.keys.forEach(print);

    return appearanceFiles.every((p) => pickedMap.containsKey(p));
  }

  Future<bool> areAllPackageCheckboxChecked(String sn) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('checkbox_state_$sn');
    if (str != null) {
      final List decoded = jsonDecode(str);
      for (var item in decoded) {
        final name = item['name'];
        final isChecked = item['isChecked'];
        print('🔍 Checkbox "$name" isChecked = $isChecked');

        if (isChecked != true) {
          return false;
        }
      }
      return true; // 所有都勾了
    }
    return false; // 找不到資料也視為 false
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return MainLayout(
      title: context.tr('oqc_report'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // ❗先做 fail 檢查
          List<String> failItems = [];

          //bill6

          if (psuSNPassOrFail == false) {
            failItems.add(context.tr('psu_sn'));
          }
          if (swVerPassOrFail == false) {
            failItems.add(context.tr('software_version'));
          }
          if (appearanceStructureInspectionPassOrFail == false) {
            failItems.add(context.tr('appearance_structure_inspection'));
          }
          if (ioCharacteristicsPassOrFail == false) {
            failItems.add(context.tr('input_output_characteristics'));
          }
          if (basicFunctionTestPassOrFail == false) {
            failItems.add(context.tr('basic_function_test'));
          }
          if (protectionFunctionTestPassOrFail == false) {
            failItems.add(context.tr('protection_function_test'));
          }
          if (hipotTestPassOrFail == false) {
            failItems.add(context.tr('hipot_test'));
          }

          final packagingCompleted = await areAllPackagePhotosSelected(
              widget.oqcModel.model, widget.oqcModel.sn);
          final appearanceCompleted = await areAllAppearancePhotosSelected(
              widget.oqcModel.model, widget.oqcModel.sn);
          final allBoxChecked =
              await areAllPackageCheckboxChecked(widget.oqcModel.sn);

          if (!packagingCompleted || !allBoxChecked) {
            failItems.add(context.tr('package_list'));
          }
          if (!appearanceCompleted) {
            failItems.add(context.tr('attachment'));
          }

          if (failItems.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                //title: context.tr('oqc_report'),
                title: Text('⚠️ ${context.tr('check_failed')}'),
                //title: const Text('⚠️ 檢查未通過'),
                content: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(
                        text: '${context.tr('check_failed_message')}\n\n',
                      ),
                      TextSpan(
                        text: failItems.join('\n'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Only show byPass button in debug mode
                  if (kDebugMode)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                      child: const Text('Bypass'),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close dialog first
                        await _handlePdfGenerationAndUpload(); // Execute PDF generation and upload
                      },
                    ),
                ],
              ),
            );

            return; // ❌ 不繼續執行
          }

          await _handlePdfGenerationAndUpload();
        },
        icon: const Icon(Icons.upload_file),
        label: Text(context.tr('submit')),
        backgroundColor: AppColors.fabColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModelNameAndSerialNumberTable(
                    model: widget.oqcModel.model,
                    sn: widget.oqcModel.sn,
                  ),
                  PsuSerialNumbersTable(widget.oqcModel.psuSerialNumbers!),
                  SoftwareVersionTable(widget.oqcModel.softwareVersion!),
                  AppearanceStructureInspectionTable(
                      widget.oqcModel.testFunction!),
                  InputOutputCharacteristicsTable(
                      widget.oqcModel.inputOutputCharacteristics!),
                  BasicFunctionTestTable(widget.oqcModel
                      .inputOutputCharacteristics!.basicFunctionTestResult),
                  ProtectionFunctionTestTable(
                    widget.oqcModel.protectionTestResults!,
                  ),
                  HiPotTestTable(
                    widget.oqcModel.protectionTestResults!,
                  ),
                  PackageListTable(
                    widget.oqcModel.packageListResult!,
                    sn: widget.oqcModel.sn,
                    model: widget.oqcModel.model,
                  ),
                  AttachmentTable(
                    sn: widget.oqcModel.sn,
                    model: widget.oqcModel.model,
                  ),
                  SignatureTable(
                    picController: _picController,
                    dateController: _dateController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildLanguageDropdownButton(
      BuildContext context, Locale currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<Locale>(
        value: currentLocale,
        icon: const Icon(Icons.language),
        underline: Container(),
        elevation: 4,
        items: context.supportedLocales.map((locale) {
          String label = '';
          switch (locale.languageCode) {
            case 'en':
              label = 'English';
              break;
            case 'zh':
              label = '繁體中文';
              break;
            case 'vi':
              label = 'Tiếng Việt';
              break;
            case 'ja':
              label = '日本語';
              break;
            default:
              label = locale.languageCode;
          }
          return DropdownMenuItem(
            value: locale,
            child: Text(label),
          );
        }).toList(),
        onChanged: (Locale? locale) {
          if (locale != null) {
            context.setLocale(locale);
          }
        },
      ),
    );
  }
}
