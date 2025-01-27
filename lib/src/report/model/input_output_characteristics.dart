import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';

class InputOutputCharacteristics {
  final InputOutputCharacteristicsSide leftSideInputOutputCharacteristics;
  final InputOutputCharacteristicsSide rightSideInputOutputCharacteristics;
  final BasicFunctionTestResult basicFunctionTestResult;

  List<InputOutputCharacteristicsSide> get inputOutputCharacteristicsSide => [
        leftSideInputOutputCharacteristics,
        rightSideInputOutputCharacteristics,
      ];

  InputOutputCharacteristics({
    required this.rightSideInputOutputCharacteristics,
    required this.leftSideInputOutputCharacteristics,
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
    InputOutputMeasurement? eff;
    InputOutputMeasurement? powerFactor;
    InputOutputMeasurement? harmonic;
    InputOutputMeasurement? standbyTotalInputPower;

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

      //print("檢查數據: SPC_DESC=$spcDesc, SPC_VALUE=$spcValue");

      if (spcDesc != null && spcItem != null) {
        if (spcDesc.contains("Input_Voltage")) {
          if (spcItem.contains("Left  Plug") && leftInputVoltageCount < 3) {
            leftInputVoltageCount++;
            leftInputVoltage.add(InputOutputMeasurement(
              spec: 220,
              value: spcValue,
              count: leftInputVoltageCount,
              key: spcDesc,
              name: "Vin",
              description: '',
              judgement: Judgement.pass,
            ));
          } else if (spcItem.contains("Right Plug") &&
              rightInputVoltageCount < 3) {
            rightInputVoltageCount++;
            rightInputVoltage.add(InputOutputMeasurement(
              spec: 220,
              value: spcValue,
              count: rightInputVoltageCount,
              key: spcDesc,
              name: "Vin",
              description: '',
              judgement: Judgement.pass,
            ));
          }
        } else if (spcDesc.contains("Input_Current")) {
          if (spcItem.contains("Left  Plug") && leftInputCurrentCount < 3) {
            leftInputCurrentCount++;
            leftInputCurrent.add(InputOutputMeasurement(
              spec: 295,
              value: spcValue,
              count: leftInputCurrentCount,
              key: spcDesc,
              name: "Iin",
              description: '',
              judgement: Judgement.pass,
            ));
            print("加入 Left Input Current: $spcValue");
          } else if (spcItem.contains("Right Plug") &&
              rightInputCurrentCount < 3) {
            rightInputCurrentCount++;
            rightInputCurrent.add(InputOutputMeasurement(
              spec: 295,
              value: spcValue,
              count: rightInputCurrentCount,
              key: spcDesc,
              name: "Iin",
              description: '',
              judgement: Judgement.pass,
            ));
            print("加入 Right Input Current: $spcValue");
          }
        } else if (spcDesc.contains("Total_Input_Power")) {
          if (spcItem.contains("Left  Plug") && leftTotalInputPowerCount < 1) {
            leftTotalInputPowerCount++;
            leftTotalInputPower = InputOutputMeasurement(
                spec: 196,
                value: spcValue,
                count: leftTotalInputPowerCount,
                key: spcDesc,
                name: "Pin",
                description: '',
                judgement: Judgement.pass);
          } else if (spcItem.contains("Right Plug") &&
              rightTotalInputPowerCount < 1) {
            rightTotalInputPowerCount++;
            rightTotalInputPower = InputOutputMeasurement(
                spec: 196,
                value: spcValue,
                count: leftTotalInputPowerCount,
                key: spcDesc,
                name: "Pin",
                description: '',
                judgement: Judgement.pass);
          }
        } else if (spcDesc.contains("Output_Voltage")) {
          if (spcItem.contains("Left  Plug") && leftOutputVoltageCount < 1) {
            leftOutputVoltageCount++;
            leftOutputVoltage = InputOutputMeasurement(
                spec: 935,
                value: spcValue,
                count: leftOutputVoltageCount,
                key: spcDesc,
                name: "Vout",
                description: '',
                judgement: Judgement.pass);
          } else if (spcItem.contains("Right Plug") &&
              rightOutputVoltageCount < 1) {
            rightOutputVoltageCount++;
            rightOutputVoltage = InputOutputMeasurement(
                spec: 935,
                value: spcValue,
                count: rightOutputVoltageCount,
                key: spcDesc,
                name: "Vout",
                description: '',
                judgement: Judgement.pass);
          }
        } else if (spcDesc.contains("Output_Current")) {
          if (spcItem.contains("Left  Plug") && leftOutputCurrentCount < 1) {
            leftOutputCurrentCount++;
            leftOutputCurrent = InputOutputMeasurement(
                spec: 189,
                value: spcValue,
                count: leftOutputCurrentCount,
                key: spcDesc,
                name: "Iout",
                description: '',
                judgement: Judgement.pass);
          } else if (spcItem.contains("Right Plug") &&
              rightOutputCurrentCount < 1) {
            rightOutputCurrentCount++;
            rightOutputCurrent = InputOutputMeasurement(
                spec: 189,
                value: spcValue,
                count: rightOutputCurrentCount,
                key: spcDesc,
                name: "Iout",
                description: '',
                judgement: Judgement.pass);
          }
        } else if (spcDesc.contains("Output_Power")) {
          if (spcItem.contains("Left  Plug") && leftTotalOutputPowerCount < 1) {
            leftTotalOutputPowerCount++;
            leftTotalOutputPower = InputOutputMeasurement(
                spec: 180,
                value: spcValue,
                count: leftTotalOutputPowerCount,
                key: spcDesc,
                name: "Pout",
                description: '',
                judgement: Judgement.pass);
          } else if (spcItem.contains("Right Plug") &&
              rightTotalOutputPowerCount < 1) {
            rightTotalOutputPowerCount++;
            rightTotalOutputPower = InputOutputMeasurement(
                spec: 180,
                value: spcValue,
                count: rightTotalOutputPowerCount,
                key: spcDesc,
                name: "Pout",
                description: '',
                judgement: Judgement.pass);
          }
        } else if (spcDesc.contains("EFF")) {
          if (effCount < 1) {
            effCount++;
            eff = InputOutputMeasurement(
                spec: 94,
                value: spcValue,
                count: effCount,
                key: spcDesc,
                name: "EFF",
                description: 'Spec: >94%',
                judgement: Judgement.pass);
          }
        } else if (spcDesc.contains("PowerFactor")) {
          if (powerFactorCount < 1) {
            powerFactorCount++;
            powerFactor = InputOutputMeasurement(
                spec: 0.99,
                value: spcValue,
                count: effCount,
                key: spcDesc,
                name: "PF",
                description: 'Spec: ≧ 0.99',
                judgement: Judgement.pass);
          }
        } else if (spcDesc.contains("THD")) {
          if (thdCount < 1) {
            thdCount++;
            harmonic = InputOutputMeasurement(
                spec: 5,
                value: spcValue,
                count: thdCount,
                key: spcDesc,
                name: "Harmonic",
                description: 'Spec: <5%',
                judgement: Judgement.pass);
          }
        } else if (spcDesc.contains("Standby_Total_Input_Power")) {
          if (standbyTotalInputPowerCount < 1) {
            standbyTotalInputPowerCount++;
            standbyTotalInputPower = InputOutputMeasurement(
                spec: 100,
                value: spcValue,
                count: standbyTotalInputPowerCount,
                key: spcDesc,
                name: "STIP",
                description: 'Spec: <100W',
                judgement: Judgement.pass);
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
          eff: eff ?? InputOutputMeasurement.empty(),
          powerFactor: powerFactor ?? InputOutputMeasurement.empty(),
          harmonic: harmonic ?? InputOutputMeasurement.empty(),
          standbyTotalInputPower:
              standbyTotalInputPower ?? InputOutputMeasurement.empty(),
        ));
  }

  static fromExcel(String string) {}
}

class BasicFunctionTestResult {
  final InputOutputMeasurement eff;
  final InputOutputMeasurement powerFactor;
  final InputOutputMeasurement harmonic;
  final InputOutputMeasurement standbyTotalInputPower;

  BasicFunctionTestResult({
    required this.eff,
    required this.powerFactor,
    required this.harmonic,
    required this.standbyTotalInputPower,
  });

  List<InputOutputMeasurement> get testItems => [
        eff,
        powerFactor,
        harmonic,
        standbyTotalInputPower,
      ];
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
