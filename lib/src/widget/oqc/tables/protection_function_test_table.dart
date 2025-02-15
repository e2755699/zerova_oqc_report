import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';

class ProtectionFunctionTestTable extends StatefulWidget {
  final ProtectionFunctionTestResult data;

  const ProtectionFunctionTestTable(this.data, {super.key});

  @override
  State<ProtectionFunctionTestTable> createState() =>
      _ProtectionFunctionTestTableState();
}

class _ProtectionFunctionTestTableState
    extends State<ProtectionFunctionTestTable> with TableHelper {
  List<ProtectionFunctionMeasurement> get testItems =>
      widget.data.specialFunctionTestResult.testItems;

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: 'Protection Function Test',
      content: StyledDataTable(
        dataRowMinHeight: 50.0,
        dataRowMaxHeight: 150.0,
        columns: [
          OqcTableStyle.getDataColumn('No.'),
          OqcTableStyle.getDataColumn('Test Items'),
          OqcTableStyle.getDataColumn('Testing Record'),
          OqcTableStyle.getDataColumn('Judgement'),
        ],
        rows: List.generate(
          testItems.length,
          (index) => DataRow(
            cells: [
              OqcTableStyle.getDataCell((index + 1).toString()),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    testItems[index].name,
                    style: TableTextStyle.contentStyle(),
                  ),
                ),
              ),
              DataCell(
                Wrap(
                  children: [
                    Text(
                      testItems[index].description,
                      style: TableTextStyle.contentStyle(),
                    )
                  ],
                ),
              ),
              OqcTableStyle.getDataCell(
                testItems[index].judgement.name.toUpperCase(),
                color: testItems[index].judgement == Judgement.pass
                    ? Colors.green
                    : testItems[index].judgement == Judgement.fail
                        ? Colors.red
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
