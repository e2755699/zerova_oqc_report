import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';

class SoftwareVersionTable extends StatefulWidget {
  final SoftwareVersion data;

  const SoftwareVersionTable(this.data, {super.key});

  @override
  State<SoftwareVersionTable> createState() => _SoftwareVersionTableState();
}

class _SoftwareVersionTableState extends State<SoftwareVersionTable> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.data.versions
        .map((v) => TextEditingController(text: v.value))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
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

            final dataTable = StyledDataTable(
              columns: [
                OqcTableStyle.getDataColumn('No.'),
                OqcTableStyle.getDataColumn('Item'),
                OqcTableStyle.getDataColumn('Version'),
              ],
              rows: List.generate(widget.data.versions.length, (index) {
                final version = widget.data.versions[index];

                return DataRow(cells: [
                  OqcTableStyle.getDataCell((index + 1).toString()),
                  OqcTableStyle.getDataCell(version.name),
                  DataCell(
                    isEditable
                        ? TextFormField(
                      controller: _controllers[index],
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        border: OutlineInputBorder(),
                        //hintText: 'Enter version',
                      ),
                      onChanged: (val) {
                        setState(() {
                          widget.data.versions[index].value = val;
                        });
                      },
                    )
                        : OqcTableStyle
                        .getDataCell(widget.data.versions[index].value)
                        .child,
                  ),
                ]);
              }),
            );

            return TableWrapper(
              title: context.tr('software_version'),
              content: dataTable,
            );
          },
        );
      },
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            border: pw.TableBorder.all(),
            headers: ['No.', 'Item', 'Version'],
            data: List.generate(
              widget.data.versions.length,
                  (index) => [
                (index + 1).toString(),
                widget.data.versions[index].name,
                widget.data.versions[index].value,
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
