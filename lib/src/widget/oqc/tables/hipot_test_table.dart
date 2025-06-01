import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/widget/common/table_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/widget/common/oqc_text_field.dart';
import 'package:zerova_oqc_report/src/widget/common/judgement_dropdown.dart';

class HiPotTestTable extends StatefulWidget {
  final ProtectionFunctionTestResult data;

  const HiPotTestTable(this.data, {super.key});

  @override
  State<HiPotTestTable> createState() => _HiPotTestTableState();
}

class _HiPotTestTableState extends State<HiPotTestTable> with TableHelper {
  late ProtectionFunctionTestResult data;
  late TextEditingController insulationSpecController;
  late TextEditingController leakageSpecController;

  void someFunction() {
    if (globalHipotTestSpec != null) {
      print(globalHipotTestSpec!.insulationimpedancespec);
      print(globalHipotTestSpec!.leakagecurrentspec);

    } else {
      print('資料還沒載入');
    }
  }
  double _defaultIfEmptyDouble(double? value, double defaultValue) {
    return (value == null || value.isNaN) ? defaultValue : value;
  }

  Map<int, double> get _defaultSpec {
    final spec = globalHipotTestSpec;
    return {
      1: _defaultIfEmptyDouble(spec?.insulationimpedancespec, 10),
      2: _defaultIfEmptyDouble(spec?.leakagecurrentspec, 10),
    };
  }

  void initializeGlobalSpec() {
    globalHipotTestSpec = HipotTestSpec(
      insulationimpedancespec: _defaultSpec[1] ?? 10,
      leakagecurrentspec: _defaultSpec[2] ?? 10,
    );
  }

  @override
  void initState() {
    super.initState();
    initializeGlobalSpec();

    insulationSpecController = TextEditingController(
      text: globalHipotTestSpec?.insulationimpedancespec?.toStringAsFixed(0) ?? '10',
    );
    leakageSpecController = TextEditingController(
      text: globalHipotTestSpec?.leakagecurrentspec?.toStringAsFixed(0) ?? '10',
    );

    data = widget.data;
    data.hiPotTestResult.insulationImpedanceTest.updateStoredJudgement();
    data.hiPotTestResult.insulationVoltageTest.updateStoredJudgement();
  }

  @override
  void dispose() {
    insulationSpecController.dispose();
    leakageSpecController.dispose();
    super.dispose();
  }

  Widget _buildInsulationTestingRecord() {
    return ValueListenableBuilder<int>(
        valueListenable: globalEditModeNotifier,
        builder: (context, editMode, _) {
      return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable = editMode == 1 && (permission == 1 || permission == 2);
            final isHeaderEditable = editMode == 1 && permission == 1;
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: isHeaderEditable
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Insulation impedance > ',
                  style: TableTextStyle.contentStyle(),
                ),
                SizedBox(
                  width: 60,
                  height: 30,
                  child: TextField(
                    controller: insulationSpecController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TableTextStyle.contentStyle(),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        globalHipotTestSpec = globalHipotTestSpec!.copyWith(insulationimpedancespec: parsed);
                      }
                    },
                  ),
                ),
                Text(
                  ' MΩ',
                  style: TableTextStyle.contentStyle(),
                ),
              ],
            )
                : Text(
              'Insulation impedance > ${globalHipotTestSpec?.insulationimpedancespec?.toStringAsFixed(2) ?? '10'} MΩ',
              style: TableTextStyle.contentStyle(),
              textAlign: TextAlign.center,
            ),
          ),
          Table(
            border: TableBorder.all(color: AppColors.lightBlueColor),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  // Left Plug
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Left Plug:',
                          style: TableTextStyle.contentStyle().copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        isEditable
                            ? OqcTextField(
                                hintText: 'Input/Output (MΩ)',
                                controller: TextEditingController(
                                  text: data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputOutput.value.toStringAsFixed(2),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputOutput.value = parsed;
                                  }
                                },
                              )
                            : Text(
                                'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                                style: TableTextStyle.contentStyle(),
                                textAlign: TextAlign.center,
                              ),
                        const SizedBox(height: 8),
                        isEditable
                            ? OqcTextField(
                                hintText: 'Input/Ground (MΩ)',
                                controller: TextEditingController(
                                  text: data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputGround.value.toStringAsFixed(2),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputGround.value = parsed;
                                  }
                                },
                              )
                            : Text(
                                'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                                style: TableTextStyle.contentStyle(),
                                textAlign: TextAlign.center,
                              ),
                        const SizedBox(height: 8),
                        isEditable
                            ? OqcTextField(
                                hintText: 'Output/Ground (MΩ)',
                                controller: TextEditingController(
                                  text: data.hiPotTestResult.insulationImpedanceTest.leftInsulationOutputGround.value.toStringAsFixed(2),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    data.hiPotTestResult.insulationImpedanceTest.leftInsulationOutputGround.value = parsed;
                                  }
                                },
                              )
                            : Text(
                                'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                                style: TableTextStyle.contentStyle(),
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                  ),

                  // Right Plug
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Right Plug:',
                          style: TableTextStyle.contentStyle().copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        isEditable
                            ? OqcTextField(
                                hintText: 'Input/Output (MΩ)',
                                controller: TextEditingController(
                                  text: data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputOutput.value.toStringAsFixed(2),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputOutput.value = parsed;
                                  }
                                },
                              )
                            : Text(
                                'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                                style: TableTextStyle.contentStyle(),
                                textAlign: TextAlign.center,
                              ),
                        const SizedBox(height: 8),
                        isEditable
                            ? OqcTextField(
                                hintText: 'Input/Ground (MΩ)',
                                controller: TextEditingController(
                                  text: data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputGround.value.toStringAsFixed(2),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputGround.value = parsed;
                                  }
                                },
                              )
                            : Text(
                                'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                                style: TableTextStyle.contentStyle(),
                                textAlign: TextAlign.center,
                              ),
                        const SizedBox(height: 8),
                        isEditable
                            ? OqcTextField(
                                hintText: 'Output/Ground (MΩ)',
                                controller: TextEditingController(
                                  text: data.hiPotTestResult.insulationImpedanceTest.rightInsulationOutputGround.value.toStringAsFixed(2),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    data.hiPotTestResult.insulationImpedanceTest.rightInsulationOutputGround.value = parsed;
                                  }
                                },
                              )
                            : Text(
                                'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                                style: TableTextStyle.contentStyle(),
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                  ),
                ],
              )


            ],
          ),
        ],
      ),
    );
          },
      );
        },
    );
  }

  Widget _buildLeakageTestingRecord() {
    return ValueListenableBuilder<int>(
        valueListenable: globalEditModeNotifier,
        builder: (context, editMode, _) {
      return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable = editMode == 1 && (permission == 1 || permission == 2);
            final isHeaderEditable = editMode == 1 && permission == 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: isHeaderEditable
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Leakage current < ',
                style: TableTextStyle.contentStyle().copyWith(color: Colors.red),
              ),
              SizedBox(
                width: 60,
                height: 30,
                child: TextField(
                  controller: leakageSpecController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TableTextStyle.contentStyle().copyWith(color: Colors.red),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      globalHipotTestSpec = globalHipotTestSpec!.copyWith(leakagecurrentspec: parsed);
                    }
                  },
                ),
              ),
              Text(
                ' mA',
                style: TableTextStyle.contentStyle().copyWith(color: Colors.red),
              ),
            ],
          )
              : Text(
            'Leakage current < ${globalHipotTestSpec?.leakagecurrentspec?.toStringAsFixed(2) ?? '10'} mA',
            style: TableTextStyle.contentStyle().copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),

        Table(
          border: TableBorder.all(color: AppColors.lightBlueColor),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                // Left Plug
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Left Plug:',
                        style: TableTextStyle.contentStyle().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      isEditable
                          ? OqcTextField(
                              hintText: 'Input/Output (mA)',
                              controller: TextEditingController(
                                text: data.hiPotTestResult.insulationVoltageTest.leftInsulationInputOutput.value.toStringAsFixed(2),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) {
                                  data.hiPotTestResult.insulationVoltageTest.leftInsulationInputOutput.value = parsed;
                                }
                              },
                            )
                          : Text(
                              'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputOutput.value.toStringAsFixed(2)} mA',
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 8),
                      isEditable
                          ? OqcTextField(
                              hintText: 'Input/Ground (mA)',
                              controller: TextEditingController(
                                text: data.hiPotTestResult.insulationVoltageTest.leftInsulationInputGround.value.toStringAsFixed(2),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) {
                                  data.hiPotTestResult.insulationVoltageTest.leftInsulationInputGround.value = parsed;
                                }
                              },
                            )
                          : Text(
                              'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputGround.value.toStringAsFixed(2)} mA',
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 8),
                      isEditable
                          ? OqcTextField(
                              hintText: 'Output/Ground (mA)',
                              controller: TextEditingController(
                                text: data.hiPotTestResult.insulationVoltageTest.leftInsulationOutputGround.value.toStringAsFixed(2),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) {
                                  data.hiPotTestResult.insulationVoltageTest.leftInsulationOutputGround.value = parsed;
                                }
                              },
                            )
                          : Text(
                              'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationOutputGround.value.toStringAsFixed(2)} mA',
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),

                // Right Plug
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Right Plug:',
                        style: TableTextStyle.contentStyle().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      isEditable
                          ? OqcTextField(
                              hintText: 'Input/Output (mA)',
                              controller: TextEditingController(
                                text: data.hiPotTestResult.insulationVoltageTest.rightInsulationInputOutput.value.toStringAsFixed(2),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) {
                                  data.hiPotTestResult.insulationVoltageTest.rightInsulationInputOutput.value = parsed;
                                }
                              },
                            )
                          : Text(
                              'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputOutput.value.toStringAsFixed(2)} mA',
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 8),
                      isEditable
                          ? OqcTextField(
                              hintText: 'Input/Ground (mA)',
                              controller: TextEditingController(
                                text: data.hiPotTestResult.insulationVoltageTest.rightInsulationInputGround.value.toStringAsFixed(2),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) {
                                  data.hiPotTestResult.insulationVoltageTest.rightInsulationInputGround.value = parsed;
                                }
                              },
                            )
                          : Text(
                              'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputGround.value.toStringAsFixed(2)} mA',
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 8),
                      isEditable
                          ? OqcTextField(
                              hintText: 'Output/Ground (mA)',
                              controller: TextEditingController(
                                text: data.hiPotTestResult.insulationVoltageTest.rightInsulationOutputGround.value.toStringAsFixed(2),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) {
                                  data.hiPotTestResult.insulationVoltageTest.rightInsulationOutputGround.value = parsed;
                                }
                              },
                            )
                          : Text(
                              'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationOutputGround.value.toStringAsFixed(2)} mA',
                              style: TableTextStyle.contentStyle(),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
          },
      );
        },
    );
  }


  @override
  Widget build(BuildContext context) {
    // 先更新 storedJudgement

    return ValueListenableBuilder<int>(
      valueListenable: globalEditModeNotifier,
      builder: (context, editMode, _) {
        return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable = editMode == 1 && (permission == 1 || permission == 2);
            final isHeaderEditable = editMode == 1 && permission == 1;

            return TableWrapper(
              title: context.tr('hipot_test'),
              content: StyledDataTable(
                dataRowMinHeight: 200,
                dataRowMaxHeight: 230,
                columns: [
                  OqcTableStyle.getDataColumn('No.'),
                  OqcTableStyle.getDataColumn('Test Items'),
                  OqcTableStyle.getDataColumn('Testing Record'),
                  OqcTableStyle.getDataColumn('Judgement'),
                ],
                rows: [
                  DataRow(cells: [
                    OqcTableStyle.getDataCell('1'),
                    OqcTableStyle.getDataCell(
                      'Insulation Impedance Test.\n\nApply a DC Voltage:\na) Between each circuit.\nb) Between each of the independent circuits and the ground.',
                    ),
                    DataCell(_buildInsulationTestingRecord()),
                    DataCell(
                      isEditable
                          ? JudgementDropdown(
                        value: data.hiPotTestResult.insulationImpedanceTest.storedJudgement,
                        onChanged: (Judgement? newValue) {
                          if (newValue != null) {
                            setState(() {
                              data.hiPotTestResult.insulationImpedanceTest.storedJudgement = newValue;
                            });
                          }
                        },
                      )
                          : Center(
                        child: Text(
                          data.hiPotTestResult.insulationImpedanceTest.storedJudgement.name.toUpperCase(),
                          style: JudgementStyles.getTextStyle(data.hiPotTestResult.insulationImpedanceTest.storedJudgement),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ]),
                  DataRow(cells: [
                    OqcTableStyle.getDataCell('2'),
                    OqcTableStyle.getDataCell(
                      'Insulation Voltage Test.\n\nApply a DC Voltage:\na) Between each circuit.\nb) Between each of the independent circuits and the ground.',
                    ),
                    DataCell(_buildLeakageTestingRecord()),
                    DataCell(

                      isEditable
                          ? JudgementDropdown(
                        value: data.hiPotTestResult.insulationVoltageTest.storedJudgement,
                        onChanged: (Judgement? newValue) {
                          if (newValue != null) {
                            setState(() {
                              data.hiPotTestResult.insulationVoltageTest.storedJudgement = newValue;
                            });
                          }
                        },
                      )
                          : Center(
                        child: Text(
                          data.hiPotTestResult.insulationVoltageTest.storedJudgement.name.toUpperCase(),
                          style: JudgementStyles.getTextStyle(data.hiPotTestResult.insulationVoltageTest.storedJudgement),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            );
          },
        );
      },
    );
  }


}
