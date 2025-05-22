// 這邊先放你的 InputOutputCharacteristicsSpec 類別
// 假設它長這樣（你可以換成你自己完整的實作）

class InputOutputCharacteristicsSpec {
  final String vin;
  final String iin;
  final String pin;
  final String vout;
  final String iout;
  final String pout;

  InputOutputCharacteristicsSpec({
    required this.vin,
    required this.iin,
    required this.pin,
    required this.vout,
    required this.iout,
    required this.pout,
  });

  factory InputOutputCharacteristicsSpec.fromJson(Map<String, dynamic> json) {
    return InputOutputCharacteristicsSpec(
      vin: json['Vin'] ?? '',
      iin: json['Iin'] ?? '',
      pin: json['Pin'] ?? '',
      vout: json['Vout'] ?? '',
      iout: json['Iout'] ?? '',
      pout: json['Pout'] ?? '',
    );
  }

  InputOutputCharacteristicsSpec copyWith({
    String? vin,
    String? iin,
    String? pin,
    String? vout,
    String? iout,
    String? pout,
  }) {
    return InputOutputCharacteristicsSpec(
      vin: vin ?? this.vin,
      iin: iin ?? this.iin,
      pin: pin ?? this.pin,
      vout: vout ?? this.vout,
      iout: iout ?? this.iout,
      pout: pout ?? this.pout,
    );
  }

  Map<String, dynamic> toJson() => {
    'Vin': vin,
    'Iin': iin,
    'Pin': pin,
    'Vout': vout,
    'Iout': iout,
    'Pout': pout,
  };

  @override
  String toString() {
    return 'Vin: $vin, Iin: $iin, Pin: $pin, Vout: $vout, Iout: $iout, Pout: $pout';
  }
}

// 在檔案最上層宣告一個全域變數
InputOutputCharacteristicsSpec? globalInputOutputSpec;
