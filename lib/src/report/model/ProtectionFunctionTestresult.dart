class ProtectionFunctionTestResult {
  final Map<String, Measurement> leftGunResults;
  final Map<String, Measurement> rightGunResults;
  final Measurement emergencyStopFailCount;
  final Measurement doorOpenFailCount;
  final Measurement groundFaultFailCount;

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

  static ProtectionFunctionTestResult fromJsonList(List<dynamic> data) {
    int emergencyFailCount = 0;
    int doorFailCount = 0;
    int groundFailCount = 0;

    Map<String, Measurement> leftGunResults = {};
    Map<String, Measurement> rightGunResults = {};

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
        FailStatus judgment = (value >= spec - tolerance && value <= spec + tolerance)
            ? FailStatus.PASS
            : FailStatus.FAIL;

        // 新建測量結果
        Measurement measurement = Measurement(
          spec: spec,
          value: value,
          key: spcDesc,
          name: "$testType",
          judgment: judgment,
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
      emergencyStopFailCount: Measurement(
        spec: 3,
        value: emergencyFailCount.toDouble(),
        key: "Emergency_Stop",
        name: "緊急停止失敗次數",
        judgment: emergencyFailCount >= 3 ? FailStatus.FAIL : FailStatus.PASS,
      ),
      doorOpenFailCount: Measurement(
        spec: 3,
        value: doorFailCount.toDouble(),
        key: "Door_Open",
        name: "門開啟失敗次數",
        judgment: doorFailCount >= 3 ? FailStatus.FAIL : FailStatus.PASS,
      ),
      groundFaultFailCount: Measurement(
        spec: 3,
        value: groundFailCount.toDouble(),
        key: "Ground_Fault",
        name: "接地故障失敗次數",
        judgment: groundFailCount >= 3 ? FailStatus.FAIL : FailStatus.PASS,
      ),
    );
  }
}

class Measurement {
  final double spec;
  final double value;
  final String key;
  final String name;
  final FailStatus judgment;

  Measurement({
    required this.spec,
    required this.value,
    required this.key,
    required this.name,
    required this.judgment,
  });
}

enum FailStatus { PASS, FAIL, UNKNOWN }
