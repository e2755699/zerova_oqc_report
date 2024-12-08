class InputOutputCharacteristics {

  final Measurement leftInputVoltage;
  final Measurement leftInputCurrent;
  final Measurement leftTotalInputPower;
  final Measurement rightInputVoltage;
  final Measurement rightInputCurrent;
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


  InputOutputCharacteristics(
      {
        required this.leftInputVoltage,
        required this.leftInputCurrent,
        required this.leftTotalInputPower,
        required this.rightInputVoltage,
        required this.rightInputCurrent,
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

  factory InputOutputCharacteristics.fromJson(Map<String, dynamic> json){
    var leftInputVoltage = Measurement(
        spec: 220, value: json["L_Input_V"], key: "L_Input_V", name: " Vin");
    var rightInputVoltage = Measurement(
        spec: 220, value: json["R_Input_V"], key: "R_Input_V", name: " Vin");
    var leftInputCurrent = Measurement(
        spec: 295, value: json["L_Input_A"], key: "L_Input_A", name: " Iin");
    var rightInputCurrent = Measurement(
        spec: 295, value: json["R_Input_A"], key: "R_Input_A", name: " Iin");
    var leftTotalInputPower = Measurement(spec: 195,
        value: json["L_Total_Input_P"],
        key: "L_Total_Input_P",
        name: " Pin");
    var rightTotalInputPower = Measurement(spec: 195,
        value: json["R_Total_Input_P"],
        key: "R_Total_Input_P",
        name: " Pin");
    var leftOutputVoltage = Measurement(
        spec: 950, value: json["L_Output_V"], key: "L_Output_V", name: " Vout");
    var rightOutputVoltage = Measurement(
        spec: 950, value: json["R_Output_V"], key: "R_Output_V", name: " Vout");
    var leftOutputCurrent = Measurement(
        spec: 189, value: json["L_Output_A"], key: "L_Output_A", name: " Iout");
    var rightOutputCurrent = Measurement(
        spec: 189, value: json["R_Output_A"], key: "R_Output_A", name: " Iout");
    var leftTotalOutputPower = Measurement(spec: 180,
        value: json["L_Total_Output_P"],
        key: "L_Total_Input_P",
        name: " Pout");
    var rightTotalOutputPower = Measurement(spec: 180,
        value: json["R_Total_Output_P"],
        key: "R_Total_Input_P",
        name: " Pout");
    var eff = Measurement(spec: 180,
        value: json["Eff"],
        key: "EFF",
        name: " Eff");
    var powerFactor = Measurement(spec: 180,
        value: json["Power_Factor"],
        key: "Power_Factor",
        name: " PF");
    var thd = Measurement(spec: 180,
        value: json["THD"],
        key: "THD",
        name: " thd");
    var standbyTotalInputPower = Measurement(spec: 180,
        value: json["Standby_TotalInput_Power"],
        key: "Standby_TotalInput_Power",
        name: " STIP");
    return InputOutputCharacteristics(leftInputVoltage: leftInputVoltage,
        leftInputCurrent: leftInputCurrent,
        leftTotalInputPower: leftTotalInputPower,
        rightInputVoltage: rightInputVoltage,
        rightInputCurrent: rightInputCurrent,
        rightTotalInputPower: rightTotalInputPower,
        leftOutputVoltage: leftOutputVoltage,
        leftOutputCurrent: leftOutputCurrent,
        leftTotalOutputPower: leftTotalOutputPower,
        rightOutputVoltage: rightOutputVoltage,
        rightOutputCurrent: rightOutputCurrent,
        rightTotalOutputPower: rightTotalOutputPower,
        eff: eff,
        powerFactor: powerFactor,
        thd: thd,
        standbyTotalInputPower: standbyTotalInputPower);
  }

}

class Measurement {
  final double spec;
  final double value;
  final String key;
  final String name;

  Measurement(
      {required this.spec, required this.value, required this.key, required this.name});
}


