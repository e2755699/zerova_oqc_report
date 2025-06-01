import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';

class ProtectionFunctionTestTable extends StatefulWidget {
  final ProtectionFunctionTestResult data;
  final bool isEditing;
  const ProtectionFunctionTestTable(this.data, {super.key, this.isEditing = false});

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
    return ValueListenableBuilder<int>(
        valueListenable: globalEditModeNotifier,
        builder: (context, editMode, _) {
      return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
        final isEditable = editMode == 1 && (permission == 1 || permission == 2);
    return TableWrapper(
      title: context.tr('protection_function_test'),
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
              DataCell(
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: TableTextStyle.contentStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Text(
                      testItems[index].name,
                      style: TableTextStyle.contentStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  testItems[index].description,
                  style: TableTextStyle.contentStyle(),
                  textAlign: TextAlign.start,
                ),
              ),
              isEditable
                  ? DataCell(
                DropdownButton<Judgement>(
                  value: testItems[index].judgement,
                  items: Judgement.values.map((j) {
                    return DropdownMenuItem(
                      value: j,
                      child: Text(
                        j.name.toUpperCase(),
                        style: TextStyle(
                          color: j == Judgement.pass
                              ? Colors.green
                              : j == Judgement.fail
                              ? Colors.red
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        testItems[index].judgement = value;
                      });
                    }
                  },
                ),
              )
                  : OqcTableStyle.getDataCell(
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
          },
      );
        },
    );
  }
}
