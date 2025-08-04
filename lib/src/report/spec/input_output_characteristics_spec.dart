// 這邊先放你的 InputOutputCharacteristicsSpec 類別
// 假設它長這樣（你可以換成你自己完整的實作）

class InputOutputCharacteristicsSpec {
  double leftVinLowerbound;
  double leftVinUpperbound;
  double leftIinLowerbound;
  double leftIinUpperbound;
  double leftPinLowerbound;
  double leftPinUpperbound;
  double leftVoutLowerbound;
  double leftVoutUpperbound;
  double leftIoutLowerbound;
  double leftIoutUpperbound;
  double leftPoutLowerbound;
  double leftPoutUpperbound;

  double rightVinLowerbound;
  double rightVinUpperbound;
  double rightIinLowerbound;
  double rightIinUpperbound;
  double rightPinLowerbound;
  double rightPinUpperbound;
  double rightVoutLowerbound;
  double rightVoutUpperbound;
  double rightIoutLowerbound;
  double rightIoutUpperbound;
  double rightPoutLowerbound;
  double rightPoutUpperbound;

  // 新增：Pin 和 Pout 的單位選擇
  String leftPinUnit;
  String leftPoutUnit;
  String rightPinUnit;
  String rightPoutUnit;

  InputOutputCharacteristicsSpec({
    required this.leftVinLowerbound,
    required this.leftVinUpperbound,
    required this.leftIinLowerbound,
    required this.leftIinUpperbound,
    required this.leftPinLowerbound,
    required this.leftPinUpperbound,
    required this.leftVoutLowerbound,
    required this.leftVoutUpperbound,
    required this.leftIoutLowerbound,
    required this.leftIoutUpperbound,
    required this.leftPoutLowerbound,
    required this.leftPoutUpperbound,
    required this.rightVinLowerbound,
    required this.rightVinUpperbound,
    required this.rightIinLowerbound,
    required this.rightIinUpperbound,
    required this.rightPinLowerbound,
    required this.rightPinUpperbound,
    required this.rightVoutLowerbound,
    required this.rightVoutUpperbound,
    required this.rightIoutLowerbound,
    required this.rightIoutUpperbound,
    required this.rightPoutLowerbound,
    required this.rightPoutUpperbound,
    // Pin 預設 kVA，Pout 預設 kW
    this.leftPinUnit = 'kVA',
    this.leftPoutUnit = 'kW',
    this.rightPinUnit = 'kVA',
    this.rightPoutUnit = 'kW',
  });

  factory InputOutputCharacteristicsSpec.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      return (value is num)
          ? value.toDouble()
          : double.tryParse(value.toString()) ?? double.nan;
    }

    return InputOutputCharacteristicsSpec(
      leftVinLowerbound: parseDouble(json['LVinLB']),
      leftVinUpperbound: parseDouble(json['LVinUB']),
      leftIinLowerbound: parseDouble(json['LIinLB']),
      leftIinUpperbound: parseDouble(json['LIinUB']),
      leftPinLowerbound: parseDouble(json['LPinLB']),
      leftPinUpperbound: parseDouble(json['LPinUB']),
      leftVoutLowerbound: parseDouble(json['LVoutLB']),
      leftVoutUpperbound: parseDouble(json['LVoutUB']),
      leftIoutLowerbound: parseDouble(json['LIoutLB']),
      leftIoutUpperbound: parseDouble(json['LIoutUB']),
      leftPoutLowerbound: parseDouble(json['LPoutLB']),
      leftPoutUpperbound: parseDouble(json['LPoutUB']),
      rightVinLowerbound: parseDouble(json['RVinLB']),
      rightVinUpperbound: parseDouble(json['RVinUB']),
      rightIinLowerbound: parseDouble(json['RIinLB']),
      rightIinUpperbound: parseDouble(json['RIinUB']),
      rightPinLowerbound: parseDouble(json['RPinLB']),
      rightPinUpperbound: parseDouble(json['RPinUB']),
      rightVoutLowerbound: parseDouble(json['RVoutLB']),
      rightVoutUpperbound: parseDouble(json['RVoutUB']),
      rightIoutLowerbound: parseDouble(json['RIoutLB']),
      rightIoutUpperbound: parseDouble(json['RIoutUB']),
      rightPoutLowerbound: parseDouble(json['RPoutLB']),
      rightPoutUpperbound: parseDouble(json['RPoutUB']),
      // 讀取單位，若無則使用預設值
      leftPinUnit: json['LPinUnit']?.toString() ?? 'kVA',
      leftPoutUnit: json['LPoutUnit']?.toString() ?? 'kW',
      rightPinUnit: json['RPinUnit']?.toString() ?? 'kVA',
      rightPoutUnit: json['RPoutUnit']?.toString() ?? 'kW',
    );
  }

  InputOutputCharacteristicsSpec copyWith({
    double? leftVinLowerbound,
    double? leftVinUpperbound,
    double? leftIinLowerbound,
    double? leftIinUpperbound,
    double? leftPinLowerbound,
    double? leftPinUpperbound,
    double? leftVoutLowerbound,
    double? leftVoutUpperbound,
    double? leftIoutLowerbound,
    double? leftIoutUpperbound,
    double? leftPoutLowerbound,
    double? leftPoutUpperbound,
    double? rightVinLowerbound,
    double? rightVinUpperbound,
    double? rightIinLowerbound,
    double? rightIinUpperbound,
    double? rightPinLowerbound,
    double? rightPinUpperbound,
    double? rightVoutLowerbound,
    double? rightVoutUpperbound,
    double? rightIoutLowerbound,
    double? rightIoutUpperbound,
    double? rightPoutLowerbound,
    double? rightPoutUpperbound,
    String? leftPinUnit,
    String? leftPoutUnit,
    String? rightPinUnit,
    String? rightPoutUnit,
  }) {
    return InputOutputCharacteristicsSpec(
      leftVinLowerbound: leftVinLowerbound ?? this.leftVinLowerbound,
      leftVinUpperbound: leftVinUpperbound ?? this.leftVinUpperbound,
      leftIinLowerbound: leftIinLowerbound ?? this.leftIinLowerbound,
      leftIinUpperbound: leftIinUpperbound ?? this.leftIinUpperbound,
      leftPinLowerbound: leftPinLowerbound ?? this.leftPinLowerbound,
      leftPinUpperbound: leftPinUpperbound ?? this.leftPinUpperbound,
      leftVoutLowerbound: leftVoutLowerbound ?? this.leftVoutLowerbound,
      leftVoutUpperbound: leftVoutUpperbound ?? this.leftVoutUpperbound,
      leftIoutLowerbound: leftIoutLowerbound ?? this.leftIoutLowerbound,
      leftIoutUpperbound: leftIoutUpperbound ?? this.leftIoutUpperbound,
      leftPoutLowerbound: leftPoutLowerbound ?? this.leftPoutLowerbound,
      leftPoutUpperbound: leftPoutUpperbound ?? this.leftPoutUpperbound,
      rightVinLowerbound: rightVinLowerbound ?? this.rightVinLowerbound,
      rightVinUpperbound: rightVinUpperbound ?? this.rightVinUpperbound,
      rightIinLowerbound: rightIinLowerbound ?? this.rightIinLowerbound,
      rightIinUpperbound: rightIinUpperbound ?? this.rightIinUpperbound,
      rightPinLowerbound: rightPinLowerbound ?? this.rightPinLowerbound,
      rightPinUpperbound: rightPinUpperbound ?? this.rightPinUpperbound,
      rightVoutLowerbound: rightVoutLowerbound ?? this.rightVoutLowerbound,
      rightVoutUpperbound: rightVoutUpperbound ?? this.rightVoutUpperbound,
      rightIoutLowerbound: rightIoutLowerbound ?? this.rightIoutLowerbound,
      rightIoutUpperbound: rightIoutUpperbound ?? this.rightIoutUpperbound,
      rightPoutLowerbound: rightPoutLowerbound ?? this.rightPoutLowerbound,
      rightPoutUpperbound: rightPoutUpperbound ?? this.rightPoutUpperbound,
      leftPinUnit: leftPinUnit ?? this.leftPinUnit,
      leftPoutUnit: leftPoutUnit ?? this.leftPoutUnit,
      rightPinUnit: rightPinUnit ?? this.rightPinUnit,
      rightPoutUnit: rightPoutUnit ?? this.rightPoutUnit,
    );
  }

  Map<String, dynamic> toJson() => {
        // 左側欄位
        'LVinLB': leftVinLowerbound,
        'LVinUB': leftVinUpperbound,
        'LIinLB': leftIinLowerbound,
        'LIinUB': leftIinUpperbound,
        'LPinLB': leftPinLowerbound,
        'LPinUB': leftPinUpperbound,
        'LVoutLB': leftVoutLowerbound,
        'LVoutUB': leftVoutUpperbound,
        'LIoutLB': leftIoutLowerbound,
        'LIoutUB': leftIoutUpperbound,
        'LPoutLB': leftPoutLowerbound,
        'LPoutUB': leftPoutUpperbound,

        // 右側欄位
        'RVinLB': rightVinLowerbound,
        'RVinUB': rightVinUpperbound,
        'RIinLB': rightIinLowerbound,
        'RIinUB': rightIinUpperbound,
        'RPinLB': rightPinLowerbound,
        'RPinUB': rightPinUpperbound,
        'RVoutLB': rightVoutLowerbound,
        'RVoutUB': rightVoutUpperbound,
        'RIoutLB': rightIoutLowerbound,
        'RIoutUB': rightIoutUpperbound,
        'RPoutLB': rightPoutLowerbound,
        'RPoutUB': rightPoutUpperbound,

        // 單位欄位
        'LPinUnit': leftPinUnit,
        'LPoutUnit': leftPoutUnit,
        'RPinUnit': rightPinUnit,
        'RPoutUnit': rightPoutUnit,
      };

  @override
  String toString() {
    return '''
      LVinLB: $leftVinLowerbound, LVinUB: $leftVinUpperbound,
      LIinLB: $leftIinLowerbound, LIinUB: $leftIinUpperbound,
      LPinLB: $leftPinLowerbound, LPinUB: $leftPinUpperbound ($leftPinUnit),
      LVoutLB: $leftVoutLowerbound, LVoutUB: $leftVoutUpperbound,
      LIoutLB: $leftIoutLowerbound, LIoutUB: $leftIoutUpperbound,
      LPoutLB: $leftPoutLowerbound, LPoutUB: $leftPoutUpperbound ($leftPoutUnit),
      RVinLB: $rightVinLowerbound, RVinUB: $rightVinUpperbound,
      RIinLB: $rightIinLowerbound, RIinUB: $rightIinUpperbound,
      RPinLB: $rightPinLowerbound, RPinUB: $rightPinUpperbound ($rightPinUnit),
      RVoutLB: $rightVoutLowerbound, RVoutUB: $rightVoutUpperbound,
      RIoutLB: $rightIoutLowerbound, RIoutUB: $rightIoutUpperbound,
      RPoutLB: $rightPoutLowerbound, RPoutUB: $rightPoutUpperbound ($rightPoutUnit),
      ''';
  }
}

// 在檔案最上層宣告一個全域變數
InputOutputCharacteristicsSpec? globalInputOutputSpec;
