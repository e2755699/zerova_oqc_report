import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
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
    final dataTable = StyledDataTable(
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
                    // TODO: Update judgement
                  });
                }
              },
            ))          ],
        ),
      ),
    );

    return TableWrapper(
      title: context.tr('appearance_structure_inspection'),
      content: dataTable,
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // 添加 PDF 表格
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            border: pw.TableBorder.all(),
            headers: ['No.', 'Item', 'Description', 'Result'],
            data: List.generate(
              data.testItems.length,
              (index) => [
                (index + 1).toString(),
                data.testItems[index].name,
                data.testItems[index].description,
                data.testItems[index].judgement,
              ],
            ),
          );
        },
      ),
    );

    // 預覽 PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
