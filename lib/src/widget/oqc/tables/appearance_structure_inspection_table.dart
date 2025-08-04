import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/widget/common/table_failorpass.dart';

class AppearanceStructureInspectionTable extends StatefulWidget {
  final AppearanceStructureInspectionFunctionResult data;

  const AppearanceStructureInspectionTable(this.data, {super.key});

  @override
  State<AppearanceStructureInspectionTable> createState() =>
      _AppearanceStructureInspectionTableState();
}

class _AppearanceStructureInspectionTableState
    extends State<AppearanceStructureInspectionTable> with TableHelper {
  late AppearanceStructureInspectionFunctionResult data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    updateOverallJudgement();
  }

  void updateOverallJudgement() {
    print('🔍 開始外觀結構檢查自動判斷:');

    // 計算通過項目數
    final passResults =
        data.testItems.where((item) => item.judgement.toUpperCase() == 'PASS');
    final failResults =
        data.testItems.where((item) => item.judgement.toUpperCase() != 'PASS');
    final passCount = passResults.length;
    final totalItems = data.testItems.length;

    // 詳細日誌輸出
    for (final item in data.testItems) {
      final passed = (item.judgement.toUpperCase() == 'PASS');
      print(
          '  📊 ${item.name}: ${item.judgement} -> ${passed ? "✅ PASS" : "❌ FAIL"}');
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
      appearanceStructureInspectionPassOrFail = false;
      GlobalJudgementMonitor.updateTestResult(
          'appearanceStructureInspection', false);
      return;
    }

    // 🔒 強制檢查：如果有任何個別項目是FAIL，整體必須是FAIL
    if (finalCheck && !noFailItems) {
      print('🚨 發現邏輯錯誤！有項目FAIL但整體為PASS，強制修正為FAIL');
      appearanceStructureInspectionPassOrFail = false;
      GlobalJudgementMonitor.updateTestResult(
          'appearanceStructureInspection', false);
      return;
    }

    // 最終判斷結果
    appearanceStructureInspectionPassOrFail = finalCheck;
    GlobalJudgementMonitor.updateTestResult(
        'appearanceStructureInspection', finalCheck);
    print(
        'appearanceStructureInspectionPassOrFail = $appearanceStructureInspectionPassOrFail');
  }

  Color getJudgementColor(String j) {
    switch (j) {
      case 'PASS':
        return Colors.green;
      case 'FAIL':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
              title: context.tr('appearance_structure_inspection'),
              content: StyledDataTable(
                dataRowMinHeight: 40,
                dataRowMaxHeight: 60,
                columns: [
                  OqcTableStyle.getDataColumn('No.'),
                  OqcTableStyle.getDataColumn('Item'),
                  OqcTableStyle.getDataColumn('Details'),
                  OqcTableStyle.getDataColumn('Judgement'),
                ],
                rows: List.generate(
                  data.testItems.length,
                  (index) => DataRow(
                    cells: [
                      OqcTableStyle.getDataCell((index + 1).toString()),
                      OqcTableStyle.getDataCell(data.testItems[index].name),
                      DataCell(
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(data.testItems[index].description),
                        ),
                      ),
                      DataCell(
                        isEditable
                            ? buildJudgementDropdown(
                                data.testItems[index].judgement,
                                (newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      data.testItems[index]
                                          .updateJudgement(newValue);
                                    });
                                  }
                                  updateOverallJudgement(); // <- 這會自動更新全域變數
                                },
                              )
                            : Center(
                                child: Text(
                                  data.testItems[index].judgement.toUpperCase(),
                                  style: TextStyle(
                                    color: getJudgementColor(data
                                        .testItems[index].judgement
                                        .toUpperCase()),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      )
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
