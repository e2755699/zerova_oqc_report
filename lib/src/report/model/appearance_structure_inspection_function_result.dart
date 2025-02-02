import 'package:collection/collection.dart'; // 需要引入集合工具庫
import 'package:flutter/foundation.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';

class AppearanceStructureInspectionFunctionResult {
  final List<TestItem> testItems;

  AppearanceStructureInspectionFunctionResult(this.testItems);

  static List<String> keys = [
    "CSU、PSU",
    "Label, Nameplate",
    "Screen",
    "Fan",
    "Cables",
    "Screws",
    "Door Lock",
    "Grounding",
    "Waterproofing",
    "Acrylic Panel",
    "Charging Cable",
    "Cabinet",
    "Pallet",
    "LED",
    "Meter",
  ];

  factory AppearanceStructureInspectionFunctionResult.fromJson(
      List<dynamic> json) {
    var results = json
        .map((j) => TestItem.fromJson(j))
        .where((r) => keys.contains(r.name))
        .toList();
    return AppearanceStructureInspectionFunctionResult(results);
  }
}

class TestItem {
  final String name;
  final String description;
  final String result;
  final ValueNotifier<Judgement> _judgementNotifier;

  TestItem(this.name, this.description, this.result)
      : _judgementNotifier = ValueNotifier(_calculateInitialJudgement(result));

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(
      json['ITEM_NAME'] ?? 'N/A',
      json['ITEM_DESC'] ?? 'N/A',
      json['INSP_RESULT'] ?? 'N/A',
    );
  }

  static Judgement _calculateInitialJudgement(String result) {
    switch (result) {
      case "OK":
        return Judgement.pass;
      default:
        return Judgement.fail;
    }
  }

  String get judgement =>
      _judgementNotifier.value.toString().split('.').last.toUpperCase();

  void updateJudgement(Judgement newJudgement) {
    _judgementNotifier.value = newJudgement;
  }

  @override
  String toString() {
    return 'TestItem{name: $name, judgement: $judgement}';
  }
}

class Result {
  final String name;
  final String description;
  final String judgement;

  Result(this.name, this.description, this.judgement);

  @override
  String toString() {
    return 'Result{itemName: $name, itemDesc: $description, judgement: $judgement}';
  }
}
