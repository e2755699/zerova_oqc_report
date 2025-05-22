import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';

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
              style: TableTextStyle.contentStyle(),
              textAlign: TextAlign.center,
            ),
          ),
          Table(
            border: TableBorder.all(color: AppColors.lightBlueColor),
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
                            style: TableTextStyle.contentStyle().copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                            'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle()),
                        Text(
                            'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle()),
                        Text(
                            'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle()),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Right Plug:',
                            style: TableTextStyle.contentStyle().copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                            'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle()),
                        Text(
                            'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle()),
                        Text(
                            'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                            style: TableTextStyle.contentStyle()),
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
            style: TableTextStyle.contentStyle().copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Table(
          border: TableBorder.all(color: AppColors.lightBlueColor),
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
                          style: TableTextStyle.contentStyle().copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                          'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputOutput.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle()),
                      Text(
                          'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle()),
                      Text(
                          'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationOutputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Right Plug:',
                          style: TableTextStyle.contentStyle().copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                          'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputOutput.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle()),
                      Text(
                          'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle()),
                      Text(
                          'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationOutputGround.value.toStringAsFixed(2)} mA',
                          style: TableTextStyle.contentStyle()),
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
    return ValueListenableBuilder<int>(
        valueListenable: globalEditModeNotifier,
        builder: (context, editMode, _) {
      return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
        final isEditable = editMode == 1 && (permission == 1 || permission == 2);
    return TableWrapper(
      title: context.tr('hipot_test'),
      content: StyledDataTable(
        dataRowMinHeight: 200,
        dataRowMaxHeight: 230,
        columns: [
          OqcTableStyle.getDataColumn('No.'),
          OqcTableStyle.getDataColumn('Test Items'),
          OqcTableStyle.getDataColumn('Testing Record'),
          OqcTableStyle.getDataColumn('Judgement'),
        ],
        rows: [
          DataRow(cells: [
            OqcTableStyle.getDataCell('1'),
            OqcTableStyle.getDataCell(
              'Insulation Impedance Test.\n\nApply a DC Voltage:\na) Between each circuit.\nb) Between each of the independent circuits and the ground.',
            ),
            DataCell(_buildInsulationTestingRecord()),
            OqcTableStyle.getDataCell(
              data.hiPotTestResult.insulationImpedanceTest.judgement.name.toUpperCase(),
              color: data.hiPotTestResult.insulationImpedanceTest.judgement ==
                      Judgement.pass
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ]),
          DataRow(cells: [
            OqcTableStyle.getDataCell('2'),
            OqcTableStyle.getDataCell(
              'Insulation Voltage Test.\n\nApply a DC Voltage:\na) Between each circuit.\nb) Between each of the independent circuits and the ground.',
            ),
            DataCell(_buildLeakageTestingRecord()),
            OqcTableStyle.getDataCell(
              data.hiPotTestResult.insulationVoltageTest.judgement.name.toUpperCase(),
              color: data.hiPotTestResult.insulationVoltageTest.judgement ==
                      Judgement.pass
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ]),
        ],
      ),
    );
          },
      );
        },
    );
  }
}
