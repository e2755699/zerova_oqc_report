import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/text_form_field_style.dart';
import 'package:zerova_oqc_report/src/widget/common/oqc_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/report/spec/psu_serial_numbers_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/widget/common/table_failorpass.dart';

class PsuSerialNumbersTable extends StatefulWidget {
  final Psuserialnumber data;

  const PsuSerialNumbersTable(this.data, {super.key});

  @override
  State<PsuSerialNumbersTable> createState() => _PsuSerialNumbersTableState();
}

class _PsuSerialNumbersTableState extends State<PsuSerialNumbersTable> {
  late List<TextEditingController> _controllers;
  late TextEditingController _headerController;

  int _defaultIfEmptyInt(int? value, int defaultValue) {
    return (value == null) ? defaultValue : value;
  }

  Map<int, int> get _defaultSpecValues {
    final spec = globalPsuSerialNumSpec;
    return {
      1: _defaultIfEmptyInt(spec?.qty, 12),
    };
  }

  void initializeGlobalSpec() {
    final specValues = _defaultSpecValues;

    globalPsuSerialNumSpec = PsuSerialNumSpec(
      qty: specValues[1] ?? 12,
    );
  }

  void updateQtyAndControllers(int newQty) {
    globalPsuSerialNumSpec = globalPsuSerialNumSpec?.copyWith(qty: newQty);

    final currentText = _headerController.text;
    final newText = newQty.toString();

    // 避免輸入時全選覆蓋問題，設定游標位置在文字尾
    if (currentText != newText) {
      _headerController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    final oldLength = _controllers.length;
    if (newQty > oldLength) {
      // 新增 controllers，初始值取自 data.psuSN (有資料就帶入，無資料就空字串)
      _controllers.addAll(List.generate(
        newQty - oldLength,
        (i) {
          final index = oldLength + i;
          return TextEditingController(
            text: index < widget.data.psuSN.length
                ? widget.data.psuSN[index].value
                : '',
          );
        },
      ));
    } else if (newQty < oldLength) {
      // 減少時釋放多餘 controllers
      for (int i = oldLength - 1; i >= newQty; i--) {
        _controllers[i].dispose();
        _controllers.removeAt(i);
      }
    }
  }

  void validate() {
    bool hasError = false;

    final expectedQty = globalPsuSerialNumSpec?.qty ?? 0;

    // 防止 psuSN 長度不足
    if (widget.data.psuSN.length < expectedQty) {
      print('⚠️ widget.data.psuSN 數量不足，無法進行完整驗證');
      hasError = true;
    }

    for (int i = 0; i < expectedQty; i++) {
      if (i >= widget.data.psuSN.length) {
        hasError = true;  // 沒資料也算錯
        break;
      }

      final sn = widget.data.psuSN[i];
      if (sn.value.trim().isEmpty) {
        hasError = true;  // 有空值就是錯誤
        break;
      }
    }

    psuSNPassOrFail = !hasError;
  }


  @override
  void initState() {
    super.initState();
    initializeGlobalSpec();

    final qty = globalPsuSerialNumSpec?.qty ?? 12;

    _controllers = List.generate(
      qty,
      (i) => TextEditingController(
        text: i < widget.data.psuSN.length ? widget.data.psuSN[i].value : '',
      ),
    );

    _headerController = TextEditingController(text: qty.toString());

    validate();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _headerController.dispose();
    super.dispose();
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
                editMode == 1 && (permission == 1 || permission == 2);
            //final isHeaderEditable = editMode == 1 && permission == 1;
            final isHeaderEditable = false;

            final qty = globalPsuSerialNumSpec?.qty ?? 12;

            return TableWrapper(
              title: context.tr('psu_sn'),
              content: StyledDataTable(
                columns: [
                  OqcTableStyle.getDataColumn('No.'),
                  DataColumn(
                    label: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('S/N', style: TableTextStyle.headerStyle()),
                          const SizedBox(width: 20),
                          if (isHeaderEditable) ...[
                            Text("Q'ty : ",
                                style: TableTextStyle.headerStyle()),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 60,
                              height: 28,
                              child: TextFormField(
                                controller: _headerController,
                                style: TableTextStyle.headerStyle(),
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 4),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  final parsed = int.tryParse(val);
                                  if (parsed != null && parsed >= 0) {
                                    setState(() {
                                      updateQtyAndControllers(parsed);
                                    });
                                  }
                                },
                              ),
                            ),
                          ] else
                            Text("Q'ty : $qty",
                                style: TableTextStyle.headerStyle()),
                        ],
                      ),
                    ),
                  ),
                ],
                rows: List.generate(qty, (index) {
                  final controller = _controllers[index];

                  return DataRow(
                    cells: [
                      OqcTableStyle.getDataCell((index + 1).toString()),
                      DataCell(
                        isEditable
                            ? OqcTextField(
                                controller: _controllers[index],
                                onChanged: (val) {
                                    if (index < widget.data.psuSN.length) {
                                      widget.data.psuSN[index].value = val.trim();
                                    } else {
                                      // 先補滿到 index
                                      while (
                                          widget.data.psuSN.length <= index) {
                                        widget.data.psuSN.add(
                                          SerialNumber(
                                            spec: 12,
                                            value: '', // 空值先填，等會下面會被填入 val
                                            key: "PSU SN",
                                            name: "PSU",
                                          ),
                                        );
                                      }
                                      widget.data.psuSN[index].value = val.trim();
                                    }
                                    validate();
                                })
                            : OqcTableStyle.getDataCell(
                                index < widget.data.psuSN.length
                                    ? widget.data.psuSN[index].value
                                    : controller.text,
                              ).child,
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }
}
