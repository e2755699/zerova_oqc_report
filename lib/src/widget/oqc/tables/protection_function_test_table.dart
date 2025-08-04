import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/widget/common/table_failorpass.dart';

class ProtectionFunctionTestTable extends StatefulWidget {
  final ProtectionFunctionTestResult data;
  final bool isEditing;
  const ProtectionFunctionTestTable(this.data,
      {super.key, this.isEditing = false});

  @override
  State<ProtectionFunctionTestTable> createState() =>
      _ProtectionFunctionTestTableState();
}

class _ProtectionFunctionTestTableState
    extends State<ProtectionFunctionTestTable> with TableHelper {
  List<ProtectionFunctionMeasurement> get testItems =>
      widget.data.specialFunctionTestResult.testItems;

  void _updateProtectionFunctionTestPassOrFail() {
    print('🔍 開始保護功能測試自動判斷:');

    // 計算通過項目數
    final passResults =
        testItems.where((item) => item.judgement == Judgement.pass);
    final failResults =
        testItems.where((item) => item.judgement == Judgement.fail);
    final passCount = passResults.length;
    final totalItems = testItems.length;

    // 詳細日誌輸出
    for (final item in testItems) {
      final passed = (item.judgement == Judgement.pass);
      print('  📊 ${item.name}: ${passed ? "✅ PASS" : "❌ FAIL"}');
    }

    // 🔒 強制邏輯：所有項目都必須PASS，整體才能PASS
    final bool allItemsPass = (passCount == totalItems);
    final bool noFailItems = failResults.isEmpty;
    final bool finalCheck = allItemsPass && noFailItems;

    print(
        '  📈 通過項目數: $passCount/$totalItems，最終判斷: ${finalCheck ? "✅ PASS" : "❌ FAIL"}');

    // 🔒 強制檢查：如果是PASS但passCount < totalItems，強制設為FAIL
    if (finalCheck && passCount < totalItems) {
      print(
          '🚨 發現邏輯錯誤！強制修正為FAIL (passCount: $passCount, totalItems: $totalItems)');
      protectionFunctionTestPassOrFail = false;
      GlobalJudgementMonitor.updateTestResult('protectionFunctionTest', false);
      return;
    }

    // 🔒 強制檢查：如果有任何個別項目是FAIL，整體必須是FAIL
    if (finalCheck && !noFailItems) {
      print('🚨 發現邏輯錯誤！有項目FAIL但整體為PASS，強制修正為FAIL');
      protectionFunctionTestPassOrFail = false;
      GlobalJudgementMonitor.updateTestResult('protectionFunctionTest', false);
      return;
    }

    // 最終判斷結果
    protectionFunctionTestPassOrFail = finalCheck;
    GlobalJudgementMonitor.updateTestResult(
        'protectionFunctionTest', finalCheck);
    print(
        'protectionFunctionTestPassOrFail = $protectionFunctionTestPassOrFail');
  }

  final List<ProtectionFunctionMeasurement>
      defaultProtectionFunctionMeasurements = [
    ProtectionFunctionMeasurement(
      spec: 3,
      value: 3,
      key: "Emergency_Stop",
      name: "Emergency Stop Function",
      description:
          'After the charger is powered on and charging normally, set the rated load to initiate charging. Once the charger reaches normal output current, press the emergency stop button. This action will disconnect the charger from the AC output and trigger an alarm.',
      judgement: Judgement.fail,
    ),
    ProtectionFunctionMeasurement(
      spec: 3,
      value: 3,
      key: "Door_Open",
      name: "Door Open Function",
      description:
          'While opening the door, the charger should stop charging immediately and shows alarm when the door open.',
      judgement: Judgement.fail,
    ),
    ProtectionFunctionMeasurement(
      spec: 3,
      value: 3,
      key: "Ground_Fault",
      name: "Ground Fault Function",
      description:
          "If the charger detects a ground fault or a drop in insulation below the protection threshold of rated resistance during simulation, it should stop charging and trigger an alarm to protect charger immediately.",
      judgement: Judgement.fail,
    ),
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 0;
        i < widget.data.specialFunctionTestResult.testItems.length;
        i++) {
      final item = widget.data.specialFunctionTestResult.testItems[i];

      final isNameEmpty = item.name.trim().isEmpty;
      final isDescriptionEmpty = item.description.trim().isEmpty;

      if (isNameEmpty || isDescriptionEmpty) {
        if (i < defaultProtectionFunctionMeasurements.length) {
          final defaultItem = defaultProtectionFunctionMeasurements[i];
          debugPrint('🔁 Updating item at index $i with default values.');

          // 就地修改欄位
          item.spec = defaultItem.spec;
          item.value = defaultItem.value;
          item.key = defaultItem.key;
          item.name = defaultItem.name;
          item.description = defaultItem.description;
          item.judgement = defaultItem.judgement;
        } else {
          debugPrint('⚠️ No default value at index $i to apply.');
        }
      }
    }
    for (int i = 0;
        i < widget.data.specialFunctionTestResult.testItems.length;
        i++) {
      debugPrint(
          'testItems[$i] => key: ${testItems[i].key}, name: ${testItems[i].name}, description: ${testItems[i].description}, judgement: ${testItems[i].judgement}');
    }
    _updateProtectionFunctionTestPassOrFail(); // 初始時立即檢查判斷
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: globalEditModeNotifier,
      builder: (context, editMode, _) {
        return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable =
                editMode == 1 && (permission == 1 || permission == 2);
            return TableWrapper(
              title: context.tr('protection_function_test'),
              content: StyledDataTable(
                dataRowMinHeight: 50.0,
                dataRowMaxHeight: 150.0,
                columns: [
                  OqcTableStyle.getDataColumn('No.'),
                  OqcTableStyle.getDataColumn('Test Items'),
                  OqcTableStyle.getDataColumn('Testing Record'),
                  OqcTableStyle.getDataColumn('Judgement'),
                ],
                rows: List.generate(
                  testItems.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Text(
                              testItems[index].name,
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          testItems[index].description,
                          style: TableTextStyle.contentStyle(),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      isEditable
                          ? DataCell(
                              DropdownButton<Judgement>(
                                value: testItems[index].judgement,
                                items: Judgement.values.map((j) {
                                  return DropdownMenuItem(
                                    value: j,
                                    child: Text(
                                      j.name.toUpperCase(),
                                      style: TextStyle(
                                        color: j == Judgement.pass
                                            ? Colors.green
                                            : j == Judgement.fail
                                                ? Colors.red
                                                : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      testItems[index].judgement = value;
                                    });
                                  }
                                  _updateProtectionFunctionTestPassOrFail();
                                },
                              ),
                            )
                          : OqcTableStyle.getDataCell(
                              testItems[index].judgement.name.toUpperCase(),
                              color: testItems[index].judgement ==
                                      Judgement.pass
                                  ? Colors.green
                                  : testItems[index].judgement == Judgement.fail
                                      ? Colors.red
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
