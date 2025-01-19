import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

class AppearanceStructureInspectionTable extends StatelessWidget {
  final AppearanceStructureInspectionFunctionResult data;

  const AppearanceStructureInspectionTable(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final dataTable = StyledDataTable(
      columns: const [
        DataColumn(
          label: Text(
            'Item',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlueColor,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Result',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlueColor,
            ),
          ),
        ),
      ],
      rows: data.testItems.map((item) => DataRow(
        cells: [
          DataCell(Text(
            item.name,
            style: const TextStyle(color: AppColors.blackColor),
          )),
          DataCell(Text(
            item.judgement,
            style: TextStyle(
              color: item.judgement == 'OK' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )),
        ],
      )).toList(),
    );

    return StyledCard(
      title: 'b. Appearance & Structure Inspection',
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
