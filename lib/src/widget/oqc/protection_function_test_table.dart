import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';

class ProtectionFunctionTestTable extends StatelessWidget {
  final ProtectionFunctionTestResult data;

  const ProtectionFunctionTestTable(this.data, {super.key});

  List<String> get headers =>
      ['No.', 'Test Items', 'Testing Record', 'Judgement'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "d. Protection Function Test",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
          ),
          DataTable(
            border: TableBorder.all(
              color: Colors.black, // 黑色邊框
              width: 1, // 邊框寬度
            ),
            columnSpacing: 32,
            columns: headers
                .map(
                  (header) => DataColumn(
                    label: Text(
                      header,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            rows: List.generate(
              data.showTestResultByColumn.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(data.showTestResultByColumn[index].name)),
                  DataCell(Text(data.showTestResultByColumn[index].description)),
                  DataCell(Text(data.showTestResultByColumn[index].judgement.name)),
                ],
              ),
            ),
          ),
        ],
      ),
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
