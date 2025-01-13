import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PackageListResult {

  List<String> get header => [
        "No.",
        "Items",
        "Q'ty",
        "Check",
      ];

  final List<PackageListResultMeasurement> showResultByColumn = [
    PackageListResultMeasurement(
      spec: 2,
      key: '1',
      name: 'packagingItem1'.tr(), // 多語系翻譯
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: '2',
      name: 'packagingItem2'.tr(), // 多語系翻譯
    ),
    PackageListResultMeasurement(
      spec: 22,
      key: '3',
      name: 'packagingItem3'.tr(), // 多語系翻譯
    ),
    PackageListResultMeasurement(
      spec: 4,
      key: '4',
      name: 'packagingItem4'.tr(), // 多語系翻譯
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: '5',
      name: 'packagingItem5'.tr(), // 多語系翻譯
    ),
  ];
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
