import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:zerova_oqc_report/src/repo/firebase_service.dart';

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
import 'package:zerova_oqc_report/src/widget/common/send_email_service.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';
import 'package:intl/intl.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LoadFileHelper {
  String result = '';
  bool isLoading = false; // 添加 loading 狀態變數
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
            // 按鈕Mail
            /*SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  await SendEmailService.sendMail();
                },
                child: const Text('Send Mail'),
              ),
            ),
            const SizedBox(height: 20),*/
            // 按鈕1: 輸入帳號密碼
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
            // Model Spec Template 按鈕 (只有管理員可見)
            ValueListenableBuilder<int>(
              valueListenable: permissions,
              builder: (context, value, child) {
                if (value == 1) {
                  // 只有管理員 (permissions == 1) 可見
                  return Column(
                    children: [
                      SizedBox(
                        width: 300,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: () {
                            context.go('/model-spec-template');
                          },
                          child: Text(context.tr('model_spec_template')),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  return const SizedBox.shrink(); // 非管理員不顯示
                }
              },
            ),
            // 按鈕2: 輸入SN機種
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: isLoading
                    ? null
                    : () {
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

            // 按鈕3: QR Scan
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: isLoading
                    ? null // 如果正在加載，禁用按鈕
                    : () async {
                        globalPackageListSpecInitialized = false;
                        setState(() {
                          isLoading = true; // 開始加載
                        });
                        try {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BarcodeScannerScreen(),
                            ),
                          );
                          if (res != null) {
                            setState(() {
                              result = res;
                              print(result);
                            });
                            /*String model = '';
                            String serialNumber = '';

                            List<String> parts = res.split(RegExp(r'\s+'));
                            if (parts.length >= 2) {
                              model = parts[0];
                              serialNumber = parts[1];
                            } else {
                              model = res;
                              serialNumber = '';
                            }
                            */

                            //String? tres = "EV100T2449A003A1";  // 或是 "EV100\nT2449A003A1"
                            String model = "";
                            String serialNumber = "";

                            if (res != null) {
                              final cleanedRes = res.replaceAll(RegExp(r'\s+'), '');

                              if (cleanedRes.length >= 11) {
                                serialNumber = cleanedRes.substring(cleanedRes.length - 11); // T2449A003A1
                                model = cleanedRes.substring(0, cleanedRes.length - 11);     // EV100
                              } else {
                                print("錯誤：字串長度不足 11 碼");
                              }
                            }

                            print("Model: $model");
                            print("Serial Number: $serialNumber");

                            await loadFileModule(serialNumber, model, context);
                          }
                        } finally {
                          setState(() {
                            isLoading = false; // 結束加載
                          });
                        }
                      },
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(context.tr('processing')),
                        ],
                      )
                    : Text(context.tr('qr_code_scan')),
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
/*
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
*/
    //String res = "EV100T2449A003A1";
    String model = "";
    String serialNumber = "";

    if (res != null) {
      final cleanedRes = res.replaceAll(RegExp(r'\s+'), '');

      if (cleanedRes.length >= 11) {
        serialNumber = cleanedRes.substring(cleanedRes.length - 11); // T2449A003A1
        model = cleanedRes.substring(0, cleanedRes.length - 11);     // EV100
      } else {
        print("錯誤：字串長度不足 11 碼");
      }
    }

    print("Model: $model");
    print("Serial Number: $serialNumber");


    // 建立日誌檔案
    var logFilePath = '';
    if (Platform.isMacOS) {
      logFilePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova', 'logs');
    } else if (Platform.isWindows) {
      logFilePath = path.join(Platform.environment['USERPROFILE'] ?? '',
          'Test Result', 'Zerova', 'logs');
    } else {
      logFilePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova', 'logs');
    }
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final logFile = File(path.join(
        logFilePath, 'spec_log_${serialNumber}_${model}_$timestamp.txt'));
    await logFile.writeAsString('開始獲取 $model 型號的規格數據...\n',
        mode: FileMode.append);

    try {
      await logFile.writeAsString('嘗試獲取 InputOutputCharacteristicsSpecs...\n',
          mode: FileMode.append);
      await fetchAndPrintInputOutputCharacteristicsSpecs(model);
      await logFile.writeAsString('成功獲取 InputOutputCharacteristicsSpecs\n',
          mode: FileMode.append);
    } catch (e, st) {
      await logFile.writeAsString('獲取 InputOutputCharacteristicsSpecs 失敗: $e\n',
          mode: FileMode.append);
      await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
    }

    try {
      await logFile.writeAsString('嘗試獲取 BasicFunctionTestSpecs...\n',
          mode: FileMode.append);
      await fetchAndPrintBasicFunctionTestSpecs(model);
      await logFile.writeAsString('成功獲取 BasicFunctionTestSpecs\n',
          mode: FileMode.append);
    } catch (e, st) {
      await logFile.writeAsString('獲取 BasicFunctionTestSpecs 失敗: $e\n',
          mode: FileMode.append);
      await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
    }

    try {
      await logFile.writeAsString('嘗試獲取 HipotTestSpecs...\n',
          mode: FileMode.append);
      await fetchAndPrintHipotTestSpecs(model);
      await logFile.writeAsString('成功獲取 HipotTestSpecs\n',
          mode: FileMode.append);
    } catch (e, st) {
      await logFile.writeAsString('獲取 HipotTestSpecs 失敗: $e\n',
          mode: FileMode.append);
      await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
    }

    try {
      await logFile.writeAsString('嘗試獲取 FailCountsForDevice...\n',
          mode: FileMode.append);
      await fetchFailCountsForDevice(model, serialNumber);
      await logFile.writeAsString('成功獲取 FailCountsForDevice\n',
          mode: FileMode.append);
    } catch (e, st) {
      await logFile.writeAsString('獲取 FailCountsForDevice 失敗: $e\n',
          mode: FileMode.append);
      await logFile.writeAsString('堆疊追蹤: $st\n', mode: FileMode.append);
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
    var logFilePath = '';
    if (Platform.isMacOS) {
      // macOS 路徑
      filePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova');
      logFilePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova', 'logs');
    } else if (Platform.isWindows) {
      // Windows 路徑
      filePath = path.join(
          Platform.environment['USERPROFILE'] ?? '', 'Test Result', 'Zerova');
      logFilePath = path.join(Platform.environment['USERPROFILE'] ?? '',
          'Test Result', 'Zerova', 'logs');
    } else {
      // 其他系統（如 Linux）
      filePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova');
      logFilePath = path.join(
          Platform.environment['HOME'] ?? '', 'Test Result', 'Zerova', 'logs');
    }


    //bill
    SharePointUploader(uploadOrDownload: 1, sn: '', model: model).startAuthorization(
      categoryTranslations: {
        "packageing_photo": "Packageing Photo ",
        "appearance_photo": "Appearance Photo ",
        "oqc_report": "OQC Report ",
      },
    );
    // 確保日誌目錄存在
    final logDirectory = Directory(logFilePath);
    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    // 建立日誌檔案
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final logFile =
        File(path.join(logFilePath, 'api_log_${sn}_$timestamp.txt'));

    try {
      //bill
/*
       // 嘗試從本地文件加載數據
       try {
         String jsonContent =
             await File("$filePath/$sn/T2449A003A1_test.json").readAsString();
         String testFunctionJsonContent =
             await File("$filePath/$sn/T2449A003A1_oqc.json").readAsString();
         String moduleJsonContent =
             await File("$filePath/$sn/T2449A003A1_keypart.json").readAsString();

         await logFile.writeAsString('成功從本地文件加載數據\n', mode: FileMode.append);
         await logFile.writeAsString('test.json 文件內容: $jsonContent\n', mode: FileMode.append);
         await logFile.writeAsString('oqc.json 文件內容: $testFunctionJsonContent\n', mode: FileMode.append);
         await logFile.writeAsString('keypart.json 文件內容: $moduleJsonContent\n', mode: FileMode.append);

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
       } catch (e) {
         await logFile.writeAsString('從本地文件加載數據失敗: $e\n', mode: FileMode.append);
         await logFile.writeAsString('嘗試從 API 獲取數據...\n', mode: FileMode.append);
       }
*/

      //call api
      final apiClient = OqcApiClient();
      await logFile.writeAsString('開始呼叫 API 獲取數據，SN: $sn, 型號: $model\n',
          mode: FileMode.append);

      // 單獨處理每個 API 呼叫，以便記錄詳細信息
      try {
        await logFile.writeAsString('正在呼叫 fetchAndSaveKeyPartData API...\n',
            mode: FileMode.append);
        final keyPartData = await apiClient.fetchAndSaveKeyPartData(sn);
        await logFile.writeAsString('fetchAndSaveKeyPartData API 呼叫成功\n',
            mode: FileMode.append);
        await logFile.writeAsString('返回數據: ${jsonEncode(keyPartData)}\n',
            mode: FileMode.append);
        var psuSerialNumbers = Psuserialnumber.fromJsonList(keyPartData);

        await logFile.writeAsString('正在呼叫 fetchAndSaveOqcData API...\n',
            mode: FileMode.append);
        final oqcData = await apiClient.fetchAndSaveOqcData(sn);
        await logFile.writeAsString('fetchAndSaveOqcData API 呼叫成功\n',
            mode: FileMode.append);
        await logFile.writeAsString('返回數據: ${jsonEncode(oqcData)}\n',
            mode: FileMode.append);
        var testFunction =
            AppearanceStructureInspectionFunctionResult.fromJson(oqcData);

        await logFile.writeAsString('正在呼叫 fetchAndSaveTestData API...\n',
            mode: FileMode.append);
        final testData = await apiClient.fetchAndSaveTestData(sn);
        await logFile.writeAsString('fetchAndSaveTestData API 呼叫成功\n',
            mode: FileMode.append);
        await logFile.writeAsString('返回數據: ${jsonEncode(testData)}\n',
            mode: FileMode.append);
        var softwareVersion = SoftwareVersion.fromJsonList(testData);
        var inputOutputCharacteristics =
            InputOutputCharacteristics.fromJsonList(testData);
        var protectionTestResults =
            ProtectionFunctionTestResult.fromJsonList(testData);

        await logFile.writeAsString('所有 API 呼叫成功，正在導航到 OQC 報告頁面\n',
            mode: FileMode.append);

        context.push('/oqc-report', extra: {
          'sn': sn,
          'model': model,
          'psuSerialNumbers': psuSerialNumbers,
          'softwareVersion': softwareVersion,
          'testFunction': testFunction,
          'inputOutputCharacteristics': inputOutputCharacteristics,
          'protectionTestResults': protectionTestResults,
        });
      } catch (e, st) {
        await logFile.writeAsString('API 呼叫過程中發生錯誤: $e\n , st : $st',
            mode: FileMode.append);

        // 顯示錯誤對話框
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(context.tr('error')),
              content: Text('${context.tr('api_error')}: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.tr('ok')),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // 記錄整體處理過程中的任何錯誤
      await logFile.writeAsString('處理過程中發生未預期的錯誤: $e\n', mode: FileMode.append);

      // 顯示錯誤對話框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(context.tr('error')),
            content: Text('${context.tr('unexpected_error')}: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('ok')),
              ),
            ],
          );
        },
      );
    }
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
                  backgroundColor: Colors.black,
                  // 黑底
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                  // 白字
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
