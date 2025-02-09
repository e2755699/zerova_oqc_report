import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zerova_oqc_report/src/report/model/input_output_characteristics.dart';
import 'package:zerova_oqc_report/src/report/model/psu_serial_number.dart';
import 'package:zerova_oqc_report/src/report/model/protection_function_test_result.dart';
import 'package:zerova_oqc_report/src/report/model/software_version.dart';
import 'package:zerova_oqc_report/src/report/model/appearance_structure_inspection_function_result.dart';

class OqcApiClient {
  final String baseUrl = "http://api.ztmn.com/zapi";
  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiWmVyb3ZhX09RQyJ9.-glMWnDu11Wm93OFdvRmyrwP2KnQY3J-yUS_W4QZm-k";

  OqcApiClient();

  Future<List<dynamic>> fetchAndSaveOqcData(String serialNumber) async {
    final url = Uri.parse("$baseUrl/OQC");
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final params = {
      'sn': serialNumber,
    };

    try {
      final response = await http.get(url.replace(queryParameters: params),
          headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print("無法取得資料，狀態碼: ${response.statusCode}");
        print("回應內容: ${response.body}");
        throw Exception();
      }
    } catch (e) {
      print("發生錯誤: $e");
      throw Exception();
    }
  }

  Future<List<dynamic>> fetchAndSaveTestData(String serialNumber) async {
    final url = Uri.parse("$baseUrl/TEST");
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final params = {
      'sn': serialNumber,
    };

    try {
      final response = await http.get(url.replace(queryParameters: params),
          headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print("無法取得資料，狀態碼: ${response.statusCode}");
        print("回應內容: ${response.body}");
        throw Exception();
      }
    } catch (e) {
      print("發生錯誤: $e");
      throw Exception();
    }
  }

  Future<List<dynamic>> fetchAndSaveKeyPartData(String serialNumber) async {
    final url = Uri.parse("$baseUrl/KEYPART");
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final params = {
      'sn': serialNumber,
    };

    try {
      final response = await http.get(url.replace(queryParameters: params),
          headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print("無法取得資料，狀態碼: ${response.statusCode}");
        print("回應內容: ${response.body}");
        throw Exception();
      }
    } catch (e) {
      print("發生錯誤: $e");
      throw Exception();
    }
  }
}

class OQCTestData {
  final SoftwareVersion softwareversion;
  final InputOutputCharacteristics inputOutputCharacteristics;
  final ProtectionFunctionTestResult protectionFunctionTestResult;

  OQCTestData(this.softwareversion, this.inputOutputCharacteristics,
      this.protectionFunctionTestResult);
}
