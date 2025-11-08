import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/basic_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/utils/image_utils.dart';
import 'package:zerova_oqc_report/src/report/spec/psu_serial_numbers_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';

class PdfGenerator {
  // Common constants for consistent styling
  static const double _defaultFontSize = 12.0;
  static const double _titleFontSize = 16.0;
  static const double _coverTitleFontSize = 24.0;
  static const double _coverSubtitleFontSize = 20.0;
  static const double _coverModelFontSize = 18.0;
  static const double _smallFontSize = 8.0;

  // Helper method to create consistently styled table cells
  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    pw.TextAlign textAlign = pw.TextAlign.center,
    int? maxLines,
    double? fontSize,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: fontSize ?? _defaultFontSize,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
        ),
      ),
    );
  }

  // Simple helper to replace pw.Padding with consistent centering
  static pw.Widget _buildCenteredTableCell(
    String text,
    pw.Font font, {
    pw.TextAlign textAlign = pw.TextAlign.center,
    int? maxLines,
    double? fontSize,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: fontSize ?? _defaultFontSize,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );
  }

  static Future<pw.Document> generateOqcReport({
    required String modelName,
    required String serialNumber,
    required String pic,
    required String date,
    required BuildContext context,
    Psuserialnumber? psuSerialNumbers,
    SoftwareVersion? softwareVersion,
    AppearanceStructureInspectionFunctionResult? testFunction,
    InputOutputCharacteristics? inputOutputCharacteristics,
    ProtectionFunctionTestResult? protectionTestResults,
    PackageListResult? packageListResult,
    InputOutputCharacteristicsSpec? inputOutputSpec, // 新增參數
  }) async {
    await context.setLocale(context.locale);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansTCRegular();

    // Load images first
    final packageListImages = packageListResult != null
        ? await _loadPackageListImages(serialNumber)
        : List<pw.Widget>.empty();
    final attachmentImages = await _loadAttachmentImages(serialNumber);

    // Load logo
    final logoImage = await _loadLogoImage();

    // Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          children: [
            // Logo at the top
            if (logoImage != null) ...[
              pw.SizedBox(height: 40),
              pw.Container(
                height: 80,
                child: pw.Image(logoImage, fit: pw.BoxFit.contain),
              ),
            ] else
              pw.SizedBox(height: 60),

            // Center content
            pw.Expanded(
              child: pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'ZEROVA TECHNOLOGIES Co., Ltd.',
                      style: pw.TextStyle(
                        fontSize: _coverTitleFontSize,
                        fontWeight: pw.FontWeight.bold,
                        font: font,
                      ),
                    ),
                    pw.SizedBox(height: 60),
                    pw.Text(
                      'Electric Vehicle DC Charger\nOutgoing Quality Control Report',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: _coverSubtitleFontSize,
                        fontWeight: pw.FontWeight.bold,
                        font: font,
                      ),
                    ),
                    pw.SizedBox(height: 120),
                    pw.Text(
                      'Model Name: $modelName',
                      style: pw.TextStyle(
                        fontSize: _defaultFontSize,
                        font: font,
                      ),
                    ),
                    pw.Text(
                      'SN: $serialNumber',
                      style: pw.TextStyle(
                        fontSize: _defaultFontSize,
                        font: font,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (psuSerialNumbers != null && psuSerialNumbers.psuSN.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildPsuSerialNumbersTable(psuSerialNumbers, font),
          ],
          footer: (context) => pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: _smallFontSize,
                font: font,
              ),
            ),
          ),
        ),
      );
    }

    if (softwareVersion != null || softwareVersion!.versions.isNotEmpty) {
      addPage(pdf, _buildSoftwareVersionTable(softwareVersion, font), font);
    }
    addPage(pdf, _buildAppearanceInspectionTable(testFunction!, font), font);
    addPage(
        pdf,
        pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          _buildInputOutputCharacteristicsTable(
              inputOutputCharacteristics!, font, inputOutputSpec),
          pw.SizedBox(height: 80),
          _buildBasicFunctionTestTable(
              inputOutputCharacteristics.basicFunctionTestResult, font)
        ]),
        font);
    addPage(pdf,
        _buildProtectionFunctionTestTable(protectionTestResults!, font), font);
    addPage(
      pdf,
      _buildHiPotTestTable(protectionTestResults, font),
      font,
    );
    pdf.addPage(pw.MultiPage(
      maxPages: 20,
      build: (context) =>
          [_buildPackageListTable(packageListResult!, font, packageListImages)],
      pageFormat: PdfPageFormat.a4,
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: pw.TextStyle(
            fontSize: _smallFontSize,
            font: font,
          ),
        ),
      ),
    ));
    pdf.addPage(pw.MultiPage(
      maxPages: 20,
      build: (context) => [
        _buildAttachmentTable(font, attachmentImages),
        pw.SizedBox(height: 80),
        _buildSignatureTable(pic, date, font),
      ],
      pageFormat: PdfPageFormat.a4,
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: pw.TextStyle(
            fontSize: _smallFontSize,
            font: font,
          ),
        ),
      ),
    ));

    return pdf;
  }

  static void addPage(pw.Document pdf, pw.Widget child, pw.Font font) {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Expanded(
                child: pw.Center(
                  child: child,
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text(
                  '${context.pageNumber} / ${context.pagesCount}',
                  style: pw.TextStyle(
                    fontSize: _smallFontSize,
                    font: font,
                  ),
                ),
              ),
            ],
          );
        },
        pageFormat: PdfPageFormat.a4,
      ),
    );
  }

  static pw.Widget _buildPsuSerialNumbersTable(
      Psuserialnumber data, pw.Font font) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.5), // No.
      1: const pw.FlexColumnWidth(3.0), // S/N
    };
    final totalQty = globalPsuSerialNumSpec?.qty ?? 12;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PSU S/N',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                _buildTableCell('No.', font),
                _buildTableCell("S/N  Q'ty : $totalQty", font),
              ],
            ),
          ],
        ),
        ...List.generate(totalQty, (index) {
          return pw.Table(
            columnWidths: columnWidths,
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  _buildTableCell('${index + 1}', font),
                  _buildTableCell(
                      index < data.psuSN.length ? data.psuSN[index].value : '',
                      font),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildSoftwareVersionTable(
      SoftwareVersion data, pw.Font font) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.5), // No.
      1: const pw.FlexColumnWidth(2.0), // Item
      2: const pw.FlexColumnWidth(1.5), // Version
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Software Version',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                _buildTableCell('No.', font),
                _buildTableCell('Item', font),
                _buildTableCell('Version', font),
              ],
            ),
            ...List.generate(
              data.versions.length,
              (index) => pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  _buildTableCell('${index + 1}', font),
                  _buildTableCell(data.versions[index].name, font),
                  _buildTableCell(data.versions[index].value, font),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildAppearanceInspectionTable(
      AppearanceStructureInspectionFunctionResult data, pw.Font font) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.3), // No. 縮小
      1: const pw.FlexColumnWidth(1.0), // Item 適中
      2: const pw.FlexColumnWidth(3.0), // Details 加大
      3: const pw.FlexColumnWidth(0.5), // Judgement 縮小
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Appearance & Structure Inspection',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                _buildTableCell('No.', font),
                _buildTableCell('Item', font),
                _buildTableCell('Details', font),
                _buildTableCell('Judgement', font),
              ],
            ),
            ...List.generate(
              data.testItems.length,
              (index) => pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  _buildTableCell('${index + 1}', font),
                  _buildTableCell(data.testItems[index].name, font),
                  _buildTableCell(
                    AppearanceStructureInspectionFunctionResult
                            .descriptionMapping[data.testItems[index].name] ??
                        '',
                    font,
                    textAlign: pw.TextAlign.left,
                    maxLines: 5,
                  ),
                  _buildTableCell(data.testItems[index].judgement, font),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInputOutputCharacteristicsTable(
      InputOutputCharacteristics data,
      pw.Font font,
      InputOutputCharacteristicsSpec? inputSpec) {
    // 優先使用傳入的 spec，然後是全域 spec
    final spec = inputSpec ?? globalInputOutputSpec;

    String formatSpec(num? upper, num? lower, String unit) {
      final upperStr = upper?.toStringAsFixed(0) ?? "-";
      final lowerStr = lower?.toStringAsFixed(0) ?? "-";
      return "$upperStr$unit, $lowerStr$unit";
    }

    // Get dynamic units (separate for left and right)
    final leftPinUnit = spec?.leftPinUnit ?? 'kVA';
    final leftPoutUnit = spec?.leftPoutUnit ?? 'kW';
    final rightPinUnit = spec?.rightPinUnit ?? 'kVA';
    final rightPoutUnit = spec?.rightPoutUnit ?? 'kW';

    // Header for Left Spec
    List<String> leftHeaders = [
      'Item \n Spec',
      'Pin \n ${formatSpec(spec?.leftPinUpperbound, spec?.leftPinLowerbound, leftPinUnit)}',
      'Vout \n ${formatSpec(spec?.leftVoutUpperbound, spec?.leftVoutLowerbound, 'V')}',
      'Iout \n ${formatSpec(spec?.leftIoutUpperbound, spec?.leftIoutLowerbound, 'A')}',
      'Pout \n ${formatSpec(spec?.leftPoutUpperbound, spec?.leftPoutLowerbound, leftPoutUnit)}',
      'Judgement',
    ];

    // Header for Right Spec
    List<String> rightHeaders = [
      'Item \n Spec',
      'Pin \n ${formatSpec(spec?.rightPinUpperbound, spec?.rightPinLowerbound, rightPinUnit)}',
      'Vout \n ${formatSpec(spec?.rightVoutUpperbound, spec?.rightVoutLowerbound, 'V')}',
      'Iout \n ${formatSpec(spec?.rightIoutUpperbound, spec?.rightIoutLowerbound, 'A')}',
      'Pout \n ${formatSpec(spec?.rightPoutUpperbound, spec?.rightPoutLowerbound, rightPoutUnit)}',
      'Judgement',
    ];

    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.8),
      1: const pw.FlexColumnWidth(1.0),
      2: const pw.FlexColumnWidth(1.0),
      3: const pw.FlexColumnWidth(1.0),
      4: const pw.FlexColumnWidth(1.0),
      5: const pw.FlexColumnWidth(1.2),
    };

    // 收集 table row
    final List<pw.TableRow> tableRows = [];

    // ➤ 加入 Left Header
    tableRows.add(
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: leftHeaders
            .map((header) => pw.Center(
                    child: pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
                    textAlign: pw.TextAlign.center,
                  ),
                )))
            .toList(),
      ),
    );

    // ➤ 加入 Left 資料列
    final left = data.inputOutputCharacteristicsSide.firstWhere(
      (item) => item.side.toLowerCase().contains('left'),
      orElse: () => data.inputOutputCharacteristicsSide.first,
    );
    tableRows.add(_buildDataRow(left, font, leftPinUnit, leftPoutUnit));

    // ➤ 加入 Right Header
    tableRows.add(
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: rightHeaders
            .map((header) => pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
                    textAlign: pw.TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );

    // ➤ 加入 Right 資料列
    final right = data.inputOutputCharacteristicsSide.firstWhere(
      (item) => item.side.toLowerCase().contains('right'),
      orElse: () => data.inputOutputCharacteristicsSide.last,
    );
    tableRows.add(_buildDataRow(right, font, rightPinUnit, rightPoutUnit));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Input & Output Characteristics',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: tableRows,
        ),
      ],
    );
  }

  static pw.TableRow _buildDataRow(InputOutputCharacteristicsSide item,
      pw.Font font, String pinUnit, String poutUnit) {
    return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(item.side,
              style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
              textAlign: pw.TextAlign.center),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
              "${item.totalInputPower.value.toStringAsFixed(2)} ${pinUnit}",
              style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
              textAlign: pw.TextAlign.center),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text("${item.outputVoltage.value.toStringAsFixed(2)} V",
              style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
              textAlign: pw.TextAlign.center),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text("${item.outputCurrent.value.toStringAsFixed(2)} A",
              style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
              textAlign: pw.TextAlign.center),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
              "${item.totalOutputPower.value.toStringAsFixed(2)} ${poutUnit}",
              style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
              textAlign: pw.TextAlign.center),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Center(
            child: pw.Text(item.judgement.name.toUpperCase(),
                style: pw.TextStyle(font: font, fontSize: _defaultFontSize),
                textAlign: pw.TextAlign.center),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBasicFunctionTestTable(
      BasicFunctionTestResult data, pw.Font font) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.5), // No.
      1: const pw.FlexColumnWidth(1.5), // Test Items
      2: const pw.FlexColumnWidth(2.0), // Testing Record
      3: const pw.FlexColumnWidth(1.0), // Judgement
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Basic Function Test',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Test Items',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Testing Record',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Judgement',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
              ],
            ),
            ...List.generate(
              data.testItems.length,
              (index) => pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('${index + 1}',
                        style: pw.TextStyle(
                            font: font, fontSize: _defaultFontSize),
                        textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(data.testItems[index].name,
                        style: pw.TextStyle(
                            font: font, fontSize: _defaultFontSize),
                        textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      data.testItems[index].description.replaceAll("{VALUE}",
                          data.testItems[index].value.toStringAsFixed(2)),
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.start,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        data.testItems[index].judgement.name.toUpperCase(),
                        style: pw.TextStyle(
                            font: font, fontSize: _defaultFontSize),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildProtectionFunctionTestTable(
      ProtectionFunctionTestResult data, pw.Font font) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.5), // No.
      1: const pw.FlexColumnWidth(1.0), // Test Items
      2: const pw.FlexColumnWidth(2.5), // Testing Record
      3: const pw.FlexColumnWidth(1.0), // Judgement
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Protection Function Test',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Test Items',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Testing Record',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Judgement',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
              ],
            ),
            ...List.generate(
              data.specialFunctionTestResult.testItems.length,
              (index) {
                final item = data.specialFunctionTestResult.testItems[index];
                return pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${index + 1}',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.name,
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.description,
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(
                          item.judgement.name.toUpperCase(),
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildHiPotTestTable(
      ProtectionFunctionTestResult data, pw.Font font) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.5), // No.
      1: const pw.FlexColumnWidth(1.5), // Test Items
      2: const pw.FlexColumnWidth(3.0), // Testing Record
      3: const pw.FlexColumnWidth(1.0), // Judgement
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Hi-Pot Test',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: [
            // Header Row
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Test Items',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Testing Record',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Judgement',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
              ],
            ),
            // Insulation Impedance Test Row
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('1',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Insulation Impedance Test.',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                      pw.SizedBox(height: 5),
                      pw.Text('Apply a DC Voltage:',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                      pw.Text('a) Between each circuit.',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                      pw.Text(
                          'b) Between each of the independent circuits and the ground.',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Center(
                        child: pw.Text(
                          'Insulation impedance > ${globalHipotTestSpec?.insulationimpedancespec.toStringAsFixed(2) ?? '10'} MΩ',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            verticalAlignment:
                                pw.TableCellVerticalAlignment.middle,
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Left Plug:',
                                        style: pw.TextStyle(
                                          font: font,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                  ],
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Right Plug:',
                                        style: pw.TextStyle(
                                          font: font,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text(
                        data.hiPotTestResult.insulationImpedanceTest
                            .storedJudgement.name
                            .toUpperCase(),
                        style: pw.TextStyle(
                            font: font, fontSize: _defaultFontSize),
                        textAlign: pw.TextAlign.center),
                  ),
                ),
              ],
            ),
            // Insulation Voltage Test Row
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('2',
                      style:
                          pw.TextStyle(font: font, fontSize: _defaultFontSize),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Insulation Voltage Test.',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                      pw.SizedBox(height: 5),
                      pw.Text('Apply a DC Voltage:',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                      pw.Text('a) Between each circuit.',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                      pw.Text(
                          'b) Between each of the independent circuits and the ground.',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.start),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Center(
                        child: pw.Text(
                          'Leakage current < ${globalHipotTestSpec?.leakagecurrentspec.toStringAsFixed(2) ?? '10'} mA',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            verticalAlignment:
                                pw.TableCellVerticalAlignment.middle,
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Left Plug:',
                                        style: pw.TextStyle(
                                          font: font,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputOutput.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationOutputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                  ],
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Right Plug:',
                                        style: pw.TextStyle(
                                          font: font,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputOutput.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationOutputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(
                                            font: font,
                                            fontSize: _defaultFontSize),
                                        textAlign: pw.TextAlign.center),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text(
                        data.hiPotTestResult.insulationVoltageTest
                            .storedJudgement.name
                            .toUpperCase(),
                        style: pw.TextStyle(
                            font: font, fontSize: _defaultFontSize),
                        textAlign: pw.TextAlign.center),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPackageListTable(
      PackageListResult data, pw.Font font, List<pw.Widget> images) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.5), // No.
      1: const pw.FlexColumnWidth(2.0), // Items
      2: const pw.FlexColumnWidth(0.8), // Q'ty
      3: const pw.FlexColumnWidth(0.8), // Check
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Packaging Checklist',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          columnWidths: columnWidths,
          border: pw.TableBorder.all(),
          children: [
            // 表頭
            pw.TableRow(
              children: PackageListResult.defaultHeader
                  .map((header) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          header,
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
            // 動態內容
            ...List.generate(
              data.measurements.length,
              (index) {
                final m = data.measurements[index];
                return pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${index + 1}',
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(m.itemName,
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(m.quantity,
                          style: pw.TextStyle(
                              font: font, fontSize: _defaultFontSize),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(m.isCheck.value ? '✓' : '',
                            style: pw.TextStyle(
                                font: font, fontSize: _defaultFontSize),
                            textAlign: pw.TextAlign.center),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        if (images.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          ...images,
        ],
      ],
    );
  }

  static pw.Widget _buildAttachmentTable(pw.Font font, List<pw.Widget> images) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Attachment',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        if (images.isNotEmpty) ...images,
      ],
    );
  }

  static pw.Widget _buildSignatureTable(String pic, String date, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Signature',
          style: pw.TextStyle(
            fontSize: _titleFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Column(
          children: [
            pw.Row(
              children: [
                pw.Container(
                  width: 100,
                  child: pw.Text(
                    'PIC : ',
                    style: pw.TextStyle(
                      fontSize: _defaultFontSize,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(pic,
                        style: pw.TextStyle(
                            font: font, fontSize: _defaultFontSize),
                        textAlign: pw.TextAlign.center),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                pw.Container(
                  width: 100,
                  child: pw.Text(
                    'Date : ',
                    style: pw.TextStyle(
                      fontSize: _defaultFontSize,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(date,
                        style: pw.TextStyle(
                            font: font, fontSize: _defaultFontSize),
                        textAlign: pw.TextAlign.center),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Future<String> _getPicturesPath() async {
    if (Platform.isMacOS) {
      // macOS 路徑
      return path.join(
          Platform.environment['HOME'] ?? '', 'Pictures', 'Zerova');
    } else if (Platform.isWindows) {
      // Windows 路徑
      return path.join(
          Platform.environment['USERPROFILE'] ?? '', 'Pictures', 'Zerova');
    } else {
      // 其他系統（如 Linux）
      return path.join(
          Platform.environment['HOME'] ?? '', 'Pictures', 'Zerova');
    }
  }

  static Future<List<pw.Widget>> _loadPackageListImages(String sn) async {
    try {
      final picturesPath = await _getPicturesPath();
      if (picturesPath.isEmpty) {
        return [];
      }

      final directory =
          path.join(picturesPath, 'Selected Photos', sn, 'Packaging');
      return await ImageUtils.loadAndGroupImages(directory);
    } catch (e) {
      debugPrint('Error loading package list images: $e');
      return [];
    }
  }

  static Future<List<pw.Widget>> _loadAttachmentImages(String sn) async {
    try {
      final picturesPath = await _getPicturesPath();
      if (picturesPath.isEmpty) {
        return [];
      }

      final directory =
          path.join(picturesPath, 'Selected Photos', sn, 'Attachment');
      return await ImageUtils.loadAndGroupImages(directory);
    } catch (e) {
      debugPrint('Error loading attachment images: $e');
      return [];
    }
  }

  static Future<pw.ImageProvider?> _imageFromPath(String path) async {
    return await ImageUtils.imageFromPath(path);
  }

  static Future<pw.ImageProvider?> _loadLogoImage() async {
    try {
      // Load logo from assets
      const logoPath = 'assets/logo.png';
      final logoFile = File(logoPath);

      if (await logoFile.exists()) {
        final logoBytes = await logoFile.readAsBytes();
        return pw.MemoryImage(logoBytes);
      } else {
        // Try alternative path in case of different project structure
        final logoFile2 = File('logo.png');
        if (await logoFile2.exists()) {
          final logoBytes = await logoFile2.readAsBytes();
          return pw.MemoryImage(logoBytes);
        }
      }
    } catch (e) {
      debugPrint('Error loading logo image: $e');
    }
    return null;
  }
}
