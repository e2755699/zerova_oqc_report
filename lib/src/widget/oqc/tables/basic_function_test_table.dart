import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/report/model/basic_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/widget/common/table_failorpass.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/oqc_text_field.dart';
import 'package:flutter/services.dart';
import 'package:zerova_oqc_report/src/widget/common/judgement_dropdown.dart';

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

  final defaultNames = ['Efficiency', 'Power Factor (PF)', 'Harmonic', 'Standby Power'];

  final List<String> valueLabels = [
    'Efficiency:',
    'PF:',
    'THD:',
    'Standby Power:'
  ];
  final List<String> valueUnits = ['%', '', '%', 'W'];

  double _defaultIfEmptyDouble(double? value, double defaultValue) {
    return (value == null || value.isNaN) ? defaultValue : value;
  }

  Map<int, double> get _defaultSpec {
    final spec = globalBasicFunctionTestSpec;
    return {
      // Left Side
      1: _defaultIfEmptyDouble(spec?.eff, 94),
      2: _defaultIfEmptyDouble(spec?.pf, 0.99),
      3: _defaultIfEmptyDouble(spec?.thd, 5),
      4: _defaultIfEmptyDouble(spec?.sp, 100),
    };
  }

  void initializeGlobalSpec() {
    globalBasicFunctionTestSpec = BasicFunctionTestSpec(
      // Left Side
      eff: _defaultSpec[1] ?? 94,
      pf: _defaultSpec[2] ?? 0.99,
      thd: _defaultSpec[3] ?? 5,
      sp: _defaultSpec[4] ?? 100,
    );
  }

  void updateGlobalSpec(int index, double value) {
    switch (index) {
      case 0:
        globalBasicFunctionTestSpec =
            globalBasicFunctionTestSpec!.copyWith(eff: value);
        break;
      case 1:
        globalBasicFunctionTestSpec =
            globalBasicFunctionTestSpec!.copyWith(pf: value);
        break;
      case 2:
        globalBasicFunctionTestSpec =
            globalBasicFunctionTestSpec!.copyWith(thd: value);
        break;
      case 3:
        globalBasicFunctionTestSpec =
            globalBasicFunctionTestSpec!.copyWith(sp: value);
        break;
    }
  }

  String getSpecLabel(int index) {
    switch (index) {
      case 0:
        return 'spec: >';
      case 1:
        return 'spec: ≧';
      case 2:
      case 3:
        return 'spec: <';
      default:
        return 'spec:';
    }
  }

  void _updateBasicFunctionTestPassOrFail() {
    bool allPassed = true;
    bool allFieldsFilled = true;

    for (var i = 0; i < data.testItems.length; i++) {
      // 判斷 judgement
      if (data.testItems[i].judgement != Judgement.pass) {
        allPassed = false;
        break;
      }
    }

    final effValue = data.eff.value;
    final powerFactorValue = data.powerFactor.value;
    final harmonicValue = data.harmonic.value;
    final standbyValue = data.standbyTotalInputPower.value;

    print('🔍 effValue = $effValue');
    print('🔍 powerFactorValue = $powerFactorValue');
    print('🔍 harmonicValue = $harmonicValue');
    print('🔍 standbyTotalInputPowerValue = $standbyValue');

    if (effValue == null) {
      print('❌ effValue 為空！');
      allFieldsFilled = false;
    }
    if (powerFactorValue == null) {
      print('❌ powerFactorValue 為空！');
      allFieldsFilled = false;
    }
    if (harmonicValue == null) {
      print('❌ harmonicValue 為空！');
      allFieldsFilled = false;
    }
    if (standbyValue == null) {
      print('❌ standbyTotalInputPower 為空！');
      allFieldsFilled = false;
    }

    // 判斷結果
    basicFunctionTestPassOrFail = allPassed && allFieldsFilled;
    debugPrint('basicFunctionTestPassOrFail = $basicFunctionTestPassOrFail');
  }

  @override
  void initState() {
    super.initState();
    initializeGlobalSpec();

    data = widget.data;

    _reportValues = List.generate(
      data.testItems.length,
      (index) {

        if (data.testItems[index].name == null || data.testItems[index].name.trim().isEmpty) {
          if (index < defaultNames.length) {
            data.testItems[index].name = defaultNames[index];
          }
        }

        String specValue = _defaultSpec[index + 1]?.toString() ?? '';

        // 設定符號依照 index
        String specPrefix;
        switch (index) {
          case 0:
            specPrefix = '> '; // 第1列
            break;
          case 1:
            specPrefix = '≧ '; // 第2列
            break;
          case 2:
          case 3:
            specPrefix = '< '; // 第3、4列
            break;
          default:
            specPrefix = ''; // 其他預設為空
        }

        // 數值與單位
        double rawValue = data.testItems[index].value;
        String valueText = rawValue.toStringAsFixed(2);
        String label = valueLabels.length > index ? valueLabels[index] : '';
        String unit = valueUnits.length > index ? valueUnits[index] : '';

        // description 組合內容
        data.testItems[index].description =
            'Spec: $specPrefix$specValue$unit\n$label $valueText$unit';

        return [specValue, valueText];
      },
    );
    _updateBasicFunctionTestPassOrFail();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: globalEditModeNotifier,
      builder: (context, editMode, _) {
        return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable =
                editMode == 1 && permission <= 2;
            //final isHeaderEditable = editMode == 1 && permission == 1;
            final isHeaderEditable = false;
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
                        Padding(
                        padding: const EdgeInsets.only(left: 12.0), // 根據需要調整左邊距
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  getSpecLabel(index),
                                  style: TableTextStyle.contentStyle(),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(width: 8),
                                isHeaderEditable
                                    ? Expanded(
                                        child: OqcTextField(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          initialValue: _reportValues[index][0],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*')),
                                          ],
                                          onChanged: (value) {
                                            final doubleValue =
                                                double.tryParse(value);
                                            if (doubleValue != null) {
                                              setState(() {
                                                _reportValues[index][0] = value;
                                                updateGlobalSpec(
                                                    index, doubleValue);

                                                // 其他同步更新描述等
                                                final specText =
                                                    _reportValues[index][0];
                                                final valueText =
                                                    _reportValues[index][1];
                                                final label =
                                                    valueLabels.length > index
                                                        ? valueLabels[index]
                                                        : '';
                                                final unit =
                                                    valueUnits.length > index
                                                        ? valueUnits[index]
                                                        : '';

                                                // 指定符號 prefix
                                                String specPrefix;
                                                switch (index) {
                                                  case 0:
                                                    specPrefix = '> ';
                                                    break;
                                                  case 1:
                                                    specPrefix = '≧ ';
                                                    break;
                                                  case 2:
                                                  case 3:
                                                    specPrefix = '< ';
                                                    break;
                                                  default:
                                                    specPrefix = '';
                                                }

                                                data.testItems[index]
                                                        .description =
                                                    'Spec: $specPrefix$specText$unit\n$label $valueText$unit';
                                              });
                                            }
                                            // 如果轉換失敗可以忽略或做錯誤處理
                                          },
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          _reportValues[index][0],
                                          style: TableTextStyle.contentStyle(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                const SizedBox(width: 8),
                                // 單位獨立顯示
                                Text(
                                  valueUnits.length > index
                                      ? valueUnits[index]
                                      : '',
                                  style: TableTextStyle.contentStyle(),
                                ),
                              ],
                            ),
                        ),
                            const SizedBox(height: 8),
                            // 第二欄 Value + Label + Unit
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0), // 根據需要調整左邊距
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  valueLabels.length > index
                                      ? valueLabels[index]
                                      : '',
                                  style: TableTextStyle.contentStyle(),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(width: 8),
                                isEditable
                                    ? Expanded(
                                        child: OqcTextField(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        initialValue: _reportValues[index][1],
                                        onChanged: (value) {
                                          setState(() {
                                            _reportValues[index][1] = value;

                                            // 同步更新 description
                                            final specText =
                                                _reportValues[index][0];
                                            final valueText =
                                                _reportValues[index][1];
                                            final label =
                                                valueLabels.length > index
                                                    ? valueLabels[index]
                                                    : '';
                                            final unit =
                                                valueUnits.length > index
                                                    ? valueUnits[index]
                                                    : '';

                                            // 決定 spec 符號
                                            String specPrefix;
                                            switch (index) {
                                              case 0:
                                                specPrefix = '> ';
                                                break;
                                              case 1:
                                                specPrefix = '≧ ';
                                                break;
                                              case 2:
                                              case 3:
                                                specPrefix = '< ';
                                                break;
                                              default:
                                                specPrefix = '';
                                            }

                                            data.testItems[index].description =
                                                'Spec: $specPrefix$specText$unit\n$label $valueText$unit';
                                          });
                                          _updateBasicFunctionTestPassOrFail();
                                        },
                                      ))
                                    : Text(
                                        _reportValues[index][1],
                                        style: TableTextStyle.contentStyle(),
                                        textAlign: TextAlign.center,
                                      ),
                                Text(
                                  valueUnits.length > index
                                      ? valueUnits[index]
                                      : '',
                                  style: TableTextStyle.contentStyle(),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                        ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    isEditable
                        ? DataCell(
                            JudgementDropdown(
                              value: data.testItems[index].judgement,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    data.testItems[index].judgement = value;
                                  });
                                }
                                _updateBasicFunctionTestPassOrFail();
                              },
                            ),
                          )
                        : OqcTableStyle.getJudgementCell(
                            data.testItems[index].judgement),
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
