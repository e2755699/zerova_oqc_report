import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class ProtectionFunctionTestTable extends StatefulWidget {
  final ProtectionFunctionTestResult data;

  const ProtectionFunctionTestTable(this.data, {super.key});

  @override
  State<ProtectionFunctionTestTable> createState() => _ProtectionFunctionTestTableState();
}

class _ProtectionFunctionTestTableState extends State<ProtectionFunctionTestTable> with TableHelper {
  late ProtectionFunctionTestResult data;

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
              item.judgement.name,
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
              data.testItems.length,
              (index) => [
                (index + 1).toString(),
                data.testItems[index].name,
                data.testItems[index].description,
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
}
