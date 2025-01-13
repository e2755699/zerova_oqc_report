import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';

class PackageListTable extends StatelessWidget {
  final PackageListResult data;

  const PackageListTable(this.data, {super.key});

  List<String> get headers => data.header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "c. Basic Function Test",
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
              data.showResultByColumn.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(data.showResultByColumn[index].name)),
                  DataCell(
                      Text(data.showResultByColumn[index].spec.toString())),
                  DataCell(ValueListenableBuilder(
                    key: GlobalKey(debugLabel: 'checkbox_${data.showResultByColumn[index].key}'),
                    valueListenable: data.showResultByColumn[index].isCheck,
                    builder: (context, value, _) => Checkbox(
                        value: value,
                        onChanged: (isCheck) {
                          data.showResultByColumn[index].toggle();
                        }),
                  )),
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
              data.showResultByColumn.length,
              (index) => [
                (index + 1).toString(),
                data.showResultByColumn[index].name,
                data.showResultByColumn[index].spec,
                data.showResultByColumn[index].isCheck.value,
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
