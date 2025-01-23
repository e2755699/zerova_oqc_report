import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PackageListResult {
  static final List<String> defaultHeader = [
    "No.",
    "Items",
    "Q'ty",
    "Check",
  ];

  static final List<PackageListResultMeasurement> defaultDatas = [
    PackageListResultMeasurement(
      spec: 2,
      key: '1',
      name: 'packagingItem1'.tr(),
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: '2',
      name: 'packagingItem2'.tr(),
    ),
    PackageListResultMeasurement(
      spec: 22,
      key: '3',
      name: 'packagingItem3'.tr(),
    ),
    PackageListResultMeasurement(
      spec: 4,
      key: '4',
      name: 'packagingItem4'.tr(),
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: '5',
      name: 'packagingItem5'.tr(),
    ),
  ];

  final List<String> header;
  final List<List<String>> rows;
  final List<PackageListResultMeasurement> datas;

  PackageListResult({
    List<String>? header,
    List<List<String>>? rows,
    List<PackageListResultMeasurement>? datas,
  }) : this.header = header ?? defaultHeader,
       this.rows = rows ?? [],
       this.datas = datas ?? defaultDatas;

  List<List<String>> get showResultByColumn {
    return datas.map((data) => [
      data.name,
      data.spec.toString(),
      data.isCheck.value ? '✓' : ''
    ]).toList();
  }
}

class PackageListResultMeasurement {
  final int spec;
  final String key;
  final String name;
  final ValueNotifier<bool> isCheck;

  PackageListResultMeasurement({
    required this.spec,
    required this.key,
    required this.name,
  }) : isCheck = ValueNotifier<bool>(false);

  void toggle() {
    isCheck.value = !isCheck.value;
  }
}
