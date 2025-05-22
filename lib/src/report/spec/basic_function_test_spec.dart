// 這邊先放你的 InputOutputCharacteristicsSpec 類別
// 假設它長這樣（你可以換成你自己完整的實作）

class BasicFunctionTestSpec {
  final String eff;
  final String pf;
  final String thd;
  final String sp;

  BasicFunctionTestSpec({
    required this.eff,
    required this.pf,
    required this.thd,
    required this.sp,
  });

  factory BasicFunctionTestSpec.fromJson(Map<String, dynamic> json) {
    return BasicFunctionTestSpec(
      eff: json['EFF'] ?? '',
      pf: json['PF'] ?? '',
      thd: json['THD'] ?? '',
      sp: json['SP'] ?? '',
    );
  }

  BasicFunctionTestSpec copyWith({
    String? eff,
    String? pf,
    String? thd,
    String? sp,
  }) {
    return BasicFunctionTestSpec(
      eff: eff ?? this.eff,
      pf: pf ?? this.pf,
      thd: thd ?? this.thd,
      sp: sp ?? this.sp,
    );
  }

  Map<String, dynamic> toJson() => {
    'EFF': eff,
    'PF': pf,
    'THD': thd,
    'SP': sp,
  };

  @override
  String toString() {
    return 'EFF: $eff, PF: $pf, THD: $thd, SP: $sp';
  }
}

// 在檔案最上層宣告一個全域變數
BasicFunctionTestSpec? globalBasicFunctionTestSpec;
