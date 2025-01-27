import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class BasicFunctionTestTable extends StatefulWidget {
  final BasicFunctionTestResult data;

  const BasicFunctionTestTable(this.data, {super.key});

  @override
  State<BasicFunctionTestTable> createState() => _BasicFunctionTestTableState();
}

class _BasicFunctionTestTableState extends State<BasicFunctionTestTable> with TableHelper {
  late BasicFunctionTestResult data;

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
            DropdownButton<Judgement>(
              value: getJudgementFromString(item.judgement.name),
              items: Judgement.values.map((Judgement value) {
                return DropdownMenuItem<Judgement>(
                  value: value,
                  child: Text(
                    value.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      color: value == Judgement.pass ? Colors.green : 
                             value == Judgement.fail ? Colors.red :
                             Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (Judgement? newValue) {
                if (newValue != null) {
                  setState(() {
                    item.judgement.name;
                  });
                }
              },
            ),
          ),
        ],
      )).toList(),
    );

    return TableWrapper(
      title: context.tr('basic_function_test'),
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
