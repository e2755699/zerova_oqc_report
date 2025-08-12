import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:intl/intl.dart';

class ProtectionFunctionTestResult {
  final HiPotTestResult hiPotTestResult;
  final SpecialFunctionTestResult specialFunctionTestResult;
  ProtectionFunctionTestResult({
    required this.hiPotTestResult,
    required this.specialFunctionTestResult,
  });

  static ProtectionFunctionTestResult fromJsonList(List<dynamic> data) {
    ProtectionFunctionMeasurement? leftInsulationImpedanceInputOutput;
    ProtectionFunctionMeasurement? leftInsulationImpedanceInputGround;
    ProtectionFunctionMeasurement? leftInsulationImpedanceOutputGround;
    ProtectionFunctionMeasurement? leftInsulationVoltageInputOutput;
    ProtectionFunctionMeasurement? leftInsulationVoltageInputGround;
    ProtectionFunctionMeasurement? leftInsulationVoltageOutputGround;
    ProtectionFunctionMeasurement? rightInsulationImpedanceInputOutput;
    ProtectionFunctionMeasurement? rightInsulationImpedanceInputGround;
    ProtectionFunctionMeasurement? rightInsulationImpedanceOutputGround;
    ProtectionFunctionMeasurement? rightInsulationVoltageInputOutput;
    ProtectionFunctionMeasurement? rightInsulationVoltageInputGround;
    ProtectionFunctionMeasurement? rightInsulationVoltageOutputGround;
    ProtectionFunctionMeasurement? emergencyTest;
    ProtectionFunctionMeasurement? doorOpenTest;
    ProtectionFunctionMeasurement? groundFaultTest;
    double leftInsulationImpedanceInputOutputValue = 1000000000;
    double leftInsulationImpedanceInputGroundValue = 1000000000;
    double leftInsulationImpedanceOutputGroundValue = 1000000000;
    double leftInsulationVoltageInputOutputValue = 1000000000;
    double leftInsulationVoltageInputGroundValue = 1000000000;
    double leftInsulationVoltageOutputGroundValue = 1000000000;
    double rightInsulationImpedanceInputOutputValue = 1000000000;
    double rightInsulationImpedanceInputGroundValue = 1000000000;
    double rightInsulationImpedanceOutputGroundValue = 1000000000;
    double rightInsulationVoltageInputOutputValue = 1000000000;
    double rightInsulationVoltageInputGroundValue = 1000000000;
    double rightInsulationVoltageOutputGroundValue = 1000000000;

    final rfc1123Format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
    DateTime? leftIVIOUpdateTime;
    DateTime? leftIVIGUpdateTime;
    DateTime? leftIVOGUpdateTime;
    DateTime? leftIIIOUpdateTime;
    DateTime? leftIIIGUpdateTime;
    DateTime? leftIIOGUpdateTime;
    DateTime? rightIVIOUpdateTime;
    DateTime? rightIVIGUpdateTime;
    DateTime? rightIVOGUpdateTime;
    DateTime? rightIIIOUpdateTime;
    DateTime? rightIIIGUpdateTime;
    DateTime? rightIIOGUpdateTime;
    DateTime? emergencyUpdateTime;
    DateTime? doorUpdateTime;
    DateTime? groundUpdateTime;

    double emergencyFailCount = 0;
    double doorFailCount = 0;
    double groundFailCount = 0;
    bool specialflag = true;

    DateTime? parseRfc1123(String? input) {
      if (input == null) return null;
      try {
        return rfc1123Format.parseUtc(input);
      } catch (e) {
        print('解析時間失敗: $e');
        return null;
      }
    }

    for (var item in data) {
      String? spcDesc = item['SPC_DESC'];
      String? spcItem = item['SPC_ITEM'];
      String? spcValueStr = item['SPC_VALUE'];
      String? spcResult = item['RESULT'];
      String? spcUpdateTime = item['UPDATE_TIME'];
      double spcValue = double.tryParse(spcValueStr ?? "0") ?? 0;

      if (spcDesc != null && spcItem != null && spcValue != 2770 && spcValue != 3310) {
        if (spcItem.contains("Seq.4")) {
          if (spcItem.contains("Data_5") || spcItem.contains("Data_6")) {
            specialflag = false;
          }
        }
      }
    }
    for (var item in data) {
      String? spcDesc = item['SPC_DESC'];
      String? spcItem = item['SPC_ITEM'];
      String? spcValueStr = item['SPC_VALUE'];
      String? spcResult = item['RESULT'];
      String? spcUpdateTime = item['UPDATE_TIME'];
      DateTime? spcUpdateDateTime = parseRfc1123(spcUpdateTime);
      double spcValue = double.tryParse(spcValueStr ?? "0") ?? 0;

      if (spcDesc != null && spcItem != null) {
        if(spcValue != 2770 && spcValue != 3310) {
          if (spcItem.contains("Data_1")) {
            double spec = globalHipotTestSpec!.leakagecurrentspec;
            if (spcItem.contains("Seq.2")) {
              if (leftIVIOUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftIVIOUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(leftIVIOUpdateTime!)
              ) {
                leftIVIOUpdateTime = spcUpdateDateTime; // 更新時間
                spcValue = spcValue / 1000;
                leftInsulationVoltageInputOutput =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IVIO",
                      description: '',
                      judgement: spcValue < spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftIVIOUpdateTime');
              }
            } else if (spcItem.contains("Seq.4")) {
              if (rightIVIOUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightIVIOUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(rightIVIOUpdateTime!)
              ) {
                rightIVIOUpdateTime = spcUpdateDateTime; // 更新時間
                spcValue = spcValue / 1000;
                rightInsulationVoltageInputOutput =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IVIO",
                      description: '',
                      judgement: spcValue < spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightIVIOUpdateTime');
              }
            }
          }
          else if (spcItem.contains("Data_2")) {
            double spec = globalHipotTestSpec!.leakagecurrentspec;
            if (spcItem.contains("Seq.2")) {
              if (leftIVIGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftIVIGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(leftIVIGUpdateTime!)
              ) {
                leftIVIGUpdateTime = spcUpdateDateTime; // 更新時間
                spcValue = spcValue / 1000;
                leftInsulationVoltageInputGround =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IVIG",
                      description: '',
                      judgement: spcValue < spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
                if (specialflag) {
                  spcValue = spcValue / 1000;
                  rightInsulationVoltageInputGround =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IVIG",
                        description: '',
                        judgement: spcValue < spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftIVIGUpdateTime');
              }
            } else if (spcItem.contains("Seq.4")) {
              if (rightIVIGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightIVIGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(rightIVIGUpdateTime!)
              ) {
                rightIVIGUpdateTime = spcUpdateDateTime; // 更新時間
                if (specialflag) {
                  spcValue = spcValue / 1000;
                  rightInsulationVoltageOutputGround =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IVOG",
                        description: '',
                        judgement: spcValue < spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
                else {
                  spcValue = spcValue / 1000;
                  rightInsulationVoltageInputGround =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IVIG",
                        description: '',
                        judgement: spcValue < spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightIVIGUpdateTime');
              }
            }
          }
          else if (spcItem.contains("Data_3")) {
            double spec = globalHipotTestSpec!.leakagecurrentspec;
            if (spcItem.contains("Seq.2")) {
              if (leftIVOGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftIVOGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(leftIVOGUpdateTime!)
              ) {
                leftIVOGUpdateTime = spcUpdateDateTime; // 更新時間
                spcValue = spcValue / 1000;
                leftInsulationVoltageOutputGround =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IVOG",
                      description: '',
                      judgement: spcValue < spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftIVOGUpdateTime');
              }
            }
            else if (spcItem.contains("Seq.4")) {
              if (rightIVOGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightIVOGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(rightIVOGUpdateTime!)
              ) {
                rightIVOGUpdateTime = spcUpdateDateTime; // 更新時間
                if (!specialflag) {
                  spcValue = spcValue / 1000;
                  rightInsulationVoltageOutputGround =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IVOG",
                        description: '',
                        judgement: spcValue < spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
                else {
                  rightInsulationImpedanceInputOutput =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IIIO",
                        description: '',
                        judgement: spcValue > spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightIVOGUpdateTime');
              }
            }
          }
          else if (spcItem.contains("Data_4")) {
            double spec = globalHipotTestSpec!.insulationimpedancespec;
            if (spcItem.contains("Seq.2")) {
              if (leftIIIOUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftIIIOUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(leftIIIOUpdateTime!)
              ) {
                leftIIIOUpdateTime = spcUpdateDateTime; // 更新時間
                leftInsulationImpedanceInputOutput =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IIIO",
                      description: '',
                      judgement: spcValue > spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftIIIOUpdateTime');
              }
            }
            else if (spcItem.contains("Seq.4")) {
              if (rightIIIOUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightIIIOUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(rightIIIOUpdateTime!)
              ) {
                rightIIIOUpdateTime = spcUpdateDateTime; // 更新時間
                if (!specialflag) {
                  rightInsulationImpedanceInputOutput =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IIIO",
                        description: '',
                        judgement: spcValue > spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
                else {
                  rightInsulationImpedanceOutputGround =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IIOG",
                        description: '',
                        judgement: spcValue > spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightIIIOUpdateTime');
              }
            }
          }
          else if (spcItem.contains("Data_5")) {
            double spec = globalHipotTestSpec!.insulationimpedancespec;
            if (spcItem.contains("Seq.2")) {
              if (leftIIIGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftIIIGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(leftIIIGUpdateTime!)
              ) {
                leftIIIGUpdateTime = spcUpdateDateTime; // 更新時間
                leftInsulationImpedanceInputGround =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IIIG",
                      description: '',
                      judgement: spcValue > spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
                if (specialflag) {
                  rightInsulationImpedanceInputGround =
                      ProtectionFunctionMeasurement(
                        spec: spec,
                        value: spcValue,
                        key: spcItem,
                        name: "IIIG",
                        description: '',
                        judgement: spcValue > spec
                            ? Judgement.pass
                            : Judgement.fail,
                      );
                }
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftIIIGUpdateTime');
              }
            } else if (spcItem.contains("Seq.4")) {
              if (rightIIIGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightIIIGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(rightIIIGUpdateTime!)
              ) {
                rightIIIGUpdateTime = spcUpdateDateTime; // 更新時間
                rightInsulationImpedanceInputGround =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IIIG",
                      description: '',
                      judgement: spcValue > spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightIIIGUpdateTime');
              }
            }
          }
          else if (spcItem.contains("Data_6")) {
            double spec = globalHipotTestSpec!.insulationimpedancespec;
            if (spcItem.contains("Seq.2")) {
              if (leftIIOGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftIIOGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(leftIIOGUpdateTime!)
              ) {
                leftIIOGUpdateTime = spcUpdateDateTime; // 更新時間
                leftInsulationImpedanceOutputGround =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IIOG",
                      description: '',
                      judgement: spcValue > spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftIIOGUpdateTime');
              }
            } else if (spcItem.contains("Seq.4")) {
              if (rightIIOGUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightIIOGUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(rightIIOGUpdateTime!)
              ) {
                rightIIOGUpdateTime = spcUpdateDateTime; // 更新時間
                rightInsulationImpedanceOutputGround =
                    ProtectionFunctionMeasurement(
                      spec: spec,
                      value: spcValue,
                      key: spcItem,
                      name: "IIOG",
                      description: '',
                      judgement: spcValue > spec
                          ? Judgement.pass
                          : Judgement.fail,
                    );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightIIOGUpdateTime');
              }
            }
          }
          /*else if (spcItem.contains("Emergency Test")) {
          double spec = 3;
          if (spcResult == "FAIL") {
            emergencyFailCount++;
          }
          emergencyTest = ProtectionFunctionMeasurement(
              spec: spec,
              value: emergencyFailCount.toDouble(),
              key: "Emergency_Stop",
              name: "Emergency Stop Function",
              description:
                  'After the charger is powered on and charging normally, set the rated load to initiate charging. Once the charger reaches normal output current, press the emergency stop button. This action will disconnect the charger from the AC output and trigger an alarm.',
              judgement:
                  emergencyFailCount >= spec ? Judgement.fail : Judgement.pass);
        } else if (spcItem.contains("Door Open Test")) {
          double spec = 3;
          if (spcResult == "FAIL") {
            doorFailCount++;
          }
          doorOpenTest = ProtectionFunctionMeasurement(
            spec: spec,
            value: doorFailCount.toDouble(),
            key: "Door_Open",
            name: "Door Open Function",
            description:
                'While opening the door, the charger should stop charging immediately and shows alarm when the door open.',
            judgement: doorFailCount >= spec ? Judgement.fail : Judgement.pass,
          );
        }*/
          else if (spcDesc.contains("Comsuption_Input_Power") && spcValue != 0) {
            if (spcItem.contains("Comsuption Power Test")) {
              if (emergencyUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(emergencyUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(emergencyUpdateTime!)
              ) {
                emergencyUpdateTime = spcUpdateDateTime; // 更新時間
                doorUpdateTime = spcUpdateDateTime; // 更新時間
                double spec = 1;
                if (spcResult == "FAIL") {
                  emergencyFailCount++;
                  doorFailCount++;
                }
                emergencyTest = ProtectionFunctionMeasurement(
                    spec: spec,
                    value: emergencyFailCount.toDouble(),
                    key: "Emergency_Stop",
                    name: "Emergency Stop Function",
                    description:
                    'After the charger is powered on and charging normally, set the rated load to initiate charging. Once the charger reaches normal output current, press the emergency stop button. This action will disconnect the charger from the AC output and trigger an alarm.',
                    judgement:
                    emergencyFailCount >= spec ? Judgement.fail : Judgement
                        .pass);
                doorOpenTest = ProtectionFunctionMeasurement(
                  spec: spec,
                  value: doorFailCount.toDouble(),
                  key: "Door_Open",
                  name: "Door Open Function",
                  description:
                  'While opening the door, the charger should stop charging immediately and shows alarm when the door open.',
                  judgement: doorFailCount >= spec ? Judgement.fail : Judgement
                      .pass,
                );
              }
              else {
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $emergencyUpdateTime');
                print(
                    '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $doorUpdateTime');
              }
            }
          }
          else if (spcItem.contains("Ground Fault") && spcItem.contains("Test")) {
            if (groundUpdateTime == null ||
                spcUpdateDateTime!.isAfter(groundUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(groundUpdateTime!)
            ) {
              if (groundUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(groundUpdateTime!)
              ) {
                groundFailCount = 0;
              }
              groundUpdateTime = spcUpdateDateTime; // 更新時間
              double spec = 3;
              if (spcResult == "FAIL") {
                groundFailCount++;
              }
              groundFaultTest = ProtectionFunctionMeasurement(
                spec: spec,
                value: groundFailCount.toDouble(),
                key: "Ground_Fault",
                name: "Ground Fault Function",
                description:
                "If the charger detects a ground fault or a drop in insulation below the protection threshold of rated resistance during simulation, it should stop charging and trigger an alarm to protect charger immediately.",
                judgement:
                groundFailCount >= spec ? Judgement.fail : Judgement.pass,
              );
            }
            else {
              print(
                  '❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $groundUpdateTime');
            }
          }
        }
      }
    }
    var insulationImpedanceInputOutput = InsulationTestResult(
      leftInsulationImpedanceInputOutput ??
          ProtectionFunctionMeasurement.empty(),
      leftInsulationImpedanceInputGround ??
          ProtectionFunctionMeasurement.empty(),
      leftInsulationImpedanceOutputGround ??
          ProtectionFunctionMeasurement.empty(),
      rightInsulationImpedanceInputOutput ??
          ProtectionFunctionMeasurement.empty(),
      rightInsulationImpedanceInputGround ??
          ProtectionFunctionMeasurement.empty(),
      rightInsulationImpedanceOutputGround ??
          ProtectionFunctionMeasurement.empty(),
    );
    var insulationVInputOutput = InsulationTestResult(
        leftInsulationVoltageInputOutput ??
            ProtectionFunctionMeasurement.empty(),
        leftInsulationVoltageInputGround ??
            ProtectionFunctionMeasurement.empty(),
        leftInsulationVoltageOutputGround ??
            ProtectionFunctionMeasurement.empty(),
        rightInsulationVoltageInputOutput ??
            ProtectionFunctionMeasurement.empty(),
        rightInsulationVoltageInputGround ??
            ProtectionFunctionMeasurement.empty(),
        rightInsulationVoltageOutputGround ??
            ProtectionFunctionMeasurement.empty());

    var result = ProtectionFunctionTestResult(
      hiPotTestResult: HiPotTestResult(
        insulationImpedanceTest: insulationImpedanceInputOutput,
        insulationVoltageTest: insulationVInputOutput,
      ),
      specialFunctionTestResult: SpecialFunctionTestResult(
        emergencyTest: emergencyTest ?? ProtectionFunctionMeasurement.empty(),
        doorOpenTest: doorOpenTest ?? ProtectionFunctionMeasurement.empty(),
        groundFaultTest:
            groundFaultTest ?? ProtectionFunctionMeasurement.empty(),
      ),
    );
    /*
  print("=== Protection Function Test Result ===");
  for (var side in result.protectionFunctionTestResultSide) {
    print("Side: ${side.side}");
    print("Insulation Impedance Input-Output: ${side.insulationImpedanceInputOutput.value}, Judgement: ${side.insulationImpedanceInputOutput.judgement}");
    print("Insulation Impedance Input-Ground: ${side.insulationImpedanceInputGround.value}, Judgement: ${side.insulationImpedanceInputGround.judgement}");
    print("Insulation Impedance Output-Ground: ${side.insulationImpedanceOutputGround.value}, Judgement: ${side.insulationImpedanceOutputGround.judgement}");
    print("Insulation Voltage Input-Output: ${side.insulationVoltageInputOutput.value}, Judgement: ${side.insulationVoltageInputOutput.judgement}");
    print("Insulation Voltage Input-Ground: ${side.insulationVoltageInputGround.value}, Judgement: ${side.insulationVoltageInputGround.judgement}");
    print("Insulation Voltage Output-Ground: ${side.insulationVoltageOutputGround.value}, Judgement: ${side.insulationVoltageOutputGround.judgement}");
    print("----------------------------");
  }
  print("=== Special Function Test Result ===");
  print("Emergency Test: ${result.specialFunctionTestResult.emergencyTest.value}, Judgement: ${result.specialFunctionTestResult.emergencyTest.judgement}");
  print("Door Open Test: ${result.specialFunctionTestResult.doorOpenTest.value}, Judgement: ${result.specialFunctionTestResult.doorOpenTest.judgement}");
  print("Ground Fault Test: ${result.specialFunctionTestResult.groundFaultTest.value}, Judgement: ${result.specialFunctionTestResult.groundFaultTest.judgement}");
  print("=====================================");*/
    return result;
  }

  static fromExcel(String string) {}
}

class SpecialFunctionTestResult {
  final ProtectionFunctionMeasurement emergencyTest;
  final ProtectionFunctionMeasurement doorOpenTest;
  final ProtectionFunctionMeasurement groundFaultTest;

  SpecialFunctionTestResult({
    required this.emergencyTest,
    required this.doorOpenTest,
    required this.groundFaultTest,
  });

  List<ProtectionFunctionMeasurement> get testItems => [
        emergencyTest,
        doorOpenTest,
        groundFaultTest,
      ];
}

class HiPotTestResult {
  final InsulationTestResult insulationImpedanceTest;
  final InsulationTestResult insulationVoltageTest;

  HiPotTestResult(
      {required this.insulationImpedanceTest,
      required this.insulationVoltageTest});

  List<InsulationTestResult> get hiPotTestResults => [
        insulationImpedanceTest,
        insulationVoltageTest,
      ];
}

class InsulationTestResult {
  final ProtectionFunctionMeasurement leftInsulationInputOutput;
  final ProtectionFunctionMeasurement leftInsulationInputGround;
  final ProtectionFunctionMeasurement leftInsulationOutputGround;
  final ProtectionFunctionMeasurement rightInsulationInputOutput;
  final ProtectionFunctionMeasurement rightInsulationInputGround;
  final ProtectionFunctionMeasurement rightInsulationOutputGround;

  Judgement storedJudgement;

  Judgement get judgement {
    int passCount = 0;
    if (leftInsulationInputOutput.judgement == Judgement.pass) passCount++;
    if (leftInsulationInputGround.judgement == Judgement.pass) passCount++;
    if (leftInsulationOutputGround.judgement == Judgement.pass) passCount++;
    if (rightInsulationInputOutput.judgement == Judgement.pass) passCount++;
    if (rightInsulationInputGround.judgement == Judgement.pass) passCount++;
    if (rightInsulationOutputGround.judgement == Judgement.pass) passCount++;
    return passCount >= 3 ? Judgement.pass : Judgement.fail;
  }

  Map<String, List<ProtectionFunctionMeasurement>>
      get leftInsulationInputOutputBySide => {
            'R': [
              rightInsulationInputOutput,
              rightInsulationInputGround,
              rightInsulationOutputGround,
            ],
            'L': [
              leftInsulationInputOutput,
              leftInsulationInputGround,
              leftInsulationOutputGround,
            ]
          };

  InsulationTestResult(
      this.leftInsulationInputOutput,
      this.leftInsulationInputGround,
      this.leftInsulationOutputGround,
      this.rightInsulationInputOutput,
      this.rightInsulationInputGround,
      this.rightInsulationOutputGround) : storedJudgement = Judgement.na;

  void updateStoredJudgement() {
    storedJudgement = judgement;
  }
}

class ProtectionFunctionMeasurement {
   double spec;
   double value;
   String key;
   String name;
   String description;
  Judgement judgement;

  ProtectionFunctionMeasurement({
    required this.spec,
    required this.value,
    required this.description,
    required this.key,
    required this.name,
    required this.judgement,
  });

  factory ProtectionFunctionMeasurement.empty() {
    return ProtectionFunctionMeasurement(
        spec: 0,
        value: 0,
        description: '',
        key: "",
        name: "",
        judgement: Judgement.fail);
  }
}
