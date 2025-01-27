import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
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
import 'package:zerova_oqc_report/src/report/pdf_generator.dart';
import 'package:zerova_oqc_report/src/widget/common/custom_app_bar.dart';

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

  final SharePointUploader _uploader = SharePointUploader();

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

  Future<void> _generateAndUploadPdf() async {
    try {
      // 生成 PDF
      final pdf = await PdfGenerator.generateOqcReport(
        modelName: 'T2437A011A0',
        serialNumber: 'SN8765432',
        pic: _picController.text,
        date: _dateController.text,
        psuSerialNumbers: widget.psuSerialNumbers,
        softwareVersion: widget.softwareVersion,
        testFunction: widget.testFunction,
        inputOutputCharacteristics: widget.inputOutputCharacteristics,
        protectionTestResults: widget.protectionTestResults,
        packageListResult: widget.packageListResult,
      );

      // 獲取用戶的 Pictures/OQC report 目錄
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      if (userProfile.isEmpty) {
        throw Exception('無法獲取用戶目錄');
      }

      final pdfPath = path.join(userProfile, 'Pictures', 'OQC report',
          'oqc_report_${DateTime.now().millisecondsSinceEpoch}.pdf');

      // 保存 PDF 文件
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      // 上傳到 SharePoint
      await _uploader.startAuthorization();

      // 顯示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('報告已生成並上傳')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錯誤：$e')),
        );
      }
    }
  }

  pw.Widget _buildPsuSerialNumbersTable(Psuserialnumber data) {
    return pw.Table(
        // ... table implementation ...
        );
  }

  // ... implement other table builders ...

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return Scaffold(
      appBar: CustomAppBar(
        leading: FittedBox(
          fit: BoxFit.cover,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => context.pop(),
          ),
        ),
        title: context.tr('oqc_report'),
        titleStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 60,
          fontWeight: FontWeight.w700,
          height: 1.2,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateAndUploadPdf,
        icon: const Icon(Icons.upload_file),
        label: const Text('Submit'),
        backgroundColor: const Color(0xFFF8F9FD),  // 使用 #f8f9fd 顏色
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0, bottom: 80.0),
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
                              'SN8765432', // 這裡可以放入實際的 SN
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
                    BasicFunctionTestTable(widget
                        .inputOutputCharacteristics!.baseFunctionTestResult),
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
                              width: 100, // 固定標籤寬度
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 100, // 固定標籤寬度
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
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
        ],
      ),
    );
  }

  Container buildLanguageDropdownButton(
      BuildContext context, Locale currentLocale) {
    return Container(
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
    );
  }
}
