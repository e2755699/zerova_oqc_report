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
      translationKey: 'packagingItem1',
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: '2',
      translationKey: 'packagingItem2',
    ),
    PackageListResultMeasurement(
      spec: 22,
      key: '3',
      translationKey: 'packagingItem3',
    ),
    PackageListResultMeasurement(
      spec: 4,
      key: '4',
      translationKey: 'packagingItem4',
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: '5',
      translationKey: 'packagingItem5',
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

  List<List<String>> get testItems {
    return datas.map((data) => [
      data.translationKey.tr(),
      data.spec.toString(),
      data.isCheck.value ? '✓' : ''
    ]).toList();
  }
}

class PackageListResultMeasurement {
  final int spec;
  final String key;
  final String translationKey;
  final ValueNotifier<bool> isCheck;

  PackageListResultMeasurement({
    required this.spec,
    required this.key,
    required this.translationKey,
  }) : isCheck = ValueNotifier<bool>(false);

  void toggle() {
    isCheck.value = !isCheck.value;
  }
}
