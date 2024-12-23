class Testfunction {
  final Result csu;
  final Result psu;
  final Result label;
  final Result nameplate;
  final Result screen;
  final Result fan;
  final Result cables;
  final Result screws;
  final Result doorLock;
  final Result grounding;
  final Result waterproofing;
  final Result acrylicPanel;
  final Result chargingCable;
  final Result cabinet;
  final Result pallet;
  final Result burnInTest;

  Testfunction({
    required this.csu,
    required this.psu,
    required this.label,
    required this.nameplate,
    required this.screen,
    required this.fan,
    required this.cables,
    required this.screws,
    required this.doorLock,
    required this.grounding,
    required this.waterproofing,
    required this.acrylicPanel,
    required this.chargingCable,
    required this.cabinet,
    required this.pallet,
    required this.burnInTest,
  });


  factory Testfunction.fromJson(Map<String, dynamic> json) {
    return Testfunction(
      csu: Result(
        value: json["CSU"] ?? "未找到",
        key: "CSU",
        name: "CSU",
      ),
      psu: Result(
        value: json["PSU"] ?? "未找到",
        key: "PSU",
        name: "PSU",
      ),
      label: Result(
        value: json["標籤"] ?? "未找到",
        key: "標籤",
        name: "Label",
      ),
      nameplate: Result(
        value: json["銘牌"] ?? "未找到",
        key: "銘牌",
        name: "Nameplate",
      ),
      screen: Result(
        value: json["螢幕"] ?? "未找到",
        key: "螢幕",
        name: "Screen",
      ),
      fan: Result(
        value: json["風扇"] ?? "未找到",
        key: "風扇",
        name: "Fan",
      ),
      cables: Result(
        value: json["線材"] ?? "未找到",
        key: "線材",
        name: "Cables",
      ),
      screws: Result(
        value: json["螺絲"] ?? "未找到",
        key: "螺絲",
        name: "Screws",
      ),
      doorLock: Result(
        value: json["門鎖"] ?? "未找到",
        key: "門鎖",
        name: "Door Lock",
      ),
      grounding: Result(
        value: json["接地"] ?? "未找到",
        key: "接地",
        name: "Grounding",
      ),
      waterproofing: Result(
        value: json["防水"] ?? "未找到",
        key: "防水",
        name: "Waterproofing",
      ),
      acrylicPanel: Result(
        value: json["壓克力板"] ?? "未找到",
        key: "壓克力板",
        name: "Acrylic Panel",
      ),
      chargingCable: Result(
        value: json["槍線"] ?? "未找到",
        key: "槍線",
        name: "Charging Cable",
      ),
      cabinet: Result(
        value: json["機櫃"] ?? "未找到",
        key: "機櫃",
        name: "Cabinet",
      ),
      pallet: Result(
        value: json["棧板"] ?? "未找到",
        key: "棧板",
        name: "Pallet",
      ),
      burnInTest: Result(
        value: json["燒機"] ?? "未找到",
        key: "燒機",
        name: "Burn-in Test",
      ),
    );
  }

  static Testfunction fromJsonList(List<dynamic> data) {
    Map<String, String> results = {
      "CSU": "未找到",
      "PSU": "未找到",
      "標籤": "未找到",
      "銘牌": "未找到",
      "螢幕": "未找到",
      "風扇": "未找到",
      "線材": "未找到",
      "螺絲": "未找到",
      "門鎖": "未找到",
      "接地": "未找到",
      "防水": "未找到",
      "壓克力板": "未找到",
      "槍線": "未找到",
      "機櫃": "未找到",
      "棧板": "未找到",
      "燒機": "未找到",
    };

    Map<String, String> descMapping = {
      "需有防拆貼紙。": "未找到",
      "內容需依照圖面，不得有模糊、斷字、歪斜、刮花等不良": "未找到",
      "外觀不得有劃痕、髒汙、殘膠、氣泡等": "未找到",
      "確認風扇網及風扇的安裝方向(依箭頭方向確認)": "未找到",
      "確認線材連接位置、組裝是否到位、是否理線": "未找到",
      "整機不得有螺絲漏鎖、且須有確認扭力的畫線": "未找到",
      "大電力螺絲鎖附扭力值需確認": "未找到",
      "開關門鎖、轉動手把需運作正常": "未找到",
      "接地線安裝位置需與接地標籤相對應": "未找到",
      "防水膠需塗布均勻、塗布位置需依循防水對策規範": "未找到",
      "壓克力板不可晃動、劃痕": "未找到",
      "長度及規格需正確、槍頭絲印資訊需正確": "未找到",
      "機櫃外觀不得有掉漆、劃痕、髒污、生鏽、脫焊、色差等不良": "未找到",
      "機櫃內底部不得有異物": "未找到",
      "棧板扭力值需達標及畫線": "未找到",
      "確認LED亮燈狀況(故障/待機/充車)": "未找到",
      "確認電表功率的累積功率與實際功率值是否符合": "未找到",
      "記錄輸出銅牌溫度": "未找到",
    };

    for (var item in data) {
      String? itemName = item['ITEM_NAME'];
      String? itemDesc = item['ITEM_DESC'];
      String? inspResult = item['INSP_RESULT'];

      if (itemName != null && itemDesc != null && inspResult != null) {
        for (var key in results.keys) {
          if (itemDesc.contains(key)) {
            for (var descKey in descMapping.keys) {
              if (itemDesc.contains(descKey)) {
                if (inspResult == "NG") {
                   results[key] = inspResult;
                }
                else if(inspResult == "NA" || inspResult == "N/A") {
                  if (results[key] != "NG") {
                    results[key] = inspResult;
                  }
                }
                else if(inspResult == "OK") {
                  if (results[key] != "NG" && results[key] != "NA" && results[key] != "N/A") {
                    results[key] = inspResult;
                  }
                }
              }
            }
          }
        }
      }
    }


    return Testfunction.fromJson(results);
  }
}

class Result {
  final String value;
  final String key;
  final String name;

  Result({
    required this.value,
    required this.key,
    required this.name,
  });
}