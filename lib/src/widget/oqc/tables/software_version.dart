import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/oqc_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/widget/common/table_failorpass.dart';

class SoftwareVersionTable extends StatefulWidget {
  final SoftwareVersion data;

  const SoftwareVersionTable(this.data, {super.key});

  @override
  State<SoftwareVersionTable> createState() => _SoftwareVersionTableState();
}

class _SoftwareVersionTableState extends State<SoftwareVersionTable> {
  late List<TextEditingController> _controllers;

  void validate() {
    print('🔍 開始軟體版本表自動判斷:');

    // 檢查每個版本項目
    int validCount = 0;
    int totalCount = widget.data.versions.length;

    for (final version in widget.data.versions) {
      final isEmpty = version.value.trim().isEmpty;
      final isValid = !isEmpty;

      if (isValid) validCount++;

      print(
          '  📊 ${version.name}: "${version.value}" -> ${isValid ? "✅ PASS" : "❌ FAIL"}${isEmpty ? " (空值)" : ""}');
    }

    // 🔒 強制邏輯：所有版本都必須填寫，整體才能PASS
    final bool allItemsPass = (validCount == totalCount);
    final bool noEmptyFields =
        widget.data.versions.every((v) => v.value.trim().isNotEmpty);
    final bool finalCheck = allItemsPass && noEmptyFields;

    print(
        '  📈 通過項目數: $validCount/$totalCount，最終判斷: ${finalCheck ? "✅ PASS" : "❌ FAIL"}');

    // 🔒 強制檢查：如果是PASS但validCount < totalCount，強制設為FAIL
    if (finalCheck && validCount < totalCount) {
      print(
          '🚨 發現邏輯錯誤！強制修正為FAIL (validCount: $validCount, totalCount: $totalCount)');
      setState(() {
        swVerPassOrFail = false;
        GlobalJudgementMonitor.updateTestResult('swVer', false);
      });
      return;
    }

    // 🔒 強制檢查：如果有空值但整體為PASS，強制設為FAIL
    if (finalCheck && !noEmptyFields) {
      print('🚨 發現邏輯錯誤！有項目FAIL但整體為PASS，強制修正為FAIL');
      setState(() {
        swVerPassOrFail = false;
        GlobalJudgementMonitor.updateTestResult('swVer', false);
      });
      return;
    }

    setState(() {
      swVerPassOrFail = finalCheck;
      GlobalJudgementMonitor.updateTestResult('swVer', finalCheck);
    });
    print('swVerPassOrFail = $swVerPassOrFail');
  }

  @override
  void initState() {
    super.initState();
    _controllers = widget.data.versions
        .map((v) => TextEditingController(text: v.value))
        .toList();
    validate();
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
                        ? OqcTextField(
                            controller: _controllers[index],
                            onChanged: (val) {
                              setState(() {
                                widget.data.versions[index].value = val;
                              });
                              validate();
                            },
                          )
                        : OqcTableStyle.getDataCell(
                                widget.data.versions[index].value)
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
