import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:flutter/services.dart';
import 'package:zerova_oqc_report/src/report/spec/FailCountStore.dart';

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
      print('Left Side:');
      print('  Vin: ${globalInputOutputSpec!.leftVinLowerbound} ~ ${globalInputOutputSpec!.leftVinUpperbound}');
      print('  Iin: ${globalInputOutputSpec!.leftIinLowerbound} ~ ${globalInputOutputSpec!.leftIinUpperbound}');
      print('  Pin: ${globalInputOutputSpec!.leftPinLowerbound} ~ ${globalInputOutputSpec!.leftPinUpperbound}');
      print('  Vout: ${globalInputOutputSpec!.leftVoutLowerbound} ~ ${globalInputOutputSpec!.leftVoutUpperbound}');
      print('  Iout: ${globalInputOutputSpec!.leftIoutLowerbound} ~ ${globalInputOutputSpec!.leftIoutUpperbound}');
      print('  Pout: ${globalInputOutputSpec!.leftPoutLowerbound} ~ ${globalInputOutputSpec!.leftPoutUpperbound}');

      print('Right Side:');
      print('  Vin: ${globalInputOutputSpec!.rightVinLowerbound} ~ ${globalInputOutputSpec!.rightVinUpperbound}');
      print('  Iin: ${globalInputOutputSpec!.rightIinLowerbound} ~ ${globalInputOutputSpec!.rightIinUpperbound}');
      print('  Pin: ${globalInputOutputSpec!.rightPinLowerbound} ~ ${globalInputOutputSpec!.rightPinUpperbound}');
      print('  Vout: ${globalInputOutputSpec!.rightVoutLowerbound} ~ ${globalInputOutputSpec!.rightVoutUpperbound}');
      print('  Iout: ${globalInputOutputSpec!.rightIoutLowerbound} ~ ${globalInputOutputSpec!.rightIoutUpperbound}');
      print('  Pout: ${globalInputOutputSpec!.rightPoutLowerbound} ~ ${globalInputOutputSpec!.rightPoutUpperbound}');
    } else {
      print('資料還沒載入');
    }
  }

  void someFunction2() {
    // 讀取
    int currentFailCount = FailCountStore.getCount('InputOutputCharacteristics');
    print('現在 InputOutputCharacteristics 失敗數量: $currentFailCount');

    // 增加
    FailCountStore.increment('InputOutputCharacteristics');

    // 再讀取看看
    print('更新後的失敗數量: ${FailCountStore.inputOutputCharacteristics}');
  }

  double _defaultIfEmptyDouble(double? value, double defaultValue) {
    return (value == null || value.isNaN) ? defaultValue : value;
  }

  Map<int, double> get _defaultSpec {
    final spec = globalInputOutputSpec;
    return {
      // Left Side
      1: _defaultIfEmptyDouble(spec?.leftVinLowerbound, 187),
      2: _defaultIfEmptyDouble(spec?.leftVinUpperbound, 253),

      3: _defaultIfEmptyDouble(spec?.leftIinLowerbound, 0),
      4: _defaultIfEmptyDouble(spec?.leftIinUpperbound, 230),

      5: _defaultIfEmptyDouble(spec?.leftPinLowerbound, 0),
      6: _defaultIfEmptyDouble(spec?.leftPinUpperbound, 130),

      7: _defaultIfEmptyDouble(spec?.leftVoutLowerbound, 931),
      8: _defaultIfEmptyDouble(spec?.leftVoutUpperbound, 969),

      9: _defaultIfEmptyDouble(spec?.leftIoutLowerbound, 123),
      10: _defaultIfEmptyDouble(spec?.leftIoutUpperbound, 129),

      11: _defaultIfEmptyDouble(spec?.leftPoutLowerbound, 118),
      12: _defaultIfEmptyDouble(spec?.leftPoutUpperbound, 122),

      // Right Side
      13: _defaultIfEmptyDouble(spec?.rightVinLowerbound, 187),
      14: _defaultIfEmptyDouble(spec?.rightVinUpperbound, 253),

      15: _defaultIfEmptyDouble(spec?.rightIinLowerbound, 0),
      16: _defaultIfEmptyDouble(spec?.rightIinUpperbound, 230),

      17: _defaultIfEmptyDouble(spec?.rightPinLowerbound, 0),
      18: _defaultIfEmptyDouble(spec?.rightPinUpperbound, 130),

      19: _defaultIfEmptyDouble(spec?.rightVoutLowerbound, 931),
      20: _defaultIfEmptyDouble(spec?.rightVoutUpperbound, 969),

      21: _defaultIfEmptyDouble(spec?.rightIoutLowerbound, 123),
      22: _defaultIfEmptyDouble(spec?.rightIoutUpperbound, 129),

      23: _defaultIfEmptyDouble(spec?.rightPoutLowerbound, 118),
      24: _defaultIfEmptyDouble(spec?.rightPoutUpperbound, 122),
    };
  }

  void initializeGlobalSpec() {
    globalInputOutputSpec = InputOutputCharacteristicsSpec(
      // Left Side
      leftVinLowerbound: _defaultSpec[1] ?? 187,
      leftVinUpperbound: _defaultSpec[2] ?? 253,
      leftIinLowerbound: _defaultSpec[3] ?? 0,
      leftIinUpperbound: _defaultSpec[4] ?? 230,
      leftPinLowerbound: _defaultSpec[5] ?? 0,
      leftPinUpperbound: _defaultSpec[6] ?? 130,
      leftVoutLowerbound: _defaultSpec[7] ?? 931,
      leftVoutUpperbound: _defaultSpec[8] ?? 969,
      leftIoutLowerbound: _defaultSpec[9] ?? 123,
      leftIoutUpperbound: _defaultSpec[10] ?? 129,
      leftPoutLowerbound: _defaultSpec[11] ?? 118,
      leftPoutUpperbound: _defaultSpec[12] ?? 122,

      // Right Side
      rightVinLowerbound: _defaultSpec[13] ?? 187,
      rightVinUpperbound: _defaultSpec[14] ?? 253,
      rightIinLowerbound: _defaultSpec[15] ?? 0,
      rightIinUpperbound: _defaultSpec[16] ?? 230,
      rightPinLowerbound: _defaultSpec[17] ?? 0,
      rightPinUpperbound: _defaultSpec[18] ?? 130,
      rightVoutLowerbound: _defaultSpec[19] ?? 931,
      rightVoutUpperbound: _defaultSpec[20] ?? 969,
      rightIoutLowerbound: _defaultSpec[21] ?? 123,
      rightIoutUpperbound: _defaultSpec[22] ?? 129,
      rightPoutLowerbound: _defaultSpec[23] ?? 118,
      rightPoutUpperbound: _defaultSpec[24] ?? 122,
    );
  }

  void _parseAndSetInput(int index) {
    final text = _controllers[index]?.text.trim();
    final value = double.tryParse(text ?? '');
    if (value != null && globalInputOutputSpec != null) {
      setState(() {
        switch (index) {
          case 1:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftVinLowerbound: value);
            break;
          case 2:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftVinUpperbound: value);
            break;
          case 3:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftIinLowerbound: value);
            break;
          case 4:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftIinUpperbound: value);
            break;
          case 5:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftPinLowerbound: value);
            break;
          case 6:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftPinUpperbound: value);
            break;
          case 7:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftVoutLowerbound: value);
            break;
          case 8:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftVoutUpperbound: value);
            break;
          case 9:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftIoutLowerbound: value);
            break;
          case 10:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftIoutUpperbound: value);
            break;
          case 11:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftPoutLowerbound: value);
            break;
          case 12:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(leftPoutUpperbound: value);
            break;
          case 13:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightVinLowerbound: value);
            break;
          case 14:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightVinUpperbound: value);
            break;
          case 15:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightIinLowerbound: value);
            break;
          case 16:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightIinUpperbound: value);
            break;
          case 17:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightPinLowerbound: value);
            break;
          case 18:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightPinUpperbound: value);
            break;
          case 19:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightVoutLowerbound: value);
            break;
          case 20:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightVoutUpperbound: value);
            break;
          case 21:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightIoutLowerbound: value);
            break;
          case 22:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightIoutUpperbound: value);
            break;
          case 23:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightPoutLowerbound: value);
            break;
          case 24:
            globalInputOutputSpec = globalInputOutputSpec!.copyWith(rightPoutUpperbound: value);
            break;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeGlobalSpec();
    someFunction();
    someFunction2();

    for (var i = 1; i <= 24; i++) {
      _focusNodes[i] = FocusNode();

      final defaultValue = _defaultSpec[i];
      final defaultStr = defaultValue?.toStringAsFixed(0);

      _userInput[i] = defaultStr;
      _controllers[i] = TextEditingController(text: defaultStr);

      _focusNodes[i]!.addListener(() {
        setState(() {
          if (_focusNodes[i]!.hasFocus) {
            _focusedIndices.add(i);
          } else {
            _focusedIndices.remove(i);
            // 當失去焦點時，嘗試解析為 double 並更新 globalInputOutputSpec
            _parseAndSetInput(i);
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
  List<List<String>> get leftHeaders {
    String format(int index) {
      return _controllers[index]?.text.isNotEmpty == true
          ? _controllers[index]!.text
          : _defaultSpec[index]!.toStringAsFixed(0);
    }

    return [
      ['Item', 'Spec'],
      ['Pin', format(5), 'kW', format(6), 'kW'],
      ['Vout', format(7), 'V', format(8), 'V'],
      ['Iout', format(9), 'A', format(10), 'A'],
      ['Pout', format(11), 'kW', format(12), 'kW'],
      ['Judgement'],
    ];
  }

  List<List<String>> get rightHeaders {
    String format(int index) {
      return _controllers[index]?.text.isNotEmpty == true
          ? _controllers[index]!.text
          : _defaultSpec[index]!.toStringAsFixed(0);
    }

    return [
      ['Item', 'Spec'],
      ['Pin', format(17), 'kW', format(18), 'kW'],
      ['Vout', format(19), 'V', format(20), 'V'],
      ['Iout', format(21), 'A', format(22), 'A'],
      ['Pout', format(23), 'kW', format(24), 'kW'],
      ['Judgement'],
    ];
  }

  final Map<int, List<int>> leftHeaderEditableIndexMap = {
    1: [5, 6],   // Pin
    2: [7, 8],   // Vout
    3: [9, 10],  // Iout
    4: [11, 12], // Pout
  };

  final Map<int, List<int>> rightHeaderEditableIndexMap = {
    1: [17, 18], // Pin
    2: [19, 20], // Vout
    3: [21, 22], // Iout
    4: [23, 24], // Pout
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
            //final isHeaderEditable = editMode == 1 && permission == 1;
            final isHeaderEditable = false;

            // 你的 headerColumns (完全照你給的程式碼)
            final leftHeaderColumns = leftHeaders.asMap().entries.map((entry) {
              final index = entry.key;
              final header = entry.value;

              if (leftHeaderEditableIndexMap.containsKey(index)) {
                final controllerIndices = leftHeaderEditableIndexMap[index]!; // e.g., [5, 6]
                final lowerIndex = controllerIndices[0];
                final upperIndex = controllerIndices[1];

                // 推斷單位（從 header 內部抓）
                final lowerUnit = header[2];
                final upperUnit = header[4];

                return DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(header[0], style: TableTextStyle.headerStyle()),
                      const SizedBox(height: 4),

                      Visibility(
                        visible: isHeaderEditable,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              child: TextField(
                                focusNode: _focusNodes[upperIndex],
                                controller: _controllers[upperIndex],
                                enabled: isHeaderEditable,
                                style: TableTextStyle.headerStyle(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Up',
                                  hintText: _focusedIndices.contains(upperIndex)
                                      ? ''
                                      : '${_defaultSpec[upperIndex]?.toInt().toString() ?? ''}',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _userInput[upperIndex] = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(header[2], style: TableTextStyle.headerStyle()),

                            const SizedBox(width: 16),

                            SizedBox(
                              width: 60,
                              child: TextField(
                                focusNode: _focusNodes[lowerIndex],
                                controller: _controllers[lowerIndex],
                                enabled: isHeaderEditable,
                                style: TableTextStyle.headerStyle(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Low',
                                  hintText: _focusedIndices.contains(lowerIndex)
                                      ? ''
                                      : '${_defaultSpec[lowerIndex]?.toInt().toString() ?? ''}',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _userInput[lowerIndex] = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(header[4], style: TableTextStyle.headerStyle()),
                          ],
                        ),
                      ),

                      if (!isHeaderEditable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_controllers[upperIndex]?.text.isNotEmpty == true ? _controllers[upperIndex]!.text.split('.').first : _defaultSpec[upperIndex]?.toInt().toString() ?? ''}${upperUnit}',
                              style: TableTextStyle.headerStyle(),
                            ),
                            const SizedBox(width: 4),
                            const Text(',', style: TextStyle(fontWeight: FontWeight.normal)),
                            const SizedBox(width: 4),
                            Text(
                              '${_controllers[lowerIndex]?.text.isNotEmpty == true ? _controllers[lowerIndex]!.text.split('.').first : _defaultSpec[lowerIndex]?.toInt().toString() ?? ''}${lowerUnit}',
                              style: TableTextStyle.headerStyle(),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }

              // default: non-editable column
              return DataColumn(
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: header.map((h) => Text(h, style: TableTextStyle.headerStyle())).toList(),
                ),
              );
            }).toList();


            final rightHeaderColumns = rightHeaders.asMap().entries.map((entry) {
              final index = entry.key;
              final header = entry.value;

              if (rightHeaderEditableIndexMap.containsKey(index)) {
                final controllerIndices = rightHeaderEditableIndexMap[index]!; // [lower, upper]
                final lowerIndex = controllerIndices[0];
                final upperIndex = controllerIndices[1];

                final lowerUnit = header[2];
                final upperUnit = header[4];

                return DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(header[0], style: TableTextStyle.headerStyle()),
                      const SizedBox(height: 4),

                      Visibility(
                        visible: isHeaderEditable,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,  // 寬度調整
                              child: TextField(
                                focusNode: _focusNodes[upperIndex],
                                controller: _controllers[upperIndex],
                                enabled: isHeaderEditable,
                                style: TableTextStyle.headerStyle(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Up',
                                  hintText: _focusedIndices.contains(upperIndex)
                                      ? ''
                                      : '${_defaultSpec[upperIndex]?.toInt().toString() ?? ''}',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _userInput[upperIndex] = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(header[2], style: TableTextStyle.headerStyle()),

                            const SizedBox(width: 16),

                            SizedBox(
                              width: 60,  // 寬度調整
                              child: TextField(
                                focusNode: _focusNodes[lowerIndex],
                                controller: _controllers[lowerIndex],
                                enabled: isHeaderEditable,
                                style: TableTextStyle.headerStyle(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Low',
                                  hintText: _focusedIndices.contains(lowerIndex)
                                      ? ''
                                      : '${_defaultSpec[lowerIndex]?.toInt().toString() ?? ''}',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _userInput[lowerIndex] = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(header[4], style: TableTextStyle.headerStyle()),
                          ],
                        ),
                      ),

                      if (!isHeaderEditable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_controllers[upperIndex]?.text.isNotEmpty == true ? _controllers[upperIndex]!.text.split('.').first : _defaultSpec[upperIndex]?.toInt().toString() ?? ''}${upperUnit}',
                              style: TableTextStyle.headerStyle(),
                            ),
                            const SizedBox(width: 4),
                            const Text(',', style: TextStyle(fontWeight: FontWeight.normal)),
                            const SizedBox(width: 4),
                            Text(
                              '${_controllers[lowerIndex]?.text.isNotEmpty == true ? _controllers[lowerIndex]!.text.split('.').first : _defaultSpec[lowerIndex]?.toInt().toString() ?? ''}${lowerUnit}',
                              style: TableTextStyle.headerStyle(),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }

              // default: non-editable column
              return DataColumn(
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: header.map((h) => Text(h, style: TableTextStyle.headerStyle())).toList(),
                ),
              );
            }).toList();

            final headerRow2 = DataRow(
              color: MaterialStateProperty.all(
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
              ),
              cells: rightHeaderColumns
                  .map((dataColumn) => DataCell(Center(child: dataColumn.label)))
                  .toList(), );

            // L 列
            DataRow? lRow;
            if (widget.inputOutputCharacteristics.inputOutputCharacteristicsSide.isNotEmpty) {
              final item = widget.inputOutputCharacteristics.inputOutputCharacteristicsSide[0];
              lRow = DataRow(
                cells: [
                  editableCell("L_0", item.side, false),
                  editableCell("L_3", item.totalInputPower.value.toStringAsFixed(2), isEditable,
                      suffix: ' kW'),
                  editableCell("L_4", item.outputVoltage.value.toStringAsFixed(2), isEditable,
                      suffix: ' V'),
                  editableCell("L_5", item.outputCurrent.value.toStringAsFixed(2), isEditable,
                      suffix: ' A'),
                  editableCell("L_6", item.totalOutputPower.value.toStringAsFixed(2), isEditable,
                      suffix: ' kW'),
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
                        items: Judgement.values.map((value) {
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
                ],
              );
            }

            // R 列
            DataRow? rRow;
            if (widget.inputOutputCharacteristics.inputOutputCharacteristicsSide.length > 1) {
              final item = widget.inputOutputCharacteristics.inputOutputCharacteristicsSide[1];
              rRow = DataRow(
                cells: [
                  editableCell("R_0", item.side, false),
                  editableCell("R_3", item.totalInputPower.value.toStringAsFixed(2), isEditable,
                      suffix: ' kW'),
                  editableCell("R_4", item.outputVoltage.value.toStringAsFixed(2), isEditable,
                      suffix: ' V'),
                  editableCell("R_5", item.outputCurrent.value.toStringAsFixed(2), isEditable,
                      suffix: ' A'),
                  editableCell("R_6", item.totalOutputPower.value.toStringAsFixed(2), isEditable,
                      suffix: ' kW'),
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
                        items: Judgement.values.map((value) {
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
                ],
              );
            }

            return TableWrapper(
              title: context.tr('input_output_characteristics'),
              content: StyledDataTable(
                dataRowMinHeight: 50,
                dataRowMaxHeight: 80,
                columns: leftHeaderColumns,
                rows: [
                  if (lRow != null) lRow,
                  headerRow2,
                  if (rRow != null) rRow,
                ],
              ),
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
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100, // 固定輸入框寬度
            child: TextField(
              controller: _getCellController(rowKey, defaultValue),
              onChanged: (newValue) {
                setState(() {
                  _cellInputs[rowKey] = newValue;
                  int? index;

                  // 處理 R0_3、R1_4 等格式
                  final rowMatch = RegExp(r'R(\d+)_\d+').firstMatch(rowKey);
                  if (rowMatch != null) {
                    index = int.tryParse(rowMatch.group(1)!);
                  }

                  // 處理 L_3 → index = 0
                  if (rowKey.startsWith('L_')) {
                    index = 0;
                  }

                  // 處理 R_3 → index = 1
                  if (rowKey.startsWith('R_')) {
                    index = 1;
                  }
                  if (index != null &&
                      index >= 0 &&
                      index < widget.inputOutputCharacteristics.inputOutputCharacteristicsSide.length){
                    final side = widget.inputOutputCharacteristics.inputOutputCharacteristicsSide[index];
                    if (rowKey.endsWith('_3')) {
                      final parsed = double.tryParse(newValue);
                      if (parsed != null) side.totalInputPower.value = parsed;
                    }
                    if (rowKey.endsWith('_4')) {
                      final parsed = double.tryParse(newValue);
                      if (parsed != null) side.outputVoltage.value = parsed;
                    }
                    if (rowKey.endsWith('_5')) {
                      final parsed = double.tryParse(newValue);
                      if (parsed != null) side.outputCurrent.value = parsed;
                    }
                    if (rowKey.endsWith('_6')) {
                      final parsed = double.tryParse(newValue);
                      if (parsed != null) side.totalOutputPower.value = parsed;
                    }
                  }
                });
              },
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                border: const OutlineInputBorder(),
                suffixText: null, // 不用 suffixText
              ),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),

          if (suffix.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                suffix.trim(),
                //style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

}
