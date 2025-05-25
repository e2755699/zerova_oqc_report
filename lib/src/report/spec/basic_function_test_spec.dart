// 這邊先放你的 InputOutputCharacteristicsSpec 類別
// 假設它長這樣（你可以換成你自己完整的實作）

class BasicFunctionTestSpec {
   double eff;
   double pf;
   double thd;
   double sp;

  BasicFunctionTestSpec({
    required this.eff,
    required this.pf,
    required this.thd,
    required this.sp,
  });

   factory BasicFunctionTestSpec.fromJson(Map<String, dynamic> json) {
     double parseDouble(dynamic value) {
       return (value is num)
           ? value.toDouble()
           : double.tryParse(value.toString()) ?? double.nan;
     }
     return BasicFunctionTestSpec(
       eff: parseDouble(json['EFF']),
       pf: parseDouble(json['PF']),
       thd: parseDouble(json['THD']),
       sp: parseDouble(json['SP']),
     );
   }

   BasicFunctionTestSpec copyWith({
     double? eff,
     double? pf,
     double? thd,
     double? sp,
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
