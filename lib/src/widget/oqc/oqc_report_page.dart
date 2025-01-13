import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/appearance_structure_inspection_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/basic_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/input_output_characteristics_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/package_list_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/protection_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/software_version.dart';

class OqcReportPage extends StatelessWidget {
  const OqcReportPage({
    super.key,
    required this.softwareVersion,
    required this.testFunction,
    required this.inputOutputCharacteristics,
    required this.protectionTestResults,
  });

  final SoftwareVersion? softwareVersion;
  final AppearanceStructureInspectionFunctionResult? testFunction;
  final InputOutputCharacteristics? inputOutputCharacteristics;
  final ProtectionFunctionTestResult? protectionTestResults;

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (softwareVersion != null) SoftwareVersionTable(softwareVersion!),
            if (testFunction != null)
              AppearanceStructureInspectionTable(testFunction!),
            if (inputOutputCharacteristics != null)
              InputOutputCharacteristicsTable(inputOutputCharacteristics!),
            if (inputOutputCharacteristics != null)
              BasicFunctionTestTable(
                  inputOutputCharacteristics!.baseFunctionTestResult),
            if (protectionTestResults != null)
              ProtectionFunctionTestTable(
                protectionTestResults!,
              ),
            PackageListTable(PackageListResult()),
          ],
        ),
        Positioned(
          top: 0,
          right: 16,
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
      ],
    );
  }
}
