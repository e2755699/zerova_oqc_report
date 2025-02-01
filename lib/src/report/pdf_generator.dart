import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:flutter/rendering.dart';

class PdfGenerator {
  static Future<pw.Document> generateOqcReport({
    required String modelName,
    required String serialNumber,
    required String pic,
    required String date,
    Psuserialnumber? psuSerialNumbers,
    SoftwareVersion? softwareVersion,
    AppearanceStructureInspectionFunctionResult? testFunction,
    InputOutputCharacteristics? inputOutputCharacteristics,
    ProtectionFunctionTestResult? protectionTestResults,
    PackageListResult? packageListResult,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansTCRegular();

    // Load images first
    final packageListImages = packageListResult != null ? await _loadPackageListImages() : List<pw.Widget>.empty();
    final attachmentImages = await _loadAttachmentImages();

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
              pw.SizedBox(height: 40),
              pw.Text(
                'Electric Vehicle DC Charger\nOutgoing Quality Control Report',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'DS Series',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 40),
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

    // Software Version & PSU S/N Page
    if (softwareVersion != null) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _buildSoftwareVersionTable(softwareVersion, font),
                pw.SizedBox(height: 20),
                if (psuSerialNumbers != null)
                  _buildPsuSerialNumbersTable(psuSerialNumbers, font),
              ],
            ),
          ),
        ),
      );
    }

    // Appearance, I/O, Basic Function Test Page
    if (testFunction != null || inputOutputCharacteristics != null) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (testFunction != null) ...[
                  _buildAppearanceInspectionTable(testFunction, font),
                  pw.SizedBox(height: 20),
                ],
                if (inputOutputCharacteristics != null) ...[
                  _buildInputOutputCharacteristicsTable(inputOutputCharacteristics, font),
                  pw.SizedBox(height: 20),
                  _buildBasicFunctionTestTable(inputOutputCharacteristics.basicFunctionTestResult, font),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Protection Function Test & Package List Page
    if (protectionTestResults != null || packageListResult != null) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (protectionTestResults != null) ...[
                  _buildProtectionFunctionTestTable(protectionTestResults, font),
                  pw.SizedBox(height: 20),
                ],
                if (packageListResult != null) ...[
                  _buildPackageListTable(packageListResult, font, packageListImages),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Attachment & Signature Page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              _buildAttachmentTable(font, attachmentImages),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'PIC: $pic',
                    style: pw.TextStyle(fontSize: 16, font: font),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Text(
                    'Date: $date',
                    style: pw.TextStyle(fontSize: 16, font: font),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildPsuSerialNumbersTable(Psuserialnumber data, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'PSU S/N',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('No.', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('S/N', style: pw.TextStyle(font: font)),
                  ),
                ),
              ],
            ),
            ...data.psuSN.asMap().entries.map((entry) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text('${entry.key + 1}', style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.value, style: pw.TextStyle(font: font)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSoftwareVersionTable(SoftwareVersion data, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Software Version',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('No.', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Item', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Version', style: pw.TextStyle(font: font)),
                  ),
                ),
              ],
            ),
            ...data.versions.asMap().entries.map((entry) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text('${entry.key + 1}', style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.name, style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.value, style: pw.TextStyle(font: font)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildAppearanceInspectionTable(AppearanceStructureInspectionFunctionResult data, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'b. Appearance & Structure Inspection',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('No.', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Item', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Description', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Result', style: pw.TextStyle(font: font)),
                  ),
                ),
              ],
            ),
            ...data.testItems.asMap().entries.map((entry) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text('${entry.key + 1}', style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.name, style: pw.TextStyle(font: font)),
                    ),
                  ),
                  // pw.Padding(
                  //   padding: const pw.EdgeInsets.all(5),
                  //   child: pw.Center(
                  //     child: pw.Text(entry.value.description, style: pw.TextStyle(font: font)),
                  //   ),
                  // ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        entry.value.judgement.toString().split('.').last.toUpperCase(),
                        style: pw.TextStyle(font: font),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInputOutputCharacteristicsTable(InputOutputCharacteristics data, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'c. Input & Output Characteristics',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // ... 實現表格內容
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBasicFunctionTestTable(BasicFunctionTestResult data, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'd. Basic Function Test',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('No.', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Item', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Value', style: pw.TextStyle(font: font)),
                  ),
                ),
              ],
            ),
            ...data.testItems.asMap().entries.map((entry) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text('${entry.key + 1}', style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.name, style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.value.toString(), style: pw.TextStyle(font: font)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildProtectionFunctionTestTable(ProtectionFunctionTestResult data, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'e. Protection Function Test',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('No.', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Item', style: pw.TextStyle(font: font)),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Text('Value', style: pw.TextStyle(font: font)),
                  ),
                ),
              ],
            ),
            ...data.specialFunctionTestResult.testItems.asMap().entries.map((entry) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text('${entry.key + 1}', style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.name, style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.value.toString(), style: pw.TextStyle(font: font)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPackageListTable(PackageListResult data, pw.Font font, List<pw.Widget> images) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'f. Package List',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: data.header.map((header) => pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(
                  child: pw.Text(header, style: pw.TextStyle(font: font)),
                ),
              )).toList(),
            ),
            ...data.datas.asMap().entries.map((entry) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text('${entry.key + 1}', style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.translationKey.tr(), style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.spec.toString(), style: pw.TextStyle(font: font)),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(entry.value.isCheck.value ? '✓' : '', style: pw.TextStyle(font: font)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
        pw.SizedBox(height: 20),
        if (images.isNotEmpty)
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: images,
          ),
      ],
    );
  }

  static pw.Widget _buildAttachmentTable(pw.Font font, List<pw.Widget> images) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'g. Attachment',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        if (images.isNotEmpty)
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: images,
          )
        else
          pw.Table(
            border: pw.TableBorder.all(),
            children: List.generate(8, (index) => pw.TableRow(
              children: List.generate(4, (colIndex) => pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Container(height: 50),
              )),
            )),
          ),
      ],
    );
  }

  static Future<List<pw.Widget>> _loadPackageListImages() async {
    final directory = Directory('C:\\Users\\USER\\Pictures\\All');
    final images = <pw.Widget>[];
    
    if (directory.existsSync()) {
      final imageFiles = directory.listSync()
          .where((file) => 
              file.path.toLowerCase().endsWith('.jpg') || 
              file.path.toLowerCase().endsWith('.jpeg') || 
              file.path.toLowerCase().endsWith('.png'))
          .take(8)
          .toList();

      for (final file in imageFiles) {
        final image = await _imageFromPath(file.path);
        if (image != null) {
          images.add(
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Image(image, height: 100, fit: pw.BoxFit.contain),
            ),
          );
        }
      }
    }
    return images;
  }

  static Future<List<pw.Widget>> _loadAttachmentImages() async {
    final directory = Directory('C:\\Users\\USER\\Pictures\\Attachment');
    final images = <pw.Widget>[];
    
    if (directory.existsSync()) {
      final imageFiles = directory.listSync()
          .where((file) => 
              file.path.toLowerCase().endsWith('.jpg') || 
              file.path.toLowerCase().endsWith('.jpeg') || 
              file.path.toLowerCase().endsWith('.png'))
          .take(8)
          .toList();

      for (final file in imageFiles) {
        final image = await _imageFromPath(file.path);
        if (image != null) {
          images.add(
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Image(image, height: 100, fit: pw.BoxFit.contain),
            ),
          );
        }
      }
    }
    return images;
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