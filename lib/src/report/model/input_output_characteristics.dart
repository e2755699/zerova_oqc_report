import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/basic_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:intl/intl.dart';

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
    double effValue = 0;
    double powerFactorValue = 0;
    double thdValue = 0;
    double standbyTotalInputPowerValue = 0;

    final rfc1123Format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
    DateTime? leftInputVoltageUpdateTime;
    DateTime? leftInputCurrentUpdateTime;
    DateTime? leftTotalInputPowerUpdateTime;
    DateTime? leftOutputVoltageUpdateTime;
    DateTime? leftOutputCurrentUpdateTime;
    DateTime? leftTotalOutputPowerUpdateTime;
    DateTime? rightInputVoltageUpdateTime;
    DateTime? rightInputCurrentUpdateTime;
    DateTime? rightTotalInputPowerUpdateTime;
    DateTime? rightOutputVoltageUpdateTime;
    DateTime? rightOutputCurrentUpdateTime;
    DateTime? rightTotalOutputPowerUpdateTime;
    DateTime? effUpdateTime;
    DateTime? powerFactorUpdateTime;
    DateTime? thdUpdateTime;
    DateTime? standbyTotalInputPowerUpdateTime;

    DateTime? parseRfc1123(String? input) {
      if (input == null) return null;
      try {
        return rfc1123Format.parseUtc(input);
      } catch (e) {
        print('解析時間失敗: $e');
        return null;
      }
    }

    // Helper function: process power values auto divide 1000
    double processPowerValue(double value) {
      return value > 100000 ? value / 1000 : value;
    }

    // Helper function: create measurement with unit support
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
      String? spcUpdateTime = item['UPDATE_TIME'];
      DateTime? spcUpdateDateTime = parseRfc1123(spcUpdateTime);
      double spcValue = double.tryParse(spcValueStr ?? "0") ?? 0;

      if (spcDesc != null && spcItem != null) {
        if (spcDesc.contains("Input_Voltage") && spcValue != 0) {
          if (spcItem.contains("Left Plug")) {
            if (leftInputVoltageUpdateTime == null ||
                spcUpdateDateTime!.isAfter(leftInputVoltageUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(leftInputVoltageUpdateTime!)
            ) {
              if(leftInputVoltageUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftInputVoltageUpdateTime!)
              ){
                leftInputVoltageCount = 0;
              }
              leftInputVoltageUpdateTime = spcUpdateDateTime; // Update time
              if (leftInputVoltageCount < 3) {
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
                  unit: 'V',
                ));
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftInputVoltageUpdateTime');
            }
          }
          else if (spcItem.contains("Right Plug")) {
            if (rightInputVoltageUpdateTime == null ||
                spcUpdateDateTime!.isAfter(rightInputVoltageUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(rightInputVoltageUpdateTime!)
            ) {
              if (rightInputVoltageUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightInputVoltageUpdateTime!)
              ) {
                rightInputVoltageCount = 0;
              }
              rightInputVoltageUpdateTime = spcUpdateDateTime; // Update time
              if (rightInputVoltageCount < 3) {
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
                  unit: 'V',
                ));
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightInputVoltageUpdateTime');
            }
          }
        }
        else if (spcDesc.contains("Input_Current") && spcValue != 0) {
          if (spcItem.contains("Left Plug")) {
            if (leftInputCurrentUpdateTime == null ||
                spcUpdateDateTime!.isAfter(leftInputCurrentUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(leftInputCurrentUpdateTime!)
            ) {
              if (leftInputCurrentUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftInputCurrentUpdateTime!)
              ) {
                leftInputCurrentCount = 0;
              }
              leftInputCurrentUpdateTime = spcUpdateDateTime; // Update time
              if (leftInputCurrentCount < 3) {
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
                  unit: 'A',
                ));
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftInputCurrentUpdateTime');
            }
          }
          else if (spcItem.contains("Right Plug")) {
            if (rightInputCurrentUpdateTime == null ||
                spcUpdateDateTime!.isAfter(rightInputCurrentUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(rightInputCurrentUpdateTime!)
            ) {
              if (rightInputCurrentUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightInputCurrentUpdateTime!)
              ) {
                rightInputCurrentCount = 0;
              }
              rightInputCurrentUpdateTime = spcUpdateDateTime; // Update time
              if (rightInputCurrentCount < 3) {
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
                  unit: 'A',
                ));
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightInputCurrentUpdateTime');
            }
          }
        }
        else if (spcDesc == "Total_Input_Power" && spcValue != 0) {
          if (spcItem.contains("Left Plug")) {
            if (leftTotalInputPowerUpdateTime == null ||
                spcUpdateDateTime!.isAfter(leftTotalInputPowerUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(leftTotalInputPowerUpdateTime!)
            ) {
              if (leftTotalInputPowerUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftTotalInputPowerUpdateTime!)
              ) {
                leftTotalInputPowerCount = 0;
              }
              leftTotalInputPowerUpdateTime = spcUpdateDateTime; // Update time
              if (leftTotalInputPowerCount < 1) {
                double spec = 130;
                double lowerBound = globalInputOutputSpec!.leftPinLowerbound;
                double upperBound = globalInputOutputSpec!.leftPinUpperbound;
                double processedValue = processPowerValue(spcValue); // Auto divide 1000
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
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftTotalInputPowerUpdateTime');
            }
          }
          else if (spcItem.contains("Right Plug")) {
            if (rightTotalInputPowerUpdateTime == null ||
                spcUpdateDateTime!.isAfter(rightTotalInputPowerUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(rightTotalInputPowerUpdateTime!)
            ) {
              if (rightTotalInputPowerUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightTotalInputPowerUpdateTime!)
              ) {
                rightTotalInputPowerCount = 0;
              }
              rightTotalInputPowerUpdateTime = spcUpdateDateTime; // Update time
              if (rightTotalInputPowerCount < 1) {
                double spec = 130;
                double lowerBound = globalInputOutputSpec!.rightPinLowerbound;
                double upperBound = globalInputOutputSpec!.rightPinUpperbound;
                double processedValue = processPowerValue(spcValue); // Auto divide 1000
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
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightTotalInputPowerUpdateTime');
            }
          }
        }
        else if (spcDesc.contains("Output_Voltage") && spcValue != 0) {
          if (spcItem.contains("Left Plug")) {
            if (leftOutputVoltageUpdateTime == null ||
                spcUpdateDateTime!.isAfter(leftOutputVoltageUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(leftOutputVoltageUpdateTime!)
            ) {
              if (leftOutputVoltageUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftOutputVoltageUpdateTime!)
              ) {
                leftOutputVoltageCount = 0;
              }
              leftOutputVoltageUpdateTime = spcUpdateDateTime; // Update time
              if (leftOutputVoltageCount < 1) {
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
                  unit: 'V',
                );
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftOutputVoltageUpdateTime');
            }
          }
          else if (spcItem.contains("Right Plug")) {
            if (rightOutputVoltageUpdateTime == null ||
                spcUpdateDateTime!.isAfter(rightOutputVoltageUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(rightOutputVoltageUpdateTime!)
            ) {
              if (rightOutputVoltageUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightOutputVoltageUpdateTime!)
              ) {
                rightOutputVoltageCount = 0;
              }
              rightOutputVoltageUpdateTime = spcUpdateDateTime; // Update time
              if (rightOutputVoltageCount < 1) {
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
                  unit: 'V',
                );
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightOutputVoltageUpdateTime');
            }
          }
        }
        else if (spcDesc.contains("Output_Current") && spcValue != 0) {
          if (spcItem.contains("Left Plug")) {
            if (leftOutputCurrentUpdateTime == null ||
                spcUpdateDateTime!.isAfter(leftOutputCurrentUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(leftOutputCurrentUpdateTime!)
            ) {
              if (leftOutputCurrentUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftOutputCurrentUpdateTime!)
              ) {
                leftOutputCurrentCount = 0;
              }
              leftOutputCurrentUpdateTime = spcUpdateDateTime; // Update time
              if (leftOutputCurrentCount < 1) {
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
                  unit: 'A',
                );
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftOutputCurrentUpdateTime');
            }
          } else if (spcItem.contains("Right Plug")) {
            if (rightOutputCurrentUpdateTime == null ||
                spcUpdateDateTime!.isAfter(rightOutputCurrentUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(rightOutputCurrentUpdateTime!)
            ) {
              if (rightOutputCurrentUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightOutputCurrentUpdateTime!)
              ) {
                rightOutputCurrentCount = 0;
              }
              rightOutputCurrentUpdateTime = spcUpdateDateTime; // Update time
              if (rightOutputCurrentCount < 1) {
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
                  unit: 'A',
                );
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightOutputCurrentUpdateTime');
            }
          }
        }
        else if (spcDesc.contains("Output_Power") && spcValue != 0) {
          if (spcItem.contains("Left Plug")) {
            if (leftTotalOutputPowerUpdateTime == null ||
                spcUpdateDateTime!.isAfter(leftTotalOutputPowerUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(leftTotalOutputPowerUpdateTime!)
            ) {
              if (leftTotalOutputPowerUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(leftTotalOutputPowerUpdateTime!)
              ) {
                leftTotalOutputPowerCount = 0;
              }
              leftTotalOutputPowerUpdateTime = spcUpdateDateTime; // Update time
              if (leftTotalOutputPowerCount < 1) {
                double spec = 120;
                double lowerBound = globalInputOutputSpec!.leftPoutLowerbound;
                double upperBound = globalInputOutputSpec!.leftPoutUpperbound;
                double processedValue = processPowerValue(spcValue); // Auto divide 1000
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
              }
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $leftTotalOutputPowerUpdateTime');
            }
          }
          else if (spcItem.contains("Right Plug")) {
            if (rightTotalOutputPowerUpdateTime == null ||
                spcUpdateDateTime!.isAfter(rightTotalOutputPowerUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(rightTotalOutputPowerUpdateTime!)
            ) {
              if (rightTotalOutputPowerUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(rightTotalOutputPowerUpdateTime!)
              ) {
                rightTotalOutputPowerCount = 0;
              }
              rightTotalOutputPowerUpdateTime = spcUpdateDateTime; // Update time
              if (rightTotalOutputPowerCount < 1) {
                double spec = 120;
                double lowerBound = globalInputOutputSpec!.rightPoutLowerbound;
                double upperBound = globalInputOutputSpec!.rightPoutUpperbound;
                double processedValue = processPowerValue(spcValue); // Auto divide 1000
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
            }
            else {
              print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $rightTotalOutputPowerUpdateTime');
            }
          }
        }
        else if (spcDesc.contains("EFF") && spcValue != 0) {
          if (spcItem.contains("Left Plug") || spcItem.contains("Right Plug")) {
            if (spcItem.contains("Input Output Test-EFF")) {
              if (effUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(effUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(effUpdateTime!)
              ) {
                if (effUpdateTime == null ||
                    spcUpdateDateTime!.isAfter(effUpdateTime!)
                ) {
                  effValue = 0;
                }
                effUpdateTime = spcUpdateDateTime; // Update time
                double spec = globalBasicFunctionTestSpec!.eff;
                if (effValue == 0) {
                  effValue = spcValue;
                }
                if (spcValue <= effValue) {
                  effValue = spcValue;
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
              }
              else {
                print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $effUpdateTime');
              }
            }
          }
        }
        else if (spcDesc.contains("PowerFactor") && spcValue != 0) {
          if (spcItem.contains("Left Plug") || spcItem.contains("Right Plug")) {
            if (spcItem.contains("Input Output Test-PowerFactor")) {
              if (powerFactorUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(powerFactorUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(powerFactorUpdateTime!)
              ) {
                if (powerFactorUpdateTime == null ||
                    spcUpdateDateTime!.isAfter(powerFactorUpdateTime!)
                ) {
                  powerFactorValue = 0;
                }
                powerFactorUpdateTime = spcUpdateDateTime; // Update time
                double spec = globalBasicFunctionTestSpec!.pf;
                if (powerFactorValue == 0) {
                  powerFactorValue = spcValue;
                }
                if (spcValue <= powerFactorValue) {
                  powerFactorValue = spcValue;
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
              }
              else {
                print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $powerFactorUpdateTime');
              }
            }
          }
        }
        else if (spcDesc.contains("THD") && spcValue != 0) {
          if (spcItem.contains("Left Plug") || spcItem.contains("Right Plug")) {
            if (spcItem.contains("Input Output Test-THD_I")) {
              if (thdUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(thdUpdateTime!) ||
                  spcUpdateDateTime!.isAtSameMomentAs(thdUpdateTime!)
              ) {
                if (thdUpdateTime == null ||
                    spcUpdateDateTime!.isAfter(thdUpdateTime!)
                ) {
                  thdValue = 0;
                }
                thdUpdateTime = spcUpdateDateTime; // Update time
                double spec = globalBasicFunctionTestSpec!.thd;
                if (thdValue == 0) {
                  thdValue = spcValue;
                }
                if (spcValue >= thdValue) {
                  thdValue = spcValue;
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
              }
              else {
                print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $thdUpdateTime');
              }
            }
          }
        }
        else if (spcDesc.contains("Comsuption_Input_Power") && spcValue != 0) {
          if (spcItem.contains("Comsuption Power Test")) {
            if (standbyTotalInputPowerUpdateTime == null ||
                spcUpdateDateTime!.isAfter(standbyTotalInputPowerUpdateTime!) ||
                spcUpdateDateTime!.isAtSameMomentAs(standbyTotalInputPowerUpdateTime!)
            ) {
              if (standbyTotalInputPowerUpdateTime == null ||
                  spcUpdateDateTime!.isAfter(standbyTotalInputPowerUpdateTime!)
              ) {
                standbyTotalInputPowerCount = 0;
              }
              standbyTotalInputPowerUpdateTime = spcUpdateDateTime; // Update time
              double spec = globalBasicFunctionTestSpec!.sp;
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
          else {
            print('❌ 資料較舊，不覆蓋，資料時間: $spcUpdateDateTime，現有時間: $standbyTotalInputPowerUpdateTime');
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

  Judgement? _manualJudgement; // Manual override judgement, default null

  // getter: if manual judgement exists, return it; otherwise return auto judgement
  Judgement get judgement {
    if (_manualJudgement != null) {
      print('🔧 手動設定判斷結果 ($side): $_manualJudgement');
      return _manualJudgement!;
    }

    // Auto judgement logic
    //Vin and Iin temporarily removed
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

    // Detailed log output - show complete ranges
    String getJudgmentInfo(InputOutputMeasurement measurement,
        double lowerBound, double upperBound) {
      final passed = measurement.judgement == Judgement.pass;
      return '  📊 ${measurement.name}: ${measurement.value} (範圍: $lowerBound ~ $upperBound) -> ${passed ? "✅ PASS" : "❌ FAIL"}';
    }

    // Get spec ranges
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

    // Show corresponding ranges based on side
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

    // Calculate passed items count
    final testResults = [
      /*inputVoltagePass,
      inputCurrentPass,*/
      totalInputPowerPass,
      outputVoltagePass,
      outputCurrentPass,
      totalOutputPowerPass
    ];

    // Recalculate passCount to ensure logic is correct
    passCount = 0;
    for (bool result in testResults) {
      if (result) passCount++;
    }

    // 🔒 Forced fix logic: ALL items must PASS for overall PASS
    final int totalItems = 4; // Pin, Vout, Iout, Pout
    final bool allItemsPass = (passCount == totalItems);

    // 🔒 Extra safety check: ensure no items are FAIL
    final bool noFailItems = testResults.every((result) => result == true);

    // 🔒 Double check: both conditions must be satisfied
    final bool finalCheck = allItemsPass && noFailItems;

    final Judgement finalResult = finalCheck ? Judgement.pass : Judgement.fail;

    print(
        '  📈 通過項目數: $passCount/$totalItems，最終判斷: ${finalResult == Judgement.pass ? "✅ PASS" : "❌ FAIL"}');

    // 🔒 Force check: if PASS but passCount < totalItems, force to FAIL
    if (finalResult == Judgement.pass && passCount < totalItems) {
      print(
          '🚨 發現邏輯錯誤！強制修正為FAIL (passCount: $passCount, totalItems: $totalItems)');
      return Judgement.fail;
    }

    // 🔒 Force check: if any individual item is FAIL, overall must be FAIL
    if (finalResult == Judgement.pass && !noFailItems) {
      print('🚨 發現邏輯錯誤！有項目FAIL但整體為PASS，強制修正為FAIL');
      return Judgement.fail;
    }

    return finalResult;
  }

  // setter: for manual override
  set judgement(Judgement value) {
    _manualJudgement = value;
  }

  // Constructor
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
