import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/appearance_structure_inspection_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/basic_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/input_output_characteristics_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/package_list_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/protection_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/psu_serial_numbers_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/software_version.dart';

class OqcReportPage extends StatefulWidget {
  const OqcReportPage({
    super.key,
    required this.softwareVersion,
    required this.testFunction,
    required this.inputOutputCharacteristics,
    required this.protectionTestResults,
    this.psuSerialNumbers,
  });

  final SoftwareVersion? softwareVersion;
  final AppearanceStructureInspectionFunctionResult? testFunction;
  final InputOutputCharacteristics? inputOutputCharacteristics;
  final ProtectionFunctionTestResult? protectionTestResults;
  final Psuserialnumber? psuSerialNumbers;

  @override
  State<OqcReportPage> createState() => _OqcReportPageState();
}

class _OqcReportPageState extends State<OqcReportPage> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('OQC Report'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.psuSerialNumbers != null)
                    PsuSerialNumbersTable(widget.psuSerialNumbers!),
                  if (widget.softwareVersion != null)
                    SoftwareVersionTable(widget.softwareVersion!),
                  if (widget.testFunction != null)
                    AppearanceStructureInspectionTable(widget.testFunction!),
                  if (widget.inputOutputCharacteristics != null)
                    InputOutputCharacteristicsTable(
                        widget.inputOutputCharacteristics!),
                  if (widget.inputOutputCharacteristics != null)
                    BasicFunctionTestTable(
                        widget.inputOutputCharacteristics!.baseFunctionTestResult),
                  if (widget.protectionTestResults != null)
                    ProtectionFunctionTestTable(
                      widget.protectionTestResults!,
                    ),
                  PackageListTable(PackageListResult()),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButton<Locale>(
                value: currentLocale,
                icon: const Icon(Icons.language),
                underline: Container(),
                elevation: 4,
                items: context.supportedLocales.map((locale) {
                  String label = '';
                  switch (locale.languageCode) {
                    case 'en':
                      label = 'English';
                      break;
                    case 'zh':
                      label = '繁體中文';
                      break;
                    case 'vi':
                      label = 'Tiếng Việt';
                      break;
                    case 'ja':
                      label = '日本語';
                      break;
                    default:
                      label = locale.languageCode;
                  }
                  return DropdownMenuItem(
                    value: locale,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (Locale? locale) {
                  if (locale != null) {
                    context.setLocale(locale);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
