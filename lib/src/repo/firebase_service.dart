import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/FailCountStore.dart';

class FirebaseService {
  final String projectId = 'oqcreport-87e5a';
  final String apiKey = 'AIzaSyBzlul4mftI7HHJnj48I2aUs2nV154x0iI'; // 替換為你的 API Key

  /// 新增或更新某個 model/SN/tableName 的 spec 文件
  Future<bool> addOrUpdateSpec({
    required String model,
    required String tableName,
    required Map<String, dynamic> spec,
  }) async {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/models/$model/$tableName/spec?key=$apiKey';
    final body = json.encode({
      "fields": {
        "spec": {
          "mapValue": {
            "fields": _toFirestoreFields(spec),
          }
        }
      }
    });

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    print('🔥 StatusCode: ${response.statusCode}');
    print('🔥 Body: ${response.body}');
    return response.statusCode == 200;
  }
  /// 新增或更新 fail count 到 /failcounts/{model}/{serialNumber}/{tableName}
  Future<bool> addOrUpdateFailCount({
    required String model,
    required String serialNumber,
    required String tableName,
    required int failCount,
  }) async {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/failcounts/$model/$serialNumber/$tableName?key=$apiKey';

    final body = json.encode({
      "fields": {
        "failCount": {
          "integerValue": failCount.toString(),
        },
      },
    });

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('🚀 FailCount Upload Status: ${response.statusCode}');
    print('🚀 Response Body: ${response.body}');

    return response.statusCode == 200;
  }


  /// 讀取多個 tableName 的 spec，回傳 Map<tableName, spec>
  Future<Map<String, Map<String, dynamic>>> getAllSpecs({
    required String model,
    //required String serialNumber,
    required List<String> tableNames,
  }) async {
    final result = <String, Map<String, dynamic>>{};

    for (final tableName in tableNames) {
      final url =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/models/$model/$tableName/spec?key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final specField = data['fields']?['spec'];
        if (specField != null && specField is Map) {
          final fieldsMap = specField['mapValue']?['fields'];
          if (fieldsMap != null && fieldsMap is Map<String, dynamic>) {
            result[tableName] = _fromFirestoreFields(Map<String, dynamic>.from(fieldsMap));
          } else {
            result[tableName] = {};
          }
        } else {
          result[tableName] = {};
        }
      } else if (response.statusCode == 404) {
        // 文件不存在
        result[tableName] = {};
      } else {
        throw Exception('Failed to load $tableName spec, statusCode=${response.statusCode}');
      }
    }

    return result;
  }

  /// 讀取多個 table 的 fail count，回傳 Map<tableName, count>
  Future<Map<String, int>> getAllFailCounts({
    required String model,
    required String serialNumber,
    required List<String> tableNames,
  }) async {
    final result = <String, int>{};

    for (final tableName in tableNames) {
      final url =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/failcounts/$model/$serialNumber/$tableName?key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fields = data['fields'] ?? {};
        final countField = fields['failCount'];
        if (countField != null && countField is Map && countField['integerValue'] != null) {
          result[tableName] = int.tryParse(countField['integerValue']) ?? 0;
        } else {
          result[tableName] = 0;
        }
      } else if (response.statusCode == 404) {
        // 文件不存在就預設為 0
        result[tableName] = 0;
      } else {
        throw Exception('Failed to load fail count for $tableName, statusCode=${response.statusCode}');
      }
    }

    return result;
  }

  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = {};
    data.forEach((key, value) {
      if (value is String) {
        fields[key] = {"stringValue": value};
      } else if (value is int) {
        fields[key] = {"integerValue": value.toString()};
      } else if (value is double) {
        fields[key] = {"doubleValue": value};
      } else if (value is bool) {
        fields[key] = {"booleanValue": value};
      } else if (value is Map<String, dynamic>) {
        fields[key] = {"mapValue": {"fields": _toFirestoreFields(value)}};
      } else if (value is List) {
        fields[key] = {
          "arrayValue": {
            "values": value.map((e) {
              if (e is String) return {"stringValue": e};
              if (e is int) return {"integerValue": e.toString()};
              if (e is double) return {"doubleValue": e};
              if (e is bool) return {"booleanValue": e};
              if (e is Map<String, dynamic>) {
                return {"mapValue": {"fields": _toFirestoreFields(e)}};
              }
              return {"nullValue": null};
            }).toList()
          }
        };
      } else {
        fields[key] = {"nullValue": null};
      }
    });
    return fields;
  }

  Map<String, dynamic> _fromFirestoreFields(Map<String, dynamic> fields) {
    final Map<String, dynamic> result = {};
    fields.forEach((key, value) {
      if (value.containsKey('stringValue')) {
        result[key] = value['stringValue'];
      } else if (value.containsKey('integerValue')) {
        result[key] = int.tryParse(value['integerValue']) ?? 0;
      } else if (value.containsKey('doubleValue')) {
        result[key] = value['doubleValue'];
      } else if (value.containsKey('booleanValue')) {
        result[key] = value['booleanValue'];
      } else if (value.containsKey('mapValue')) {
        result[key] = _fromFirestoreFields(Map<String, dynamic>.from(value['mapValue']['fields']));
      } else if (value.containsKey('arrayValue')) {
        final list = value['arrayValue']['values'] as List<dynamic>? ?? [];
        result[key] = list.map((e) {
          if (e.containsKey('stringValue')) return e['stringValue'];
          if (e.containsKey('integerValue')) return int.tryParse(e['integerValue']) ?? 0;
          if (e.containsKey('doubleValue')) return e['doubleValue'];
          if (e.containsKey('booleanValue')) return e['booleanValue'];
          if (e.containsKey('mapValue')) {
            return _fromFirestoreFields(Map<String, dynamic>.from(e['mapValue']['fields']));
          }
          return null;
        }).toList();
      } else {
        result[key] = null;
      }
    });
    return result;
  }
}

/// 範例：撈取並印出 InputOutputCharacteristics 的 spec
Future<void> fetchAndPrintInputOutputCharacteristicsSpecs(String model) async {
  final firebaseService = FirebaseService();
  final tableNames = ['InputOutputCharacteristics'];

  final specs = await firebaseService.getAllSpecs(
    model: model,
    //serialNumber: sn,
    tableNames: tableNames,
  );
  final specMap = specs['InputOutputCharacteristics'];
  if (specMap != null) {
    // 把資料存到全域變數
    globalInputOutputSpec = InputOutputCharacteristicsSpec.fromJson(specMap);

    print('=== InputOutputCharacteristics ===');
    print(globalInputOutputSpec); // 直接印出全域變數內容
  }
  for (var entry in specs.entries) {
    print('=== ${entry.key} ===');
    print(jsonEncode(entry.value));
  }
}

Future<void> fetchAndPrintBasicFunctionTestSpecs(String model) async {
  final firebaseService = FirebaseService();
  final tableNames = ['BasicFunctionTest'];

  final specs = await firebaseService.getAllSpecs(
    model: model,
    //serialNumber: sn,
    tableNames: tableNames,
  );
  final specMap = specs['BasicFunctionTest'];
  if (specMap != null) {
    // 把資料存到全域變數
    globalBasicFunctionTestSpec = BasicFunctionTestSpec.fromJson(specMap);

    print('=== BasicFunctionTest ===');
    print(globalBasicFunctionTestSpec); // 直接印出全域變數內容
  }
  for (var entry in specs.entries) {
    print('=== ${entry.key} ===');
    print(jsonEncode(entry.value));
  }
}

Future<void> fetchAndPrintHipotTestSpecs(String model) async {
  final firebaseService = FirebaseService();
  final tableNames = ['HipotTestSpec'];

  final specs = await firebaseService.getAllSpecs(
    model: model,
    tableNames: tableNames,
  );
  final specMap = specs['HipotTestSpec'];
  if (specMap != null) {
    // 把資料存到全域變數
    globalHipotTestSpec = HipotTestSpec.fromJson(specMap);

    print('=== HipotTestSpec ===');
    print(globalHipotTestSpec); // 直接印出全域變數內容
  }
  for (var entry in specs.entries) {
    print('=== ${entry.key} ===');
    print(jsonEncode(entry.value));
  }
}

Future<void> fetchFailCountsForDevice(String model, String serialNumber) async {
  final firebaseService = FirebaseService();
  final tableNames = [
    'AppearanceStructureInspectionFunction',
    'InputOutputCharacteristics',
    'BasicFunctionTest',
    'HipotTestSpec',
  ];

  final failCounts = await firebaseService.getAllFailCounts(
    model: model,
    serialNumber: serialNumber,
    tableNames: tableNames,
  );

  // 把讀到的 fail count 寫入 FailCountStore 全域變數
  for (final entry in failCounts.entries) {
    FailCountStore.setCount(entry.key, entry.value);
    print('❌ ${entry.key}: ${entry.value} fails');
  }
}

