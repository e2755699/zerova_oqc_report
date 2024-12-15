class InputOutputCharacteristics {
  final List<Measurement> leftInputVoltage;
  final List<Measurement> leftInputCurrent;
  final List<Measurement> rightInputVoltage;
  final List<Measurement> rightInputCurrent;
  final Measurement leftTotalInputPower;
  final Measurement rightTotalInputPower;
  final Measurement leftOutputVoltage;
  final Measurement leftOutputCurrent;
  final Measurement leftTotalOutputPower;
  final Measurement rightOutputVoltage;
  final Measurement rightOutputCurrent;
  final Measurement rightTotalOutputPower;
  final Measurement eff;
  final Measurement powerFactor;
  final Measurement thd;
  final Measurement standbyTotalInputPower;

  InputOutputCharacteristics({
    required this.leftInputVoltage,
    required this.leftInputCurrent,
    required this.rightInputVoltage,
    required this.rightInputCurrent,
    required this.leftTotalInputPower,
    required this.rightTotalInputPower,
    required this.leftOutputVoltage,
    required this.leftOutputCurrent,
    required this.leftTotalOutputPower,
    required this.rightOutputVoltage,
    required this.rightOutputCurrent,
    required this.rightTotalOutputPower,
    required this.eff,
    required this.powerFactor,
    required this.thd,
    required this.standbyTotalInputPower,
  });

  /// 從 JSON 資料生成 `InputOutputCharacteristics`
  factory InputOutputCharacteristics.fromJson(Map<String, dynamic> json) {
    Measurement parseMeasurement(String prefix, String key, double spec, String name) {
      return Measurement(
        spec: spec,
        value: json["${prefix}_$key"] ?? 0.0,
        key: "${prefix}_$key",
        name: name,
      );
    }

    return InputOutputCharacteristics(
      leftInputVoltage: [],
      leftInputCurrent: [],
      rightInputVoltage: [],
      rightInputCurrent: [],
      leftTotalInputPower: parseMeasurement("L", "Total_Input_P", 195, "Pin"),
      rightTotalInputPower: parseMeasurement("R", "Total_Input_P", 195, "Pin"),
      leftOutputVoltage: parseMeasurement("L", "Output_V", 950, "Vout"),
      leftOutputCurrent: parseMeasurement("L", "Output_A", 189, "Iout"),
      leftTotalOutputPower: parseMeasurement("L", "Total_Output_P", 180, "Pout"),
      rightOutputVoltage: parseMeasurement("R", "Output_V", 950, "Vout"),
      rightOutputCurrent: parseMeasurement("R", "Output_A", 189, "Iout"),
      rightTotalOutputPower: parseMeasurement("R", "Total_Output_P", 180, "Pout"),
      eff: parseMeasurement("", "Eff", 180, "Eff"),
      powerFactor: parseMeasurement("", "Power_Factor", 180, "PF"),
      thd: parseMeasurement("", "THD", 180, "THD"),
      standbyTotalInputPower: parseMeasurement("", "Standby_TotalInput_Power", 180, "STIP"),
    );
  }

  /// 從 JSON 清單數據提取並生成 `InputOutputCharacteristics`
  static InputOutputCharacteristics fromJsonList(List<dynamic> data) {
    List<Measurement> leftInputVoltage = [];
    List<Measurement> leftInputCurrent = [];
    List<Measurement> rightInputVoltage = [];
    List<Measurement> rightInputCurrent = [];

    for (var item in data) {
      String? spcDesc = item['SPC_DESC'];
      String? spcValueStr = item['SPC_VALUE'];
      String? spcItem = item['SPC_ITEM'];
      double spcValue = double.tryParse(spcValueStr ?? "0") ?? 0;

      print("檢查數據: SPC_DESC=$spcDesc, SPC_VALUE=$spcValue");

      if (spcDesc != null && spcItem != null) {
        if (spcDesc.contains("Input_Voltage")) {
          if (spcItem.contains("Left Plug")) {

            leftInputVoltage.add(Measurement(
              spec: 220,
              value: spcValue,
              key: spcDesc,
              name: "Vin",
            ));
            print("加入 Left Input Voltage: $spcValue");
          }
          else if (spcItem.contains("Right Plug")) {
            rightInputVoltage.add(Measurement(
              spec: 220,
              value: spcValue,
              key: spcDesc,
              name: "Vin",
            ));
            print("加入 Right Input Voltage: $spcValue");
          }
        } else if (spcDesc.contains("Input_Current")) {
          if (spcItem.contains("Left Plug")) {
            leftInputCurrent.add(Measurement(
              spec: 295,
              value: spcValue,
              key: spcDesc,
              name: "Iin",
            ));
            print("加入 Left Input Current: $spcValue");
          }
          else if (spcItem.contains("Right Plug")) {
            rightInputCurrent.add(Measurement(
              spec: 295,
              value: spcValue,
              key: spcDesc,
              name: "Iin",
            ));
            print("加入 Right Input Current: $spcValue");
          }
        }
      }
    }

    return InputOutputCharacteristics(
      leftInputVoltage: leftInputVoltage,
      leftInputCurrent: leftInputCurrent,
      rightInputVoltage: rightInputVoltage,
      rightInputCurrent: rightInputCurrent,
      leftTotalInputPower: Measurement(spec: 0, value: 0, key: "", name: ""),
      rightTotalInputPower: Measurement(spec: 0, value: 0, key: "", name: ""),
      leftOutputVoltage: Measurement(spec: 0, value: 0, key: "", name: ""),
      leftOutputCurrent: Measurement(spec: 0, value: 0, key: "", name: ""),
      leftTotalOutputPower: Measurement(spec: 0, value: 0, key: "", name: ""),
      rightOutputVoltage: Measurement(spec: 0, value: 0, key: "", name: ""),
      rightOutputCurrent: Measurement(spec: 0, value: 0, key: "", name: ""),
      rightTotalOutputPower: Measurement(spec: 0, value: 0, key: "", name: ""),
      eff: Measurement(spec: 0, value: 0, key: "", name: ""),
      powerFactor: Measurement(spec: 0, value: 0, key: "", name: ""),
      thd: Measurement(spec: 0, value: 0, key: "", name: ""),
      standbyTotalInputPower: Measurement(spec: 0, value: 0, key: "", name: ""),
    );
  }


}

class Measurement {
  final double spec;
  final double value;
  final String key;
  final String name;

  Measurement({
    required this.spec,
    required this.value,
    required this.key,
    required this.name,
  });
}
