class softwareversion {
  final Version csuRootfs;
  final Version fanModule;
  final Version relayModule;
  final Version primaryMCU;
  final Version connector1;
  final Version connector2;
  final Version lcmUI;
  final Version ledModule;

  softwareversion({
    required this.csuRootfs,
    required this.fanModule,
    required this.relayModule,
    required this.primaryMCU,
    required this.connector1,
    required this.connector2,
    required this.lcmUI,
    required this.ledModule,
  });

  /// 從單個 JSON 對象創建 `softwareversion`
  factory softwareversion.fromJson(Map<String, dynamic> json) {
    return softwareversion(
      csuRootfs: Version(
        value: json["CSU Rootfs"] ?? "未找到",
        key: "CSU Rootfs",
        name: "CSU",
      ),
      fanModule: Version(
        value: json["FAN Module"] ?? "未找到",
        key: "FAN Module",
        name: "FAN Module",
      ),
      relayModule: Version(
        value: json["Relay Module"] ?? "未找到",
        key: "Relay Module",
        name: "Relay Board",
      ),
      primaryMCU: Version(
        value: json["Primary MCU"] ?? "未找到",
        key: "Primary MCU",
        name: "MCU",
      ),
      connector1: Version(
        value: json["Connector 1"] ?? "未找到",
        key: "Connector 1",
        name: "CCS 1",
      ),
      connector2: Version(
        value: json["Connector 2"] ?? "未找到",
        key: "Connector 2",
        name: "CCS 2",
      ),
      lcmUI: Version(
        value: json["LCM UI"] ?? "未找到",
        key: "LCM UI",
        name: "UI",
      ),
      ledModule: Version(
        value: json["LED Module"] ?? "未找到",  // value 改為 String
        key: "LED Module",
        name: "LED",
      ),
    );
  }

  /// 從 JSON 數據清單提取並生成 `softwareversion`
  static softwareversion fromJsonList(List<dynamic> data) {
    Map<String, String> results = {
      "CSU Rootfs": "未找到",
      "FAN Module": "未找到",
      "Relay Module": "未找到",
      "Primary MCU": "未找到",
      "Connector 1": "未找到",
      "Connector 2": "未找到",
      "LCM UI": "未找到",
      "LED Module": "未找到",
    };

    for (var item in data) {
      String? spcDesc = item['SPC_DESC'];
      String? spcValue = item['SPC_VALUE'];  // 確保 spcValue 是 String 類型

      if (spcDesc != null && spcValue != null) {
        for (var key in results.keys) {
          if (spcDesc.contains(key)) {
            results[key] = spcValue;  // 儲存為 String 類型
          }
        }
      }
    }

    // 生成並返回 `softwareversion` 實例
    return softwareversion.fromJson(results);
  }
}

class Version {
  final String value;  // value 類型由 double 改為 String
  final String key;
  final String name;

  Version({
    required this.value,
    required this.key,
    required this.name,
  });
}
