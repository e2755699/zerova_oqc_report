import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/basic_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/basic_function_test_table.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';

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
            leftInputVoltage.add(InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftInputVoltageCount,
              key: spcDesc,
              name: "Vin",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            ));
          } else if (spcItem.contains("Right Plug") &&
              rightInputVoltageCount < 3) {
            double spec = 220;
            double lowerBound = globalInputOutputSpec!.rightVinLowerbound;
            double upperBound = globalInputOutputSpec!.rightVinUpperbound;
            rightInputVoltageCount++;
            rightInputVoltage.add(InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: rightInputVoltageCount,
              key: spcDesc,
              name: "Vin",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            ));
          }
        } else if (spcDesc.contains("Input_Current")) {
          if (spcItem.contains("Left  Plug") && leftInputCurrentCount < 3) {
            double spec = 230;
            double lowerBound = globalInputOutputSpec!.leftIinLowerbound;
            double upperBound = globalInputOutputSpec!.leftIinUpperbound;
            leftInputCurrentCount++;
            leftInputCurrent.add(InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftInputCurrentCount,
              key: spcDesc,
              name: "Iin",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            ));
          } else if (spcItem.contains("Right Plug") &&
              rightInputCurrentCount < 3) {
            double spec = 230;
            double lowerBound = globalInputOutputSpec!.rightIinLowerbound;
            double upperBound = globalInputOutputSpec!.rightIinUpperbound;
            rightInputCurrentCount++;
            rightInputCurrent.add(InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: rightInputCurrentCount,
              key: spcDesc,
              name: "Iin",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            ));
          }
        }
        else if (spcDesc == "Total_Input_Power" && spcValue != 0) {
          if (spcItem.contains("Left  Plug") && leftTotalInputPowerCount < 1) {
            double spec = 130;
            double lowerBound = globalInputOutputSpec!.leftPinLowerbound;
            double upperBound = globalInputOutputSpec!.leftPinUpperbound;
            leftTotalInputPowerCount++;

            // 數值轉換：如果大於10萬則除以1000 (W -> kW)
            double convertedValue =
                spcValue > 100000 ? spcValue / 1000 : spcValue;

            leftTotalInputPower = InputOutputMeasurement(
              spec: spec,
              value: convertedValue,
              count: leftTotalInputPowerCount,
              key: spcDesc,
              name: "Pin",
              description: '',
              judgement:
                  (convertedValue >= lowerBound && convertedValue <= upperBound)
                      ? Judgement.pass
                      : Judgement.fail,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightTotalInputPowerCount < 1) {
            double spec = 130;
            double lowerBound = globalInputOutputSpec!.rightPinLowerbound;
            double upperBound = globalInputOutputSpec!.rightPinUpperbound;
            rightTotalInputPowerCount++;

            // 數值轉換：如果大於10萬則除以1000 (W -> kW)
            double convertedValue =
                spcValue > 100000 ? spcValue / 1000 : spcValue;

            rightTotalInputPower = InputOutputMeasurement(
              spec: spec,
              value: convertedValue,
              count: leftTotalInputPowerCount,
              key: spcDesc,
              name: "Pin",
              description: '',
              judgement:
                  (convertedValue >= lowerBound && convertedValue <= upperBound)
                      ? Judgement.pass
                      : Judgement.fail,
            );
          }
        }
        else if (spcDesc.contains("Output_Voltage") && spcValue != 0) {
          if (spcItem.contains("Left  Plug") && leftOutputVoltageCount < 1) {
            double spec = 950;
            double lowerBound = globalInputOutputSpec!.leftVoutLowerbound;
            double upperBound = globalInputOutputSpec!.leftVoutUpperbound;
            leftOutputVoltageCount++;
            leftOutputVoltage = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftOutputVoltageCount,
              key: spcDesc,
              name: "Vout",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightOutputVoltageCount < 1) {
            double spec = 950;
            double lowerBound = globalInputOutputSpec!.rightVoutLowerbound;
            double upperBound = globalInputOutputSpec!.rightVoutUpperbound;
            rightOutputVoltageCount++;
            rightOutputVoltage = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: rightOutputVoltageCount,
              key: spcDesc,
              name: "Vout",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            );
          }
        }
        else if (spcDesc.contains("Output_Current") && spcValue != 0) {
          if (spcItem.contains("Left  Plug") && leftOutputCurrentCount < 1) {
            double spec = 126;
            double lowerBound = globalInputOutputSpec!.leftIoutLowerbound;
            double upperBound = globalInputOutputSpec!.leftIoutUpperbound;
            leftOutputCurrentCount++;
            leftOutputCurrent = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftOutputCurrentCount,
              key: spcDesc,
              name: "Iout",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightOutputCurrentCount < 1) {
            double spec = 126;
            double lowerBound = globalInputOutputSpec!.rightIoutLowerbound;
            double upperBound = globalInputOutputSpec!.rightIoutUpperbound;
            rightOutputCurrentCount++;
            rightOutputCurrent = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: rightOutputCurrentCount,
              key: spcDesc,
              name: "Iout",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            );
          }
        }
        else if (spcDesc.contains("Output_Power") && spcValue != 0) {
          if (spcItem.contains("Left  Plug") && leftTotalOutputPowerCount < 1) {
            double spec = 120;
            double lowerBound = globalInputOutputSpec!.leftPoutLowerbound;
            double upperBound = globalInputOutputSpec!.leftPoutUpperbound;
            leftTotalOutputPowerCount++;

            // 數值轉換：如果大於10萬則除以1000 (W -> kW)
            double convertedValue =
                spcValue > 100000 ? spcValue / 1000 : spcValue;

            leftTotalOutputPower = InputOutputMeasurement(
              spec: spec,
              value: convertedValue,
              count: leftTotalOutputPowerCount,
              key: spcDesc,
              name: "Pout",
              description: '',
              judgement:
                  (convertedValue >= lowerBound && convertedValue <= upperBound)
                      ? Judgement.pass
                      : Judgement.fail,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightTotalOutputPowerCount < 1) {
            double spec = 120;
            double lowerBound = globalInputOutputSpec!.rightPoutLowerbound;
            double upperBound = globalInputOutputSpec!.rightPoutUpperbound;
            rightTotalOutputPowerCount++;

            // 數值轉換：如果大於10萬則除以1000 (W -> kW)
            double convertedValue =
                spcValue > 100000 ? spcValue / 1000 : spcValue;

            rightTotalOutputPower = InputOutputMeasurement(
              spec: spec,
              value: convertedValue,
              count: rightTotalOutputPowerCount,
              key: spcDesc,
              name: "Pout",
              description: '',
              judgement:
                  (convertedValue >= lowerBound && convertedValue <= upperBound)
                      ? Judgement.pass
                      : Judgement.fail,
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
      return _manualJudgement!;
    }

    // 自動判斷邏輯（你原本的判斷）
    //Vin跟Iin暫時拿掉
    int passCount = 0;
    /*bool inputVoltagePass =
    inputVoltage.every((m) => m.judgement == Judgement.pass);
    bool inputCurrentPass =
    inputCurrent.every((m) => m.judgement == Judgement.pass);*/
    bool totalInputPowerPass = totalInputPower.judgement == Judgement.pass;
    bool outputVoltagePass = outputVoltage.judgement == Judgement.pass;
    bool outputCurrentPass = outputCurrent.judgement == Judgement.pass;
    bool totalOutputPowerPass = totalOutputPower.judgement == Judgement.pass;
    [
      /*inputVoltagePass,
      inputCurrentPass,*/
      totalInputPowerPass,
      outputVoltagePass,
      outputCurrentPass,
      totalOutputPowerPass
    ].forEach((passed) {
      if (passed) passCount++;
    });

    return passCount > 2 ? Judgement.pass : Judgement.fail;
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
