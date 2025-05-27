// 這邊先放你的 Package List Spec 類別
bool globalPackageListSpecInitialized = false;

class PackageListSpec {
  String rfidcard;
  String productcertificatecard;
  String screwassym4;
  String boltscover;
  String usermanual;

  int? rfidcardspec;
  int? productcertificatecardspec;
  int? screwassym4spec;
  int? boltscoverspec;
  int? usermanualspec;

  PackageListSpec({
    required this.rfidcard,
    required this.productcertificatecard,
    required this.screwassym4,
    required this.boltscover,
    required this.usermanual,
    required this.rfidcardspec,
    required this.productcertificatecardspec,
    required this.screwassym4spec,
    required this.boltscoverspec,
    required this.usermanualspec,
  });

  factory PackageListSpec.fromJson(Map<String, dynamic> json) {
    return PackageListSpec(
      rfidcard: json['RFIDCNAME']?.toString() ?? '',
      productcertificatecard: json['PCCAME']?.toString() ?? '',
      screwassym4: json['SAM4AME']?.toString() ?? '',
      boltscover: json['BCNAME']?.toString() ?? '',
      usermanual: json['UMNAME']?.toString() ?? '',
      rfidcardspec: _parseNullableInt(json['RFIDCSPEC']),
      productcertificatecardspec: _parseNullableInt(json['PCCSPEC']),
      screwassym4spec: _parseNullableInt(json['SAM4SPEC']),
      boltscoverspec: _parseNullableInt(json['BCSPEC']),
      usermanualspec: _parseNullableInt(json['UMSPEC']),
    );
  }




  PackageListSpec copyWith({
    String? rfidcard,
    String? productcertificatecard,
    String? screwassym4,
    String? boltscover,
    String? usermanual,
    int? rfidcardspec,
    int? productcertificatecardspec,
    int? screwassym4spec,
    int? boltscoverspec,
    int? usermanualspec,
  }) {
    return PackageListSpec(
      rfidcard: rfidcard ?? this.rfidcard,
      productcertificatecard: productcertificatecard ?? this.productcertificatecard,
      screwassym4: screwassym4 ?? this.screwassym4,
      boltscover: boltscover ?? this.boltscover,
      usermanual: usermanual ?? this.usermanual,
      rfidcardspec: rfidcardspec ?? this.rfidcardspec,
      productcertificatecardspec: productcertificatecardspec ?? this.productcertificatecardspec,
      screwassym4spec: screwassym4spec ?? this.screwassym4spec,
      boltscoverspec: boltscoverspec ?? this.boltscoverspec,
      usermanualspec: usermanualspec ?? this.usermanualspec,
    );
  }



  Map<String, dynamic> toJson() => {
    'RFIDCNAME': rfidcard,
    'PCCAME': productcertificatecard,
    'SAM4AME': screwassym4,
    'BCNAME': boltscover,
    'UMNAME': usermanual,
    'RFIDCSPEC': rfidcardspec,
    'PCCSPEC': productcertificatecardspec,
    'SAM4SPEC': screwassym4spec,
    'BCSPEC': boltscoverspec,
    'UMSPEC': usermanualspec,
  };


  @override
  String toString() {
    return 'PackageListSpec('
        'RFIDCNAME: $rfidcard, '
        'PCCAME: $productcertificatecard, '
        'SAM4AME: $screwassym4, '
        'BCNAME: $boltscover, '
        'UMNAME: $usermanual, '
        'RFIDCSPEC: $rfidcardspec, '
        'PCCSPEC: $productcertificatecardspec, '
        'SAM4SPEC: $screwassym4spec, '
        'BCSPEC: $boltscoverspec, '
        'UMSPEC: $usermanualspec'
        ')';
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

}

// 在檔案最上層宣告一個全域變數
PackageListSpec? globalPackageListSpec;
