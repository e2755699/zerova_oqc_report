import 'package:zerova_oqc_report/src/report/model/charge_module.dart';

import 'software_version.dart';

class OqcReportModel {
  final List<ChargeModule> chargeModules = List.empty(growable: true);
  final List<SoftwareVersion> softwareVersions = List.empty(growable: true);
  final List<Map<String, dynamic>> ioCharacteristicsFilteredData =
      List.empty(growable: true);
  final List<Map<String, dynamic>> protectionFunctionTestResultData =
      List.empty(growable: true);

  void setChargeModule(ChargeModule chargeModule) {
    chargeModules.add(chargeModule);
  }

  void setSoftwareVersion(SoftwareVersion softwareVersion) {
    softwareVersions.add(softwareVersion);
  }

  void setIOCharacteristicsFilteredData(
      List<Map<String, dynamic>> ioCharacteristicsFilteredData) {
    ioCharacteristicsFilteredData.addAll(ioCharacteristicsFilteredData);
  }

  void setProtectionFunctionTestResultData(
      List<Map<String, dynamic>> protectionFunctionTestResultData) {
    protectionFunctionTestResultData.addAll(protectionFunctionTestResultData);
  }
}
