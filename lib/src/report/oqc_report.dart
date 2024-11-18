import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OqcReport extends StatefulWidget {
  OqcReport({super.key});

  @override
  State<OqcReport> createState() => _OqcReportState();
}

class _OqcReportState extends State<OqcReport> with PdfMixin{
  late pw.Document _pdf;
  late Future<pw.Font> _tableCellFont;
  String _exportPath = "";

  @override
  void initState() {
    _tableCellFont = PdfGoogleFonts.notoSansTCRegular();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Page
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                createPdf();
              },
              child: const Text("create pdf")),
          ElevatedButton(
              onPressed: () {
                export();
              },
              child: const Text("export pdf")),
          Text(_exportPath),
        ],
      ),
    );
  }

  Future<void> createPdf() async {
    var tableCellFont = await _tableCellFont;

    _pdf = pw.Document();

    _pdf.addPage(_homePage());
    _pdf.addPage(_modelInfoPage(tableCellFont));
    _pdf.addPage(_buildAppearanceStructureInspectionPage(tableCellFont));
    _pdf.addPage(
      _buildPage((context) {
        return Section(title: "b. Input & Output Characteristics", table:
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(
            color: PdfColors.black,
          ),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
          ),
          cellStyle: pw.TextStyle(
            font: tableCellFont,
            fontSize: 8,
          ),
          // columnWidths: {
          //
          // },
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.centerLeft,
          },
          headers: [pw.Column(children: [pw.Text("Item"),pw.Text("Spec")]), "Vin","Iin","Pin","Vout","Iout","Pout"],
          data: [["L","R"]],
        ),
        );
      })
    );
  }

  pw.Page _buildAppearanceStructureInspectionPage(pw.Font tableCellFont) {
    return _buildPage((context) {
      return pw.Column(children: [
        AppearanceStructureInspection(tableCellFont: tableCellFont),
      ]);
    });
  }

  pw.Page _modelInfoPage(pw.Font tableCellFont) {
    return _buildPage((context) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 100),
        child: pw.Column(children: [
          pw.Spacer(flex: 2),
          PsuSection(),
          pw.Spacer(flex: 1),
          EvSoftwareVersionSection(tableCellFont: tableCellFont),
          pw.Spacer(flex: 2),
        ]),
      );
    });
  }

  pw.Page _homePage() {
    return _buildPage((context) {
      return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Spacer(flex: 1),
            _buildHeaderText("ZEROVA TECHNOLOGIES Co., Ltd.", 25),
            pw.Spacer(flex: 2),
            _buildHeaderText(
                "Electric Vehicle DC Charger Outgoing Quality Control Report",
                20),
            _buildHeaderText("DS Series", 20),
            pw.Spacer(flex: 1),
            _buildHeaderText("Model Name : DSYE182XXXXXXX-RW", 20),
            _buildHeaderText("SN :                      ", 20),
            pw.Spacer(flex: 2),
          ]);
    });
  }

  pw.Text _buildHeaderText(String data, double fontSize) {
    return pw.Text(data,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
        ));
  }

  pw.Page _buildPage(pw.Widget Function(pw.Context context) builder) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: builder,
    );
  }

  pw.Center _buildPdfCenter(String data) {
    return pw.Center(
      child: pw.Text(data),
    );
  }

  Future<void> export() async {
    // On Flutter, use the [path_provider](https://pub.dev/packages/path_provider) library:
    final output = await getTemporaryDirectory();
    _exportPath = "${output.path}/example.pdf";
    final file = File(_exportPath);
    await file.writeAsBytes(await _pdf.save());
    setState(() {});
  }
}

class PsuSection extends pw.StatelessWidget with PdfMixin {
  @override
  pw.Widget build(pw.Context context) {
    return Section(
      title: "PSU S/N",
      table: _buildTable(
        columnWidths: {
          0: pw.FlexColumnWidth(1.5),
          1: pw.FlexColumnWidth(9.5),
        },
        headers: ["No.", "S/N"],
        rows: [
          ["1.", ""],
          ["2.", ""],
          ["3.", ""],
          ["4.", ""],
          ["5.", ""],
          ["6.", ""],
        ],
      ),
    );
  }
}

class EvSoftwareVersionSection extends pw.StatelessWidget with PdfMixin {
  final pw.Font tableCellFont;

  EvSoftwareVersionSection({required this.tableCellFont});

  @override
  pw.Widget build(pw.Context context) {
    return Section(
        title: "EV Software Version ",
        table: _buildTable(tableCellFont: tableCellFont, headers: [
          "No.",
          "Item",
          "Version"
        ], rows: [
          ["1", "CSU", "1234"],
          ["2", "Fan Board", "5667"],
          ["3", "Relay Board", "8901"],
          ["4", "DCM 407", "2345"],
          ["5", "CCS", "68798"],
          ["6", "UI", "04678"],
          ["7", "LED", "97325"],
          ["8", "", ""],
        ]));
  }
}

class AppearanceStructureInspection extends pw.StatelessWidget with PdfMixin {
  final pw.Font tableCellFont;

  AppearanceStructureInspection({required this.tableCellFont});

  @override
  pw.Widget build(pw.Context context) {
    return Section(
      title: "a. Appearance & Structure Inspection",
      table: _buildTable(tableCellFont: tableCellFont, columnWidths: {
        2: pw.FlexColumnWidth(4),
      }, headers: [
        "No.",
        "Inspection Item",
        "Insp ection Details",
        "Judgement",
      ], rows: [
        [
          "1",
          "CSU、PSU",
          "需有防拆貼紙。\nMust have tamper-evident stickers.",
          "OK/NG/NA"
        ],
        [
          "2",
          "標籤、銘牌\nLabel, Nameplate",
          "內容需依照圖面，不得有模糊、斷字、歪斜、刮花等不良。\nContent must match the diagram, and there should be no blurriness, broken characters, misalignment, scratches, or other defects.",
          "OK/NG/NA"
        ],
        [
          "3",
          "螢幕\nScreen",
          "外觀不得有劃痕、髒汙、殘膠、氣泡等。\nThe appearance must be free of scratches, dirt, adhesive residue, bubbles, etc.",
          "OK/NG/NA"
        ],
        [
          "4",
          "風扇\nFan",
          "確認風扇網及風扇的安裝方向(依箭頭方向確認)。\nConfirm the fan grill and fan installation direction. (Follow the arrow)",
          "OK/NG/NA"
        ],
        [
          "5",
          "線材\nCables",
          "確認線材連接位置、組裝是否到位、是否理線。\nConfirm cable connection positions, proper assembly, and proper cable routing.",
          "OK/NG/NA"
        ],
        [
          "6",
          "螺絲\nScrews",
          "1. 整機不得有螺絲漏鎖、且須有確認扭力的畫線\n2. 大電力螺絲鎖附扭力值需確認\n1. No missing screws in the unit, and torque markings must be verified.\n2. For high-power screws, ensure torque values are checked.",
          "OK/NG/NA"
        ],
        [
          "7",
          "門鎖\nDoor Lock",
          "開關門鎖、轉動手把需運作正常。\nDoor locks and handles must operate correctly.",
          "OK/NG/NA"
        ],
        [
          "8",
          "接地\nGrounding",
          "接地線安裝位置需與接地標籤相對應。\nThe grounding wire installation position must correspond with the grounding label.",
          "OK/NG/NA"
        ],
        [
          "9",
          "防水\nWaterproofing",
          "防水膠需塗布均勻、塗布位置需依循防水對策規範。\nWaterproof glue must be applied evenly, and the application area must follow waterproofing guidelines.",
          "OK/NG/NA"
        ],
        [
          "10",
          "壓克力板\nAcrylic Panel",
          "壓克力板不可晃動、劃痕。\nThe acrylic panel must not be loose or scratched.",
          "OK/NG/NA"
        ],
        [
          "11",
          "槍線\nCharging Cable",
          "長度及規格需正確、槍頭絲印資訊需正確。\nThe length and specifications must be correct, and the printing on the plug must be accurate.",
          "OK/NG/NA"
        ],
        [
          "12",
          "機櫃\nCabinet",
          "1. 機櫃外觀不得有掉漆、劃痕、髒污、生鏽、脫焊、色差等不良。\n2. 機櫃內底部不得有異物。\n1. The cabinet appearance must be free of paint peeling, scratches, dirt, rust, welding defects, and color discrepancies.\n2. The bottom of the cabinet interior must be free of foreign objects.",
          "OK/NG/NA"
        ],
        [
          "13",
          "棧板\nPallet",
          "棧板扭力值需達標及畫線\nPallet torque values must meet the standard, and torque markings should be checked.",
          "OK/NG/NA"
        ],
        [
          "14",
          "燒機\nBurn-in Test",
          "1. 確認LED亮燈狀況(故障/待機/充車)。\n2. 確認電表功率的累積功率與實際功率值是否符合。\n3. 記錄輸出銅牌溫度。\n1. Confirm LED status. (Fault/Standby/Charging).\n2. Confirm that the cumulative power reading on the meter matches the actual power value.\n3. Record the copper busbar temperature.",
          "OK/NG/NA"
        ],
      ]),
    );
  }
}

class Section extends pw.StatelessWidget {
  final String title;
  final pw.Table table;

  Section({required this.title, required this.table});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(children: [
      _buildTitle(title),
      table,
    ]);
  }

  pw.Widget _buildTitle(String title) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(title),
    );
  }
}

mixin PdfMixin {
  pw.Table _buildTable({
    required List<String> headers,
    required List<List<String>> rows,
    pw.Font? tableCellFont,
    Map<int, pw.TableColumnWidth>? columnWidths,
  }) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(
        color: PdfColors.black,
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      ),
      cellStyle: pw.TextStyle(
        font: tableCellFont,
        fontSize: 8,
      ),
      columnWidths: columnWidths,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
      },
      headers: headers,
      data: rows,
    );
  }

  pw.TableRow _buildRowByStringColumns(List<String> columns) {
    return pw.TableRow(children: [
      ...columns.map((column) => pw.Text(column)),
    ]);
  }
}
