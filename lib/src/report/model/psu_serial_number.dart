class Psuserialnumber {
  final List<SerialNumber> psuSN; // 確保這裡是 List<Serialnumber>

  Psuserialnumber({required this.psuSN});

  /// 從 JSON 數據清單提取並生成多筆 PSU SN
  static Psuserialnumber fromJsonList(List<dynamic> data) {
    List<SerialNumber> serialNumbers = [];
    double spec = 4;
    for (var item in data) {
      String? spcDesc = item['ITEM_PART_SPECS'];
      String? spcValue = item['ITEM_PART_SN']; // 確保 spcValue 是 String 類型

      if (spcDesc != null && spcValue != null && spcDesc.contains("CHARGING MODULE")) {
        serialNumbers.add(SerialNumber(
          spec: spec,
          value: spcValue,
          key: "PSU SN",
          name: "PSU",
        ));
      }
    }

    // 返回包含多筆 PSU SN 的 psuserialnumber 實例
    return Psuserialnumber(psuSN: serialNumbers);
  }
}

class SerialNumber {
  final double spec;
  final String value;
  final String key;
  final String name;

  SerialNumber({
    required this.spec,
    required this.value,
    required this.key,
    required this.name});
}
