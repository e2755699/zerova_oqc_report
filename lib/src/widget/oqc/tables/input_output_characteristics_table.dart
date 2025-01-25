import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:easy_localization/easy_localization.dart';

class InputOutputCharacteristicsTable extends StatelessWidget {
  final InputOutputCharacteristics inputOutputCharacteristics;

  const InputOutputCharacteristicsTable(this.inputOutputCharacteristics, {super.key});

  List<List<String>> get headers => [
        ['Item', 'Spec'],
        ['Vin', '253V,187V'],
        ['Iin', '<230A'],
        ['Pin', '<130kW'],
        ['Vout', '969V,931V'],
        ['Iout', '129A,1223A'],
        ['Pout', '122kW,118kW'],
        ['Judgement'],
      ];

  @override
  Widget build(BuildContext context) {
    final dataTable = StyledDataTable(
      columns: headers.map((header) => DataColumn(
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: header.map((headerColumn) => Text(
            headerColumn,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlueColor,
            ),
          )).toList(),
        ),
      )).toList(),
      rows: inputOutputCharacteristics.inputOutputCharacteristicsSide.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(item.side)),
            DataCell(RichText(
              text: TextSpan(
                  children: item.inputVoltage
                      .map((iv) => TextSpan(text: "${iv.value} V"))
                      .toList()),
            )),
            DataCell(RichText(
              text: TextSpan(
                  children: item.inputCurrent
                      .map((iv) => TextSpan(text: "${iv.value} A"))
                      .toList()),
            )),
            DataCell(Text("${item.totalInputPower.value} KW")),
            DataCell(Text("${item.outputVoltage.value} V")),
            DataCell(Text("${item.outputCurrent.value} A")),
            DataCell(Text("${item.totalOutputPower.value} KW")),
            DataCell(Text(item.judgement)),
          ],
        );
      }).toList(),
    );

    return StyledCard(
      title: context.tr('input_output_characteristics'),
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
            headers: headers,
            data: List.generate(
              inputOutputCharacteristics.inputOutputCharacteristicsSide.length,
              (index) {
                var inc = inputOutputCharacteristics
                    .inputOutputCharacteristicsSide[index];
                return [
                  inc.side,
                  Column(
                    children: inc.inputVoltage
                        .map((iv) => Text("${iv.value} V"))
                        .toList(),
                  ),
                  Column(
                    children: inc.inputCurrent
                        .map((iv) => Text("${iv.value} A"))
                        .toList(),
                  ),
                  "${inc.totalInputPower.value} KW",
                  "${inc.outputVoltage.value} V",
                  "${inc.outputCurrent.value} A",
                  "${inc.totalOutputPower.value} KW",
                  inc.judgement,
                ];
              },
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
