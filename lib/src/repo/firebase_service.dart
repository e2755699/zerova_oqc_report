import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zerova_oqc_report/src/report/spec/psu_serial_numbers_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/basic_function_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/package_list_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/FailCountStore.dart';
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/report/spec/new_package_list_spec.dart.dart';

class FirebaseService {
  final String projectId = 'oqcreport-87e5a';
  final String apiKey =
      'AIzaSyBzlul4mftI7HHJnj48I2aUs2nV154x0iI'; // 替換為你的 API Key

  /// 取得所有模型列表（改進版：更可靠的方法）
  Future<List<String>> getModelList() async {
    try {
      // 查詢多個規格類型，確保不遺漏任何模型
      final specTypes = [
        'InputOutputCharacteristics',
        'BasicFunctionTest',
        'HipotTestSpec',
        'PsuSerialNumSpec',
        'PackageListSpec'
      ];

      final modelSet = <String>{};

      // 對每種規格類型進行collection group查詢
      for (final specType in specTypes) {
        try {
          final url =
              'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery?key=$apiKey';

          final body = json.encode({
            "structuredQuery": {
              "from": [
                {"collectionId": specType, "allDescendants": true}
              ],
              "limit": 100 // 增加限制以防遺漏
            }
          });

          final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final documents = data as List<dynamic>? ?? [];

            // 從文檔路徑中提取模型名稱
            for (final docWrapper in documents) {
              final doc = docWrapper['document'];
              if (doc != null) {
                final String name = doc['name'] as String;
                // 路徑格式：projects/{project}/databases/(default)/documents/models/{modelId}/{specType}/{docId}
                final segments = name.split('/');
                if (segments.length >= 8 && segments[5] == 'models') {
                  final modelId = segments[6];
                  // 驗證模型ID不為空且合理
                  if (modelId.isNotEmpty && modelId != 'undefined') {
                    modelSet.add(modelId);
                  }
                }
              }
            }
          }
        } catch (e) {
          // 如果某個規格類型查詢失敗，繼續查詢其他類型
          print('⚠️ 查詢 $specType 失敗: $e');
          continue;
        }
      }

      // 如果所有查詢都失敗，拋出異常
      if (modelSet.isEmpty) {
        throw Exception('無法從任何規格類型中找到模型');
      }

      final modelList = modelSet.toList()..sort();
      return modelList;
    } catch (e) {
      // 如果改進方法失敗，回退到原始方法
      return await _getModelListFallback();
    }
  }

  /// 備用方法：簡單的InputOutputCharacteristics查詢
  Future<List<String>> _getModelListFallback() async {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery?key=$apiKey';

    final body = json.encode({
      "structuredQuery": {
        "from": [
          {"collectionId": "InputOutputCharacteristics", "allDescendants": true}
        ],
        "limit": 50
      }
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final documents = data as List<dynamic>? ?? [];

      final modelSet = <String>{};

      for (final docWrapper in documents) {
        final doc = docWrapper['document'];
        if (doc != null) {
          final String name = doc['name'] as String;
          final segments = name.split('/');
          if (segments.length >= 8) {
            final modelId = segments[6];
            if (modelId.isNotEmpty) {
              modelSet.add(modelId);
            }
          }
        }
      }

      return modelSet.toList()..sort();
    } else {
      throw Exception(
          'Failed to load model list, statusCode=${response.statusCode}');
    }
  }

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
            result[tableName] =
                _fromFirestoreFields(Map<String, dynamic>.from(fieldsMap));
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
        throw Exception(
            'Failed to load $tableName spec, statusCode=${response.statusCode}');
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
        if (countField != null &&
            countField is Map &&
            countField['integerValue'] != null) {
          result[tableName] = int.tryParse(countField['integerValue']) ?? 0;
        } else {
          result[tableName] = 0;
        }
      } else if (response.statusCode == 404) {
        // 文件不存在就預設為 0
        result[tableName] = 0;
      } else {
        throw Exception(
            'Failed to load fail count for $tableName, statusCode=${response.statusCode}');
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
        fields[key] = {
          "mapValue": {"fields": _toFirestoreFields(value)}
        };
      } else if (value is List) {
        fields[key] = {
          "arrayValue": {
            "values": value.map((e) {
              if (e is String) return {"stringValue": e};
              if (e is int) return {"integerValue": e.toString()};
              if (e is double) return {"doubleValue": e};
              if (e is bool) return {"booleanValue": e};
              if (e is Map<String, dynamic>) {
                return {
                  "mapValue": {"fields": _toFirestoreFields(e)}
                };
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
        result[key] = _fromFirestoreFields(
            Map<String, dynamic>.from(value['mapValue']['fields']));
      } else if (value.containsKey('arrayValue')) {
        final list = value['arrayValue']['values'] as List<dynamic>? ?? [];
        result[key] = list.map((e) {
          if (e.containsKey('stringValue')) return e['stringValue'];
          if (e.containsKey('integerValue'))
            return int.tryParse(e['integerValue']) ?? 0;
          if (e.containsKey('doubleValue')) return e['doubleValue'];
          if (e.containsKey('booleanValue')) return e['booleanValue'];
          if (e.containsKey('mapValue')) {
            return _fromFirestoreFields(
                Map<String, dynamic>.from(e['mapValue']['fields']));
          }
          return null;
        }).toList();
      } else {
        result[key] = null;
      }
    });
    return result;
  }

  /// 刪除特定模型和表格名稱的規格文件
  Future<bool> deleteSpec({
    required String model,
    required String tableName,
  }) async {
    final url =
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/models/$model/$tableName/spec?key=$apiKey';

    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    print('🗑️ Delete Spec Status: ${response.statusCode}');
    print('🗑️ Response Body: ${response.body}');

    return response.statusCode == 200 ||
        response.statusCode == 404; // 404表示已經不存在，也算成功
  }

  /// 刪除特定模型的所有規格文件
  Future<bool> deleteAllModelSpecs({
    required String model,
  }) async {
    try {
      final tableNames = [
        'InputOutputCharacteristics',
        'BasicFunctionTest',
        'HipotTestSpec',
        'PsuSerialNumSpec',
        'PackageListSpec'
      ];

      bool allSuccess = true;

      // 刪除所有規格類型
      for (final tableName in tableNames) {
        try {
          final success = await deleteSpec(model: model, tableName: tableName);
          if (!success) {
            print('⚠️ 刪除 $model/$tableName 失敗');
            allSuccess = false;
          }
        } catch (e) {
          print('⚠️ 刪除 $model/$tableName 異常: $e');
          allSuccess = false;
        }
      }

      return allSuccess;
    } catch (e) {
      print('❌ 刪除模型 $model 所有規格失敗: $e');
      return false;
    }
  }

  /// 刪除特定模型的所有fail count記錄
  Future<bool> deleteAllModelFailCounts({
    required String model,
  }) async {
    try {
      // 首先獲取所有該模型的fail count文檔
      final url =
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery?key=$apiKey';

      final body = json.encode({
        "structuredQuery": {
          "from": [
            {"collectionId": "failcounts"}
          ],
          "where": {
            "compositeFilter": {
              "op": "AND",
              "filters": [
                {
                  "fieldFilter": {
                    "field": {"fieldPath": "__name__"},
                    "op": "GREATER_THAN_OR_EQUAL",
                    "value": {
                      "stringValue":
                          "projects/$projectId/databases/(default)/documents/failcounts/$model"
                    }
                  }
                },
                {
                  "fieldFilter": {
                    "field": {"fieldPath": "__name__"},
                    "op": "LESS_THAN",
                    "value": {
                      "stringValue":
                          "projects/$projectId/databases/(default)/documents/failcounts/${model}z"
                    }
                  }
                }
              ]
            }
          }
        }
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data as List<dynamic>? ?? [];

        bool allSuccess = true;

        // 刪除每個找到的文檔
        for (final docWrapper in documents) {
          final doc = docWrapper['document'];
          if (doc != null) {
            final String documentName = doc['name'] as String;
            // 從完整路徑中提取用於DELETE請求的路徑
            final pathParts = documentName.split('/documents/')[1];
            final deleteUrl =
                'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$pathParts?key=$apiKey';

            final deleteResponse = await http.delete(
              Uri.parse(deleteUrl),
              headers: {'Content-Type': 'application/json'},
            );

            if (deleteResponse.statusCode != 200 &&
                deleteResponse.statusCode != 404) {
              print(
                  '⚠️ 刪除fail count文檔失敗: $documentName, status: ${deleteResponse.statusCode}');
              allSuccess = false;
            }
          }
        }

        return allSuccess;
      } else {
        print('⚠️ 查詢fail count文檔失敗: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ 刪除模型 $model 所有fail count失敗: $e');
      return false;
    }
  }
}

Future<void> fetchAndPsuSerialNumSpecs(String model) async {
  final firebaseService = FirebaseService();
  final tableNames = ['PsuSerialNumSpec'];

  final specs = await firebaseService.getAllSpecs(
    model: model,
    tableNames: tableNames,
  );
  final specMap = specs['PsuSerialNumSpec'];
  if (specMap != null) {
    // 把資料存到全域變數
    globalPsuSerialNumSpec = PsuSerialNumSpec.fromJson(specMap);

    print('=== PsuSerialNumSpec ===');
    print(globalPsuSerialNumSpec); // 直接印出全域變數內容
  }
  for (var entry in specs.entries) {
    print('=== ${entry.key} ===');
    print(jsonEncode(entry.value));
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


Future<void> fetchAndPrintPackageListSpecs(String model) async {
  final firebaseService = FirebaseService();
  final tableNames = ['PackageListSpec'];

  final specs = await firebaseService.getAllSpecs(
    model: model,
    tableNames: tableNames,
  );
  final specMap = specs['PackageListSpec'];
  if (specMap != null) {
    // 把資料存到全域變數
    globalPackageListSpec = PackageListSpec.fromJson(specMap);

    print('=== PackageListSpec ===');
    print(globalPackageListSpec); // 直接印出全域變數內容
  }
  for (var entry in specs.entries) {
    print('=== ${entry.key} ===');
    print(jsonEncode(entry.value));
  }
}

/// 撈取 /models/{model}/PackageListSpec/spec 文件，並回傳 spec 內容 Map
Future<PackageListResult?> fetchPackageListSpec(String model) async {
  final String projectId = 'oqcreport-87e5a';
  final String apiKey = 'AIzaSyBzlul4mftI7HHJnj48I2aUs2nV154x0iI'; // 替換為你的 API Key
  final url =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/models/$model/PackageListSpec/spec?key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final specField = data['fields']?['spec'];
    if (specField != null && specField is Map) {
      final fieldsMap = specField['mapValue']?['fields'];
      if (fieldsMap != null && fieldsMap is Map<String, dynamic>) {
        final specData = _fromFirestoreFields(Map<String, dynamic>.from(fieldsMap));

        // 轉換 measurements 內的 map<string, object> 到 List<Map>
        if (specData.containsKey('measurements')) {
          final measurementsRaw = specData['measurements'];
          if (measurementsRaw is Map<String, dynamic>) {
            final measurementsList = measurementsRaw.entries
                .toList()
              ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
            final parsedList = measurementsList.map((e) => e.value).toList();
            specData['measurements'] = parsedList;
          }
        }

        // 呼叫轉換函式，把 specData 轉成 PackageListResult
        return packageListResultFromSpecData(specData);
      }
    }
    return null;
  } else if (response.statusCode == 404) {
    return null;
  } else {
    throw Exception('Failed to fetch PackageListSpec spec, statusCode=${response.statusCode}');
  }
}


Map<String, dynamic> _fromFirestoreFields(Map<String, dynamic> fields) {
  final result = <String, dynamic>{};

  fields.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      if (value.containsKey('stringValue')) {
        result[key] = value['stringValue'];
      } else if (value.containsKey('integerValue')) {
        result[key] = int.tryParse(value['integerValue'].toString()) ?? 0;
      } else if (value.containsKey('doubleValue')) {
        result[key] = double.tryParse(value['doubleValue'].toString()) ?? 0.0;
      } else if (value.containsKey('booleanValue')) {
        result[key] = value['booleanValue'];
      } else if (value.containsKey('mapValue')) {
        final nestedFields = value['mapValue']['fields'] as Map<String, dynamic>? ?? {};
        result[key] = _fromFirestoreFields(nestedFields);
      } else if (value.containsKey('arrayValue')) {
        final arrayValues = value['arrayValue']['values'] as List<dynamic>? ?? [];
        result[key] = arrayValues.map((e) {
          if (e is Map<String, dynamic>) {
            return _fromFirestoreFields(e);
          } else {
            return e;
          }
        }).toList();
      } else {
        result[key] = value; // fallback，可能是 null 或其他型態
      }
    } else {
      result[key] = value; // fallback
    }
  });

  return result;
}



Future<bool> uploadPackageListSpec({
  required String model,
  required String tableName,
  required PackageListResult packageListResult,
}) async {
  final firebaseService = FirebaseService();

  // 轉成 List 格式也可以，這邊示範 Map 格式保持你原本寫法
  Map<String, dynamic> specData = {
    "measurements": packageListResult.measurements.asMap().map((index, m) => MapEntry(
      index.toString(),
      {
        "itemName": m.itemName,
        "quantity": m.quantity,
        "isChecked": m.isCheck.value,
      },
    ))
  };

  print('準備上傳資料: $specData');

  bool success = await firebaseService.addOrUpdateSpec(
    model: model,
    tableName: tableName,
    spec: specData,
  );

  print('上傳結果: $success');
  return success;
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

/// 測試新的getModelList()方法
Future<void> testNewGetModelList() async {
  print('\n🧪 === 測試新的getModelList()方法 ===');

  try {
    final firebaseService = FirebaseService();
    final models = await firebaseService.getModelList();

    print('\n📝 獲取到的模型列表:');
    for (int i = 0; i < models.length; i++) {
      print('  ${i + 1}. ${models[i]}');
    }

    print('\n🎯 期望的模型列表:');
    final expectedModels = [
      "DDYA362F0QEFOA",
      "DDYA362F0QEFOA-RW",
      "DDYA482F0VEFUU",
      "DOYE362000D3PN",
      "EV100",
      "EV1000",
      "EV500"
    ];

    for (int i = 0; i < expectedModels.length; i++) {
      final expected = expectedModels[i];
      final found = models.contains(expected);
      print('  ${found ? '✅' : '❌'} $expected ${found ? '(找到)' : '(未找到)'}');
    }

    print('\n📊 統計:');
    print('  實際獲取: ${models.length} 個模型');
    print('  期望獲取: ${expectedModels.length} 個模型');
    print(
        '  匹配數量: ${expectedModels.where((e) => models.contains(e)).length} 個');
  } catch (e) {
    print('❌ 測試失敗: $e');
  }
}
