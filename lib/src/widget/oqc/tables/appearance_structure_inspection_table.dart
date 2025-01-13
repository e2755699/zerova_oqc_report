import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';

class AppearanceStructureInspectionTable extends StatelessWidget {
  final AppearanceStructureInspectionFunctionResult testFunction;

  const AppearanceStructureInspectionTable(this.testFunction, {super.key});

  List<String> get headers =>
      ['No.', 'Inspection Item', 'Inspection Details', 'Judgement'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "a. Appearance & Structure Inspection",
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
              testFunction.testItems.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(testFunction.testItems[index].name)),
                  DataCell(getResultDes(index)),
                  DataCell(Text(testFunction.testItems[index].judgement)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getResultDes(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: testFunction.testItems[index].results
          .asMap()
          .entries
          .map((r) => Text("${r.key + 1}. ${r.value.itemDesc}"))
          .toList(),
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
              testFunction.testItems.length,
              (index) => [
                (index + 1).toString(),
                testFunction.testItems[index].name,
                getResultDes(index),
                testFunction.testItems[index].judgement,
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
