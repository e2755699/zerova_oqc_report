class psuserialnumber {
  final List<Serialnumber> psuSN; // 確保這裡是 List<Serialnumber>

  psuserialnumber({required this.psuSN});

  /// 從 JSON 數據清單提取並生成多筆 PSU SN
  static psuserialnumber fromJsonList(List<dynamic> data) {
    List<Serialnumber> serialNumbers = [];

    for (var item in data) {
      String? spcDesc = item['ITEM_PART_SPECS'];
      String? spcValue = item['ITEM_PART_SN']; // 確保 spcValue 是 String 類型

      if (spcDesc != null && spcValue != null && spcDesc.contains("CHARGING MODULE")) {
        serialNumbers.add(Serialnumber(
          value: spcValue,
          key: "PSU SN",
          name: "PSU",
        ));
      }
    }

    // 返回包含多筆 PSU SN 的 psuserialnumber 實例
    return psuserialnumber(psuSN: serialNumbers);
  }
}

class Serialnumber {
  final String value;
  final String key;
  final String name;

  Serialnumber({
    required this.value,
    required this.key,
    required this.name});
}
