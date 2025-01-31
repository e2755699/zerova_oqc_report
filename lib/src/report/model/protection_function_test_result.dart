import 'package:zerova_oqc_report/src/report/enum/judgement.dart';

class ProtectionFunctionTestResult {
  final ProtectionFunctionTestResultSide leftSideProtectionFunctionTestResult;
  final ProtectionFunctionTestResultSide rightSideProtectionFunctionTestResult;
  final SpecialFunctionTestResult specialFunctionTestResult;

List<ProtectionFunctionTestResultSide> get protectionFunctionTestResultSide => [
  leftSideProtectionFunctionTestResult,
  rightSideProtectionFunctionTestResult,
];

ProtectionFunctionTestResult({
  required this.leftSideProtectionFunctionTestResult,
  required this.rightSideProtectionFunctionTestResult,
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
  double emergencyFailCount = 0;
  double doorFailCount = 0;
  double groundFailCount = 0;

  for (var item in data) {
    String? spcDesc = item['SPC_DESC'];
    String? spcItem = item['SPC_ITEM'];
    String? spcValueStr = item['SPC_VALUE'];
    String? spcResult = item['RESULT'];
    double spcValue = double.tryParse(spcValueStr ?? "0") ?? 0;

    if (spcDesc != null && spcItem != null) {
      if (spcItem.contains("Data_1")) {
        double spec = 10;
        if (spcItem.contains("Seq.2")) {
          if (leftInsulationImpedanceInputOutputValue > spcValue) {
            leftInsulationImpedanceInputOutputValue = spcValue;
          }
          leftInsulationImpedanceInputOutput = ProtectionFunctionMeasurement(
            spec: spec,
            value: leftInsulationImpedanceInputOutputValue,
            key: spcItem,
            name: "IIIO",
            description: '',
            judgement: leftInsulationImpedanceInputOutputValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }else if (spcItem.contains("Seq.4")) {
          if (rightInsulationImpedanceInputOutputValue > spcValue) {
            rightInsulationImpedanceInputOutputValue = spcValue;
          }
          rightInsulationImpedanceInputOutput = ProtectionFunctionMeasurement(
            spec: spec,
            value: rightInsulationImpedanceInputOutputValue,
            key: spcItem,
            name: "IIIO",
            description: '',
            judgement: rightInsulationImpedanceInputOutputValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }
      }
      else if (spcItem.contains("Data_2")) {
        double spec = 10;
        if (spcItem.contains("Seq.2")) {
          if (leftInsulationImpedanceInputGroundValue > spcValue) {
            leftInsulationImpedanceInputGroundValue = spcValue;
          }
          leftInsulationImpedanceInputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: leftInsulationImpedanceInputGroundValue,
            key: spcItem,
            name: "IIIG",
            description: '',
            judgement: leftInsulationImpedanceInputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }else if (spcItem.contains("Seq.4")) {
          if (rightInsulationImpedanceInputGroundValue > spcValue) {
            rightInsulationImpedanceInputGroundValue = spcValue;
          }
          rightInsulationImpedanceInputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: rightInsulationImpedanceInputGroundValue,
            key: spcItem,
            name: "IIIG",
            description: '',
            judgement: rightInsulationImpedanceInputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }
      }
      else if (spcItem.contains("Data_3")) {
        double spec = 10;
        if (spcItem.contains("Seq.2")) {
          if (leftInsulationImpedanceOutputGroundValue > spcValue) {
            leftInsulationImpedanceOutputGroundValue = spcValue;
          }
          leftInsulationImpedanceOutputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: leftInsulationImpedanceOutputGroundValue,
            key: spcItem,
            name: "IIOG",
            description: '',
            judgement: leftInsulationImpedanceOutputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }else if (spcItem.contains("Seq.4")) {
          if (rightInsulationImpedanceOutputGroundValue > spcValue) {
            rightInsulationImpedanceOutputGroundValue = spcValue;
          }
          rightInsulationImpedanceOutputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: rightInsulationImpedanceOutputGroundValue,
            key: spcItem,
            name: "IIOG",
            description: '',
            judgement: rightInsulationImpedanceOutputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }
      }
      else if (spcItem.contains("Data_4")) {
        double spec = 10;
        if (spcItem.contains("Seq.2")) {
          if (leftInsulationVoltageInputOutputValue > spcValue) {
            leftInsulationVoltageInputOutputValue = spcValue;
          }
          leftInsulationVoltageInputOutput = ProtectionFunctionMeasurement(
            spec: spec,
            value: leftInsulationVoltageInputOutputValue,
            key: spcItem,
            name: "IVIO",
            description: '',
            judgement: leftInsulationVoltageInputOutputValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }else if (spcItem.contains("Seq.4")) {
          if (rightInsulationVoltageInputOutputValue > spcValue) {
            rightInsulationVoltageInputOutputValue = spcValue;
          }
          rightInsulationVoltageInputOutput = ProtectionFunctionMeasurement(
            spec: spec,
            value: rightInsulationVoltageInputOutputValue,
            key: spcItem,
            name: "IVIO",
            description: '',
            judgement: rightInsulationVoltageInputOutputValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }
      }
      else if (spcItem.contains("Data_5")) {
        double spec = 10;
        if (spcItem.contains("Seq.2")) {
          if (leftInsulationVoltageInputGroundValue > spcValue) {
            leftInsulationVoltageInputGroundValue = spcValue;
          }
          leftInsulationVoltageInputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: leftInsulationVoltageInputGroundValue,
            key: spcItem,
            name: "IVIG",
            description: '',
            judgement: leftInsulationVoltageInputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }else if (spcItem.contains("Seq.4")) {
          if (rightInsulationVoltageInputGroundValue > spcValue) {
            rightInsulationVoltageInputGroundValue = spcValue;
          }
          rightInsulationVoltageInputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: rightInsulationVoltageInputGroundValue,
            key: spcItem,
            name: "IVIG",
            description: '',
            judgement: rightInsulationVoltageInputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }
      }
      else if (spcItem.contains("Data_6")) {
        double spec = 10;
        if (spcItem.contains("Seq.2")) {
          if (leftInsulationVoltageOutputGroundValue > spcValue) {
            leftInsulationVoltageOutputGroundValue = spcValue;
          }
          leftInsulationVoltageOutputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: leftInsulationVoltageOutputGroundValue,
            key: spcItem,
            name: "IVOG",
            description: '',
            judgement: leftInsulationVoltageOutputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }else if (spcItem.contains("Seq.4")) {
          if (rightInsulationVoltageOutputGroundValue > spcValue) {
            rightInsulationVoltageOutputGroundValue = spcValue;
          }
          rightInsulationVoltageOutputGround = ProtectionFunctionMeasurement(
            spec: spec,
            value: rightInsulationVoltageOutputGroundValue,
            key: spcItem,
            name: "IVOG",
            description: '',
            judgement: rightInsulationVoltageOutputGroundValue  >= spec ? Judgement.pass : Judgement.fail,
          );
        }
      }
      else if (spcItem.contains("Emergency Test")) {
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
            judgement: emergencyFailCount >= spec ? Judgement.fail : Judgement.pass
        );
      }
      else if (spcItem.contains("Door Open Test")) {
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
      }
      else if (spcItem.contains("Ground Fault Test")) {
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
          judgement: groundFailCount >= spec ? Judgement.fail : Judgement.pass,
        );
      }
    }
  }

  var leftSideProtectionFunctionTestResultSide = ProtectionFunctionTestResultSide(
      "L",
      leftInsulationImpedanceInputOutput ?? ProtectionFunctionMeasurement.empty(),
      leftInsulationImpedanceInputGround ?? ProtectionFunctionMeasurement.empty(),
      leftInsulationImpedanceOutputGround ?? ProtectionFunctionMeasurement.empty(),
      leftInsulationVoltageInputOutput ?? ProtectionFunctionMeasurement.empty(),
      leftInsulationVoltageInputGround ?? ProtectionFunctionMeasurement.empty(),
      leftInsulationVoltageOutputGround ?? ProtectionFunctionMeasurement.empty());
  var rightSideProtectionFunctionTestResultSide = ProtectionFunctionTestResultSide(
      "R",
      rightInsulationImpedanceInputOutput ?? ProtectionFunctionMeasurement.empty(),
      rightInsulationImpedanceInputGround ?? ProtectionFunctionMeasurement.empty(),
      rightInsulationImpedanceOutputGround ?? ProtectionFunctionMeasurement.empty(),
      rightInsulationVoltageInputOutput ?? ProtectionFunctionMeasurement.empty(),
      rightInsulationVoltageInputGround ?? ProtectionFunctionMeasurement.empty(),
      rightInsulationVoltageOutputGround ?? ProtectionFunctionMeasurement.empty());

  var result = ProtectionFunctionTestResult(
    leftSideProtectionFunctionTestResult: leftSideProtectionFunctionTestResultSide,
    rightSideProtectionFunctionTestResult: rightSideProtectionFunctionTestResultSide,
    specialFunctionTestResult: SpecialFunctionTestResult(
      emergencyTest: emergencyTest ?? ProtectionFunctionMeasurement.empty(),
      doorOpenTest: doorOpenTest ?? ProtectionFunctionMeasurement.empty(),
      groundFaultTest: groundFaultTest ?? ProtectionFunctionMeasurement.empty(),
    ),
  );


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
  print("=====================================");
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

class ProtectionFunctionTestResultSide {
  final ProtectionFunctionMeasurement insulationImpedanceInputOutput;
  final ProtectionFunctionMeasurement insulationImpedanceInputGround;
  final ProtectionFunctionMeasurement insulationImpedanceOutputGround;
  final ProtectionFunctionMeasurement insulationVoltageInputOutput;
  final ProtectionFunctionMeasurement insulationVoltageInputGround;
  final ProtectionFunctionMeasurement insulationVoltageOutputGround;

  final String side;

  String get judgement => "OK";

  ProtectionFunctionTestResultSide(
      this.side,
      this.insulationImpedanceInputOutput,
      this.insulationImpedanceInputGround,
      this.insulationImpedanceOutputGround,
      this.insulationVoltageInputOutput,
      this.insulationVoltageInputGround,
      this.insulationVoltageOutputGround);
}

class ProtectionFunctionMeasurement {
  final double spec;
  final double value;
  final String key;
  final String name;
  final String description;
  final Judgement judgement;

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