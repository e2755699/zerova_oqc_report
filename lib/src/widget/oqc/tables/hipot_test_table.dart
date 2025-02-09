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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insulation impedance >10MΩ',
            style: TableTextStyle.contentStyle,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Left Plug:', style: TableTextStyle.contentStyle),
                    Text('Input/Output: ${data.insulationImpedanceTest.insulationImpedanceInputOutput.value} MΩ',
                        style: TableTextStyle.contentStyle),
                    Text('Input/Ground: ${data.insulationImpedanceTest.insulationImpedanceInputGround.value} MΩ',
                        style: TableTextStyle.contentStyle),
                    Text('Output/Ground: ${data.insulationImpedanceTest.insulationImpedanceOutputGround.value} MΩ',
                        style: TableTextStyle.contentStyle),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Right Plug:', style: TableTextStyle.contentStyle),
                    Text('Input/Output: ${data.insulationVoltageTest.insulationImpedanceInputOutput.value} MΩ',
                        style: TableTextStyle.contentStyle),
                    Text('Input/Ground: ${data.insulationVoltageTest.insulationImpedanceInputGround.value} MΩ',
                        style: TableTextStyle.contentStyle),
                    Text('Output/Ground: ${data.insulationVoltageTest.insulationImpedanceOutputGround.value} MΩ',
                        style: TableTextStyle.contentStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeakageTestingRecord() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leakage current <10mA',
            style: TextStyle(
              fontSize: TableTextStyle.contentStyle.fontSize,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Left Plug:', style: TableTextStyle.contentStyle),
                    Text('Input/Output: ${data.insulationImpedanceTest.insulationVoltageInputOutput.value} mA',
                        style: TableTextStyle.contentStyle),
                    Text('Input/Ground: ${data.insulationImpedanceTest.insulationVoltageInputGround.value} mA',
                        style: TableTextStyle.contentStyle),
                    Text('Output/Ground: ${data.insulationImpedanceTest.insulationVoltageOutputGround.value} mA',
                        style: TableTextStyle.contentStyle),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Right Plug:', style: TableTextStyle.contentStyle),
                    Text('Input/Output: ${data.insulationVoltageTest.insulationVoltageInputOutput.value} mA',
                        style: TableTextStyle.contentStyle),
                    Text('Input/Ground: ${data.insulationVoltageTest.insulationVoltageInputGround.value} mA',
                        style: TableTextStyle.contentStyle),
                    Text('Output/Ground: ${data.insulationVoltageTest.insulationVoltageOutputGround.value} mA',
                        style: TableTextStyle.contentStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: 'Hi-Pot Test',
      content: StyledDataTable(
        dataRowMinHeight: 200,
        dataRowMaxHeight: 300,
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
            OqcTableStyle.getDataCell(
              data.insulationImpedanceTest.insulationImpedanceInputOutput.judgement.name.toUpperCase(),
              color: data.insulationImpedanceTest.insulationImpedanceInputOutput.judgement == Judgement.pass
                  ? Colors.green
                  : data.insulationImpedanceTest.insulationImpedanceInputOutput.judgement == Judgement.fail
                  ? Colors.red
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
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
            DataCell(buildJudgementDropdown(
              data.insulationVoltageTest.judgement,
              (newValue) {
                if (newValue != null) {
                  setState(() {
                    // TODO: Update judgement
                  });
                }
              },
            )),
          ]),
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
            headers: ['No.', 'S/N'],
            data: List.generate(
              data.specialFunctionTestResult.testItems.length,
              (index) => [
                (index + 1).toString(),
                data.specialFunctionTestResult.testItems[index].name,
                data.specialFunctionTestResult.testItems[index].description,
                data.specialFunctionTestResult.testItems[index].judgement,
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
