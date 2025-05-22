import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:zerova_oqc_report/src/client/oqc_api_client.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/home/input_model_name_and_sn_dialog.dart';
import 'package:zerova_oqc_report/src/widget/home/input_account_and_password.dart';
import 'package:zerova_oqc_report/src/widget/oqc/oqc_report_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/custom_app_bar.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LoadFileHelper {
  String result = '';
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 公司LOGO
            Image.asset(
              'assets/logo.png', // 請確保此路徑下有對應的圖片
              height: 300, // 調整LOGO大小
            ),
            const SizedBox(height: 40),
            // 按鈕1: 輸入SN機種
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                                    return const InputAccountAndPassword(); // 彈出視窗
                    },
                  );
                },
                child: Text(context.tr('input_account_password')),
              ),
            ),
            const SizedBox(height: 20),
            // 按鈕1: 輸入SN機種
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const InputModelNameAndSnDialog(); // 彈出視窗
                    },
                  );
                },
                child: Text(context.tr('input_sn_model')),
              ),
            ),
            const SizedBox(height: 20),

            // 按鈕2: QR Scan
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                  ),
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerScreen(),
                      ),
                    );
                    if (res != null) {
                      setState(() {
                        result = res;
                        print(result);
                      });
                      String model = '';
                      String serialNumber = '';

                      List<String> parts = res.split(RegExp(r'\s+'));
                      if (parts.length >= 2) {
                        model = parts[0];
                        serialNumber = parts[1];
                      } else {
                        model = res;
                        serialNumber = '';
                      }

                      await loadFileModule(serialNumber, model, context);
                    }
                  },
                  child: Text(context.tr('qr_code_scan')),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                ),
                onPressed: () async {
                  bool? shouldClose = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(context.tr('exit_confirm_title')),
                        content: Text(context.tr('exit_confirm_message')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(context.tr('cancel')),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(context.tr('exit')),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldClose == true) {
                    await windowManager.close();
                  }
                },
                child: Text(
                  context.tr('exit'),
                  style: const TextStyle(
                    color: AppColors.darkBlueColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> qrcodeScan() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: BarcodeAppBar(
        appBarTitle: context.tr('qr_code_scan'),
        centerTitle: true,
        enableBackButton: true,
        backButtonIcon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
    );

    String model = "";
    String serialNumber = "";
    // 將 result 拆成兩部分
    List<String> parts = res!.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      model = parts[0];
      serialNumber = parts[1];
    } else {
      model = res;
      serialNumber = ''; // 若分割後不足兩部分，則 part2 保持空字串
    }

    await loadFileModule(serialNumber, model, context);
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
mixin LoadFileHelper2 {
  Future<void> loadFileModule2(
      String sn, String model, BuildContext context) async {
    //load json from User/Test Result/Zerova/$sn/...
    var filePath = '';
    if (Platform.isMacOS) {
      // macOS 路徑
      filePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova');
    } else if (Platform.isWindows) {
      // Windows 路徑
      filePath = path.join(
          Platform.environment['USERPROFILE'] ?? '', 'Test Result', 'Zerova');
    } else {
      // 其他系統（如 Linux）
      filePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova');
    }

    String jsonContent =
    await File("$filePath/$sn/T2449A003A1_test.json").readAsString();
    String testFunctionJsonContent =
    await File("$filePath/$sn/T2449A003A1_oqc.json").readAsString();
    String moduleJsonContent =
    await File("$filePath/$sn/T2449A003A1_keypart.json").readAsString();

    List<dynamic> data = jsonDecode(jsonContent);
    List<dynamic> testFunctionData = jsonDecode(testFunctionJsonContent);
    List<dynamic> moduleData = jsonDecode(moduleJsonContent);

    var softwareVersion = SoftwareVersion.fromJsonList(data);
    var psuSerialNumbers =
    Psuserialnumber.fromJsonList(moduleData); // 提取多筆 PSU Serial Number
    var inputOutputCharacteristics =
    InputOutputCharacteristics.fromJsonList(data);
    var protectionTestResults =
    ProtectionFunctionTestResult.fromJsonList(data); // 提取測試結果
    var testFunction =
    AppearanceStructureInspectionFunctionResult.fromJson(testFunctionData);

    context.push('/oqc-report', extra: {
      'sn': sn,
      'model': model,
      'psuSerialNumbers': psuSerialNumbers,
      'softwareVersion': softwareVersion,
      'testFunction': testFunction,
      'inputOutputCharacteristics': inputOutputCharacteristics,
      'protectionTestResults': protectionTestResults,
    });
    return;
  }
}

mixin LoadFileHelper {
  Future<void> loadFileModule(
      String sn, String model, BuildContext context) async {
    //load json from User/Test Result/Zerova/$sn/...
    var filePath = '';
    if (Platform.isMacOS) {
      // macOS 路徑
      filePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova');
    } else if (Platform.isWindows) {
      // Windows 路徑
      filePath = path.join(
          Platform.environment['USERPROFILE'] ?? '', 'Test Result', 'Zerova');
    } else {
      // 其他系統（如 Linux）
      filePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova');
    }

    String jsonContent =
        await File("$filePath/$sn/T2415A053A0_test.json").readAsString();
    String testFunctionJsonContent =
        await File("$filePath/$sn/T2415A053A0_oqc.json").readAsString();
    String moduleJsonContent =
        await File("$filePath/$sn/T2415A053A0_keypart.json").readAsString();

    List<dynamic> data = jsonDecode(jsonContent);
    List<dynamic> testFunctionData = jsonDecode(testFunctionJsonContent);
    List<dynamic> moduleData = jsonDecode(moduleJsonContent);

    var softwareVersion = SoftwareVersion.fromJsonList(data);
    var psuSerialNumbers =
        Psuserialnumber.fromJsonList(moduleData); // 提取多筆 PSU Serial Number
    var inputOutputCharacteristics =
        InputOutputCharacteristics.fromJsonList(data);
    var protectionTestResults =
        ProtectionFunctionTestResult.fromJsonList(data); // 提取測試結果
    var testFunction =
        AppearanceStructureInspectionFunctionResult.fromJson(testFunctionData);

    context.push('/oqc-report', extra: {
      'sn': sn,
      'model': model,
      'psuSerialNumbers': psuSerialNumbers,
      'softwareVersion': softwareVersion,
      'testFunction': testFunction,
      'inputOutputCharacteristics': inputOutputCharacteristics,
      'protectionTestResults': protectionTestResults,
    });
    return;

    //call api
    final apiClient = OqcApiClient();

    // 將 model 和 serialNumber 打印到 console
    await Future.wait<List<dynamic>>([
      apiClient.fetchAndSaveKeyPartData(sn),
      apiClient.fetchAndSaveOqcData(sn),
      apiClient.fetchAndSaveTestData(sn)
    ]).then((res) {
      var psuSerialNumbers = Psuserialnumber.fromJsonList(res[0]);
      var testFunction =
          AppearanceStructureInspectionFunctionResult.fromJson(res[1]);
      var softwareVersion = SoftwareVersion.fromJsonList(res[2]);
      var inputOutputCharacteristics =
          InputOutputCharacteristics.fromJsonList(res[2]);
      var protectionTestResults =
          ProtectionFunctionTestResult.fromJsonList(res[2]);
      context.push('/oqc-report', extra: {
        'sn': sn,
        'model': model,
        'psuSerialNumbers': psuSerialNumbers,
        'softwareVersion': softwareVersion,
        'testFunction': testFunction,
        'inputOutputCharacteristics': inputOutputCharacteristics,
        'protectionTestResults': protectionTestResults,
      });
    });
  }
}

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 內嵌掃描畫面
          const SimpleBarcodeScannerPage(),

          /// 返回按鈕 (右上角)
          Positioned(
            top: 40, // 按鈕距離畫面上方的距離
            right: 20, // 按鈕對齊右邊
            child: SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 返回上一頁
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 黑底
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white), // 白字
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white), // 白色箭頭
                    const SizedBox(width: 8),
                    Text(
                      context.tr('qrcode_back'),
                      style: const TextStyle(color: Colors.white), // 確保文字為白色
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}