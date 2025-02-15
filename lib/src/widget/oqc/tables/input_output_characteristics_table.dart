import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';

class InputOutputCharacteristicsTable extends StatelessWidget {
  final InputOutputCharacteristics inputOutputCharacteristics;

  const InputOutputCharacteristicsTable(this.inputOutputCharacteristics,
      {super.key});

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
      columns: headers
          .map((header) => DataColumn(
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: header
                      .map((headerColumn) => Text(
                            headerColumn,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlueColor,
                            ),
                          ))
                      .toList(),
                ),
              ))
          .toList(),
      rows:
          inputOutputCharacteristics.inputOutputCharacteristicsSide.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(
              item.side,
              textAlign: TextAlign.center,
            )),
            DataCell(
              Text(
                item.inputVoltage
                    .map((iv) => "${iv.value.toStringAsFixed(2)} V")
                    .toList()
                    .join("\n"),
                textAlign: TextAlign.center,
              ),
            ),
            DataCell(
              Text(
                item.inputCurrent
                    .map((iv) => "${iv.value.toStringAsFixed(2)} A")
                    .toList()
                    .join("\n"),
                textAlign: TextAlign.center,
              ),
            ),
            // DataCell(RichText(
            //   text: TextSpan(
            //       children: item.inputCurrent
            //           .map((iv) => TextSpan(text: "${iv.value.toStringAsFixed(2)} A"))
            //           .toList()),
            //    textAlign: TextAlign.center,),),
            DataCell(Text(
              "${item.totalInputPower.value.toStringAsFixed(2)} KW",
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              "${item.outputVoltage.value.toStringAsFixed(2)} V",
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              "${item.outputCurrent.value.toStringAsFixed(2)} A",
              textAlign: TextAlign.center,
            )),
            DataCell(Text(
              "${item.totalOutputPower.value.toStringAsFixed(2)} KW",
              textAlign: TextAlign.center,
            )),
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

    return TableWrapper(
      title: 'Input & Output Characteristics',
      content: dataTable,
    );
  }
}
