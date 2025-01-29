import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class AppearanceStructureInspectionTable extends StatefulWidget  {
  final AppearanceStructureInspectionFunctionResult data;

  const AppearanceStructureInspectionTable(this.data, {super.key});

  @override
  State<AppearanceStructureInspectionTable> createState() => _AppearanceStructureInspectionTableState();
}

class _AppearanceStructureInspectionTableState extends State<AppearanceStructureInspectionTable> with TableHelper{
  late AppearanceStructureInspectionFunctionResult data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    final dataTable = StyledDataTable(
      columns: const [
        DataColumn(
          label: Text(
            'Item',
            style: TableTextStyle.headerStyle,
          ),
        ),
        DataColumn(
          label: Text(
            'Result',
            style: TableTextStyle.headerStyle,
          ),
        ),
      ],
      rows: data.testItems.map((item) => DataRow(
        cells: [
          DataCell(Text(
            item.name,
            style: TableTextStyle.contentStyle,
          )),
          DataCell(
            buildJudgementDropdown(
              item.judgement,
              (newValue) {
                if (newValue != null) {
                  setState(() {
                    //todo
                    // item.judgement = updateJudgement(newValue);
                  });
                }
              },
            ),
          ),
        ],
      )).toList(),
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
                data.testItems[index].results.map((r) => r.itemDesc).join('\n'),
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

  Widget getResultDes(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: data.testItems[index].results
          .asMap()
          .entries
          .map((r) => Text("${r.key + 1}. ${r.value.itemDesc}"))
          .toList(),
    );
  }
}
