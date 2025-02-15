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

class PdfGenerator {
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
  }) async {
    await context.setLocale(context.locale);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansTCRegular();

    // Load images first
    final packageListImages = packageListResult != null
        ? await _loadPackageListImages(serialNumber)
        : List<pw.Widget>.empty();
    final attachmentImages = await _loadAttachmentImages(serialNumber);

    // Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'ZEROVA TECHNOLOGIES Co., Ltd.',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 60),
              pw.Text(
                'Electric Vehicle DC Charger\nOutgoing Quality Control Report',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 60),
              pw.Text(
                'DS Series',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 60),
              pw.Text(
                'Model Name: $modelName',
                style: pw.TextStyle(
                  fontSize: 16,
                  font: font,
                ),
              ),
              pw.Text(
                'SN: $serialNumber',
                style: pw.TextStyle(
                  fontSize: 16,
                  font: font,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Content Pages
    pdf.addPage(
      pw.MultiPage(
        maxPages: 60,
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // PSU S/N Table
          if (psuSerialNumbers != null) ...[
            _buildPsuSerialNumbersTable(psuSerialNumbers, font),
            pw.SizedBox(height: 60),
          ],

          // Software Version Table
          if (softwareVersion != null) ...[
            _buildSoftwareVersionTable(softwareVersion, font),
            pw.SizedBox(height: 60),
          ],

          // Appearance & Structure Inspection Table
          if (testFunction != null) ...[
            _buildAppearanceInspectionTable(testFunction, font),
            pw.SizedBox(height: 60),
          ],

          // Input & Output Characteristics Table
          if (inputOutputCharacteristics != null) ...[
            _buildInputOutputCharacteristicsTable(
                inputOutputCharacteristics, font),
            pw.SizedBox(height: 60),
          ],

          // Basic Function Test Table
          if (inputOutputCharacteristics?.basicFunctionTestResult != null) ...[
            _buildBasicFunctionTestTable(
                inputOutputCharacteristics!.basicFunctionTestResult, font),
            pw.SizedBox(height: 60),
          ],

          // Protection Function Test Table
          if (protectionTestResults != null) ...[
            _buildProtectionFunctionTestTable(protectionTestResults, font),
            pw.SizedBox(height: 60),
          ],

          // Hi-Pot Test Table
          if (protectionTestResults != null) ...[
            _buildHiPotTestTable(protectionTestResults, font),
            pw.SizedBox(height: 60),
          ],

          // Package List Table
          if (packageListResult != null) ...[
            _buildPackageListTable(packageListResult, font, packageListImages),
            pw.SizedBox(height: 60),
          ],

          // Attachment Table
          _buildAttachmentTable(font, attachmentImages),
          pw.SizedBox(height: 60),

          // Signature Table
          _buildSignatureTable(pic, date, font),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildModelNameAndSerialNumberTable(
      String modelName, String serialNumber, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Basic Information',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Model Name', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(modelName, style: pw.TextStyle(font: font)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child:
                      pw.Text('Serial Number', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(serialNumber, style: pw.TextStyle(font: font)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPsuSerialNumbersTable(
      Psuserialnumber data, pw.Font font) {
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.5), // No.
      1: const pw.FlexColumnWidth(3.0), // S/N
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PSU S/N',
          style: pw.TextStyle(
            fontSize: 16,
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
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child:
                      pw.Text("S/N  Spec : 4", style: pw.TextStyle(font: font)),
                ),
              ],
            ),
            ...List.generate(
              4,
              (index) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('${index + 1}',
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(data.psuSN[index].value,
                        style: pw.TextStyle(font: font)),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            fontSize: 16,
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
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Item', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Version', style: pw.TextStyle(font: font)),
                ),
              ],
            ),
            ...List.generate(
              data.versions.length,
              (index) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('${index + 1}',
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(data.versions[index].name,
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(data.versions[index].value,
                        style: pw.TextStyle(font: font)),
                  ),
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
            fontSize: 16,
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
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'No.',
                    style: pw.TextStyle(font: font),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Item',
                    style: pw.TextStyle(font: font),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Details',
                    style: pw.TextStyle(font: font),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Judgement',
                    style: pw.TextStyle(font: font),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
            ...List.generate(
              data.testItems.length,
              (index) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      '${index + 1}',
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      data.testItems[index].name,
                      style: pw.TextStyle(font: font, fontSize: 10),
                      textAlign: pw.TextAlign.left,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      AppearanceStructureInspectionFunctionResult
                              .descriptionMapping[data.testItems[index].name] ??
                          '',
                      style: pw.TextStyle(font: font, fontSize: 8),
                      textAlign: pw.TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      data.testItems[index].judgement,
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center,
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

  static pw.Widget _buildInputOutputCharacteristicsTable(
      InputOutputCharacteristics data, pw.Font font) {
    final headers = [
      'Item',
      'Spec',
      'Vin',
      'Iin',
      'Pin',
      'Vout',
      'Iout',
      'Pout',
      'Judgement'
    ];
    // 定义每列的相对宽度
    final columnWidths = <int, pw.FlexColumnWidth>{
      0: const pw.FlexColumnWidth(0.8), // Item
      1: const pw.FlexColumnWidth(1.2), // Spec
      2: const pw.FlexColumnWidth(1.2), // Vin
      3: const pw.FlexColumnWidth(1.2), // Iin
      4: const pw.FlexColumnWidth(1.0), // Pin
      5: const pw.FlexColumnWidth(1.0), // Vout
      6: const pw.FlexColumnWidth(1.0), // Iout
      7: const pw.FlexColumnWidth(1.0), // Pout
      8: const pw.FlexColumnWidth(1.2), // Judgement
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Input & Output Characteristics',
          style: pw.TextStyle(
            fontSize: 16,
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
              children: headers
                  .map((header) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(header, style: pw.TextStyle(font: font)),
                      ))
                  .toList(),
            ),
            ...data.inputOutputCharacteristicsSide
                .map((item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item.side,
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('253V,187V',
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            item.inputVoltage
                                .map((iv) => "${iv.value.toStringAsFixed(2)} V")
                                .join("\n"),
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            item.inputCurrent
                                .map((ic) => "${ic.value.toStringAsFixed(2)} A")
                                .join("\n"),
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              "${item.totalInputPower.value.toStringAsFixed(2)} KW",
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              "${item.outputVoltage.value.toStringAsFixed(2)} V",
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              "${item.outputCurrent.value.toStringAsFixed(2)} A",
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              "${item.totalOutputPower.value.toStringAsFixed(2)} KW",
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(item.judgement.name.toUpperCase(),
                              style: pw.TextStyle(font: font)),
                        ),
                      ],
                    ))
                .toList(),
          ],
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
            fontSize: 16,
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
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Test Items', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Testing Record',
                      style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Judgement', style: pw.TextStyle(font: font)),
                ),
              ],
            ),
            ...List.generate(
              data.testItems.length,
              (index) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('${index + 1}',
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(data.testItems[index].name,
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      data.testItems[index].description.replaceAll("{VALUE}",
                          data.testItems[index].value.toStringAsFixed(2)),
                      style: pw.TextStyle(font: font),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      data.testItems[index].judgement.name.toUpperCase(),
                      style: pw.TextStyle(font: font),
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
      1: const pw.FlexColumnWidth(1.5), // Test Items
      2: const pw.FlexColumnWidth(2.0), // Testing Record
      3: const pw.FlexColumnWidth(1.0), // Judgement
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Protection Function Test',
          style: pw.TextStyle(
            fontSize: 16,
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
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Test Items', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Testing Record',
                      style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Judgement', style: pw.TextStyle(font: font)),
                ),
              ],
            ),
            ...List.generate(
              data.specialFunctionTestResult.testItems.length,
              (index) {
                final item = data.specialFunctionTestResult.testItems[index];
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${index + 1}',
                          style: pw.TextStyle(font: font)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child:
                          pw.Text(item.name, style: pw.TextStyle(font: font)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.description,
                          style: pw.TextStyle(font: font)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        item.judgement.name.toUpperCase(),
                        style: pw.TextStyle(font: font),
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
            fontSize: 16,
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
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('No.',
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Test Items',
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Testing Record',
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Judgement',
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
                ),
              ],
            ),
            // Insulation Impedance Test Row
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('1',
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Insulation Impedance Test.',
                          style: pw.TextStyle(font: font)),
                      pw.SizedBox(height: 5),
                      pw.Text('Apply a DC Voltage:',
                          style: pw.TextStyle(font: font)),
                      pw.Text('a) Between each circuit.',
                          style: pw.TextStyle(font: font)),
                      pw.Text(
                          'b) Between each of the\nindependent circuits and the\nground.',
                          style: pw.TextStyle(font: font)),
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
                          'Insulation impedance >10MΩ',
                          style: pw.TextStyle(font: font),
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
                                        )),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.leftInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(font: font)),
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
                                        )),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputOutput.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationInputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationImpedanceTest.rightInsulationOutputGround.value.toStringAsFixed(2)} MΩ',
                                        style: pw.TextStyle(font: font)),
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
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(data.hiPotTestResult.judgement,
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
                ),
              ],
            ),
            // Insulation Voltage Test Row
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('2',
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Insulation Voltage Test.',
                          style: pw.TextStyle(font: font)),
                      pw.SizedBox(height: 5),
                      pw.Text('Apply a DC Voltage:',
                          style: pw.TextStyle(font: font)),
                      pw.Text('a) Between each circuit.',
                          style: pw.TextStyle(font: font)),
                      pw.Text(
                          'b) Between each of the\nindependent circuits and the\nground.',
                          style: pw.TextStyle(font: font)),
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
                          'Leakage current <10mA',
                          style: pw.TextStyle(
                            font: font,
                            color: PdfColors.red,
                          ),
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
                                        )),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputOutput.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationInputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.leftInsulationOutputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(font: font)),
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
                                        )),
                                    pw.Text(
                                        'Input/Output: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputOutput.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Input/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationInputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        'Output/Ground: ${data.hiPotTestResult.insulationVoltageTest.rightInsulationOutputGround.value.toStringAsFixed(2)} mA',
                                        style: pw.TextStyle(font: font)),
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
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(data.hiPotTestResult.judgement,
                      style: pw.TextStyle(font: font),
                      textAlign: pw.TextAlign.center),
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
            fontSize: 16,
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
              children: data.header
                  .map((header) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(header, style: pw.TextStyle(font: font)),
                      ))
                  .toList(),
            ),
            ...List.generate(
              data.datas.length,
              (index) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('${index + 1}',
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                        data.getEnglishText(data.datas[index].translationKey),
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(data.datas[index].spec.toString(),
                        style: pw.TextStyle(font: font)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(data.datas[index].isCheck.value ? '✓' : '',
                        style: pw.TextStyle(font: font)),
                  ),
                ],
              ),
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
            fontSize: 16,
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
            fontSize: 16,
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
                      fontSize: 16,
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
                    child: pw.Text(pic, style: pw.TextStyle(font: font)),
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
                      fontSize: 16,
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
                    child: pw.Text(date, style: pw.TextStyle(font: font)),
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

      final directory = Directory(
          path.join(picturesPath, 'Selected Photos', sn, 'Packaging'));
      final images = <pw.Widget>[];

      if (await directory.exists()) {
        final imageFiles = directory
            .listSync()
            .where((file) =>
                file.path.toLowerCase().endsWith('.jpg') ||
                file.path.toLowerCase().endsWith('.jpeg') ||
                file.path.toLowerCase().endsWith('.png'))
            .toList();

        // 將圖片分組為每組3張
        for (var i = 0; i < imageFiles.length; i += 2) {
          final rowImages = <pw.Widget>[];
          for (var j = 0; j < 5 && i + j < imageFiles.length; j++) {
            final image = await _imageFromPath(imageFiles[i + j].path);
            if (image != null) {
              rowImages.add(
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(5),
                    height: 200,
                    child: pw.Image(
                      image,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              );
            }
          }
          if (rowImages.isNotEmpty) {
            images.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: rowImages,
              ),
            );
          }
        }
        return images;
      }
    } catch (e) {
      debugPrint('Error loading package list images: $e');
    }
    return [];
  }

  static Future<List<pw.Widget>> _loadAttachmentImages(String sn) async {
    try {
      final picturesPath = await _getPicturesPath();
      if (picturesPath.isEmpty) {
        return [];
      }

      final directory = Directory(
          path.join(picturesPath, 'Selected Photos', sn, 'Attachment'));
      final images = <pw.Widget>[];

      if (await directory.exists()) {
        final imageFiles = directory
            .listSync()
            .where((file) =>
                file.path.toLowerCase().endsWith('.jpg') ||
                file.path.toLowerCase().endsWith('.jpeg') ||
                file.path.toLowerCase().endsWith('.png'))
            .toList();

        // 將圖片分組為每組3張
        for (var i = 0; i < imageFiles.length; i += 2) {
          final rowImages = <pw.Widget>[];
          for (var j = 0; j < 5 && i + j < imageFiles.length; j++) {
            final image = await _imageFromPath(imageFiles[i + j].path);
            if (image != null) {
              rowImages.add(
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(5),
                    height: 200,
                    child: pw.Image(
                      image,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              );
            }
          }
          if (rowImages.isNotEmpty) {
            images.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: rowImages,
              ),
            );
          }
        }
        return images;
      }
    } catch (e) {
      debugPrint('Error loading attachment images: $e');
    }
    return [];
  }

  static Future<pw.ImageProvider?> _imageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
    return null;
  }
}
