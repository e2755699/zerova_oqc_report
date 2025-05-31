import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/client/oqc_api_client.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/oqc/oqc_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

mixin LoadFileHelper<K extends StatefulWidget> on State<K> {
  Future<void> loadFileHelper(String sn, String model) async {
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
      if (kDebugMode) {
        // 嘗試從本地文件加載數據
        try {
          await loadFromFakeData(filePath, sn, logFile, context, model);
        } catch (e, st) {
          await logFile.writeAsString('從本地文件加載數據失敗: $e\n , st : $st',
              mode: FileMode.append);
          rethrow;
        }
        return;
      }

      //call api
      try {
        await loadFromApi(logFile, sn, model, context);
      } catch (e, st) {
        await logFile.writeAsString('API 呼叫過程中發生錯誤: $e\n , st : $st',
            mode: FileMode.append);
        rethrow;
      }
    } catch (e) {
      // 記錄整體處理過程中的任何錯誤
      await logFile.writeAsString('處理過程中發生未預期的錯誤: $e\n', mode: FileMode.append);
      throw Exception('處理過程中發生未預期的錯誤: $e'); // 重新拋出異常以便上層捕獲
    }
  }

  Future<void> loadFromApi(
      File logFile, String sn, String model, BuildContext context) async {
    final apiClient = OqcApiClient();
    await logFile.writeAsString('開始呼叫 API 獲取數據，SN: $sn, 型號: $model\n',
        mode: FileMode.append);

    // 單獨處理每個 API 呼叫，以便記錄詳細信息
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

    // 創建OQC模型
    var oqcModel = OqcModel(
      sn: sn,
      model: model,
      psuSerialNumbers: psuSerialNumbers,
      softwareVersion: softwareVersion,
      testFunction: testFunction,
      inputOutputCharacteristics: inputOutputCharacteristics,
      protectionTestResults: protectionTestResults,
    );

    context.push('/oqc-report', extra: {
      'oqcModel': oqcModel,
    });
  }

  Future<void> loadFromFakeData(String filePath, String sn, File logFile,
      BuildContext context, String model) async {
    // 改為從專案目錄下的test_data讀取數據
    String projectDir = Directory.current.path;
    String testDataPath =
        path.join(projectDir, 'Test Result', 'Zerova', 'test_data', sn);

    String jsonContent =
        await File(path.join(testDataPath, 'T2449A003A1_test.json'))
            .readAsString();
    String testFunctionJsonContent =
        await File(path.join(testDataPath, 'T2449A003A1_oqc.json'))
            .readAsString();
    String moduleJsonContent =
        await File(path.join(testDataPath, 'T2449A003A1_keypart.json'))
            .readAsString();

    await logFile.writeAsString('成功從test_data目錄加載數據\n', mode: FileMode.append);
    await logFile.writeAsString('test.json 文件內容: $jsonContent\n',
        mode: FileMode.append);
    await logFile.writeAsString('oqc.json 文件內容: $testFunctionJsonContent\n',
        mode: FileMode.append);
    await logFile.writeAsString('keypart.json 文件內容: $moduleJsonContent\n',
        mode: FileMode.append);

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

    // 創建OQC模型
    var oqcModel = OqcModel(
      sn: sn,
      model: model,
      psuSerialNumbers: psuSerialNumbers,
      softwareVersion: softwareVersion,
      testFunction: testFunction,
      inputOutputCharacteristics: inputOutputCharacteristics,
      protectionTestResults: protectionTestResults,
    );

    context.push('/oqc-report', extra: {
      'oqcModel': oqcModel,
    });
    return;
  }
}
