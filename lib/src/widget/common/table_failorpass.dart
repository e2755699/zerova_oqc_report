bool psuSNPassOrFail = false;
bool swVerPassOrFail = false;
bool appearanceStructureInspectionPassOrFail = false;
bool ioCharacteristicsPassOrFail = false;
bool basicFunctionTestPassOrFail = false;
bool protectionFunctionTestPassOrFail = false;
bool hipotTestPassOrFail = false;

// 全局判斷結果變數
bool globalJudgementResult = false;

// 全局判斷監聽器類別
class GlobalJudgementMonitor {
  static void updateGlobalJudgement() {
    bool allPassed = psuSNPassOrFail &&
        swVerPassOrFail &&
        appearanceStructureInspectionPassOrFail &&
        ioCharacteristicsPassOrFail &&
        basicFunctionTestPassOrFail &&
        protectionFunctionTestPassOrFail &&
        hipotTestPassOrFail;

    globalJudgementResult = allPassed;

    // 如果全部 PASS，可以在這裡加入額外的邏輯
    if (allPassed) {
      print('✅ 所有測試項目都已通過，全局判斷結果: PASS');
    } else {
      print('❌ 仍有測試項目未通過，全局判斷結果: FAIL');
    }
  }

  // 更新個別測試項目的 pass/fail 狀態
  static void updateTestResult(String testName, bool result) {
    switch (testName) {
      case 'psuSN':
        psuSNPassOrFail = result;
        break;
      case 'swVer':
        swVerPassOrFail = result;
        break;
      case 'appearanceStructureInspection':
        appearanceStructureInspectionPassOrFail = result;
        break;
      case 'ioCharacteristics':
        ioCharacteristicsPassOrFail = result;
        break;
      case 'basicFunctionTest':
        basicFunctionTestPassOrFail = result;
        break;
      case 'protectionFunctionTest':
        protectionFunctionTestPassOrFail = result;
        break;
      case 'hipotTest':
        hipotTestPassOrFail = result;
        break;
    }
    updateGlobalJudgement();
  }

  // 獲取全局判斷結果
  static bool getGlobalJudgement() {
    return globalJudgementResult;
  }

  // 獲取所有測試項目的狀態
  static Map<String, bool> getAllTestResults() {
    return {
      'psuSN': psuSNPassOrFail,
      'swVer': swVerPassOrFail,
      'appearanceStructureInspection': appearanceStructureInspectionPassOrFail,
      'ioCharacteristics': ioCharacteristicsPassOrFail,
      'basicFunctionTest': basicFunctionTestPassOrFail,
      'protectionFunctionTest': protectionFunctionTestPassOrFail,
      'hipotTest': hipotTestPassOrFail,
    };
  }
}
