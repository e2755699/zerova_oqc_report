import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';

class PsuSerialNumbersTable extends StatefulWidget {
  final Psuserialnumber data;

  const PsuSerialNumbersTable(this.data, {super.key});

  @override
  State<PsuSerialNumbersTable> createState() => _PsuSerialNumbersTableState();
}

class _PsuSerialNumbersTableState extends State<PsuSerialNumbersTable> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.data.psuSN
        .map((v) => TextEditingController(text: v.value))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
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
                          Text(
                            'S/N',
                            style: TableTextStyle.headerStyle(),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'Spec : 12',
                            style: TableTextStyle.headerStyle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                rows: List.generate(
                  widget.data.psuSN.length,
                      (index) => DataRow(
                    cells: [
                      OqcTableStyle.getDataCell((index + 1).toString()),
                      DataCell(
                        isEditable
                            ? TextFormField(
                          controller: _controllers[index],
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setState(() {
                              widget.data.psuSN[index].value = val;
                            });
                          },
                        )
                            : OqcTableStyle
                            .getDataCell(widget.data.psuSN[index].value)
                            .child,
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
