import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:zerova_oqc_report/src/client/oqc_api_client.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/oqc/oqc_report_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LoadFileHelper {
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
            SizedBox(height: 40),

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
                      return InputSNDialog(); // 彈出視窗
                    },
                  );
                },
                child: Text(context.tr('input_sn_model')),
              ),
            ),
            SizedBox(height: 20),

            // 按鈕2: QR Scan
            SizedBox(
              width: 300, // 增加按鈕寬度
              height: 60, // 增加按鈕高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20), // 增加文字大小
                ),
                onPressed: () {
                  loadFile();
                },
                child: Text(context.tr('qr_code_scan')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadFile() async {
    // String? res = await SimpleBarcodeScanner.scanBarcode(
    //   context,
    //   barcodeAppBar: const BarcodeAppBar(
    //     appBarTitle: 'Test',
    //     centerTitle: false,
    //     enableBackButton: true,
    //     backButtonIcon: Icon(Icons.arrow_back_ios),
    //   ),
    //   isShowFlashIcon: true,
    //   delayMillis: 500,
    //   cameraFace: CameraFace.back,
    //   scanFormat: ScanFormat.ONLY_BARCODE,
    // );

    var result = "T2437A011A0 SN8765432";
    String model = "";
    String serialNumber = "";
    // 將 result 拆成兩部分
    List<String> parts = result.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      model = parts[0];
      serialNumber = parts[1];
    } else {
      model = result;
      serialNumber = ''; // 若分割後不足兩部分，則 part2 保持空字串
    }

    //hard code
    /*String testData = await File(
            "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2437A011A0_test.json")
        .readAsString();
    String oqcData = await File(
            "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2433A031A0_oqc.json")
        .readAsString();
    String moduleJsonContent = await File(
            "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\1234keypart.json")
        .readAsString();*/
    await loadFileModule(serialNumber, model, context);

    // final apiClient = OqcApiClient();
    //
    // // 將 model 和 serialNumber 打印到 console
    // Future.wait<List<dynamic>>([
    //   apiClient.fetchAndSaveKeyPartData(serialNumber),
    //   apiClient.fetchAndSaveOqcData(serialNumber),
    //   apiClient.fetchAndSaveTestData(serialNumber)
    // ]).then((res) {
    //   var psuSerialNumbers = Psuserialnumber.fromJsonList(res[0]);
    //   var testFunction =
    //       AppearanceStructureInspectionFunctionResult.fromJson(res[1]);
    //   var softwareVersion = SoftwareVersion.fromJsonList(res[2]);
    //   var inputOutputCharacteristics =
    //       InputOutputCharacteristics.fromJsonList(res[2]);
    //   var protectionTestResults =
    //       ProtectionFunctionTestResult.fromJsonList(res[2]);
    //   context.push('/oqc-report', extra: {
    //     'softwareVersion': softwareVersion,
    //     'testFunction': testFunction,
    //     'inputOutputCharacteristics': inputOutputCharacteristics,
    //     'protectionTestResults': protectionTestResults,
    //   });
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

mixin LoadFileHelper {
  Future<void> loadFileModule(
      String sn, String model, BuildContext context) async {
    // String jsonContent = await File(
    //     "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2437A011A0_test.json")
    //     .readAsString();
    // String testFunctionJsonContent = await File(
    //     "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2433A031A0_oqc.json")
    //     .readAsString();
    // String moduleJsonContent = await File(
    //     "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\1234keypart.json")
    //     .readAsString();
    String jsonContent = await File(
        "C:\\Users\\USER\\OQC\\T2449A003A1\\T2449A003A1_test.json")
        .readAsString();
    String testFunctionJsonContent = await File(
        "C:\\Users\\USER\\OQC\\T2449A003A1\\T2449A003A1_oqc.json")
        .readAsString();
    String moduleJsonContent = await File(
        "C:\\Users\\USER\\OQC\\T2449A003A1\\T2449A003A1_keypart.json")
        .readAsString();

    List<dynamic> data = jsonDecode(jsonContent);
    List<dynamic> testFuncionData = jsonDecode(testFunctionJsonContent);
    List<dynamic> moduleData = jsonDecode(moduleJsonContent);

    var softwareVersion = SoftwareVersion.fromJsonList(data);
    var psuSerialNumbers =
    Psuserialnumber.fromJsonList(moduleData); // 提取多筆 PSU Serial Number
    var inputOutputCharacteristics =
    InputOutputCharacteristics.fromJsonList(data);
    var protectionTestResults =
    ProtectionFunctionTestResult.fromJsonList(data); // 提取測試結果
    var testFunction =
    AppearanceStructureInspectionFunctionResult.fromJson(testFuncionData);

    context.push('/oqc-report', extra: {
      'psuSerialNumbers': psuSerialNumbers,
      'softwareVersion': softwareVersion,
      'testFunction': testFunction,
      'inputOutputCharacteristics': inputOutputCharacteristics,
      'protectionTestResults': protectionTestResults,
    });


    // final apiClient = OqcApiClient();
    //
    // // 將 model 和 serialNumber 打印到 console
    // Future.wait<List<dynamic>>([
    //   apiClient.fetchAndSaveKeyPartData(serialNumber),
    //   apiClient.fetchAndSaveOqcData(serialNumber),
    //   apiClient.fetchAndSaveTestData(serialNumber)
    // ]).then((res) {
    //   var psuSerialNumbers = Psuserialnumber.fromJsonList(res[0]);
    //   var testFunction =
    //       AppearanceStructureInspectionFunctionResult.fromJson(res[1]);
    //   var softwareVersion = SoftwareVersion.fromJsonList(res[2]);
    //   var inputOutputCharacteristics =
    //       InputOutputCharacteristics.fromJsonList(res[2]);
    //   var protectionTestResults =
    //       ProtectionFunctionTestResult.fromJsonList(res[2]);
    //   context.push('/oqc-report', extra: {
    //     'softwareVersion': softwareVersion,
    //     'testFunction': testFunction,
    //     'inputOutputCharacteristics': inputOutputCharacteristics,
    //     'protectionTestResults': protectionTestResults,
    //   });
  }
}

class InputSNDialog extends StatefulWidget {
  @override
  _InputSNDialogState createState() => _InputSNDialogState();
}

class _InputSNDialogState extends State<InputSNDialog> with LoadFileHelper {
  final _formKey = GlobalKey<FormState>();
  final _snController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('輸入SN和Model'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _snController,
              decoration: InputDecoration(
                labelText: 'SN',
                hintText: '請輸入SN',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入SN';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'Model Name',
                hintText: '請輸入Model Name',
                prefixIcon: Icon(Icons.text_fields),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入Model Name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 關閉彈出視窗
          },
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final sn = _snController.text;
              final model = _modelController.text;

              loadFile(sn, model, context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SN: $sn, Model: $model 已提交'),
                ),
              );
              Navigator.of(context).pop(); // 關閉彈出視窗
            }
          },
          child: Text('提交'),
        ),
      ],
    );
  }

  /*Future<void> _qr() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Test',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
    );
  }*/

  Future<void> loadFile(String sn, String model, BuildContext context) async {
    loadFileModule(sn, model, context);
  }
}
