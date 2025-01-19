import 'package:zerova_oqc_report/src/report/enum/judgement.dart';

class ProtectionFunctionTestResult {
  final Map<String, ProtectionFunctionMeasurement> leftGunResults;
  final Map<String, ProtectionFunctionMeasurement> rightGunResults;
  final ProtectionFunctionMeasurement emergencyStopFailCount;
  final ProtectionFunctionMeasurement doorOpenFailCount;
  final ProtectionFunctionMeasurement groundFaultFailCount;

  static const Map<String, String> results = {
    "Emergency Test": "未找到",
    "Door Open Test": "未找到",
    "Ground Fault Test": "未找到",
    "Insulation Test": "未找到",
    "Seq.2": "未找到",
    "Seq.4": "未找到",
  };

  ProtectionFunctionTestResult({
    required this.leftGunResults,
    required this.rightGunResults,
    required this.emergencyStopFailCount,
    required this.doorOpenFailCount,
    required this.groundFaultFailCount,
  });

  List<ProtectionFunctionMeasurement> get showTestResultByColumn {
    return [emergencyStopFailCount, doorOpenFailCount, groundFaultFailCount];
  }

  static ProtectionFunctionTestResult fromJsonList(List<dynamic> data) {
    int emergencyFailCount = 0;
    int doorFailCount = 0;
    int groundFailCount = 0;

    Map<String, ProtectionFunctionMeasurement> leftGunResults = {};
    Map<String, ProtectionFunctionMeasurement> rightGunResults = {};

    for (var item in data) {
      String? spcDesc = item['SPC_DESC'];
      String? spcValue = item['SPC_VALUE'];

      if (spcDesc != null && spcValue != null) {
        double value = double.tryParse(spcValue) ?? 0.0;

        // 判斷是否為左右槍
        bool isLeftGun = spcDesc.contains("Seq.2");
        bool isRightGun = spcDesc.contains("Seq.4");

        // 判斷測試類型
        String testType;
        if (spcDesc.contains("Emergency")) {
          testType = "Emergency Test";
        } else if (spcDesc.contains("Door Open")) {
          testType = "Door Open Test";
        } else if (spcDesc.contains("Ground Fault")) {
          testType = "Ground Fault Test";
        } else if (spcDesc.contains("Insulation")) {
          testType = "Insulation Test";
        } else if (isLeftGun) {
          testType = "Seq.2";
        } else if (isRightGun) {
          testType = "Seq.4";
        } else {
          testType = "未找到";
        }

        // 查詢規格
        double spec;
        if (testType == "Insulation Test") {
          spec = 950; // VOL Input/Output
        } else if (testType == "Seq.2") {
          spec = 220; // IMP Input/Output
        } else if (testType == "Seq.4") {
          spec = 230; // IMP Input/Ground
        } else {
          spec = 0; // default spec for unrecognized test type
        }
        double tolerance = spec * 0.05; // 容差 ±5%

        // 判斷是否通過測試
        Judgement judgment =
        (value >= spec - tolerance && value <= spec + tolerance)
            ? Judgement.pass
            : Judgement.fail;

        // 新建測量結果
        ProtectionFunctionMeasurement measurement = ProtectionFunctionMeasurement(
          spec: spec,
          value: value,
          key: spcDesc,
          name: "$testType",
          judgement: judgment,
          description: "Insulation Impedance Test."
              "Apply a DC Voltage:"
              "a) Between each circuit."
              "b) Between each of the independent circuits and the ground.",
        );

        // 儲存到左右槍的對應結果中，取小的值
        if (isLeftGun) {
          if (leftGunResults.containsKey(spcDesc)) {
            if (leftGunResults[spcDesc]!.value > measurement.value) {
              leftGunResults[spcDesc] = measurement;
            }
          } else {
            leftGunResults[spcDesc] = measurement;
          }
        } else if (isRightGun) {
          if (rightGunResults.containsKey(spcDesc)) {
            if (rightGunResults[spcDesc]!.value > measurement.value) {
              rightGunResults[spcDesc] = measurement;
            }
          } else {
            rightGunResults[spcDesc] = measurement;
          }
        }

        // 累計特殊測試失敗次數
        if (testType == "Emergency Test" && spcValue == "FAIL") {
          emergencyFailCount++;
        } else if (testType == "Door Open Test" && spcValue == "FAIL") {
          doorFailCount++;
        } else if (testType == "Ground Fault Test" && spcValue == "FAIL") {
          groundFailCount++;
        }
      }
    }

    // 返回結果
    return ProtectionFunctionTestResult(
      leftGunResults: leftGunResults,
      rightGunResults: rightGunResults,
      emergencyStopFailCount: ProtectionFunctionMeasurement(
        spec: 3,
        value: emergencyFailCount.toDouble(),
        key: "Emergency_Stop",
        name: "緊急停止失敗次數",
        judgement: emergencyFailCount >= 3 ? Judgement.fail : Judgement.pass,
        description:
        'After the charger is powered on and charging normally, set the rated load to initiate charging. Once the charger reaches normal output current, press the emergency stop button. This action will disconnect the charger from the AC output and trigger an alarm.',
      ),
      doorOpenFailCount: ProtectionFunctionMeasurement(
        spec: 3,
        value: doorFailCount.toDouble(),
        key: "Door_Open",
        name: "門開啟失敗次數",
        judgement: doorFailCount >= 3 ? Judgement.fail : Judgement.pass,
        description:
        'While opening the door, the charger should stop charging immediately and shows alarm when the door open.',
      ),
      groundFaultFailCount: ProtectionFunctionMeasurement(
        spec: 3,
        value: groundFailCount.toDouble(),
        key: "Ground_Fault",
        name: "接地故障失敗次數",
        description:
        "If the charger detects a ground fault or a drop in insulation below the protection threshold of rated resistance during simulation, it should stop charging and trigger an alarm to protect charger immediately.",
        judgement: groundFailCount >= 3 ? Judgement.fail : Judgement.pass,
      ),
    );
  }

  static fromExcel(String string) {}
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
}

