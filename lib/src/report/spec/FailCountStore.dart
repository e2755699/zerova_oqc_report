import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';

class FailCountStore {
  static int appearanceStructureInspectionFunction = 0;
  static int inputOutputCharacteristics = 0;
  static int basicFunctionTest = 0;
  static int hipotTestSpec = 0;

  /// 統一方法：設置 count
  static void setCount(String tableName, int count) {
    switch (tableName) {
      case 'AppearanceStructureInspectionFunction':
        appearanceStructureInspectionFunction = count;
        break;
      case 'InputOutputCharacteristics':
        inputOutputCharacteristics = count;
        break;
      case 'BasicFunctionTest':
        basicFunctionTest = count;
        break;
      case 'HipotTestSpec':
        hipotTestSpec = count;
        break;
    }
  }

  /// 統一方法：加一
  static void increment(String tableName) {
    switch (tableName) {
      case 'AppearanceStructureInspectionFunction':
        appearanceStructureInspectionFunction++;
        break;
      case 'InputOutputCharacteristics':
        inputOutputCharacteristics++;
        break;
      case 'BasicFunctionTest':
        basicFunctionTest++;
        break;
      case 'HipotTestSpec':
        hipotTestSpec++;
        break;
    }
  }

  /// 取得某個 table 的 count
  static int getCount(String tableName) {
    switch (tableName) {
      case 'AppearanceStructureInspectionFunction':
        return appearanceStructureInspectionFunction;
      case 'InputOutputCharacteristics':
        return inputOutputCharacteristics;
      case 'BasicFunctionTest':
        return basicFunctionTest;
      case 'HipotTestSpec':
        return hipotTestSpec;
      default:
        return 0;
    }
  }

  /// 取得所有 fail count（方便上傳）
  static Map<String, int> getAllCounts() {
    return {
      'AppearanceStructureInspectionFunction': appearanceStructureInspectionFunction,
      'InputOutputCharacteristics': inputOutputCharacteristics,
      'BasicFunctionTest': basicFunctionTest,
      'HipotTestSpec': hipotTestSpec,
    };
  }

  /// 清空全部
  static void reset() {
    appearanceStructureInspectionFunction = 0;
    inputOutputCharacteristics = 0;
    basicFunctionTest = 0;
    hipotTestSpec = 0;
  }

  /// 根據 InputOutputCharacteristics 的 judgement 統計 fail 數量
  int countInputOutputCharacteristicsFails(InputOutputCharacteristics ioChar) {
    int failCount = 0;

    // 掃描左右側的所有測量值
    for (var side in ioChar.inputOutputCharacteristicsSide) {
      List<InputOutputMeasurement?> measurements = [
        ...side.inputVoltage,
        ...side.inputCurrent,
        side.totalInputPower,
        side.outputVoltage,
        side.outputCurrent,
        side.totalOutputPower,
      ];

      for (var m in measurements) {
        if (m != null && m.judgement == Judgement.fail) {
          failCount++;
        }
      }
    }

    return failCount;
  }
}
