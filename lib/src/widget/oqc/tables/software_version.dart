import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class SoftwareVersionTable extends StatelessWidget {
  final SoftwareVersion data;

  const SoftwareVersionTable(this.data, {super.key});

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
            'Version',
            style: TableTextStyle.headerStyle,
          ),
        ),
      ],
      rows: data.versions.map((version) => DataRow(
        cells: [
          DataCell(Text(
            version.name,
            style: TableTextStyle.contentStyle,
          )),
          DataCell(Text(
            version.value,
            style: TableTextStyle.contentStyle,
          )),
        ],
      )).toList(),
    );

    return TableWrapper(
      title: context.tr('software_version'),
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
            headers: ['No.', 'Item', 'Version'],
            data: List.generate(
              data.versions.length,
              (index) => [
                (index + 1).toString(),
                data.versions[index].name,
                data.versions[index].value,
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
