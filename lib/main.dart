import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zerova_oqc_report/src/client/oqc_api_client.dart';
import 'package:zerova_oqc_report/src/report/model/old_charge_module.dart';
import 'package:zerova_oqc_report/src/report/model/old_oqc_report_model.dart';
import 'package:zerova_oqc_report/src/report/model/old_software_version.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

// import 'package:pdf_text/pdf_text.dart';
import 'package:zerova_oqc_report/src/report/oqc_report.dart';
import 'package:zerova_oqc_report/src/widget/oqc/appearance_structure_inspection_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/basic_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/input_output_characteristics_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/protection_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/psu_serial_numbers_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/software_version.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel Reader & PDF Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JSONReaderScreen(),
    );
  }
}

class JSONReaderScreen extends StatefulWidget {
  @override
  _JSONReaderScreenState createState() => _JSONReaderScreenState();
}

class _JSONReaderScreenState extends State<JSONReaderScreen> {
  SoftwareVersion? _softwareVersion;
  Psuserialnumber? _psuSerialNumbers; // 添加存儲 PSU Serial Number 的變量
  InputOutputCharacteristics? _inputOutputCharacteristics;
  ProtectionFunctionTestResult?
      _protectionTestResults; // 添加存儲 Protection Function Test 結果的變量
  AppearanceStructureInspectionFunctionResult? _testfunction; // 添加存儲 Protection Function Test 結果的變量
  /// 選擇並讀取 JSON 檔案
  Future<void> _pickAndReadJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      // String jsonContent = await File(result.files.single.path!).readAsString();
      /*String testFunctionJsonContent = await File(
              "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2433A031A0_oqc.json")
          .readAsString();
      String moduleJsonContent =
          await File("C:\\Users\\USER\\Downloads\\1234keypart.json")
              .readAsString();*/
      String jsonContent = await File(
              "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2437A011A0_test.json")
          .readAsString();
      String testFunctionJsonContent = await File(
              "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2433A031A0_oqc.json")
          .readAsString();
      String moduleJsonContent = await File(
              "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\1234keypart.json")
          .readAsString();
      List<dynamic> data = jsonDecode(jsonContent);
      List<dynamic> testFuncionData = jsonDecode(testFunctionJsonContent);
      List<dynamic> moduleData = jsonDecode(moduleJsonContent);

      // 使用 `softwareversion`, `psuserialnumber` 和 `protectionfunctiontestresult` 的方法處理數據
      setState(() {
        _softwareVersion = SoftwareVersion.fromJsonList(data);
        _psuSerialNumbers =
            Psuserialnumber.fromJsonList(moduleData); // 提取多筆 PSU Serial Number
        _inputOutputCharacteristics =
            InputOutputCharacteristics.fromJsonList(data);
        _protectionTestResults =
            ProtectionFunctionTestResult.fromJsonList(data); // 提取測試結果
        _testfunction = AppearanceStructureInspectionFunctionResult.fromJson(testFuncionData);
      });
    }
  }

  String result = '';
  String Model = '';
  String SN = '';

  Future<void> _qr() async {
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
    setState(() async {
      result = res as String;
      //result = "T1234567 SN8765432";
      // 將 result 拆成兩部分
      List<String> parts = result.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        Model = parts[0];
        SN = parts[1];
      } else {
        Model = result;
        SN = ''; // 若分割後不足兩部分，則 part2 保持空字串
      }
      final apiClient = OqcApiClient();

      var serialNumber = SN;
      // 將 Model 和 SN 打印到 console
      Future.wait<List<dynamic>>([
        apiClient.fetchAndSaveKeyPartData(serialNumber),
        apiClient.fetchAndSaveOqcData(serialNumber),
        apiClient.fetchAndSaveTestData(serialNumber)
      ]).then((res) {
        setState(() {
          _psuSerialNumbers = Psuserialnumber.fromJsonList(res[0]);
          _testfunction = AppearanceStructureInspectionFunctionResult.fromJson(res[1]);
          _softwareVersion = SoftwareVersion.fromJsonList(res[2]);
          _inputOutputCharacteristics =
              InputOutputCharacteristics.fromJsonList(res[2]);
          _protectionTestResults =
              ProtectionFunctionTestResult.fromJsonList(res[2]);
        });
      });

      print('Model: $Model');
      print('SN: $SN');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OQC Report'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _qr,
                child: Text('掃描QR-Code'),
              ),
              ElevatedButton(
                onPressed: _pickAndReadJsonFile,
                child: Text('讀取 JSON 檔案'),
              ),
              if (_psuSerialNumbers != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_psuSerialNumbers != null)
                        PsuSerialNumbersTable(_psuSerialNumbers!),
                    ],
                  ),
                ),
              if (_softwareVersion != null)
                SoftwareVersionTable(_softwareVersion!),
              if (_testfunction != null)
                AppearanceStructureInspectionTable(_testfunction!),
              if (_inputOutputCharacteristics != null)
                InputOutputCharacteristicsTable(_inputOutputCharacteristics!),
              if (_inputOutputCharacteristics != null)
                BasicFunctionTestTable(_inputOutputCharacteristics!.baseFunctionTestResult),
              if (_protectionTestResults != null)
                ProtectionFunctionTestTable(
                  _protectionTestResults!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
