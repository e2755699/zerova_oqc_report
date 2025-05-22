import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';

class InputOutputCharacteristicsTable extends StatefulWidget {
  final InputOutputCharacteristics inputOutputCharacteristics;
  final InputOutputCharacteristicsSpec? spec;

  const InputOutputCharacteristicsTable(
      this.inputOutputCharacteristics, {
        super.key,
        this.spec,
      });

  @override
  State<InputOutputCharacteristicsTable> createState() => _InputOutputCharacteristicsTableState();
}

class _InputOutputCharacteristicsTableState extends State<InputOutputCharacteristicsTable> with TableHelper {
  final Map<int, FocusNode> _focusNodes = {};
  final Set<int> _focusedIndices = {};
  final Map<int, String?> _userInput = {};
  final Map<int, TextEditingController> _controllers = {};
  final Map<String, String> _cellInputs = {};
  final Map<String, TextEditingController> _cellControllers = {};

  TextEditingController _getCellController(String key, String defaultValue) {
    if (!_cellControllers.containsKey(key)) {
      final controller = TextEditingController(text: _cellInputs[key] ?? defaultValue);
      controller.addListener(() {
        _cellInputs[key] = controller.text;
      });
      _cellControllers[key] = controller;
    }
    return _cellControllers[key]!;
  }
  void someFunction() {
    if (globalInputOutputSpec != null) {
      print(globalInputOutputSpec!.vin);
      print(globalInputOutputSpec!.iin);
      print(globalInputOutputSpec!.pin);
      print(globalInputOutputSpec!.vout);
      print(globalInputOutputSpec!.iout);
      print(globalInputOutputSpec!.pout);
    } else {
      print('資料還沒載入');
    }
  }


  String _defaultIfEmpty(String? value, String defaultValue) {
    if (value == null || value.trim().isEmpty) {
      return defaultValue;
    }
    return value;
  }

  // 改成 getter 從 widget.spec 取值，沒提供用預設字串
  Map<int, String> get _defaultSpec {
    final spec = globalInputOutputSpec;
    return {
      1: _defaultIfEmpty(spec?.vin, '253V,187V'),
      2: _defaultIfEmpty(spec?.iin, '<230A'),
      3: _defaultIfEmpty(spec?.pin, '<130kW'),
      4: _defaultIfEmpty(spec?.vout, '969V,931V'),
      5: _defaultIfEmpty(spec?.iout, '129A,1223A'),
      6: _defaultIfEmpty(spec?.pout, '122kW,118kW'),
    };
  }
  void initializeGlobalSpec() {
    globalInputOutputSpec = InputOutputCharacteristicsSpec(
      vin: _defaultSpec[1] ?? '253V,187V',
      iin: _defaultSpec[2] ?? '<230A',
      pin: _defaultSpec[3] ?? '<130kW',
      vout: _defaultSpec[4] ?? '969V,931V',
      iout: _defaultSpec[5] ?? '129A,1223A',
      pout: _defaultSpec[6] ?? '122kW,118kW',
    );

  }

  @override
  void initState() {
    super.initState();
    initializeGlobalSpec();
    someFunction();

    for (var i = 1; i <= 6; i++) {
      _focusNodes[i] = FocusNode();
      _userInput[i] = _defaultSpec[i];
      _controllers[i] = TextEditingController(text: _userInput[i]);

      _focusNodes[i]!.addListener(() {
        setState(() {
          if (_focusNodes[i]!.hasFocus) {
            _focusedIndices.add(i);
          } else {
            _focusedIndices.remove(i);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var controller in _cellControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<List<String>> get headers {
    return [
      ['Item', 'Spec'],
      ['Pin', _controllers[3]?.text ?? _defaultSpec[3]!],
      ['Vout', _controllers[4]?.text ?? _defaultSpec[4]!],
      ['Iout', _controllers[5]?.text ?? _defaultSpec[5]!],
      ['Pout', _controllers[6]?.text ?? _defaultSpec[6]!],
      ['Judgement'],
    ];
  }

  final Map<int, int> _headerEditableIndexMap = {
    1: 3, // Pin 對應到 _controllers[3]
    2: 4, // Vout 對應到 _controllers[4]
    3: 5, // Iout 對應到 _controllers[5]
    4: 6, // Pout 對應到 _controllers[6]
  };

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
              columns: headers.asMap().entries.map((entry) {
                final index = entry.key;
                final header = entry.value;
                if (_headerEditableIndexMap.containsKey(index)) {
                  final originalIndex = _headerEditableIndexMap[index]!;
                  return DataColumn(
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(header[0], style: TableTextStyle.headerStyle()),
                        const SizedBox(height: 4),
                        Visibility(
                          visible: isHeaderEditable,
                          child: SizedBox(
                            height: 30,
                            width: 120,
                            child: TextField(
                              focusNode: _focusNodes[originalIndex],
                              controller: _controllers[originalIndex],
                              enabled: isHeaderEditable,
                              style: TableTextStyle.headerStyle(),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: _focusedIndices.contains(originalIndex) ? '' : _defaultSpec[originalIndex],
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _userInput[originalIndex] = value;

                                  if (globalInputOutputSpec != null) {
                                    switch (originalIndex) {
                                      case 3:
                                        globalInputOutputSpec = globalInputOutputSpec!.copyWith(pin: value);
                                        break;
                                      case 4:
                                        globalInputOutputSpec = globalInputOutputSpec!.copyWith(vout: value);
                                        break;
                                      case 5:
                                        globalInputOutputSpec = globalInputOutputSpec!.copyWith(iout: value);
                                        break;
                                      case 6:
                                        globalInputOutputSpec = globalInputOutputSpec!.copyWith(pout: value);
                                        break;
                                    }
                                  }
                                });
                              },

                            ),
                          ),
                        ),
                        if (!isHeaderEditable)
                          Text(_userInput[originalIndex] ?? _defaultSpec[originalIndex]!, style: TableTextStyle.headerStyle()),
                      ],
                    ),
                  );
                }

                return DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: header.map((h) => Text(h, style: TableTextStyle.headerStyle())).toList(),
                  ),
                );
              }).toList(),

              rows: widget.inputOutputCharacteristics.inputOutputCharacteristicsSide
                  .asMap()
                  .entries
                  .map((entry) {
                final rowIndex = entry.key;
                final item = entry.value;

                return DataRow(
                  cells: [
                    editableCell("R${rowIndex}_0", item.side, isEditable),
                    editableCell("R${rowIndex}_3", item.totalInputPower.value.toStringAsFixed(2), isEditable, suffix: ' KW'),
                    editableCell("R${rowIndex}_4", item.outputVoltage.value.toStringAsFixed(2), isEditable, suffix: ' V'),
                    editableCell("R${rowIndex}_5", item.outputCurrent.value.toStringAsFixed(2), isEditable, suffix: ' A'),
                    editableCell("R${rowIndex}_6", item.totalOutputPower.value.toStringAsFixed(2), isEditable, suffix: ' KW'),
                    DataCell(
                      Center(
                        child: isEditable
                            ? DropdownButton<Judgement>(
                          value: item.judgement,
                          onChanged: (Judgement? newValue) {
                            if (newValue != null) {
                              setState(() {
                                item.judgement = newValue;
                              });
                            }
                          },
                          items: Judgement.values.map((Judgement value) {
                            return DropdownMenuItem<Judgement>(
                              value: value,
                              child: Text(
                                value.name.toUpperCase(),
                                style: TextStyle(
                                  color: value == Judgement.pass
                                      ? Colors.green
                                      : value == Judgement.fail
                                      ? Colors.red
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          underline: SizedBox(),
                        )
                            : Text(
                          item.judgement.name.toUpperCase(),
                          style: TextStyle(
                            color: item.judgement == Judgement.pass
                                ? Colors.green
                                : item.judgement == Judgement.fail
                                ? Colors.red
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),


                    /*OqcTableStyle.getDataCell(
                      item.judgement.name.toUpperCase(),
                      color: item.judgement == Judgement.pass
                          ? Colors.green
                          : item.judgement == Judgement.fail
                          ? Colors.red
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),*/
                  ],
                );
              }).toList(),
            );

            return TableWrapper(
              title: context.tr('input_output_characteristics'),
              content: dataTable,
            );
          },
        );
      },
    );
  }

  DataCell editableCell(String rowKey, String defaultValue, bool isEditable, {String suffix = ""}) {
    final value = _cellInputs[rowKey] ?? defaultValue;

    if (!isEditable) {
      return OqcTableStyle.getDataCell("$value$suffix");
    }

    return DataCell(
      TextField(
        controller: _getCellController(rowKey, defaultValue),
        onChanged: (newValue) {
          setState(() {
            _cellInputs[rowKey] = newValue;

            // 解析 rowIndex
            final rowMatch = RegExp(r'R(\d+)_\d+').firstMatch(rowKey);
            if (rowMatch != null) {
              final index = int.parse(rowMatch.group(1)!);
              final side = widget.inputOutputCharacteristics.inputOutputCharacteristicsSide[index];

              // 根據欄位 index 寫入對應值
              if (rowKey.endsWith('_3')) {
                final parsed = double.tryParse(newValue);
                if (parsed != null) {
                  side.totalInputPower.value = parsed;
                }
              }
              if (rowKey.endsWith('_4')) {
                final parsed = double.tryParse(newValue);
                if (parsed != null) {
                  side.outputVoltage.value = parsed;
                }
              }
              if (rowKey.endsWith('_5')) {
                final parsed = double.tryParse(newValue);
                if (parsed != null) {
                  side.outputCurrent.value = parsed;
                }
              }
              if (rowKey.endsWith('_6')) {
                final parsed = double.tryParse(newValue);
                if (parsed != null) {
                  side.totalOutputPower.value = parsed;
                }
              }
              // 其他像 _4, _5, _6 可以照此類推補上
            }
          });
        },

        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          border: const OutlineInputBorder(),
          suffixText: suffix.trim(),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
