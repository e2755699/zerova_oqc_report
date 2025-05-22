import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/report/model/basic_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';

class BasicFunctionTestTable extends StatefulWidget {
  final BasicFunctionTestResult data;
  final bool isEditing;

  const BasicFunctionTestTable(this.data, {super.key, this.isEditing = false});

  @override
  State<BasicFunctionTestTable> createState() => _BasicFunctionTestTableState();
}

class _BasicFunctionTestTableState extends State<BasicFunctionTestTable>
    with TableHelper {
  late BasicFunctionTestResult data;

  /// 存每一行兩個欄位的字串，index 0: spec, index 1: value
  late List<List<String>> _reportValues;

  final List<String> valueLabels = ['Efficiency:', 'PF:', 'THD:', 'Standby Power:'];
  final List<String> valueUnits = ['%', '%', '%', 'W'];

  // 取用全域Spec，回傳 Map<int, String>，key是欄位序號
  Map<int, String> get _defaultSpec {
    final spec = globalBasicFunctionTestSpec;
    return {
      1: _defaultIfEmpty(spec?.eff, '>94%'),
      2: _defaultIfEmpty(spec?.pf, '≧ 0.99'),
      3: _defaultIfEmpty(spec?.thd, '<5%'),
      4: _defaultIfEmpty(spec?.sp, '<100W'),
    };
  }
  void updateGlobalSpec(int index, String value) {
    switch (index) {
      case 0:
        globalBasicFunctionTestSpec = globalBasicFunctionTestSpec!.copyWith(eff: value);
        break;
      case 1:
        globalBasicFunctionTestSpec = globalBasicFunctionTestSpec!.copyWith(pf: value);
        break;
      case 2:
        globalBasicFunctionTestSpec = globalBasicFunctionTestSpec!.copyWith(thd: value);
        break;
      case 3:
        globalBasicFunctionTestSpec = globalBasicFunctionTestSpec!.copyWith(sp: value);
        break;
    }
  }
  String _defaultIfEmpty(String? value, String defaultValue) {
    if (value == null || value.trim().isEmpty) {
      return defaultValue;
    }
    return value;
  }

  void initializeGlobalSpec() {
    globalBasicFunctionTestSpec = BasicFunctionTestSpec(
      eff: _defaultSpec[1] ?? '>94%',
      pf: _defaultSpec[2] ?? '≧ 0.99',
      thd: _defaultSpec[3] ?? '<5%',
      sp: _defaultSpec[4] ?? '<100W',
    );
  }

  @override
  void initState() {
    super.initState();

    initializeGlobalSpec();

    data = widget.data;

    _reportValues = List.generate(
      data.testItems.length,
          (index) {
        String specText = _defaultSpec[index + 1] ?? '';

        // 將 double 轉成字串，且只保留小數點兩位
        double rawValue = data.testItems[index].value;
        String valueText = rawValue.toStringAsFixed(2);

        // 初始化 description
        String label = valueLabels.length > index ? valueLabels[index] : '';
        String unit = valueUnits.length > index ? valueUnits[index] : '';
        data.testItems[index].description = 'Spec: $specText\n$label $valueText$unit';

        return [specText, valueText];
      },
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
            final isHeaderEditable = editMode == 1 && permission == 1;

            final dataTable = StyledDataTable(
              dataRowMinHeight: 50,
              dataRowMaxHeight: 80,
              columns: [
                OqcTableStyle.getDataColumn('No.'),
                OqcTableStyle.getDataColumn('Test Items'),
                OqcTableStyle.getDataColumn('Testing Record'),
                OqcTableStyle.getDataColumn('Judgement'),
              ],
              rows: List.generate(
                data.testItems.length,
                    (index) => DataRow(
                  cells: [
                    OqcTableStyle.getDataCell((index + 1).toString()),
                    OqcTableStyle.getDataCell(data.testItems[index].name),

                    // 這裡是測試記錄欄位，改為上下兩個輸入框（spec 與 value），
                    // 且左邊有 spec: 文字，並置中對齊
                    DataCell(
                      SizedBox(
                        width: 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 第一欄 Spec
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'spec:',
                                  style: TableTextStyle.contentStyle(),
                                ),
                                const SizedBox(width: 8),
                                isHeaderEditable
                                    ? Expanded(
                                  child: TextFormField(
                                    initialValue: _reportValues[index][0],
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _reportValues[index][0] = value;

                                        // 更新全域 Spec
                                        updateGlobalSpec(index, value);

                                        // 同步更新 description
                                        final specText = _reportValues[index][0];
                                        final valueText = _reportValues[index][1];
                                        final label = valueLabels.length > index
                                            ? valueLabels[index]
                                            : '';
                                        final unit = valueUnits.length > index
                                            ? valueUnits[index]
                                            : '';

                                        data.testItems[index].description =
                                        'Spec: $specText\n$label $valueText$unit';
                                      });
                                    },
                                  ),
                                )
                                    : Text(
                                  _reportValues[index][0],
                                  style: TableTextStyle.contentStyle(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 第二欄 Value + Label + Unit
                            isEditable
                                ? Row(
                              children: [
                                Text(
                                  valueLabels.length > index
                                      ? valueLabels[index]
                                      : '',
                                  style: TableTextStyle.contentStyle(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _reportValues[index][1],
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _reportValues[index][1] = value;

                                        // 同步更新 description
                                        final specText = _reportValues[index][0];
                                        final valueText = _reportValues[index][1];
                                        final label = valueLabels.length > index
                                            ? valueLabels[index]
                                            : '';
                                        final unit = valueUnits.length > index
                                            ? valueUnits[index]
                                            : '';

                                        data.testItems[index].description =
                                        'Spec: $specText\n$label $valueText$unit';
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  valueUnits.length > index ? valueUnits[index] : '',
                                  style: TableTextStyle.contentStyle(),
                                ),
                              ],
                            )
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  valueLabels.length > index ? valueLabels[index] : '',
                                  style: TableTextStyle.contentStyle(),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _reportValues[index][1],
                                  style: TableTextStyle.contentStyle(),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  valueUnits.length > index ? valueUnits[index] : '',
                                  style: TableTextStyle.contentStyle(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    isEditable
                        ? DataCell(
                      DropdownButton<Judgement>(
                        value: data.testItems[index].judgement,
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
                              data.testItems[index].judgement = value;
                            });
                          }
                        },
                      ),
                    )
                        : OqcTableStyle.getDataCell(
                      data.testItems[index].judgement.name.toUpperCase(),
                      color: data.testItems[index].judgement == Judgement.pass
                          ? Colors.green
                          : data.testItems[index].judgement == Judgement.fail
                          ? Colors.red
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            );

            return TableWrapper(
              title: context.tr('basic_function_test'),
              content: dataTable,
            );
          },
        );
      },
    );
  }
}
