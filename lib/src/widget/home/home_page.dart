import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:zerova_oqc_report/src/client/oqc_api_client.dart';
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/test_function.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _languages = ['繁體中文', 'English', '日本語', 'Tiếng Việt'];
  String _selectedLanguage = '繁體中文';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: _selectedLanguage,
          items: _languages
              .map((lang) => DropdownMenuItem(
            value: lang,
            child: Text(lang),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
            });
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 公司LOGO
            Image.asset(
              'assets/logo.png', // 請確保此路徑下有對應的圖片
              height: 300, // 調整LOGO大小
            ),
            SizedBox(height: 40),

            // 按鈕1: 輸入SN機種
            SizedBox(
              width: 200, // 統一按鈕寬度
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return InputSNDialog(); // 彈出視窗
                    },
                  );
                },
                child: Text('輸入SN機種'),
              ),
            ),
            SizedBox(height: 20),

            // 按鈕2: QR Scan
            SizedBox(
              width: 200, // 統一按鈕寬度
              child: ElevatedButton(
                onPressed: () {
                  _qr();
                },
                child: Text('QR code掃描'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _qr() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Test',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
    );

      var result = "T1234567 SN8765432";
      String model = "";
      String serialNumber = "";
      // 將 result 拆成兩部分
      List<String> parts = result.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        model = parts[0];
        serialNumber = parts[1];
      } else {
        model = result;
        serialNumber = ''; // 若分割後不足兩部分，則 part2 保持空字串
      }
      final apiClient = OqcApiClient();

      // 將 model 和 serialNumber 打印到 console
      Future.wait<List<dynamic>>([
        apiClient.fetchAndSaveKeyPartData(serialNumber),
        apiClient.fetchAndSaveOqcData(serialNumber),
        apiClient.fetchAndSaveTestData(serialNumber)
      ]).then((res) {
          var psuSerialNumbers = Psuserialnumber.fromJsonList(res[0]);
          var testFunction =
              AppearanceStructureInspectionFunctionResult.fromJson(res[1]);
          var softwareVersion = SoftwareVersion.fromJsonList(res[2]);
          var inputOutputCharacteristics =
              InputOutputCharacteristics.fromJsonList(res[2]);
          var protectionTestResults =
              ProtectionFunctionTestResult.fromJsonList(res[2]);
      });
  }

}

class InputSNDialog extends StatefulWidget {
  @override
  _InputSNDialogState createState() => _InputSNDialogState();
}

class _InputSNDialogState extends State<InputSNDialog> {
  final _formKey = GlobalKey<FormState>();
  final _snController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('輸入SN和Model'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _snController,
              decoration: InputDecoration(
                labelText: 'SN',
                hintText: '請輸入SN',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入SN';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'Model Name',
                hintText: '請輸入Model Name',
                prefixIcon: Icon(Icons.text_fields),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入Model Name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 關閉彈出視窗
          },
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final sn = _snController.text;
              final model = _modelController.text;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SN: $sn, Model: $model 已提交'),
                ),
              );
              Navigator.of(context).pop(); // 關閉彈出視窗
            }
          },
          child: Text('提交'),
        ),
      ],
    );
  }

  Future<void> _qr() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Test',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
    );
  }

}

