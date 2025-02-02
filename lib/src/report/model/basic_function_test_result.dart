import 'package:zerova_oqc_report/src/report/enum/judgement.dart';


class BasicFunctionTestResult {
  final BasicFunctionMeasurement eff;
  final BasicFunctionMeasurement powerFactor;
  final BasicFunctionMeasurement harmonic;
  final BasicFunctionMeasurement standbyTotalInputPower;

  BasicFunctionTestResult({
    required this.eff,
    required this.powerFactor,
    required this.harmonic,
    required this.standbyTotalInputPower,
  });

  List<BasicFunctionMeasurement> get testItems => [
    eff,
    powerFactor,
    harmonic,
    standbyTotalInputPower,
  ];
}


class BasicFunctionMeasurement {
  final double spec;
  final double value;
  final double count;
  final String key;
  final String name;
  final String description;

  final Judgement judgement;

  BasicFunctionMeasurement(
      {required this.spec,
        required this.value,
        required this.count,
        required this.key,
        required this.name,
        required this.description,
        required this.judgement});

  factory BasicFunctionMeasurement.empty() {
    return BasicFunctionMeasurement(
        spec: 0,
        value: 0,
        count: 0,
        key: "",
        name: "",
        description: '',
        judgement: Judgement.fail);
  }

  String get getReportValue => description.replaceAll("{VALUE}", value.toStringAsFixed(2));
}