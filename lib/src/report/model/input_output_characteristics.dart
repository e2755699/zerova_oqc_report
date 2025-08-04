import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/basic_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';

class InputOutputCharacteristics {
  final InputOutputCharacteristicsSide leftSideInputOutputCharacteristics;
  final InputOutputCharacteristicsSide rightSideInputOutputCharacteristics;
  final BasicFunctionTestResult basicFunctionTestResult;

  List<InputOutputCharacteristicsSide> get inputOutputCharacteristicsSide => [
        leftSideInputOutputCharacteristics,
        rightSideInputOutputCharacteristics,
      ];

  InputOutputCharacteristics({
    required this.leftSideInputOutputCharacteristics,
    required this.rightSideInputOutputCharacteristics,
    required this.basicFunctionTestResult,
  });

  /// 從 JSON 清單數據提取並生成 `InputOutputCharacteristics`
  static InputOutputCharacteristics fromJsonList(List<dynamic> data) {
    List<InputOutputMeasurement> leftInputVoltage = [];
    List<InputOutputMeasurement> leftInputCurrent = [];
    List<InputOutputMeasurement> rightInputVoltage = [];
    List<InputOutputMeasurement> rightInputCurrent = [];

    InputOutputMeasurement? leftTotalInputPower;
    InputOutputMeasurement? leftOutputVoltage;
    InputOutputMeasurement? leftOutputCurrent;
    InputOutputMeasurement? leftTotalOutputPower;
    InputOutputMeasurement? rightTotalInputPower;
    InputOutputMeasurement? rightOutputVoltage;
    InputOutputMeasurement? rightOutputCurrent;
    InputOutputMeasurement? rightTotalOutputPower;
    BasicFunctionMeasurement? eff;
    BasicFunctionMeasurement? powerFactor;
    BasicFunctionMeasurement? harmonic;
    BasicFunctionMeasurement? standbyTotalInputPower;

    double leftInputVoltageCount = 0;
    double leftInputCurrentCount = 0;
    double rightInputVoltageCount = 0;
    double rightInputCurrentCount = 0;
    double leftTotalInputPowerCount = 0;
    double leftOutputVoltageCount = 0;
    double leftOutputCurrentCount = 0;
    double leftTotalOutputPowerCount = 0;
    double rightTotalInputPowerCount = 0;
    double rightOutputVoltageCount = 0;
    double rightOutputCurrentCount = 0;
    double rightTotalOutputPowerCount = 0;
    double effCount = 0;
    double powerFactorCount = 0;
    double thdCount = 0;
    double standbyTotalInputPowerCount = 0;

    // 輔助函數：處理 Pin 和 Pout 的數值自動除 1000
    double processPowerValue(double value) {
      return value > 100000 ? value / 1000 : value;
    }

    // 輔助函數：創建帶詳細日誌的測量結果
    InputOutputMeasurement createMeasurementWithLogging({
      required String name,
      required double spec,
      required double value,
      required double lowerBound,
      required double upperBound,
      required double count,
      required String key,
      required String description,
      String? unit,
    }) {
      final bool passed = (value >= lowerBound && value <= upperBound);
      final judgement = passed ? Judgement.pass : Judgement.fail;

      print('🔢 創建測量項目: $name${unit != null ? " ($unit)" : ""}');
      print('   數值: $value');
      print('   範圍: $lowerBound ~ $upperBound');
      print('   判斷: ${passed ? "✅ PASS" : "❌ FAIL"}');

      return InputOutputMeasurement(
        spec: spec,
        value: value,
        count: count,
        key: key,
        name: unit != null ? "$name ($unit)" : name,
        description: description,
        judgement: judgement,
      );
    }

    for (var item in data) {
      String? spcDesc = item['SPC_DESC'];
      String? spcValueStr = item['SPC_VALUE'];
      String? spcItem = item['SPC_ITEM'];
      double spcValue = double.tryParse(spcValueStr ?? "0") ?? 0;

      if (spcDesc != null && spcItem != null) {
        if (spcDesc.contains("Input_Voltage")) {
          if (spcItem.contains("Left  Plug") && leftInputVoltageCount < 3) {
            double spec = 220;
            double lowerBound = globalInputOutputSpec!.leftVinLowerbound;
            double upperBound = globalInputOutputSpec!.leftVinUpperbound;
            leftInputVoltageCount++;
            leftInputVoltage.add(createMeasurementWithLogging(
              name: "Vin",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: leftInputVoltageCount,
              key: spcDesc,
              description: '',
              unit: 'V', // 固定單位
            ));
          } else if (spcItem.contains("Right Plug") &&
              rightInputVoltageCount < 3) {
            double spec = 220;
            double lowerBound = globalInputOutputSpec!.rightVinLowerbound;
            double upperBound = globalInputOutputSpec!.rightVinUpperbound;
            rightInputVoltageCount++;
            rightInputVoltage.add(createMeasurementWithLogging(
              name: "Vin",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: rightInputVoltageCount,
              key: spcDesc,
              description: '',
              unit: 'V', // 固定單位
            ));
          }
        } else if (spcDesc.contains("Input_Current")) {
          if (spcItem.contains("Left  Plug") && leftInputCurrentCount < 3) {
            double spec = 230;
            double lowerBound = globalInputOutputSpec!.leftIinLowerbound;
            double upperBound = globalInputOutputSpec!.leftIinUpperbound;
            leftInputCurrentCount++;
            leftInputCurrent.add(createMeasurementWithLogging(
              name: "Iin",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: leftInputCurrentCount,
              key: spcDesc,
              description: '',
              unit: 'A', // 固定單位
            ));
          } else if (spcItem.contains("Right Plug") &&
              rightInputCurrentCount < 3) {
            double spec = 230;
            double lowerBound = globalInputOutputSpec!.rightIinLowerbound;
            double upperBound = globalInputOutputSpec!.rightIinUpperbound;
            rightInputCurrentCount++;
            rightInputCurrent.add(createMeasurementWithLogging(
              name: "Iin",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: rightInputCurrentCount,
              key: spcDesc,
              description: '',
              unit: 'A', // 固定單位
            ));
          }
        } else if (spcDesc == "Total_Input_Power") {
          if (spcItem.contains("Left  Plug") && leftTotalInputPowerCount < 1) {
            double spec = 130;
            double lowerBound = globalInputOutputSpec!.leftPinLowerbound;
            double upperBound = globalInputOutputSpec!.leftPinUpperbound;
            double processedValue = processPowerValue(spcValue); // 自動除 1000 處理
            leftTotalInputPowerCount++;
            leftTotalInputPower = createMeasurementWithLogging(
              name: "Pin",
              spec: spec,
              value: processedValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: leftTotalInputPowerCount,
              key: spcDesc,
              description: '',
              unit: globalInputOutputSpec!.leftPinUnit,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightTotalInputPowerCount < 1) {
            double spec = 130;
            double lowerBound = globalInputOutputSpec!.rightPinLowerbound;
            double upperBound = globalInputOutputSpec!.rightPinUpperbound;
            double processedValue = processPowerValue(spcValue); // 自動除 1000 處理
            rightTotalInputPowerCount++;
            rightTotalInputPower = createMeasurementWithLogging(
              name: "Pin",
              spec: spec,
              value: processedValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: leftTotalInputPowerCount,
              key: spcDesc,
              description: '',
              unit: globalInputOutputSpec!.rightPinUnit,
            );
          }
        } else if (spcDesc.contains("Output_Voltage")) {
          if (spcItem.contains("Left  Plug") && leftOutputVoltageCount < 1) {
            double spec = 950;
            double lowerBound = globalInputOutputSpec!.leftVoutLowerbound;
            double upperBound = globalInputOutputSpec!.leftVoutUpperbound;
            leftOutputVoltageCount++;
            leftOutputVoltage = createMeasurementWithLogging(
              name: "Vout",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: leftOutputVoltageCount,
              key: spcDesc,
              description: '',
              unit: 'V', // 固定單位
            );
          } else if (spcItem.contains("Right Plug") &&
              rightOutputVoltageCount < 1) {
            double spec = 950;
            double lowerBound = globalInputOutputSpec!.rightVoutLowerbound;
            double upperBound = globalInputOutputSpec!.rightVoutUpperbound;
            rightOutputVoltageCount++;
            rightOutputVoltage = createMeasurementWithLogging(
              name: "Vout",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: rightOutputVoltageCount,
              key: spcDesc,
              description: '',
              unit: 'V', // 固定單位
            );
          }
        } else if (spcDesc.contains("Output_Current")) {
          if (spcItem.contains("Left  Plug") && leftOutputCurrentCount < 1) {
            double spec = 126;
            double lowerBound = globalInputOutputSpec!.leftIoutLowerbound;
            double upperBound = globalInputOutputSpec!.leftIoutUpperbound;
            leftOutputCurrentCount++;
            leftOutputCurrent = createMeasurementWithLogging(
              name: "Iout",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: leftOutputCurrentCount,
              key: spcDesc,
              description: '',
              unit: 'A', // 固定單位
            );
          } else if (spcItem.contains("Right Plug") &&
              rightOutputCurrentCount < 1) {
            double spec = 126;
            double lowerBound = globalInputOutputSpec!.rightIoutLowerbound;
            double upperBound = globalInputOutputSpec!.rightIoutUpperbound;
            rightOutputCurrentCount++;
            rightOutputCurrent = createMeasurementWithLogging(
              name: "Iout",
              spec: spec,
              value: spcValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: rightOutputCurrentCount,
              key: spcDesc,
              description: '',
              unit: 'A', // 固定單位
            );
          }
        } else if (spcDesc.contains("Output_Power")) {
          if (spcItem.contains("Left  Plug") && leftTotalOutputPowerCount < 1) {
            double spec = 120;
            double lowerBound = globalInputOutputSpec!.leftPoutLowerbound;
            double upperBound = globalInputOutputSpec!.leftPoutUpperbound;
            double processedValue = processPowerValue(spcValue); // 自動除 1000 處理
            leftTotalOutputPowerCount++;
            leftTotalOutputPower = createMeasurementWithLogging(
              name: "Pout",
              spec: spec,
              value: processedValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: leftTotalOutputPowerCount,
              key: spcDesc,
              description: '',
              unit: globalInputOutputSpec!.leftPoutUnit,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightTotalOutputPowerCount < 1) {
            double spec = 120;
            double lowerBound = globalInputOutputSpec!.rightPoutLowerbound;
            double upperBound = globalInputOutputSpec!.rightPoutUpperbound;
            double processedValue = processPowerValue(spcValue); // 自動除 1000 處理
            rightTotalOutputPowerCount++;
            rightTotalOutputPower = createMeasurementWithLogging(
              name: "Pout",
              spec: spec,
              value: processedValue,
              lowerBound: lowerBound,
              upperBound: upperBound,
              count: rightTotalOutputPowerCount,
              key: spcDesc,
              description: '',
              unit: globalInputOutputSpec!.rightPoutUnit,
            );
          }
        } else if (spcDesc.contains("EFF")) {
          double spec = globalBasicFunctionTestSpec!.eff;
          if (effCount < 1) {
            effCount++;
            eff = BasicFunctionMeasurement(
              spec: spec,
              value: spcValue,
              count: effCount,
              key: spcDesc,
              name: "Efficiency",
              description: 'Spec: >94% \n Efficiency: {VALUE} %',
              judgement: spcValue > spec ? Judgement.pass : Judgement.fail,
              //defaultSpecText: _defaultSpec[1] ?? '>94%',
            );
          }
        } else if (spcDesc.contains("PowerFactor")) {
          double spec = globalBasicFunctionTestSpec!.pf;
          if (powerFactorCount < 1) {
            powerFactorCount++;
            powerFactor = BasicFunctionMeasurement(
              spec: spec,
              value: spcValue,
              count: powerFactorCount,
              key: spcDesc,
              name: "Power Factor (PF)",
              description: 'Spec: ≧ 0.99 \n PF: {VALUE} %',
              judgement: spcValue >= spec ? Judgement.pass : Judgement.fail,
              // defaultSpecText: _defaultSpec[2] ?? '≧ 0.99',
            );
          }
        } else if (spcDesc.contains("THD")) {
          double spec = globalBasicFunctionTestSpec!.thd;
          if (thdCount < 1) {
            thdCount++;
            harmonic = BasicFunctionMeasurement(
              spec: spec,
              value: spcValue,
              count: thdCount,
              key: spcDesc,
              name: "Harmonic",
              description: 'Spec: <5% \n THD: {VALUE} %',
              judgement: spcValue < spec ? Judgement.pass : Judgement.fail,
              // defaultSpecText: _defaultSpec[3] ?? '<5%',
            );
          }
        } else if (spcDesc.contains("Standby_Total_Input_Power")) {
          double spec = globalBasicFunctionTestSpec!.sp;
          if (standbyTotalInputPowerCount < 1) {
            standbyTotalInputPowerCount++;
            standbyTotalInputPower = BasicFunctionMeasurement(
              spec: spec,
              value: spcValue,
              count: standbyTotalInputPowerCount,
              key: spcDesc,
              name: "Standby Power",
              description: 'Spec: <100W \n Standby Power: {VALUE} W',
              judgement: spcValue < spec ? Judgement.pass : Judgement.fail,
              // defaultSpecText: _defaultSpec[4] ?? '<100W',
            );
          }
        }
      }
    }

    var leftSideInputOutputCharacteristicsSide = InputOutputCharacteristicsSide(
        "L",
        leftInputVoltage,
        leftInputCurrent,
        leftTotalInputPower ?? InputOutputMeasurement.empty(),
        leftOutputVoltage ?? InputOutputMeasurement.empty(),
        leftOutputCurrent ?? InputOutputMeasurement.empty(),
        leftTotalOutputPower ?? InputOutputMeasurement.empty());
    var rightSideInputOutputCharacteristicsSide =
        InputOutputCharacteristicsSide(
            "R",
            rightInputVoltage,
            rightInputCurrent,
            rightTotalInputPower ?? InputOutputMeasurement.empty(),
            rightOutputVoltage ?? InputOutputMeasurement.empty(),
            rightOutputCurrent ?? InputOutputMeasurement.empty(),
            rightTotalOutputPower ?? InputOutputMeasurement.empty());
    return InputOutputCharacteristics(
        leftSideInputOutputCharacteristics:
            leftSideInputOutputCharacteristicsSide,
        rightSideInputOutputCharacteristics:
            rightSideInputOutputCharacteristicsSide,
        basicFunctionTestResult: BasicFunctionTestResult(
          eff: eff ?? BasicFunctionMeasurement.empty(),
          powerFactor: powerFactor ?? BasicFunctionMeasurement.empty(),
          harmonic: harmonic ?? BasicFunctionMeasurement.empty(),
          standbyTotalInputPower:
              standbyTotalInputPower ?? BasicFunctionMeasurement.empty(),
        ));
  }

  static fromExcel(String string) {}
}

class InputOutputCharacteristicsSide {
  final List<InputOutputMeasurement> inputVoltage;
  final List<InputOutputMeasurement> inputCurrent;
  final InputOutputMeasurement totalInputPower;
  final InputOutputMeasurement outputVoltage;
  final InputOutputMeasurement outputCurrent;
  final InputOutputMeasurement totalOutputPower;

  final String side;

  Judgement? _manualJudgement; // 新增：人工修改的結果，預設 null

  // getter: 如果有人工結果，回傳人工結果；沒的話回傳自動判斷
  Judgement get judgement {
    if (_manualJudgement != null) {
      print('🔧 手動設定判斷結果 ($side): $_manualJudgement');
      return _manualJudgement!;
    }

    // 自動判斷邏輯（你原本的判斷）
    //Vin跟Iin暫時拿掉
    print('🔍 開始自動判斷 ($side側):');

    int passCount = 0;
    /*bool inputVoltagePass =
    inputVoltage.every((m) => m.judgement == Judgement.pass);
    bool inputCurrentPass =
    inputCurrent.every((m) => m.judgement == Judgement.pass);*/

    bool totalInputPowerPass = totalInputPower.judgement == Judgement.pass;
    bool outputVoltagePass = outputVoltage.judgement == Judgement.pass;
    bool outputCurrentPass = outputCurrent.judgement == Judgement.pass;
    bool totalOutputPowerPass = totalOutputPower.judgement == Judgement.pass;

    // 詳細日誌輸出 - 顯示完整範圍
    String getJudgmentInfo(InputOutputMeasurement measurement,
        double lowerBound, double upperBound) {
      final passed = measurement.judgement == Judgement.pass;
      return '  📊 ${measurement.name}: ${measurement.value} (範圍: $lowerBound ~ $upperBound) -> ${passed ? "✅ PASS" : "❌ FAIL"}';
    }

    // 獲取規格範圍
    final leftPinLower = globalInputOutputSpec?.leftPinLowerbound ?? 0;
    final leftPinUpper = globalInputOutputSpec?.leftPinUpperbound ?? 130;
    final leftVoutLower = globalInputOutputSpec?.leftVoutLowerbound ?? 931;
    final leftVoutUpper = globalInputOutputSpec?.leftVoutUpperbound ?? 969;
    final leftIoutLower = globalInputOutputSpec?.leftIoutLowerbound ?? 123;
    final leftIoutUpper = globalInputOutputSpec?.leftIoutUpperbound ?? 129;
    final leftPoutLower = globalInputOutputSpec?.leftPoutLowerbound ?? 118;
    final leftPoutUpper = globalInputOutputSpec?.leftPoutUpperbound ?? 122;

    final rightPinLower = globalInputOutputSpec?.rightPinLowerbound ?? 0;
    final rightPinUpper = globalInputOutputSpec?.rightPinUpperbound ?? 130;
    final rightVoutLower = globalInputOutputSpec?.rightVoutLowerbound ?? 931;
    final rightVoutUpper = globalInputOutputSpec?.rightVoutUpperbound ?? 969;
    final rightIoutLower = globalInputOutputSpec?.rightIoutLowerbound ?? 123;
    final rightIoutUpper = globalInputOutputSpec?.rightIoutUpperbound ?? 129;
    final rightPoutLower = globalInputOutputSpec?.rightPoutLowerbound ?? 118;
    final rightPoutUpper = globalInputOutputSpec?.rightPoutUpperbound ?? 122;

    // 根據側別顯示對應的範圍
    if (side == 'L') {
      print(getJudgmentInfo(totalInputPower, leftPinLower, leftPinUpper));
      print(getJudgmentInfo(outputVoltage, leftVoutLower, leftVoutUpper));
      print(getJudgmentInfo(outputCurrent, leftIoutLower, leftIoutUpper));
      print(getJudgmentInfo(totalOutputPower, leftPoutLower, leftPoutUpper));
    } else {
      print(getJudgmentInfo(totalInputPower, rightPinLower, rightPinUpper));
      print(getJudgmentInfo(outputVoltage, rightVoutLower, rightVoutUpper));
      print(getJudgmentInfo(outputCurrent, rightIoutLower, rightIoutUpper));
      print(getJudgmentInfo(totalOutputPower, rightPoutLower, rightPoutUpper));
    }

    // 計算通過的項目數
    final testResults = [
      /*inputVoltagePass,
      inputCurrentPass,*/
      totalInputPowerPass,
      outputVoltagePass,
      outputCurrentPass,
      totalOutputPowerPass
    ];

    // 重新計算passCount，確保邏輯正確
    passCount = 0;
    for (bool result in testResults) {
      if (result) passCount++;
    }

    // 🔒 強制修復邏輯：ALL項目都必須PASS，整體才能PASS
    final int totalItems = 4; // Pin, Vout, Iout, Pout
    final bool allItemsPass = (passCount == totalItems);

    // 🔒 額外安全檢查：確保沒有任何項目是FAIL
    final bool noFailItems = testResults.every((result) => result == true);

    // 🔒 雙重檢查：兩個條件都必須滿足
    final bool finalCheck = allItemsPass && noFailItems;

    final Judgement finalResult = finalCheck ? Judgement.pass : Judgement.fail;

    print(
        '  📈 通過項目數: $passCount/$totalItems，最終判斷: ${finalResult == Judgement.pass ? "✅ PASS" : "❌ FAIL"}');

    // 🔒 強制檢查：如果是PASS但passCount < totalItems，強制設為FAIL
    if (finalResult == Judgement.pass && passCount < totalItems) {
      print(
          '🚨 發現邏輯錯誤！強制修正為FAIL (passCount: $passCount, totalItems: $totalItems)');
      return Judgement.fail;
    }

    // 🔒 強制檢查：如果有任何個別項目是FAIL，整體必須是FAIL
    if (finalResult == Judgement.pass && !noFailItems) {
      print('🚨 發現邏輯錯誤！有項目FAIL但整體為PASS，強制修正為FAIL');
      return Judgement.fail;
    }

    return finalResult;
  }

  // setter: 用於人工修改結果
  set judgement(Judgement value) {
    _manualJudgement = value;
  }

  // 建構子
  InputOutputCharacteristicsSide(
      this.side,
      this.inputVoltage,
      this.inputCurrent,
      this.totalInputPower,
      this.outputVoltage,
      this.outputCurrent,
      this.totalOutputPower);
}

class InputOutputMeasurement {
  double spec;
  double value;
  double count;
  String key;
  String name;
  String description;
  Judgement judgement;

  InputOutputMeasurement(
      {required this.spec,
      required this.value,
      required this.count,
      required this.key,
      required this.name,
      required this.description,
      required this.judgement});

  factory InputOutputMeasurement.empty() {
    return InputOutputMeasurement(
        spec: 0,
        value: 0,
        count: 0,
        key: "",
        name: "",
        description: '',
        judgement: Judgement.fail);
  }
}
