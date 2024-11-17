import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel Reader & PDF Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExcelReaderScreen(),
    );
  }
}

class ExcelReaderScreen extends StatefulWidget {
  @override
  _ExcelReaderScreenState createState() => _ExcelReaderScreenState();
}

class _ExcelReaderScreenState extends State<ExcelReaderScreen> {
  List<Map<String, dynamic>> _filteredData = [];
  List<Map<String, dynamic>> _csuFilteredData = []; // 用於存儲 CSU Rootfs 篩選結果

  // 選擇並讀取 Excel 檔案
  Future<void> _pickAndReadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // 找到 "Keypart" 工作表並篩選
      var keypartSheet = excel.tables['Keypart'];
      _filteredData.clear();
      if (keypartSheet != null) {
        for (int rowIndex = 1; rowIndex < keypartSheet.maxRows; rowIndex++) {
          var row = keypartSheet.row(rowIndex);
          if (row.any((cell) =>
          cell?.value?.toString().contains("CHARGING MODULE") ?? false)) {
            var row2 = row[0];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var chargeModule = ChargeModule.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "欄位內容": chargeModule.snId,
              };
              _filteredData.add(rowData);
              print("料號 ${chargeModule.snId}");
            }
          }
        }
      }

      // 找到 "Test_value" 工作表並篩選 CSU Rootfs
      var testValueSheet = excel.tables['Test_value'];
      _csuFilteredData.clear();
      if (testValueSheet != null) {
        for (int rowIndex = 1; rowIndex < testValueSheet.maxRows; rowIndex++) {
          var row = testValueSheet.row(rowIndex);
          if (row.any((cell) =>
          cell?.value?.toString().contains("CSU Rootfs") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var csuData = CSUData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "欄位內容": csuData.keyword,
              };
              _csuFilteredData.add(rowData);
              print("CSU 篩選結果: ${csuData.keyword}");
            }
          }
        }
        for (int rowIndex = 1; rowIndex < testValueSheet.maxRows; rowIndex++) {
          var row = testValueSheet.row(rowIndex);
          if (row.any((cell) =>
          cell?.value?.toString().contains("CSU Rootfs") ?? false)) {
            var row2 = row[6];
            if (row2 != null &&
                row2.value != null &&
                row2.value.toString().isNotEmpty) {
              var csuData = CSUData.fromExcel(row2.value.toString());
              Map<String, dynamic> rowData = {
                "欄位內容": csuData.keyword,
              };
              _csuFilteredData.add(rowData);
              print("CSU 篩選結果: ${csuData.keyword}");
            }
          }
        }
      }

      setState(() {}); // 更新UI
    }
  }

  // 生成並儲存 PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // 添加 Keypart 資料到 PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Keypart 篩選結果:", style: pw.TextStyle(fontSize: 16)),
              ..._filteredData.map((data) {
                return pw.Text(
                  "欄位內容: ${data['欄位內容']}",
                  style: pw.TextStyle(fontSize: 12),
                );
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Text("CSU Rootfs 篩選結果:", style: pw.TextStyle(fontSize: 16)),
              ..._csuFilteredData.map((data) {
                return pw.Text(
                  "欄位內容: ${data['欄位內容']}",
                  style: pw.TextStyle(fontSize: 12),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    // 讓使用者選擇儲存 PDF 的路徑
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: '選擇儲存路徑',
      fileName: 'filtered_data.pdf',
      allowedExtensions: ['pdf'],
    );

    if (path != null) {
      File file = File(path);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF已儲存至: ${file.path}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Reader & PDF Generator'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickAndReadExcelFile,
              child: Text('讀取Excel檔案'),
            ),
            ElevatedButton(
              onPressed: _generatePdf,
              child: Text('生成並儲存 PDF 檔案'),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (_filteredData.isNotEmpty) ...[
                    Text('Keypart 篩選結果:', style: TextStyle(fontSize: 16)),
                    ..._filteredData.map((data) {
                      return ListTile(
                        title: Text('欄位內容: ${data["欄位內容"]}'),
                      );
                    }).toList(),
                  ],
                  if (_csuFilteredData.isNotEmpty) ...[
                    Text('CSU Rootfs 篩選結果:', style: TextStyle(fontSize: 16)),
                    ..._csuFilteredData.map((data) {
                      return ListTile(
                        title: Text('欄位內容: ${data["欄位內容"]}'),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChargeModule {
  final String snId;

  factory ChargeModule.fromExcel(String moduleId) {
    return ChargeModule(moduleId);
  }

  ChargeModule(this.snId);
}

class CSUData {
  final String keyword;

  factory CSUData.fromExcel(String keyword) {
    return CSUData(keyword);
  }

  CSUData(this.keyword);
}

