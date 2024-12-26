// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
// import 'package:zerova_oqc_report/src/report/model/protection_function_testresult.dart';
// import 'package:zerova_oqc_report/src/report/model/software_version.dart';
// import 'package:zerova_oqc_report/src/report/model/test_function.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Software Version Reader',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: JSONReaderScreen(),
//     );
//   }
// }
//
// class JSONReaderScreen extends StatefulWidget {
//   @override
//   _JSONReaderScreenState createState() => _JSONReaderScreenState();
// }
//
// class _JSONReaderScreenState extends State<JSONReaderScreen> {
//   SoftwareVersion? _softwareVersion;
//   Psuserialnumber? _psuSerialNumbers; // 添加存儲 PSU Serial Number 的變量
//   ProtectionFunctionTestResult?
//       _testResults; // 添加存儲 Protection Function Test 結果的變量
//   TestFunction? _testfunction; // 添加存儲 Protection Function Test 結果的變量
//   /// 選擇並讀取 JSON 檔案
//   Future<void> _pickAndReadJsonFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//     );
//
//     if (result != null) {
//       String jsonContent = await File(result.files.single.path!).readAsString();
//       String jsonContent2 = await File(
//               "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2433A031A0_oqc.json")
//           .readAsString();
//       List<dynamic> data = jsonDecode(jsonContent);
//       List<dynamic> data2 = jsonDecode(jsonContent2);
//
//       // 使用雙反斜線或正斜線修正路徑
// /*      String jsonPath = "C:\\Users\\USER\\Downloads\\resultfile\\resultfile\\files\\T2433A031A0_oqc.json";
//       String jsonContent = await File(jsonPath).readAsString();
//       List<dynamic> data = jsonDecode(jsonContent);*/
//
//       // 使用 `softwareversion`, `psuserialnumber` 和 `protectionfunctiontestresult` 的方法處理數據
//       setState(() {
//         _softwareVersion = SoftwareVersion.fromJsonList(data);
//         _psuSerialNumbers =
//             Psuserialnumber.fromJsonList(data); // 提取多筆 PSU Serial Number
//         _testResults =
//             ProtectionFunctionTestResult.fromJsonList(data); // 提取測試結果
//         _testfunction = TestFunction.fromJsonList(data2);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Software Version Reader'),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             children: [
//               ElevatedButton(
//                 onPressed: _pickAndReadJsonFile,
//                 child: Text('讀取 JSON 檔案'),
//               ),
//               // 顯示軟體版本
//               if (_softwareVersion != null)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("CSU: ${_softwareVersion!.csuRootfs.value}"),
//                       Text("FAN Module: ${_softwareVersion!.fanModule.value}"),
//                       Text(
//                           "Relay Board: ${_softwareVersion!.relayModule.value}"),
//                       Text("MCU: ${_softwareVersion!.primaryMCU.value}"),
//                       Text("CCS 1: ${_softwareVersion!.connector1.value}"),
//                       Text("CCS 2: ${_softwareVersion!.connector2.value}"),
//                       Text("UI: ${_softwareVersion!.lcmUI.value}"),
//                       Text("LED: ${_softwareVersion!.ledModule.value}"),
//                     ],
//                   ),
//                 ),
//               // 顯示 PSU Serial Numbers
//               if (_psuSerialNumbers != null)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "PSU Serial Numbers:",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       ..._psuSerialNumbers!.psuSN.map((serial) {
//                         return Text("Serial Number: ${serial.value}");
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               // 顯示 Protection Function Test 結果
//               if (_testResults != null)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Protection Function Test Results:",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       // 第一表：Fail Counts 顯示
//                       Text(
//                           "Emergency Test: ${_testResults!.emergencyStopFailCount.value}, Status: ${_testResults!.emergencyStopFailCount.judgment}"),
//                       Text(
//                           "Door Open Test: ${_testResults!.doorOpenFailCount.value}, Status: ${_testResults!.doorOpenFailCount.judgment}"),
//                       Text(
//                           "Ground Fault Test: ${_testResults!.groundFaultFailCount.value}, Status: ${_testResults!.groundFaultFailCount.judgment}"),
//                       SizedBox(height: 16),
//
//                       // 第二表：左槍結果顯示
//                       Text(
//                         "Left Gun Results:",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       ..._testResults!.leftGunResults.entries.map((entry) {
//                         final key = entry.key;
//                         final measurement = entry.value;
//                         return Text(
//                             "$key: ${measurement.value}, Status: ${measurement.judgment}");
//                       }).toList(),
//                       SizedBox(height: 16),
//
//                       // 第二表：右槍結果顯示
//                       Text(
//                         "Right Gun Results:",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       ..._testResults!.rightGunResults.entries.map((entry) {
//                         final key = entry.key;
//                         final measurement = entry.value;
//                         return Text(
//                             "$key: ${measurement.value}, Status: ${measurement.judgment}");
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               if (_testfunction != null)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("機櫃: ${_testfunction!.cabinet.value}"),
//                       // Text("銅排: ${_testfunction!.copper.value}"),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
