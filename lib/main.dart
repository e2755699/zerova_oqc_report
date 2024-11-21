import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_text/pdf_text.dart';

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
      home: ExcelReaderScreen(),
    );
  }
}

class ExcelReaderScreen extends StatefulWidget {
  @override
  _ExcelReaderScreenState createState() => _ExcelReaderScreenState();
}

class _ExcelReaderScreenState extends State<ExcelReaderScreen> {
  List<Map<String, dynamic>> _filteredData = [];  // 用於存儲 Module ID 篩選結果
  List<Map<String, dynamic>> _swvFilteredData = []; // 用於存儲 SoftWare Version 篩選結果
  List<Map<String, dynamic>> _IOCharacteristicsFilteredData = []; // 用於存儲 IO Data 篩選結果
  List<Map<String, dynamic>> _ProtectionFunctionTestResultData = []; // 用於存儲 Protection Function Test 結果
  String? _extractedVoltage = ""; // 用來存儲從PDF提取的Present Charging Voltage

  // 選擇並讀取 Excel 檔案
  Future<void> _pickAndReadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // 找到 "Keypart" 工作表並篩選 PSU S/N
      var keypartSheet = excel.tables['Keypart'];
      _filteredData.clear();
      if (keypartSheet != null) {
        for (int rowIndex = 1; rowIndex < keypartSheet.maxRows; rowIndex++) {
          var row = keypartSheet.row(rowIndex);
          if (row.any((cell) =>
          cell?.value?.toString().contains("CHARGING MODULE") ?? false)) {
            var row2 = row[0];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var chargeModule = ChargeModule.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "PSUSN": chargeModule.snId,
              };
              _filteredData.add(rowData);
              print("PSU S/N ${chargeModule.snId}");
            }
          }
        }
      }

      // 找到 "Test_value" 工作表並篩選 SW ver
      var testValueSheet = excel.tables['Test_value'];
      _swvFilteredData.clear();
      if (testValueSheet != null) {
        for (int rowIndex = 1; rowIndex < testValueSheet.maxRows; rowIndex++) {
          var row = testValueSheet.row(rowIndex);
          if (row.any((cell) => cell?.value?.toString() == "CSU Rootfs" ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var swvData = SWVerData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "CSU": swvData.keyword,
              };
              _swvFilteredData.add(rowData);
              print("CSU Rootfs: ${swvData.keyword}");
            }
          }
          if (row.any((cell) => cell?.value?.toString() == "FAN Module" ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var swvData = SWVerData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "FANModule": swvData.keyword,
              };
              _swvFilteredData.add(rowData);
              print("FAN Module: ${swvData.keyword}");
            }
          }
          if (row.any((cell) => cell?.value?.toString() == "Relay Module" ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var swvData = SWVerData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "RelayModule": swvData.keyword,
              };
              _swvFilteredData.add(rowData);
              print("Relay Module: ${swvData.keyword}");
            }
          }
          if (row.any((cell) => cell?.value?.toString() == "Primary MCU" ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var swvData = SWVerData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "PrimaryMCU": swvData.keyword,
              };
              _swvFilteredData.add(rowData);
              print("Primary MCU: ${swvData.keyword}");
            }
          }
          if ((row.any((cell) => cell?.value?.toString() == "Connector 1" ?? false))
              || (row.any((cell) => cell?.value?.toString() == "Connector 2" ?? false))) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var swvData = SWVerData.fromExcel(row2.value.toString());

              if ((row.any((cell) => cell?.value?.toString() == "Connector 1" ?? false))){
                Map<String, dynamic> rowData = {
                  "Connector1": swvData.keyword,
                };
                _swvFilteredData.add(rowData);
                print("Connector 1: ${swvData.keyword}");
              }
              if ((row.any((cell) => cell?.value?.toString() == "Connector 2" ?? false))) {
                Map<String, dynamic> rowData = {
                  "Connector2": swvData.keyword,
                };
                _swvFilteredData.add(rowData);
                print("Connector 2: ${swvData.keyword}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString() == "LCM UI" ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var swvData = SWVerData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "LCMUI": swvData.keyword,
              };
              _swvFilteredData.add(rowData);
              print("LCM UI: ${swvData.keyword}");
            }
          }
          if (row.any((cell) => cell?.value?.toString() == "LED Module" ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var swvData = SWVerData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "LEDModule": swvData.keyword,
              };
              _swvFilteredData.add(rowData);
              print("LED Module: ${swvData.keyword}");
            }
          }
        }
      }

      // 找到 "Test_value" 工作表並篩選 IO Data
      var ioSheet = excel.tables['Test_value'];
      _IOCharacteristicsFilteredData.clear();
      if (ioSheet != null) {
        int L_Input_Voltage=0,R_Input_Voltage=0;
        int L_Input_Current=0,R_Input_Current=0;
        int L_Total_Input_Power=0,R_Total_Input_Power=0;
        int L_Output_Voltage=0,R_Output_Voltage=0;
        int L_Output_Current=0,R_Output_Current=0;
        int L_Output_Power=0,R_Output_Power=0;
        int Eff=0,PowerFactor=0,THD=0,StandbyTotalInputPower=0;
        for (int rowIndex = 1; rowIndex < ioSheet.maxRows; rowIndex++) {
          var row = ioSheet.row(rowIndex);
          if (row.any((cell) => cell?.value?.toString().contains("Input_Voltage") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("[6]") ?? false) && L_Input_Voltage < 3) {
                Map<String, dynamic> rowData = {
                  "L_Input_V": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                L_Input_Voltage++;
                print("L_Input_Voltage$L_Input_Voltage: ${ioValue.IOData}");
              }
              else if (row.any((cell) => cell?.value?.toString().contains("[13]") ?? false) && R_Input_Voltage < 3) {
                Map<String, dynamic> rowData = {
                  "R_Input_V": ioValue.IOData,
                };
                R_Input_Voltage++;
                _IOCharacteristicsFilteredData.add(rowData);
                print("R_Input_Voltage$R_Input_Voltage: ${ioValue.IOData}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Input_Current") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("[6]") ?? false) && L_Input_Current < 3) {
                Map<String, dynamic> rowData = {
                  "L_Input_A": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                L_Input_Current++;
                print("L_Input_Current$L_Input_Current: ${ioValue.IOData}");
              }
              else if (row.any((cell) => cell?.value?.toString().contains("[13]") ?? false) && R_Input_Current < 3) {
                Map<String, dynamic> rowData = {
                  "R_Input_A": ioValue.IOData,
                };
                R_Input_Current++;
                _IOCharacteristicsFilteredData.add(rowData);
                print("R_Input_Current$R_Input_Current: ${ioValue.IOData}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Total_Input_Power") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("[6]") ?? false) && L_Total_Input_Power == 0) {
                Map<String, dynamic> rowData = {
                  "L_Total_Input_P": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                L_Total_Input_Power = 1;
                print("L_Total_Input_Power ${ioValue.IOData}");
              }
              else if (row.any((cell) => cell?.value?.toString().contains("[13]") ?? false) && R_Total_Input_Power == 0) {
                Map<String, dynamic> rowData = {
                  "R_Total_Input_P": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                R_Total_Input_Power = 1;
                print("R_Total_Input_Power ${ioValue.IOData}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Output_Voltage") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("[6]") ?? false) && L_Output_Voltage == 0) {
                Map<String, dynamic> rowData = {
                  "L_Output_V": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                L_Output_Voltage = 1;
                print("L_Output_Voltage ${ioValue.IOData}");
              }
              else if (row.any((cell) => cell?.value?.toString().contains("[13]") ?? false) && R_Output_Voltage == 0) {
                Map<String, dynamic> rowData = {
                  "R_Output_V": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                R_Output_Voltage = 1;
                print("R_Output_Voltage ${ioValue.IOData}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Output_Current") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("[6]") ?? false) && L_Output_Current == 0) {
                Map<String, dynamic> rowData = {
                  "L_Output_A": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                L_Output_Current = 1;
                print("L_Output_Current ${ioValue.IOData}");
              }
              else if (row.any((cell) => cell?.value?.toString().contains("[13]") ?? false) && R_Output_Current == 0) {
                Map<String, dynamic> rowData = {
                  "R_Output_A": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                R_Output_Current = 1;
                print("R_Output_Current ${ioValue.IOData}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Output_Power") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("[6]") ?? false) && L_Output_Power == 0) {
                Map<String, dynamic> rowData = {
                  "L_Output_P": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                L_Output_Power = 1;
                print("L_Output_Power ${ioValue.IOData}");
              }
              else if (row.any((cell) => cell?.value?.toString().contains("[13]") ?? false) && R_Output_Power == 0) {
                Map<String, dynamic> rowData = {
                  "R_Output_P": ioValue.IOData,
                };
                _IOCharacteristicsFilteredData.add(rowData);
                R_Output_Power = 1;
                print("R_Output_Power ${ioValue.IOData}");
              }
            }
          }
          if ((row.any((cell) => cell?.value?.toString() == "Eff") ?? false) || (row.any((cell) => cell?.value?.toString() == "EFF") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());
              Map<String, dynamic> rowData = {
                "EFF": ioValue.IOData,
              };
              if (Eff == 0) {
                _IOCharacteristicsFilteredData.add(rowData);
                Eff = 1;
                print("Eff ${ioValue.IOData}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("PowerFactor") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());
              Map<String, dynamic> rowData = {
                "PowerFactor": ioValue.IOData,
              };
              if (PowerFactor < 3) {
                _IOCharacteristicsFilteredData.add(rowData);
                PowerFactor++;
                print("PowerFactor$PowerFactor ${ioValue.IOData}");
              }
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("THD") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());
              Map<String, dynamic> rowData = {
                "THD": ioValue.IOData,
              };
              if (THD < 3) {
                _IOCharacteristicsFilteredData.add(rowData);
                THD++;
                print("THD$THD ${ioValue.IOData}");
              }
            }
          }
          if ((row.any((cell) => cell?.value?.toString().contains("Standby_Total_Input_Power") ?? false)) || (row.any((cell) => cell?.value?.toString().contains("Standby Total Input Power") ?? false))) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var ioValue = IOCharacteristics.fromExcel(
                  row2.value.toString());
              Map<String, dynamic> rowData = {
                "StandbyTotalInputPower": ioValue.IOData,
              };
              if (StandbyTotalInputPower == 0) {
                _IOCharacteristicsFilteredData.add(rowData);
                StandbyTotalInputPower = 1;
                print("StandbyTotalInputPower ${ioValue.IOData}");
              }
            }
          }
        }
      }

      // 找到 "Test_value" 工作表並篩選 Test
      var pftSheet = excel.tables['Test_value'];
      _ProtectionFunctionTestResultData.clear();
      if (pftSheet != null) {
        int Emergency_Stop_Fail=0,Door_Open_Fail=0,Ground_Fault_Fail=0,Insulation_Fault_Fail=0;
        int L_IO=0,R_IO=0;
        int L_IG=0,R_IG=0;
        int L_OG=0,R_OG=0;
        int L_GroundOhm=0,R_GroundOhm=0;
        for (int rowIndex = 1; rowIndex < pftSheet.maxRows; rowIndex++) {
          var row = pftSheet.row(rowIndex);
          if (row.any((cell) => cell?.value?.toString().contains("Emergency Test") ?? false)) {
            var row2 = row[7];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty &&
                row2.value.toString() == "FAIL") {
              Emergency_Stop_Fail++;
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Door Open Test") ?? false)) {
            var row2 = row[7];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty &&
                row2.value.toString() == "FAIL") {
              Door_Open_Fail++;
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Ground Fault Test") ?? false)) {
            var row2 = row[7];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty &&
                row2.value.toString() == "FAIL") {
              Ground_Fault_Fail++;
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Seq.2") ?? false)) {
            var row2 = row[6];
            var row3 = row[7];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var iogValue = ProtectionFunctionTestResult.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("Data_1") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "L_IO": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                L_IO++;
                print("L_IO$L_IO: ${iogValue.PFTResult}");
              }
              if (row.any((cell) => cell?.value?.toString().contains("Data_2") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "L_IG": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                L_IG++;
                print("L_IG$L_IG: ${iogValue.PFTResult}");
              }
              if (row.any((cell) => cell?.value?.toString().contains("Data_3") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "L_OG": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                L_OG++;
                print("L_OG$L_OG: ${iogValue.PFTResult}");
              }
              if (row.any((cell) => cell?.value?.toString().contains("Data_7") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "L_GroundOhm": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                L_GroundOhm++;
                print("L_GroundOhm$L_GroundOhm: ${iogValue.PFTResult}");
              }
            }
            if (row3 != null &&
                row3.value != null &&
                row3.value.toString().isNotEmpty &&
                row3.value.toString() == "FAIL") {
              Insulation_Fault_Fail++;
            }
          }
          if (row.any((cell) => cell?.value?.toString().contains("Seq.4") ?? false)) {
            var row2 = row[6];
            var row3 = row[7];
            if (row2 != null &&
                row2.value != null &&
                row2.value
                    .toString()
                    .isNotEmpty) {
              var iogValue = ProtectionFunctionTestResult.fromExcel(
                  row2.value.toString());

              if (row.any((cell) => cell?.value?.toString().contains("Data_1") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "R_IO": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                R_IO++;
                print("R_IO$R_IO: ${iogValue.PFTResult}");
              }
              if (row.any((cell) => cell?.value?.toString().contains("Data_2") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "R_IG": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                R_IG++;
                print("R_IG$R_IG: ${iogValue.PFTResult}");
              }
              if (row.any((cell) => cell?.value?.toString().contains("Data_3") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "R_OG": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                R_OG++;
                print("R_OG$R_OG: ${iogValue.PFTResult}");
              }
              if (row.any((cell) => cell?.value?.toString().contains("Data_7") ?? false) ) {
                Map<String, dynamic> rowData = {
                  "R_GroundOhm": iogValue.PFTResult,
                };
                _ProtectionFunctionTestResultData.add(rowData);
                R_GroundOhm++;
                print("R_GroundOhm$R_GroundOhm: ${iogValue.PFTResult}");
              }
            }
            if (row3 != null &&
                row3.value != null &&
                row3.value.toString().isNotEmpty &&
                row3.value.toString() == "FAIL") {
              Insulation_Fault_Fail++;
            }
          }
        }
        if(Emergency_Stop_Fail >= 3){
          var pftValue = ProtectionFunctionTestResult.fromExcel("FAIL");
          Map<String, dynamic> rowData = {
            "EmergencyTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Emergency Test: ${pftValue.PFTResult}");
          print("Emergency FAIL: $Emergency_Stop_Fail");
        }
        else{
          var pftValue = ProtectionFunctionTestResult.fromExcel("PASS");
          Map<String, dynamic> rowData = {
            "EmergencyTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Emergency Test: ${pftValue.PFTResult}");
          print("Emergency PASS: $Emergency_Stop_Fail");
        }
        if(Door_Open_Fail >= 3){
          var pftValue = ProtectionFunctionTestResult.fromExcel("FAIL");
          Map<String, dynamic> rowData = {
            "DoorTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Door Open Test: ${pftValue.PFTResult}");
          print("Door Open FAIL: $Door_Open_Fail");
        }
        else{
          var pftValue = ProtectionFunctionTestResult.fromExcel("PASS");
          Map<String, dynamic> rowData = {
            "DoorTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Door Open Test: ${pftValue.PFTResult}");
          print("Door Open PASS: $Door_Open_Fail");
        }
        if(Ground_Fault_Fail >= 3){
          var pftValue = ProtectionFunctionTestResult.fromExcel("FAIL");
          Map<String, dynamic> rowData = {
            "GroundTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Ground Fault Test: ${pftValue.PFTResult}");
          print("Ground Fault FAIL: $Ground_Fault_Fail");
        }
        else{
          var pftValue = ProtectionFunctionTestResult.fromExcel("PASS");
          Map<String, dynamic> rowData = {
            "GroundTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Ground Fault Test: ${pftValue.PFTResult}");
          print("Ground Fault PASS: $Ground_Fault_Fail");
        }
        if(Insulation_Fault_Fail >= 3){
          var pftValue = ProtectionFunctionTestResult.fromExcel("FAIL");
          Map<String, dynamic> rowData = {
            "InsulationTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Insulation Fault Test: ${pftValue.PFTResult}");
          print("Insulation Fault FAIL: $Ground_Fault_Fail");
        }
        else{
          var pftValue = ProtectionFunctionTestResult.fromExcel("PASS");
          Map<String, dynamic> rowData = {
            "InsulationTest": pftValue.PFTResult,
          };
          _ProtectionFunctionTestResultData.add(rowData);
          print("Insulation Fault Test: ${pftValue.PFTResult}");
          print("Insulation Fault PASS: $Ground_Fault_Fail");
        }
      }

      setState(() {}); // 更新UI
    }
  }

  // 生成並儲存 PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // 添加 Keypart 資料到 PDF
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text("PSU S/N :", style: pw.TextStyle(fontSize: 16)),
          ..._filteredData.map((data) {
            return pw.Text(
              "PSUSN: ${data['PSUSN']}",
              style: pw.TextStyle(fontSize: 12),
            );
          }).toList(),
          pw.SizedBox(height: 20),
          pw.Text("Software Version :", style: pw.TextStyle(fontSize: 16)),
          ..._swvFilteredData.map((data) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (data["CSU"] != null)  pw.Text("CSU: ${data['CSU']}", style: pw.TextStyle(fontSize: 12)),
                if (data["FANModule"] != null)  pw.Text("FANModule: ${data['FANModule']}", style: pw.TextStyle(fontSize: 12)),
                if (data["RelayModule"] != null)  pw.Text("RelayModule: ${data['RelayModule']}", style: pw.TextStyle(fontSize: 12)),
                if (data["PrimaryMCU"] != null)  pw.Text("PrimaryMCU: ${data['PrimaryMCU']}", style: pw.TextStyle(fontSize: 12)),
                if (data["Connector1"] != null)  pw.Text("Connector1: ${data['Connector1']}", style: pw.TextStyle(fontSize: 12)),
                if (data["Connector2"] != null)  pw.Text("Connector2: ${data['Connector2']}", style: pw.TextStyle(fontSize: 12)),
                if (data["LCMUI"] != null)  pw.Text("LCMUI: ${data['LCMUI']}", style: pw.TextStyle(fontSize: 12)),
                if (data["LEDModule"] != null)  pw.Text("LEDModule: ${data['LEDModule']}", style: pw.TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
          pw.SizedBox(height: 20),
          pw.Text("IO Data :", style: pw.TextStyle(fontSize: 16)),
          ..._IOCharacteristicsFilteredData.map((data) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (data["L_Input_V"] != null)  pw.Text("L_Input_V: ${data['L_Input_V']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_Input_A"] != null)  pw.Text("L_Input_A: ${data['L_Input_A']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_Total_Input_P"] != null)  pw.Text("L_Total_Input_P: ${data['L_Total_Input_P']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_Output_V"] != null)  pw.Text("L_Output_V: ${data['L_Output_V']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_Output_A"] != null)  pw.Text("L_Output_A: ${data['L_Output_A']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_Output_P"] != null)  pw.Text("L_Output_P: ${data['L_Output_P']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_Input_V"] != null)  pw.Text("R_Input_V: ${data['R_Input_V']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_Input_A"] != null)  pw.Text("R_Input_A: ${data['R_Input_A']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_Total_Input_P"] != null)  pw.Text("R_Total_Input_P: ${data['R_Total_Input_P']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_Output_V"] != null)  pw.Text("R_Output_V: ${data['R_Output_V']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_Output_A"] != null)  pw.Text("R_Output_A: ${data['R_Output_A']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_Output_P"] != null)  pw.Text("R_Output_P: ${data['R_Output_P']}", style: pw.TextStyle(fontSize: 12)),
                if (data["EFF"] != null)  pw.Text("EFF: ${data['EFF']}", style: pw.TextStyle(fontSize: 12)),
                if (data["PowerFactor"] != null)  pw.Text("PowerFactor: ${data['PowerFactor']}", style: pw.TextStyle(fontSize: 12)),
                if (data["THD"] != null)  pw.Text("THD: ${data['THD']}", style: pw.TextStyle(fontSize: 12)),
                if (data["StandbyTotalInputPower"] != null)  pw.Text("StandbyTotalInputPower: ${data['StandbyTotalInputPower']}", style: pw.TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
          pw.SizedBox(height: 20),
          pw.Text("Protection Function Test :", style: pw.TextStyle(fontSize: 16)),
          ..._ProtectionFunctionTestResultData.map((data) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (data["EmergencyTest"] != null)  pw.Text("EmergencyTest: ${data['EmergencyTest']}", style: pw.TextStyle(fontSize: 12)),
                if (data["DoorTest"] != null)  pw.Text("DoorTest: ${data['DoorTest']}", style: pw.TextStyle(fontSize: 12)),
                if (data["GroundTest"] != null)  pw.Text("GroundTest: ${data['GroundTest']}", style: pw.TextStyle(fontSize: 12)),
                if (data["InsulationTest"] != null)  pw.Text("InsulationTest: ${data['InsulationTest']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_IO"] != null)  pw.Text("L_IO: ${data['L_IO']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_IG"] != null)  pw.Text("L_IG: ${data['L_IG']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_OG"] != null)  pw.Text("L_OG: ${data['L_OG']}", style: pw.TextStyle(fontSize: 12)),
                if (data["L_GroundOhm"] != null)  pw.Text("L_GroundOhm: ${data['L_GroundOhm']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_IO"] != null)  pw.Text("R_IO: ${data['R_IO']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_IG"] != null)  pw.Text("R_IG: ${data['R_IG']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_OG"] != null)  pw.Text("R_OG: ${data['R_OG']}", style: pw.TextStyle(fontSize: 12)),
                if (data["R_GroundOhm"] != null)  pw.Text("R_GroundOhm: ${data['R_GroundOhm']}", style: pw.TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ],
      ),
    );


    // 讓使用者選擇儲存 PDF 的路徑
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: '選擇儲存路徑',
      fileName: 'filtered_data.pdf',
      allowedExtensions: ['pdf'],
    );

    if (path != null) {
      File file = File(path);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF已儲存至: ${file.path}'),
      ));
    }
  }

  // 讀取並提取 PDF 中 Present Charging Voltage 下一行資料
  Future<void> _readPdfAndExtractVoltage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var doc = await PDFDoc.fromFile(file);

      String? extractedText = await doc.text;

      // 查找 Present Charging Voltage 並提取其後的一行
      final regex = RegExp(r"Present Charging Voltage[^\n]*\n([^\n]*)");
      final match = regex.firstMatch(extractedText!);

      if (match != null) {
        setState(() {
          _extractedVoltage = match.group(1); // 提取並顯示下一行的資料
        });
      } else {
        setState(() {
          _extractedVoltage = "未找到 Present Charging Voltage 資料";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Reader & PDF Generator'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickAndReadExcelFile,
              child: Text('讀取Excel檔案'),
            ),
            ElevatedButton(
              onPressed: _generatePdf,
              child: Text('生成並儲存 PDF 檔案'),
            ),
            ElevatedButton(
              onPressed: _readPdfAndExtractVoltage,
              child: Text('讀取Burn-in PDF'),
            ),
            if (_extractedVoltage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Extracted Voltage: $_extractedVoltage'),
              ),
            Expanded(
              child: ListView(
                children: [
                  if (_filteredData.isNotEmpty) ...[
                    Text('PSU S/N :', style: TextStyle(fontSize: 16)),
                    ..._filteredData.map((data) {
                      return ListTile(
                        title: Text('PSUSN: ${data["PSUSN"]}'),
                      );
                    }).toList(),
                  ],
                  if (_swvFilteredData.isNotEmpty) ...[
                    Text('Software Version :', style: TextStyle(fontSize: 16)),
                    ..._swvFilteredData.map((data) {
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data["CSU"] != null)  Text('CSU: ${data["CSU"]}'),
                            if (data["FANModule"] != null)  Text('FANModule: ${data["FANModule"]}'),
                            if (data["RelayModule"] != null)  Text('RelayModule: ${data["RelayModule"]}'),
                            if (data["Connector1"] != null)  Text('Connector1: ${data["Connector1"]}'),
                            if (data["Connector2"] != null)  Text('Connector2: ${data["Connector2"]}'),
                            if (data["LCMUI"] != null)  Text('LCMUI: ${data["LCMUI"]}'),
                            if (data["LEDModule"] != null)  Text('LEDModule: ${data["LEDModule"]}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  if (_IOCharacteristicsFilteredData.isNotEmpty) ...[
                    Text('IO Data :', style: TextStyle(fontSize: 16)),
                    ..._IOCharacteristicsFilteredData.map((data) {
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data["L_Input_V"] != null)  Text('L_Input_V: ${data["L_Input_V"]}'),
                            if (data["L_Input_A"] != null)  Text('L_Input_A: ${data["L_Input_A"]}'),
                            if (data["L_Total_Input_P"] != null)  Text('L_Total_Input_P: ${data["L_Total_Input_P"]}'),
                            if (data["L_Output_V"] != null)  Text('L_Output_V: ${data["L_Output_V"]}'),
                            if (data["L_Output_A"] != null)  Text('L_Output_A: ${data["L_Output_A"]}'),
                            if (data["L_Output_P"] != null)  Text('L_Output_P: ${data["L_Output_P"]}'),
                            if (data["R_Input_V"] != null)  Text('R_Input_V: ${data["R_Input_V"]}'),
                            if (data["R_Input_A"] != null)  Text('R_Input_A: ${data["R_Input_A"]}'),
                            if (data["R_Total_Input_P"] != null)  Text('R_Total_Input_P: ${data["R_Total_Input_P"]}'),
                            if (data["R_Output_V"] != null)  Text('R_Output_V: ${data["R_Output_V"]}'),
                            if (data["R_Output_A"] != null)  Text('R_Output_A: ${data["R_Output_A"]}'),
                            if (data["R_Output_P"] != null)  Text('R_Output_P: ${data["R_Output_P"]}'),
                            if (data["EFF"] != null)  Text('EFF: ${data["EFF"]}'),
                            if (data["PowerFactor"] != null)  Text('PowerFactor: ${data["PowerFactor"]}'),
                            if (data["THD"] != null)  Text('THD: ${data["THD"]}'),
                            if (data["StandbyTotalInputPower"] != null)  Text('StandbyTotalInputPower: ${data["StandbyTotalInputPower"]}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  if (_ProtectionFunctionTestResultData.isNotEmpty) ...[
                    Text('Protection Function Test Result :', style: TextStyle(fontSize: 16)),
                    ..._ProtectionFunctionTestResultData.map((data) {
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data["EmergencyTest"] != null)  Text('EmergencyTest: ${data["EmergencyTest"]}'),
                            if (data["DoorTest"] != null)  Text('DoorTest: ${data["DoorTest"]}'),
                            if (data["GroundTest"] != null)  Text('GroundTest: ${data["GroundTest"]}'),
                            if (data["InsulationTest"] != null)  Text('InsulationTest: ${data["InsulationTest"]}'),
                            if (data["L_IO"] != null)  Text('L_IO: ${data["L_IO"]}'),
                            if (data["L_IG"] != null)  Text('L_IG: ${data["L_IG"]}'),
                            if (data["L_OG"] != null)  Text('L_OG: ${data["L_OG"]}'),
                            if (data["L_GroundOhm"] != null)  Text('L_GroundOhm: ${data["L_GroundOhm"]}'),
                            if (data["R_IO"] != null)  Text('R_IO: ${data["R_IO"]}'),
                            if (data["R_IG"] != null)  Text('R_IG: ${data["R_IG"]}'),
                            if (data["R_OG"] != null)  Text('R_OG: ${data["R_OG"]}'),
                            if (data["R_GroundOhm"] != null)  Text('R_GroundOhm: ${data["R_GroundOhm"]}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChargeModule {
  final String snId;

  factory ChargeModule.fromExcel(String moduleId) {
    return ChargeModule(moduleId);
  }

  ChargeModule(this.snId);
}

class SWVerData {
  final String keyword;

  factory SWVerData.fromExcel(String keyword) {
    return SWVerData(keyword);
  }

  SWVerData(this.keyword);
}

class IOCharacteristics{
  final String IOData;

  factory IOCharacteristics.fromExcel(String IOData) {
    return IOCharacteristics(IOData);
  }

  IOCharacteristics(this.IOData);
}

class ProtectionFunctionTestResult{
  final String PFTResult;

  factory ProtectionFunctionTestResult.fromExcel(String PFTResult) {
    return ProtectionFunctionTestResult(PFTResult);
  }

  ProtectionFunctionTestResult(this.PFTResult);
}

