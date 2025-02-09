import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class HiPotTestTable extends StatefulWidget {
  final ProtectionFunctionTestResult data;

  const HiPotTestTable(this.data, {super.key});

  @override
  State<HiPotTestTable> createState() => _HiPotTestTableState();
}

class _HiPotTestTableState extends State<HiPotTestTable> with TableHelper {
  late ProtectionFunctionTestResult data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  Widget _buildInsulationTestingRecord() {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Insulation impedance >10MΩ',
              style: TextStyle(
                fontSize: TableTextStyle.contentStyle.fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Left Plug:',
                            style: TableTextStyle.contentStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                            'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle),
                        Text(
                            'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle),
                        Text(
                            'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Right Plug:',
                            style: TableTextStyle.contentStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                            'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle),
                        Text(
                            'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle),
                        Text(
                            'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeakageTestingRecord() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'Leakage current <10mA',
            style: TextStyle(
              fontSize: TableTextStyle.contentStyle.fontSize,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Left Plug:',
                          style: TableTextStyle.contentStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                          'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputOutput.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle),
                      Text(
                          'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle),
                      Text(
                          'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationOutputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Right Plug:',
                          style: TableTextStyle.contentStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                          'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputOutput.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle),
                      Text(
                          'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle),
                      Text(
                          'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationOutputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: 'Hi-Pot Test',
      content: StyledDataTable(
        dataRowMinHeight: 200,
        dataRowMaxHeight: 230,
        columnSpacing: 30,
        columns: const [
          DataColumn(
            label: Text(
              'No.',
              style: TableTextStyle.headerStyle,
            ),
          ),
          DataColumn(
            label: Text(
              'Test Items',
              style: TableTextStyle.headerStyle,
            ),
          ),
          DataColumn(
            label: Text(
              'Testing Record',
              style: TableTextStyle.headerStyle,
            ),
          ),
          DataColumn(
            label: Text(
              'Judgement',
              style: TableTextStyle.headerStyle,
            ),
          ),
        ],
        rows: [
          DataRow(cells: [
            const DataCell(Text(
              '1',
              style: TableTextStyle.contentStyle,
            )),
            const DataCell(Text(
              'Insulation Impedance Test.\n\nApply a DC Voltage:\na) Between each circuit.\nb) Between each of the independent circuits and the ground.',
              style: TableTextStyle.contentStyle,
            )),
            DataCell(_buildInsulationTestingRecord()),
            DataCell(Text(
              data.hiPotTestResult.judgement,
              style: TableTextStyle.contentStyle.copyWith(
                color: data.hiPotTestResult.judgement == "OK"
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )),
          ]),
          DataRow(cells: [
            const DataCell(Text(
              '2',
              style: TableTextStyle.contentStyle,
            )),
            const DataCell(Text(
              'Insulation Voltage Test.\n\nApply a DC Voltage:\na) Between each circuit.\nb) Between each of the independent circuits and the ground.',
              style: TableTextStyle.contentStyle,
            )),
            DataCell(_buildLeakageTestingRecord()),
            DataCell(Text(
              data.hiPotTestResult.judgement,
              style: TableTextStyle.contentStyle.copyWith(
                color: data.hiPotTestResult.judgement == "OK"
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )),
          ]),
        ],
      ),
    );
  }
}
