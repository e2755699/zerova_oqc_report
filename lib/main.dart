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
import 'package:zerova_oqc_report/src/report/model/protection_function_testresult.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

// import 'package:pdf_text/pdf_text.dart';
import 'package:zerova_oqc_report/src/report/oqc_report.dart';

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
      //home: ExcelReaderScreen(),
      home: JSONReaderScreen(),
    );
  }
}

class JSONReaderScreen extends StatefulWidget {
  @override
  _JSONReaderScreenState createState() => _JSONReaderScreenState();
}

class _JSONReaderScreenState extends State<JSONReaderScreen> {
  Softwareversion? _softwareVersion;
  Psuserialnumber? _psuSerialNumbers; // 添加存儲 PSU Serial Number 的變量
  InputOutputCharacteristics? _inputOutputCharacteristics;
  ProtectionFunctionTestResult?
      _testResults; // 添加存儲 Protection Function Test 結果的變量
  Testfunction? _testfunction; // 添加存儲 Protection Function Test 結果的變量
  /// 選擇並讀取 JSON 檔案
  Future<void> _pickAndReadJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      String jsonContent = await File(result.files.single.path!).readAsString();
      /*String testFunctionJsonContent = await File(
              "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2433A031A0_oqc.json")
          .readAsString();
      String moduleJsonContent =
          await File("C:\\Users\\USER\\Downloads\\1234keypart.json")
              .readAsString();*/
      String testFunctionJsonContent = await File(
          "C:\\Users\\60040\\Downloads\\T2433A031A0_oqc.json")
          .readAsString();
      String moduleJsonContent =
      await File("C:\\Users\\60040\\Downloads\\1234keypart.json")
          .readAsString();
      List<dynamic> data = jsonDecode(jsonContent);
      List<dynamic> testFuncionData = jsonDecode(testFunctionJsonContent);
      List<dynamic> moduleData = jsonDecode(moduleJsonContent);

      // 使用 `softwareversion`, `psuserialnumber` 和 `protectionfunctiontestresult` 的方法處理數據
      setState(() {
        _softwareVersion = Softwareversion.fromJsonList(data);
        _psuSerialNumbers =
            Psuserialnumber.fromJsonList(moduleData); // 提取多筆 PSU Serial Number
        _inputOutputCharacteristics =
            InputOutputCharacteristics.fromJsonList(data);
        _testResults =
            ProtectionFunctionTestResult.fromJsonList(data); // 提取測試結果
        _testfunction = Testfunction.fromJsonList(testFuncionData);
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
          _testfunction =  Testfunction.fromJsonList(res[1]);
          _softwareVersion = Softwareversion.fromJsonList(res[2]);
          _inputOutputCharacteristics =
              InputOutputCharacteristics.fromJsonList(res[2]);
          _testResults =
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
              ElevatedButton(
                /*onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OqcReport(model: _softwareVersion!),
                    ),
                  );
                },*/
                onPressed: _pickAndReadJsonFile,
                child: Text('生成並儲存 PDF 檔案'),
              ),

              // 顯示軟體版本
              if (_softwareVersion != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CSU: ${_softwareVersion!.csuRootfs.value}"),
                      Text("FAN Module: ${_softwareVersion!.fanModule.value}"),
                      Text(
                          "Relay Board: ${_softwareVersion!.relayModule.value}"),
                      Text("MCU: ${_softwareVersion!.primaryMCU.value}"),
                      Text("CCS 1: ${_softwareVersion!.connector1.value}"),
                      Text("CCS 2: ${_softwareVersion!.connector2.value}"),
                      Text("UI: ${_softwareVersion!.lcmUI.value}"),
                      Text("LED: ${_softwareVersion!.ledModule.value}"),
                    ],
                  ),
                ),
              // 顯示 PSU Serial Numbers
              if (_psuSerialNumbers != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PSU Serial Numbers:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._psuSerialNumbers!.psuSN.map((serial) {
                        return Text("Serial Number: ${serial.value}");
                      }).toList(),
                    ],
                  ),
                ),
              // 顯示 Protection Function Test 結果
              if (_inputOutputCharacteristics != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Input Voltage 顯示
                      Text(
                        "Left Input Voltage:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._inputOutputCharacteristics!.leftInputVoltage
                          .map((measurement) {
                        return Text(
                          "${measurement.name}: ${measurement.value} (Spec: ${measurement.spec})",
                        );
                      }).toList(),

                      SizedBox(height: 16),

                      // Left Input Current 顯示
                      Text(
                        "Left Input Current:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._inputOutputCharacteristics!.leftInputCurrent
                          .map((measurement) {
                        return Text(
                          "${measurement.name}: ${measurement.value} (Spec: ${measurement.spec})",
                        );
                      }).toList(),

                      SizedBox(height: 16),

                      // Right Input Voltage 顯示
                      Text(
                        "Right Input Voltage:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._inputOutputCharacteristics!.rightInputVoltage
                          .map((measurement) {
                        return Text(
                          "${measurement.name}: ${measurement.value} (Spec: ${measurement.spec})",
                        );
                      }).toList(),

                      SizedBox(height: 16),

                      // Right Input Current 顯示
                      Text(
                        "Right Input Current:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._inputOutputCharacteristics!.rightInputCurrent
                          .map((measurement) {
                        return Text(
                          "${measurement.name}: ${measurement.value} (Spec: ${measurement.spec})",
                        );
                      }).toList(),

                      SizedBox(height: 16),

                      // 總結數據
                      Text(
                        "Summary Data:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                          "Left Total Input Power: ${_inputOutputCharacteristics!.leftTotalInputPower.value}"),
                      Text(
                          "Right Total Input Power: ${_inputOutputCharacteristics!.rightTotalInputPower.value}"),
                      Text(
                          "Left Output Voltage: ${_inputOutputCharacteristics!.leftOutputVoltage.value}"),
                      Text(
                          "Left Output Current: ${_inputOutputCharacteristics!.leftOutputCurrent.value}"),
                      Text(
                          "Left Total Output Power: ${_inputOutputCharacteristics!.leftTotalOutputPower.value}"),
                      Text(
                          "Right Output Voltage: ${_inputOutputCharacteristics!.rightOutputVoltage.value}"),
                      Text(
                          "Right Output Current: ${_inputOutputCharacteristics!.rightOutputCurrent.value}"),
                      Text(
                          "Right Total Output Power: ${_inputOutputCharacteristics!.rightTotalOutputPower.value}"),
                      Text(
                          "Efficiency: ${_inputOutputCharacteristics!.eff.value}"),
                      Text(
                          "Power Factor: ${_inputOutputCharacteristics!.powerFactor.value}"),
                      Text("THD: ${_inputOutputCharacteristics!.thd.value}"),
                      Text(
                          "Standby Total Input Power: ${_inputOutputCharacteristics!.standbyTotalInputPower.value}"),
                    ],
                  ),
                ),
              if (_testResults != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Protection Function Test Results:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // 第一表：Fail Counts 顯示
                      Text(
                          "Emergency Test: ${_testResults!.emergencyStopFailCount.value}, Status: ${_testResults!.emergencyStopFailCount.judgment}"),
                      Text(
                          "Door Open Test: ${_testResults!.doorOpenFailCount.value}, Status: ${_testResults!.doorOpenFailCount.judgment}"),
                      Text(
                          "Ground Fault Test: ${_testResults!.groundFaultFailCount.value}, Status: ${_testResults!.groundFaultFailCount.judgment}"),
                      SizedBox(height: 16),

                      // 第二表：左槍結果顯示
                      Text(
                        "Left Gun Results:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ..._testResults!.leftGunResults.entries.map((entry) {
                        final key = entry.key;
                        final measurement = entry.value;
                        return Text(
                            "$key: ${measurement.value}, Status: ${measurement.judgment}");
                      }).toList(),
                      SizedBox(height: 16),

                      // 第二表：右槍結果顯示
                      Text(
                        "Right Gun Results:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ..._testResults!.rightGunResults.entries.map((entry) {
                        final key = entry.key;
                        final measurement = entry.value;
                        return Text(
                            "$key: ${measurement.value}, Status: ${measurement.judgment}");
                      }).toList(),
                    ],
                  ),
                ),
              if (_testfunction != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("機櫃: ${_testfunction!.cabinet.value}"),
                      Text("銅排: ${_testfunction!.copper.value}"),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
