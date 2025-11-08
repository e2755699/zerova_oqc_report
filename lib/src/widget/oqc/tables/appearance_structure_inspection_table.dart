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
    final hasNonPass = data.testItems.any(
          (item) => item.judgement.toUpperCase() != 'PASS',
    );

    // 只要有一個不是 PASS，就算 FAIL
    appearanceStructureInspectionPassOrFail = !hasNonPass;
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
            editMode == 1 && permission <= 2;

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
                        data.testItems[index].updateJudgement(newValue);
                      });
                    }
                    updateOverallJudgement(); // <- 這會自動更新全域變數
                  },
                )
                    : Center(
                  child: Text(
                    data.testItems[index].judgement.toUpperCase(),
                    style: TextStyle(
                      color: getJudgementColor(data.testItems[index].judgement.toUpperCase()),
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
