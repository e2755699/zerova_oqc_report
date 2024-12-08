class testfunction {
  final Result cabinet;
  final Result copper;


  testfunction({
    required this.cabinet,
    required this.copper,

  });

  /// 從單個 JSON 對象創建 `softwareversion`
  factory testfunction.fromJson(Map<String, dynamic> json) {
    return testfunction(
      cabinet: Result(
        value: json["機櫃"] ?? "未找到",
        key: "機櫃",
        name: "cabinet",
      ),
      copper: Result(
        value: json["銅排"] ?? "未找到",
        key: "銅排",
        name: "copper",
      ),
    );
  }

  /// 從 JSON 數據清單提取並生成 `softwareversion`
  static testfunction fromJsonList(List<dynamic> data) {
    Map<String, String> results = {
      "機櫃": "未找到",
      "銅排": "未找到",
    };

    for (var item in data) {
      String? itemDesc = item['ITEM_NAME'];
      String? inspValue = item['INSP_RESULT'];  // 確保 spcValue 是 String 類型

      if (itemDesc != null && inspValue != null) {
        for (var key in results.keys) {
          if (itemDesc.contains(key)) {
            results[key] = inspValue;  // 儲存為 String 類型
          }
        }
      }
    }

    // 生成並返回 `softwareversion` 實例
    return testfunction.fromJson(results);
  }
}

class Result {
  final String value;  // value 類型由 double 改為 String
  final String key;
  final String name;

  Result({
    required this.value,
    required this.key,
    required this.name,
  });
}
