import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

class BasicFunctionTestTable extends StatelessWidget {
  final BaseFunctionTestResult data;

  const BasicFunctionTestTable(this.data, {super.key});

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
            'Value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlueColor,
            ),
          ),
        ),
      ],
      rows: data.showResultByColumn.map((item) => DataRow(
        cells: [
          DataCell(Text(
            item.name,
            style: const TextStyle(color: AppColors.blackColor),
          )),
          DataCell(Text(
            item.value.toString(),
            style: TextStyle(
              color: item.judgement == Judgement.pass ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )),
        ],
      )).toList(),
    );

    return StyledCard(
      title: 'c. Basic Function Test',
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
            headers: ['No.', 'S/N'],
            data: List.generate(
              data.showResultByColumn.length,
              (index) => [
                (index + 1).toString(),
                data.showResultByColumn[index].name,
                data.showResultByColumn[index].description,
                data.showResultByColumn[index].judgement,
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
