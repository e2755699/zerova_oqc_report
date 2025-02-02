import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/basic_function_test_result.dart';

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
            double lowerBound = 187;
            double upperBound = 253;
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
            double lowerBound = 187;
            double upperBound = 253;
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
            leftInputCurrentCount++;
            leftInputCurrent.add(InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftInputCurrentCount,
              key: spcDesc,
              name: "Iin",
              description: '',
              judgement: spcValue < spec ? Judgement.pass : Judgement.fail,
            ));
          } else if (spcItem.contains("Right Plug") &&
              rightInputCurrentCount < 3) {
            double spec = 230;
            rightInputCurrentCount++;
            rightInputCurrent.add(InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: rightInputCurrentCount,
              key: spcDesc,
              name: "Iin",
              description: '',
              judgement: spcValue < spec ? Judgement.pass : Judgement.fail,
            ));
          }
        } else if (spcDesc == "Total_Input_Power") {
          if (spcItem.contains("Left  Plug") && leftTotalInputPowerCount < 1) {
            double spec = 130;
            leftTotalInputPowerCount++;
            leftTotalInputPower = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftTotalInputPowerCount,
              key: spcDesc,
              name: "Pin",
              description: '',
              judgement: spcValue < spec ? Judgement.pass : Judgement.fail,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightTotalInputPowerCount < 1) {
            double spec = 130;
            rightTotalInputPowerCount++;
            rightTotalInputPower = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftTotalInputPowerCount,
              key: spcDesc,
              name: "Pin",
              description: '',
              judgement: spcValue < spec ? Judgement.pass : Judgement.fail,
            );
          }
        } else if (spcDesc.contains("Output_Voltage")) {
          if (spcItem.contains("Left  Plug") && leftOutputVoltageCount < 1) {
            double spec = 950;
            double lowerBound = 931;
            double upperBound = 969;
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
            double lowerBound = 931;
            double upperBound = 969;
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
        } else if (spcDesc.contains("Output_Current")) {
          if (spcItem.contains("Left  Plug") && leftOutputCurrentCount < 1) {
            double spec = 126;
            double lowerBound = 123;
            double upperBound = 129;
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
            double lowerBound = 123;
            double upperBound = 129;
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
        } else if (spcDesc.contains("Output_Power")) {
          if (spcItem.contains("Left  Plug") && leftTotalOutputPowerCount < 1) {
            double spec = 120;
            double lowerBound = 118;
            double upperBound = 122;
            leftTotalOutputPowerCount++;
            leftTotalOutputPower = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: leftTotalOutputPowerCount,
              key: spcDesc,
              name: "Pout",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            );
          } else if (spcItem.contains("Right Plug") &&
              rightTotalOutputPowerCount < 1) {
            double spec = 120;
            double lowerBound = 118;
            double upperBound = 122;
            rightTotalOutputPowerCount++;
            rightTotalOutputPower = InputOutputMeasurement(
              spec: spec,
              value: spcValue,
              count: rightTotalOutputPowerCount,
              key: spcDesc,
              name: "Pout",
              description: '',
              judgement: (spcValue >= lowerBound && spcValue <= upperBound)
                  ? Judgement.pass
                  : Judgement.fail,
            );
          }
        } else if (spcDesc.contains("EFF")) {
          double spec = 94;
          if (effCount < 1) {
            effCount++;
            eff = BasicFunctionMeasurement(
              spec: spec,
              value: spcValue,
              count: effCount,
              key: spcDesc,
              name: "EFF",
              description: 'Spec: >94% \n Efficiency: {VALUE} %',
              judgement: spcValue <= spec ? Judgement.fail : Judgement.pass,
            );
          }
        } else if (spcDesc.contains("PowerFactor")) {
          double spec = 0.99;
          if (powerFactorCount < 1) {
            powerFactorCount++;
            powerFactor = BasicFunctionMeasurement(
              spec: 0.99,
              value: spcValue,
              count: powerFactorCount,
              key: spcDesc,
              name: "PF",
              description: 'Spec: ≧ 0.99 \n PF: {VALUE} %',
              judgement: spcValue < spec ? Judgement.fail : Judgement.pass,
            );
          }
        } else if (spcDesc.contains("THD")) {
          double spec = 5;
          if (thdCount < 1) {
            thdCount++;
            harmonic = BasicFunctionMeasurement(
              spec: spec,
              value: spcValue,
              count: thdCount,
              key: spcDesc,
              name: "Harmonic",
              description: 'Spec: <5% \n THD: {VALUE} %',
              judgement: spcValue >= spec ? Judgement.fail : Judgement.pass,
            );
          }
        } else if (spcDesc.contains("Standby_Total_Input_Power")) {
          double spec = 100;
          if (standbyTotalInputPowerCount < 1) {
            standbyTotalInputPowerCount++;
            standbyTotalInputPower = BasicFunctionMeasurement(
              spec: spec,
              value: spcValue,
              count: standbyTotalInputPowerCount,
              key: spcDesc,
              name: "Standby Power",
              description: 'Spec: <100W \n Standby Power: {VALUE} W',
              judgement: spcValue >= spec ? Judgement.fail : Judgement.pass,
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

  String get judgement => "OK";

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
  final double spec;
  final double value;
  final double count;
  final String key;
  final String name;
  final String description;

  final Judgement judgement;

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
