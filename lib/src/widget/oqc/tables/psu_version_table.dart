import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

class PsuVersionTable extends StatelessWidget {
  final Map<String, String> data;

  const PsuVersionTable(this.data, {super.key});

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
            'Version',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlueColor,
            ),
          ),
        ),
      ],
      rows: [
        DataRow(
          cells: [
            DataCell(Text(
              'MCU Version',
              style: const TextStyle(color: AppColors.blackColor),
            )),
            DataCell(Text(
              data['mcuVersion'] ?? 'N/A',
              style: const TextStyle(color: AppColors.blackColor),
            )),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text(
              'FPGA Version',
              style: const TextStyle(color: AppColors.blackColor),
            )),
            DataCell(Text(
              data['fpgaVersion'] ?? 'N/A',
              style: const TextStyle(color: AppColors.blackColor),
            )),
          ],
        ),
      ],
    );

    return StyledCard(
      title: 'PSU Version',
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
            headers: ['Item', 'Version'],
            data: [
              ['MCU Version', data['mcuVersion'] ?? 'N/A'],
              ['FPGA Version', data['fpgaVersion'] ?? 'N/A'],
            ],
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