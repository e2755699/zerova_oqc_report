import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/appearance_structure_inspection_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/attachment_table.dart';
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
    required this.psuSerialNumbers,
    required this.packageListResult,
  });

  final SoftwareVersion? softwareVersion;
  final AppearanceStructureInspectionFunctionResult? testFunction;
  final InputOutputCharacteristics? inputOutputCharacteristics;
  final ProtectionFunctionTestResult? protectionTestResults;
  final Psuserialnumber? psuSerialNumbers;
  final PackageListResult? packageListResult;

  @override
  State<OqcReportPage> createState() => _OqcReportPageState();
}

class _OqcReportPageState extends State<OqcReportPage> {
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 設定預設日期為今天
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _picController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

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
                  StyledCard(
                    title: 'Basic Information',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Model Name : ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBlueColor,
                              ),
                            ),
                            const Text(
                              'T2437A011A0',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'SN : ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBlueColor,
                              ),
                            ),
                            const Text(
                              'SN8765432',  // 這裡可以放入實際的 SN
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  if (widget.packageListResult != null)
                    PackageListTable(widget.packageListResult!),
                  const AttachmentTable(),
                  StyledCard(
                    title: 'Signature',
                    content: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 100,  // 固定標籤寬度
                              child: const Text(
                                'PIC : ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlueColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _picController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 100,  // 固定標籤寬度
                              child: const Text(
                                'Date : ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlueColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
