import 'package:collection/collection.dart'; // 需要引入集合工具庫
import 'package:flutter/foundation.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';

class AppearanceStructureInspectionFunctionResult {
  final List<TestItem> testItems;

  AppearanceStructureInspectionFunctionResult(this.testItems);

  static final Map<String, String> descriptionMapping = {
    "CSU、PSU": "Must have tamper-evident stickers.",
    "Label, Nameplate":
        "Content must match the diagram, and there should be no blurriness, broken characters, misalignment, scratches, or other defects.",
    "Screen":
        "The appearance must be free of scratches, dirt, adhesive residue, bubbles, etc.",
    "Fan":
        "Confirm the fan grill and fan installation direction. (Follow the arrow)",
    "Cables":
        "Confirm cable connection positions, proper assembly, and proper cable routing.",
    "Screws":
        "1. No missing screws in the unit, and torque markings must be verified.\n2. For high-power screws, ensure torque values are checked.",
    "Door Lock": "Door locks and handles must operate correctly.",
    "Grounding":
        "The grounding wire installation position must correspond with the grounding label.",
    "Waterproofing":
        "Waterproof glue must be applied evenly, and the application area must follow waterproofing guidelines.",
    "Acrylic Panel": "The acrylic panel must not be loose or scratched.",
    "Charging Cable":
        "The length and specifications must be correct, and the printing on the plug must be accurate.",
    "Cabinet":
        "1. The cabinet appearance must be free of paint peeling, scratches, dirt, rust, welding defects, and color discrepancies.\n2. The bottom of the cabinet interior must be free of foreign objects.",
    "Pallet":
        "Pallet torque values must meet the standard, and torque markings should be checked.",
    "LED": "Confirm LED status. (Fault/Standby/Charging).",
    "Meter":
        "Confirm that the cumulative power reading on the meter matches the actual power value."
  };

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
