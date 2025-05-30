// 這邊先放你的 psu serial numbers Spec 類別
bool globalPackageListSpecInitialized = false;

class PsuSerialNumSpec {
  int? qty;

  PsuSerialNumSpec({
    required this.qty,
  });

  factory PsuSerialNumSpec.fromJson(Map<String, dynamic> json) {
    return PsuSerialNumSpec(
      qty: _parseNullableInt(json['QTY']),
    );
  }

  PsuSerialNumSpec copyWith({
    int? qty,
  }) {
    return PsuSerialNumSpec(
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toJson() => {
    'QTY': qty,
  };

  @override
  String toString() {
    return 'PsuSerialNumSpec('
        'QTY: $qty'
        ')';
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

// 在檔案最上層宣告一個全域變數
PsuSerialNumSpec? globalPsuSerialNumSpec;
