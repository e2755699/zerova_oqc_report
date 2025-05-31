import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';

/// OQC報告模型，封裝所有OQC報告相關的參數
class OqcModel {
  final String sn;
  final String model;
  final SoftwareVersion? softwareVersion;
  final AppearanceStructureInspectionFunctionResult? testFunction;
  final InputOutputCharacteristics? inputOutputCharacteristics;
  final ProtectionFunctionTestResult? protectionTestResults;
  final Psuserialnumber? psuSerialNumbers;
  final PackageListResult? packageListResult;

  /// 創建OQC報告模型
  OqcModel({
    required this.sn,
    required this.model,
    this.softwareVersion,
    this.testFunction,
    this.inputOutputCharacteristics,
    this.protectionTestResults,
    this.psuSerialNumbers,
    PackageListResult? packageListResult,
  }) : this.packageListResult = packageListResult ?? PackageListResult();

  /// 從Map創建OQC報告模型
  factory OqcModel.fromMap(Map<String, dynamic> map) {
    return OqcModel(
      sn: map['sn'] as String,
      model: map['model'] as String,
      softwareVersion: map['softwareVersion'] as SoftwareVersion?,
      testFunction: map['testFunction'] as AppearanceStructureInspectionFunctionResult?,
      inputOutputCharacteristics: map['inputOutputCharacteristics'] as InputOutputCharacteristics?,
      protectionTestResults: map['protectionTestResults'] as ProtectionFunctionTestResult?,
      psuSerialNumbers: map['psuSerialNumbers'] as Psuserialnumber?,
      packageListResult: map['packageListResult'] as PackageListResult?,
    );
  }

  /// 轉換為Map
  Map<String, dynamic> toMap() {
    return {
      'sn': sn,
      'model': model,
      'softwareVersion': softwareVersion,
      'testFunction': testFunction,
      'inputOutputCharacteristics': inputOutputCharacteristics,
      'protectionTestResults': protectionTestResults,
      'psuSerialNumbers': psuSerialNumbers,
      'packageListResult': packageListResult,
    };
  }
} 