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
      spec: 1,
      key: 1,
      translationKey: 'certificate_card',
    ),
    PackageListResultMeasurement(
      spec: 2,
      key: 2,
      translationKey: 'rfid_card',
    ),
    PackageListResultMeasurement(
      spec: 22,
      key: 3,
      translationKey: 'bolts_cover',
    ),
    PackageListResultMeasurement(
      spec: 4,
      key: 4,
      translationKey: 'cabinet_key',
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: 5,
      translationKey: 'ac_breaker_key',
    ),
  ];

  final List<String> header;
  final List<List<String>> rows;
  final List<PackageListResultMeasurement> datas;

  PackageListResult({
    List<String>? header,
    List<List<String>>? rows,
    List<PackageListResultMeasurement>? datas,
  })  : header = header ?? defaultHeader,
        rows = rows ?? [],
        datas = datas ?? defaultDatas;

  List<List<String>> get testItems {
    return datas
        .map((data) => [
              data.translationKey.tr(),
              data.spec.toString(),
              data.isCheck.value ? '✓' : ''
            ])
        .toList();
  }

  static final Map<String, String> englishMapping = {
    'certificate_card': 'Certificate Card',
    'rfid_card': 'RFID Card',
    'bolts_cover': 'Bolts Cover',
    'cabinet_key': "Cabinet's key",
    'ac_breaker_key': "AC Breaker's key",
    'others': 'Others',
  };

  String getEnglishText(String key) {
    return englishMapping[key] ?? key;
  }
}

class PackageListResultMeasurement {
  final int spec;
  final int key;
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
