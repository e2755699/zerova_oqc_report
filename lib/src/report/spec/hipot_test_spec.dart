// 這邊先放你的 Hipot test Spec 類別

class HipotTestSpec {
  double insulationimpedancespec;
  double leakagecurrentspec;

  HipotTestSpec({
    required this.insulationimpedancespec,
    required this.leakagecurrentspec,
  });

  factory HipotTestSpec.fromJson(Map<String, dynamic> json) {
    return HipotTestSpec(
      insulationimpedancespec: (json['II'] is num) ? (json['II'] as num).toDouble() : double.tryParse(json['II'].toString()) ?? double.nan,
      leakagecurrentspec: (json['LC'] is num) ? (json['LC'] as num).toDouble() : double.tryParse(json['LC'].toString()) ?? double.nan,
    );
  }


  HipotTestSpec copyWith({
    double? insulationimpedancespec,
    double? leakagecurrentspec,
  }) {
    return HipotTestSpec(
      insulationimpedancespec: insulationimpedancespec ?? this.insulationimpedancespec,
      leakagecurrentspec: leakagecurrentspec ?? this.leakagecurrentspec,
    );
  }

  Map<String, dynamic> toJson() => {
    'II': insulationimpedancespec,
    'LC': leakagecurrentspec,
  };

  @override
  String toString() {
    return 'II: $insulationimpedancespec, LC: $leakagecurrentspec';
  }
}

// 在檔案最上層宣告一個全域變數
HipotTestSpec? globalHipotTestSpec;
