import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';

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
      key: 1,
      translationKey: 'rfid_card',
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: 2,
      translationKey: 'product_certificate_card',
    ),
    PackageListResultMeasurement(
      spec: 22,
      key: 3,
      translationKey: 'bolts_cover',
    ),
    PackageListResultMeasurement(
      spec: 4,
      key: 4,
      translationKey: 'screw_assy_m4_12',
    ),
    PackageListResultMeasurement(
      spec: 1,
      key: 5,
      translationKey: 'user_manual',
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
    'rfid_card': 'RFID Card',
    'product_certificate_card': 'Product Certificate Card',
    'screw_assy_m4_12': "Screw Assy M4*12",
    'bolts_cover': 'Bolts Cover',
    'user_manual': "User Manual",
    'others': 'Others',
  };

  String getEnglishText(String key) {
    return englishMapping[key] ?? key;
  }
}

class PackageListResultMeasurement {
   int spec;
  final int key;
   String translationKey;
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
