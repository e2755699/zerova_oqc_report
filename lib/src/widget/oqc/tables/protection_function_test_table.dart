import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:easy_localization/easy_localization.dart';

class ProtectionFunctionTestTable extends StatelessWidget {
  final ProtectionFunctionTestResult data;

  const ProtectionFunctionTestTable(this.data, {super.key});

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
      rows: data.showTestResultByColumn.map((item) => DataRow(
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
      title: context.tr('protection_function_test'),
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
              data.showTestResultByColumn.length,
              (index) => [
                (index + 1).toString(),
                data.showTestResultByColumn[index].name,
                data.showTestResultByColumn[index].description,
                data.showTestResultByColumn[index].judgement,
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
