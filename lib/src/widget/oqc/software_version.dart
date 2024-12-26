import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';

class SoftwareVersionTable extends StatelessWidget {
  final SoftwareVersion softwareVersion;

  const SoftwareVersionTable(this.softwareVersion, {super.key});

  List<String> get headers => ['No.', 'Item', 'Version'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "EV Software Version",
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
              softwareVersion.versions.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(softwareVersion.versions[index].name)),
                  DataCell(Text(softwareVersion.versions[index].value)),
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
            headers: headers,
            data: List.generate(
              softwareVersion.versions.length,
              (index) => [
                (index + 1).toString(),
                softwareVersion.versions[index].name,
                softwareVersion.versions[index].value,
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
