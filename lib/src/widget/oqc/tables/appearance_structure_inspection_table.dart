import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: context.tr('appearance_structure_inspection'),
      content: StyledDataTable(
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
              OqcTableStyle.getDataCell(data.testItems[index].description),
              DataCell(buildJudgementDropdown(
                data.testItems[index].judgement,
                (newValue) {
                  if (newValue != null) {
                    setState(() {
                      data.testItems[index].updateJudgement(newValue);
                    });
                  }
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
