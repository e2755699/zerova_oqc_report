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
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/appearance_structure_inspection_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/attachment_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/basic_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/protection_function_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/input_output_characteristics_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/model_name_and_serial_number_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/package_list_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/hipot_test_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/psu_serial_numbers_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/signature_table.dart';
import 'package:zerova_oqc_report/src/widget/oqc/tables/software_version.dart';
import 'package:zerova_oqc_report/src/report/pdf_generator.dart';
import 'package:zerova_oqc_report/src/widget/common/custom_app_bar.dart';
import 'package:zerova_oqc_report/src/widget/common/main_layout.dart';

class OqcReportPage extends StatefulWidget {
  const OqcReportPage({
    super.key,
    required this.softwareVersion,
    required this.testFunction,
    required this.inputOutputCharacteristics,
    required this.protectionTestResults,
    required this.psuSerialNumbers,
    required this.packageListResult,
    required this.sn,
    required this.model,
  });

  final SoftwareVersion? softwareVersion;
  final AppearanceStructureInspectionFunctionResult? testFunction;
  final InputOutputCharacteristics? inputOutputCharacteristics;
  final ProtectionFunctionTestResult? protectionTestResults;
  final Psuserialnumber? psuSerialNumbers;
  final PackageListResult? packageListResult;

  final String sn;
  final String model;

  @override
  State<OqcReportPage> createState() => _OqcReportPageState();
}

class _OqcReportPageState extends State<OqcReportPage> {
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final SharePointUploader _uploader = SharePointUploader();

  @override
  void dispose() {
    _picController.dispose();
    _dateController.dispose();
    super.dispose();
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
    return MainLayout(
      title: context.tr('oqc_report'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateAndUploadPdf,
        icon: const Icon(Icons.upload_file),
        label: const Text('Submit'),
        backgroundColor: const Color(0xFFF8F9FD),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0, bottom: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModelNameAndSerialNumberTable(
                      model: widget.model, sn: widget.sn),
                  PsuSerialNumbersTable(widget.psuSerialNumbers!),
                  SoftwareVersionTable(widget.softwareVersion!),
                  AppearanceStructureInspectionTable(widget.testFunction!),
                  InputOutputCharacteristicsTable(
                      widget.inputOutputCharacteristics!),
                  BasicFunctionTestTable(widget
                      .inputOutputCharacteristics!.basicFunctionTestResult),
                  ProtectionFunctionTestTable(
                    widget.protectionTestResults!,
                  ),
                  HiPotTestTable(
                    widget.protectionTestResults!,
                  ),
                  PackageListTable(
                    widget.packageListResult!,
                    sn: widget.sn,
                  ),
                  AttachmentTable(
                    sn: widget.sn,
                  ),
                  Signature(),
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
