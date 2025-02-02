import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';

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
      dataRowMinHeight: 50,
      dataRowMaxHeight: 80,
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
            DataCell(Text(item.side, textAlign: TextAlign.center,)),
            DataCell(Text(item.inputVoltage
                .map((iv) => "${iv.value.toStringAsFixed(2)} V").toList().join("\n")
              , textAlign: TextAlign.center,),),
            DataCell(Text(item.inputCurrent
                .map((iv) => "${iv.value.toStringAsFixed(2)} A").toList().join("\n")
              , textAlign: TextAlign.center,),),
            // DataCell(RichText(
            //   text: TextSpan(
            //       children: item.inputCurrent
            //           .map((iv) => TextSpan(text: "${iv.value.toStringAsFixed(2)} A"))
            //           .toList()),
            //    textAlign: TextAlign.center,),),
            DataCell(Text("${item.totalInputPower.value.toStringAsFixed(2)} KW", textAlign: TextAlign.center,)),
            DataCell(Text("${item.outputVoltage.value.toStringAsFixed(2)} V", textAlign: TextAlign.center,)),
            DataCell(Text("${item.outputCurrent.value.toStringAsFixed(2)} A", textAlign: TextAlign.center,)),
            DataCell(Text("${item.totalOutputPower.value.toStringAsFixed(2)} KW", textAlign: TextAlign.center,)),
            OqcTableStyle.getDataCell(
              item.judgement.name.toUpperCase(),
              color: item.judgement == Judgement.pass
                  ? Colors.green
                  : item.judgement == Judgement.fail
                  ? Colors.red
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            )
          ],
        );
      }).toList(),
    );

    return StyledCard(
      title: 'Input & Output Characteristics',
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
