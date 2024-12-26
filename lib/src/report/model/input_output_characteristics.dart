class InputOutputCharacteristics {
  final InputOutputCharacteristicsSide leftSideInputOutputCharacteristics;
  final InputOutputCharacteristicsSide rightSideInputOutputCharacteristics;

  final Measurement eff;
  final Measurement powerFactor;
  final Measurement thd;
  final Measurement standbyTotalInputPower;

  List<InputOutputCharacteristicsSide> get inputOutputCharacteristicsSide => [
        leftSideInputOutputCharacteristics,
        rightSideInputOutputCharacteristics,
      ];

  InputOutputCharacteristics({
    required this.rightSideInputOutputCharacteristics,
    required this.leftSideInputOutputCharacteristics,
    required this.eff,
    required this.powerFactor,
    required this.thd,
    required this.standbyTotalInputPower,
  });

  /// 從 JSON 清單數據提取並生成 `InputOutputCharacteristics`
  static InputOutputCharacteristics fromJsonList(List<dynamic> data) {
    List<Measurement> leftInputVoltage = [];
    List<Measurement> leftInputCurrent = [];
    List<Measurement> rightInputVoltage = [];
    List<Measurement> rightInputCurrent = [];

    Measurement? leftTotalInputPower;
    Measurement? leftOutputVoltage;
    Measurement? leftOutputCurrent;
    Measurement? leftTotalOutputPower;
    Measurement? rightTotalInputPower;
    Measurement? rightOutputVoltage;
    Measurement? rightOutputCurrent;
    Measurement? rightTotalOutputPower;
    Measurement? eff;
    Measurement? powerFactor;
    Measurement? thd;
    Measurement? standbyTotalInputPower;

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
            leftInputVoltage.add(Measurement(
              spec: 220,
              value: spcValue,
              count: leftInputVoltageCount,
              key: spcDesc,
              name: "Vin",
            ));
          } else if (spcItem.contains("Right Plug") &&
              rightInputVoltageCount < 3) {
            rightInputVoltageCount++;
            rightInputVoltage.add(Measurement(
              spec: 220,
              value: spcValue,
              count: rightInputVoltageCount,
              key: spcDesc,
              name: "Vin",
            ));
          }
        } else if (spcDesc.contains("Input_Current")) {
          if (spcItem.contains("Left  Plug") && leftInputCurrentCount < 3) {
            leftInputCurrentCount++;
            leftInputCurrent.add(Measurement(
              spec: 295,
              value: spcValue,
              count: leftInputCurrentCount,
              key: spcDesc,
              name: "Iin",
            ));
            print("加入 Left Input Current: $spcValue");
          } else if (spcItem.contains("Right Plug") &&
              rightInputCurrentCount < 3) {
            rightInputCurrentCount++;
            rightInputCurrent.add(Measurement(
              spec: 295,
              value: spcValue,
              count: rightInputCurrentCount,
              key: spcDesc,
              name: "Iin",
            ));
            print("加入 Right Input Current: $spcValue");
          }
        } else if (spcDesc.contains("Total_Input_Power")) {
          if (spcItem.contains("Left  Plug") && leftTotalInputPowerCount < 1) {
            leftTotalInputPowerCount++;
            leftTotalInputPower = Measurement(
                spec: 196,
                value: spcValue,
                count: leftTotalInputPowerCount,
                key: spcDesc,
                name: "Pin");
          } else if (spcItem.contains("Right Plug") &&
              rightTotalInputPowerCount < 1) {
            rightTotalInputPowerCount++;
            rightTotalInputPower = Measurement(
                spec: 196,
                value: spcValue,
                count: leftTotalInputPowerCount,
                key: spcDesc,
                name: "Pin");
          }
        } else if (spcDesc.contains("Output_Voltage")) {
          if (spcItem.contains("Left  Plug") && leftOutputVoltageCount < 1) {
            leftOutputVoltageCount++;
            leftOutputVoltage = Measurement(
                spec: 935,
                value: spcValue,
                count: leftOutputVoltageCount,
                key: spcDesc,
                name: "Vout");
          } else if (spcItem.contains("Right Plug") &&
              rightOutputVoltageCount < 1) {
            rightOutputVoltageCount++;
            rightOutputVoltage = Measurement(
                spec: 935,
                value: spcValue,
                count: rightOutputVoltageCount,
                key: spcDesc,
                name: "Vout");
          }
        } else if (spcDesc.contains("Output_Current")) {
          if (spcItem.contains("Left  Plug") && leftOutputCurrentCount < 1) {
            leftOutputCurrentCount++;
            leftOutputCurrent = Measurement(
                spec: 189,
                value: spcValue,
                count: leftOutputCurrentCount,
                key: spcDesc,
                name: "Iout");
          } else if (spcItem.contains("Right Plug") &&
              rightOutputCurrentCount < 1) {
            rightOutputCurrentCount++;
            rightOutputCurrent = Measurement(
                spec: 189,
                value: spcValue,
                count: rightOutputCurrentCount,
                key: spcDesc,
                name: "Iout");
          }
        } else if (spcDesc.contains("Output_Power")) {
          if (spcItem.contains("Left  Plug") && leftTotalOutputPowerCount < 1) {
            leftTotalOutputPowerCount++;
            leftTotalOutputPower = Measurement(
                spec: 180,
                value: spcValue,
                count: leftTotalOutputPowerCount,
                key: spcDesc,
                name: "Pout");
          } else if (spcItem.contains("Right Plug") &&
              rightTotalOutputPowerCount < 1) {
            rightTotalOutputPowerCount++;
            rightTotalOutputPower = Measurement(
                spec: 180,
                value: spcValue,
                count: rightTotalOutputPowerCount,
                key: spcDesc,
                name: "Pout");
          }
        } else if (spcDesc.contains("EFF")) {
          if (effCount < 1) {
            effCount++;
            eff = Measurement(
                spec: 94,
                value: spcValue,
                count: effCount,
                key: spcDesc,
                name: "EFF");
          }
        } else if (spcDesc.contains("PowerFactor")) {
          if (powerFactorCount < 1) {
            powerFactorCount++;
            powerFactor = Measurement(
                spec: 0.99,
                value: spcValue,
                count: effCount,
                key: spcDesc,
                name: "PF");
          }
        } else if (spcDesc.contains("THD")) {
          if (thdCount < 1) {
            thdCount++;
            thd = Measurement(
                spec: 5,
                value: spcValue,
                count: thdCount,
                key: spcDesc,
                name: "THD");
          }
        } else if (spcDesc.contains("Standby_Total_Input_Power")) {
          if (standbyTotalInputPowerCount < 1) {
            standbyTotalInputPowerCount++;
            standbyTotalInputPower = Measurement(
                spec: 100,
                value: spcValue,
                count: standbyTotalInputPowerCount,
                key: spcDesc,
                name: "STIP");
          }
        }
      }
    }

    var leftSideInputOutputCharacteristicsSide = InputOutputCharacteristicsSide(
        "L",
        leftInputVoltage,
        leftInputCurrent,
        leftTotalInputPower ??
            Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
        leftOutputVoltage ??
            Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
        leftOutputCurrent ??
            Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
        leftTotalOutputPower ??
            Measurement(spec: 0, value: 0, count: 0, key: "", name: ""));
    var rightSideInputOutputCharacteristicsSide =
        InputOutputCharacteristicsSide(
            "R",
            rightInputVoltage,
            rightInputCurrent,
            rightTotalInputPower ??
                Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
            rightOutputVoltage ??
                Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
            rightOutputCurrent ??
                Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
            rightTotalOutputPower ??
                Measurement(spec: 0, value: 0, count: 0, key: "", name: ""));
    return InputOutputCharacteristics(
      leftSideInputOutputCharacteristics:
          leftSideInputOutputCharacteristicsSide,
      rightSideInputOutputCharacteristics:
          rightSideInputOutputCharacteristicsSide,
      eff: eff ?? Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
      powerFactor: powerFactor ??
          Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
      thd: thd ?? Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
      standbyTotalInputPower: standbyTotalInputPower ??
          Measurement(spec: 0, value: 0, count: 0, key: "", name: ""),
    );
  }

  static fromExcel(String string) {}
}

class InputOutputCharacteristicsSide {
  final List<Measurement> inputVoltage;
  final List<Measurement> inputCurrent;
  final Measurement totalInputPower;
  final Measurement outputVoltage;
  final Measurement outputCurrent;
  final Measurement totalOutputPower;

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

class Measurement {
  final double spec;
  final double value;
  final double count;
  final String key;
  final String name;

  Measurement({
    required this.spec,
    required this.value,
    required this.count,
    required this.key,
    required this.name,
  });
}
