import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';  // 引入全域管理器
import 'package:zerova_oqc_report/src/report/spec/new_package_list_spec.dart.dart';  // 引入全域管理器

class PackageListResult {
  static final List<String> defaultHeader = [
    "No.",
    "Items",
    "Q'ty",
    "Check",
  ];

  final List<PackageListResultMeasurement> measurements;

  PackageListResult({List<PackageListResultMeasurement>? initialMeasurements})
      : measurements = initialMeasurements ?? [];

  /// 新增或更新某筆測量資料（index 對應 UI 表格順序）
  void updateOrAddMeasurement({
    required int index,
    String? name,
    String? quantity,
    bool? isChecked,
  }) {
    while (measurements.length <= index) {
      measurements.add(PackageListResultMeasurement(
        spec: 0,
        key: measurements.length,
        translationKey: '',
      ));
    }

    final m = measurements[index];
    if (name != null) m.itemName = name;
    if (quantity != null) m.quantity = quantity;
    if (isChecked != null) m.isCheck.value = isChecked;

    // 同步更新全域變數
    PackageListSpecGlobal.set(this);
  }

  /// 刪除指定 index 的測量資料
  void removeMeasurementAt(int index) {
    if (index >= 0 && index < measurements.length) {
      measurements.removeAt(index);
      // 同步更新全域變數
      PackageListSpecGlobal.set(this);
    }
  }

  @override
  String toString() {
    return 'PackageListResult(measurements: [\n' +
        measurements.map((m) => m.toString()).join(',\n') +
        '\n])';
  }
}

class PackageListResultMeasurement {
  int spec;
  final int key;
  String translationKey;
  String itemName;
  String quantity;
  final ValueNotifier<bool> isCheck;

  PackageListResultMeasurement({
    required this.spec,
    required this.key,
    required this.translationKey,
    this.itemName = '',
    this.quantity = '',
  }) : isCheck = ValueNotifier<bool>(false);

  void toggle() {
    isCheck.value = !isCheck.value;
  }

  @override
  String toString() {
    return '{itemName: $itemName, quantity: $quantity, isChecked: ${isCheck.value}}';
  }
}

PackageListResult packageListResultFromSpecData(Map<String, dynamic> specData) {
  final measurementsRaw = specData['measurements'];
  final List<PackageListResultMeasurement> measurements = [];

  if (measurementsRaw is List) {
    for (int i = 0; i < measurementsRaw.length; i++) {
      final m = measurementsRaw[i];
      if (m is Map<String, dynamic>) {
        measurements.add(PackageListResultMeasurement(
          spec: m['spec'] is int ? m['spec'] : 0,
          key: i,
          translationKey: m['translationKey']?.toString() ?? '',
          itemName: m['itemName']?.toString() ?? '',
          quantity: m['quantity']?.toString() ?? '',
        ));
      }
    }
  }

  return PackageListResult(initialMeasurements: measurements);
}

PackageListResult packageListResultFromSpecDataWithUpdate(dynamic specData) {
  final result = PackageListResult();

  if (specData is Map<String, dynamic>) {
    final measurementsRaw = specData['measurements'];
    if (measurementsRaw is List) {
      for (int i = 0; i < measurementsRaw.length; i++) {
        final m = measurementsRaw[i];
        if (m is Map<String, dynamic>) {
          result.updateOrAddMeasurement(
            index: i,
            name: m['itemName']?.toString() ?? '',
            quantity: m['quantity']?.toString() ?? '',
            isChecked: m['isChecked'] is bool ? m['isChecked'] : false,
          );
        }
      }
    }
  } else if (specData is PackageListResult) {
    for (int i = 0; i < specData.measurements.length; i++) {
      final m = specData.measurements[i];
      result.updateOrAddMeasurement(
        index: i,
        name: m.itemName,
        quantity: m.quantity,
        isChecked: m.isCheck.value,
      );
    }
  } else {
    throw ArgumentError('specData 必須是 Map<String, dynamic> 或 PackageListResult');
  }

  return result;
}


