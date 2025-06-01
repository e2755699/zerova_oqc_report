# Zerova OQC Report System - 資料結構文檔

本文檔詳細描述了Zerova OQC報告系統中所有資料結構的定義、欄位意義和使用方式。

## 📋 目錄

1. [Firebase 資料庫結構](#firebase-資料庫結構)
2. [規格數據模型 (Spec Models)](#規格數據模型-spec-models)
3. [報告數據模型 (Report Models)](#報告數據模型-report-models)
4. [測量與結果模型](#測量與結果模型)
5. [工具數據模型](#工具數據模型)
6. [枚舉類型定義](#枚舉類型定義)
7. [JSON 映射規則](#json-映射規則)

---

## 🔥 Firebase 資料庫結構

### 實際資料庫集合結構
```
projects/oqcreport-87e5a/databases/(default)/documents/
├── models/                                    # 模型規格管理
│   ├── {modelId}/                            # 具體模型ID (例: T2449A003A1)
│   │   ├── InputOutputCharacteristics/       # 輸入輸出特性規格
│   │   │   └── spec/                         # 規格文件
│   │   │       └── spec: {InputOutputCharacteristicsSpec}
│   │   ├── BasicFunctionTest/                # 基本功能測試規格
│   │   │   └── spec/
│   │   │       └── spec: {BasicFunctionTestSpec}
│   │   ├── HipotTestSpec/                    # 耐壓測試規格
│   │   │   └── spec/
│   │   │       └── spec: {HipotTestSpec}
│   │   ├── PsuSerialNumSpec/                 # PSU序號規格
│   │   │   └── spec/
│   │   │       └── spec: {PsuSerialNumSpec}
│   │   └── PackageListSpec/                  # 包裝清單規格
│   │       └── spec/
│   │           └── spec: {PackageListSpec}
├── machines/                                 # 測試設備資料
│   └── {machineId}/                         # 設備ID (例: 1-1)
│       ├── model: string                    # 設備型號
│       ├── sn: string                       # 設備序號
│       ├── voltage: number                  # 電壓參數
│       ├── current: number                  # 電流參數
│       └── power: number                    # 功率參數
├── users/                                   # 用戶管理
│   └── {userId}/                           # 用戶ID
│       ├── name: string                    # 用戶姓名
│       ├── email: string                   # 電子郵件
│       └── age: number                     # 年齡
├── failcounts/                             # 失敗計數記錄
│   └── {model}/                            # 模型
│       └── {serialNumber}/                 # 序號
│           ├── AppearanceStructureInspectionFunction/
│           │   └── failCount: number
│           ├── InputOutputCharacteristics/
│           │   └── failCount: number
│           ├── BasicFunctionTest/
│           │   └── failCount: number
│           └── HipotTestSpec/
│               └── failCount: number
└── reports/                                # OQC報告數據 (實際應用中的集合)
    └── {reportId}/
        ├── basicInfo/                      # 基本資訊
        ├── softwareVersions/               # 軟體版本
        ├── psuSerialNumbers/               # PSU序號
        ├── appearanceInspection/           # 外觀檢查
        ├── inputOutputCharacteristics/     # 輸入輸出特性
        ├── basicFunctionTest/              # 基本功能測試
        ├── protectionFunctionTest/         # 保護功能測試
        ├── packageList/                    # 包裝清單
        ├── attachments/                    # 附件
        └── signatures/                     # 簽名
```

### Firebase 集合說明
| 集合名稱 | 用途 | 文檔結構 |
|----------|------|----------|
| `models` | 產品型號規格模板 | 分層結構: 型號 → 測試類型 → spec |
| `machines` | 測試設備資料 | 扁平結構: 設備參數 |
| `users` | 用戶帳號管理 | 扁平結構: 用戶資訊 |
| `failcounts` | 測試失敗統計 | 分層結構: 型號 → 序號 → 測試類型 |
| `reports` | OQC測試報告 | 分層結構: 報告 → 各個測試項目 |

---

## 📊 規格數據模型 (Spec Models)

### 1. InputOutputCharacteristicsSpec
**用途**: 定義電源輸入輸出特性的允許範圍標準  
**Firebase路徑**: `models/{modelId}/InputOutputCharacteristics/spec`

```dart
class InputOutputCharacteristicsSpec {
  // 左側輸入規格 (Left Side Input Specifications)
  double leftVinLowerbound;    // 左側輸入電壓下限 (V)
  double leftVinUpperbound;    // 左側輸入電壓上限 (V)
  double leftIinLowerbound;    // 左側輸入電流下限 (A)
  double leftIinUpperbound;    // 左側輸入電流上限 (A)
  double leftPinLowerbound;    // 左側輸入功率下限 (W)
  double leftPinUpperbound;    // 左側輸入功率上限 (W)
  
  // 左側輸出規格 (Left Side Output Specifications)
  double leftVoutLowerbound;   // 左側輸出電壓下限 (V)
  double leftVoutUpperbound;   // 左側輸出電壓上限 (V)
  double leftIoutLowerbound;   // 左側輸出電流下限 (A)
  double leftIoutUpperbound;   // 左側輸出電流上限 (A)
  double leftPoutLowerbound;   // 左側輸出功率下限 (W)
  double leftPoutUpperbound;   // 左側輸出功率上限 (W)
  
  // 右側輸入規格 (Right Side Input Specifications)
  double rightVinLowerbound;   // 右側輸入電壓下限 (V)
  double rightVinUpperbound;   // 右側輸入電壓上限 (V)
  double rightIinLowerbound;   // 右側輸入電流下限 (A)
  double rightIinUpperbound;   // 右側輸入電流上限 (A)
  double rightPinLowerbound;   // 右側輸入功率下限 (W)
  double rightPinUpperbound;   // 右側輸入功率上限 (W)
  
  // 右側輸出規格 (Right Side Output Specifications)
  double rightVoutLowerbound;  // 右側輸出電壓下限 (V)
  double rightVoutUpperbound;  // 右側輸出電壓上限 (V)
  double rightIoutLowerbound;  // 右側輸出電流下限 (A)
  double rightIoutUpperbound;  // 右側輸出電流上限 (A)
  double rightPoutLowerbound;  // 右側輸出功率下限 (W)
  double rightPoutUpperbound;  // 右側輸出功率上限 (W)
  
  // 全局變數
  InputOutputCharacteristicsSpec? globalInputOutputSpec;
}
```

#### JSON 欄位映射
| Dart 屬性 | JSON 鍵值 | 說明 | 單位 | 典型範圍 |
|-----------|-----------|------|------|----------|
| `leftVinLowerbound` | `LVinLB` | 左側輸入電壓下限 | V | 100-240V |
| `leftVinUpperbound` | `LVinUB` | 左側輸入電壓上限 | V | 100-240V |
| `leftIinLowerbound` | `LIinLB` | 左側輸入電流下限 | A | 0.5-2.0A |
| `leftIinUpperbound` | `LIinUB` | 左側輸入電流上限 | A | 0.5-2.0A |
| `leftPinLowerbound` | `LPinLB` | 左側輸入功率下限 | W | 50-150W |
| `leftPinUpperbound` | `LPinUB` | 左側輸入功率上限 | W | 50-150W |
| `leftVoutLowerbound` | `LVoutLB` | 左側輸出電壓下限 | V | 800-1000V |
| `leftVoutUpperbound` | `LVoutUB` | 左側輸出電壓上限 | V | 800-1000V |
| `leftIoutLowerbound` | `LIoutLB` | 左側輸出電流下限 | A | 10-200A |
| `leftIoutUpperbound` | `LIoutUB` | 左側輸出電流上限 | A | 10-200A |
| `leftPoutLowerbound` | `LPoutLB` | 左側輸出功率下限 | W | 1kW-150kW |
| `leftPoutUpperbound` | `LPoutUB` | 左側輸出功率上限 | W | 1kW-150kW |

**右側參數映射規則相同，前綴為 `R` 代替 `L`**

---

### 2. BasicFunctionTestSpec
**用途**: 定義基本功能測試的性能指標標準  
**Firebase路徑**: `models/{modelId}/BasicFunctionTest/spec`

```dart
class BasicFunctionTestSpec {
  double eff;  // 效率規格 (Efficiency) - 百分比
  double pf;   // 功率因子規格 (Power Factor) - 0.0~1.0
  double thd;  // 總諧波失真規格 (Total Harmonic Distortion) - 百分比
  double sp;   // 軟啟動時間規格 (Soft Start) - 毫秒
  
  // 全局變數
  BasicFunctionTestSpec? globalBasicFunctionTestSpec;
}
```

#### JSON 欄位映射與驗證規則
| Dart 屬性 | JSON 鍵值 | 說明 | 單位/範圍 | 驗證規則 |
|-----------|-----------|------|-----------|----------|
| `eff` | `EFF` | 效率規格 | % (0-100) | ≥ 85% (一般要求) |
| `pf` | `PF` | 功率因子規格 | 0.0-1.0 | ≥ 0.9 (一般要求) |
| `thd` | `THD` | 總諧波失真規格 | % | ≤ 5% (一般要求) |
| `sp` | `SP` | 軟啟動時間規格 | ms | 50-500ms |

---

### 3. HipotTestSpec
**用途**: 定義耐壓測試的安全標準  
**Firebase路徑**: `models/{modelId}/HipotTestSpec/spec`

```dart
class HipotTestSpec {
  double insulationimpedancespec;  // 絕緣阻抗規格 (Insulation Impedance)
  double leakagecurrentspec;       // 漏電流規格 (Leakage Current)
  
  // 全局變數
  HipotTestSpec? globalHipotTestSpec;
}
```

#### JSON 欄位映射與安全標準
| Dart 屬性 | JSON 鍵值 | 說明 | 單位 | 安全標準 |
|-----------|-----------|------|------|----------|
| `insulationimpedancespec` | `II` | 絕緣阻抗規格 | MΩ | ≥ 10 MΩ (IEC標準) |
| `leakagecurrentspec` | `LC` | 漏電流規格 | mA | ≤ 1 mA (IEC標準) |

---

### 4. PsuSerialNumSpec
**用途**: 定義PSU序號管理規格  
**Firebase路徑**: `models/{modelId}/PsuSerialNumSpec/spec`

```dart
class PsuSerialNumSpec {
  int? qty;  // PSU數量規格 (Quantity) - 可選
  
  // 全局變數
  PsuSerialNumSpec? globalPsuSerialNumSpec;
  bool globalPackageListSpecInitialized = false;
}
```

#### JSON 欄位映射
| Dart 屬性 | JSON 鍵值 | 說明 | 類型 |
|-----------|-----------|------|------|
| `qty` | `QTY` | PSU數量規格 | int? |

**使用場景**:
- 批次生產管理
- 序號分配控制
- 庫存追蹤

---

### 5. PackageListSpec
**用途**: 定義包裝清單內容物和數量標準  
**Firebase路徑**: `models/{modelId}/PackageListSpec/spec`

```dart
class PackageListSpec {
  // 包裝內容物名稱 (Package Item Names)
  String rfidcard;                    // RFID卡名稱
  String productcertificatecard;      // 產品認證卡名稱
  String screwassym4;                 // M4螺絲名稱
  String boltscover;                  // 螺栓蓋名稱
  String usermanual;                  // 用戶手冊名稱
  
  // 包裝內容物數量規格 (Package Item Quantity Specifications)
  int? rfidcardspec;                  // RFID卡數量規格
  int? productcertificatecardspec;    // 產品認證卡數量規格
  int? screwassym4spec;               // M4螺絲數量規格
  int? boltscoverspec;                // 螺栓蓋數量規格
  int? usermanualspec;                // 用戶手冊數量規格
  
  // 全局變數
  PackageListSpec? globalPackageListSpec;
}
```

#### JSON 欄位映射與預設值
| Dart 屬性 | JSON 鍵值 | 說明 | 類型 | 預設值 |
|-----------|-----------|------|------|--------|
| `rfidcard` | `RFIDCNAME` | RFID卡名稱 | String | "RFID Card" |
| `productcertificatecard` | `PCCAME` | 產品認證卡名稱 | String | "Product Certificate Card" |
| `screwassym4` | `SAM4AME` | M4螺絲名稱 | String | "Screw Assy M4*12" |
| `boltscover` | `BCNAME` | 螺栓蓋名稱 | String | "Bolts Cover" |
| `usermanual` | `UMNAME` | 用戶手冊名稱 | String | "User Manual" |
| `rfidcardspec` | `RFIDCSPEC` | RFID卡數量規格 | int? | 2 |
| `productcertificatecardspec` | `PCCSPEC` | 產品認證卡數量規格 | int? | 1 |
| `screwassym4spec` | `SAM4SPEC` | M4螺絲數量規格 | int? | 4 |
| `boltscoverspec` | `BCSPEC` | 螺栓蓋數量規格 | int? | 22 |
| `usermanualspec` | `UMSPEC` | 用戶手冊數量規格 | int? | 1 |

---

## 📈 報告數據模型 (Report Models)

### 1. SoftwareVersion
**用途**: 軟體版本資訊管理  
**資料來源**: Excel/API自動讀取

```dart
class SoftwareVersion {
  final List<Version> versions;  // 版本列表
  
  // 支援的軟體組件
  static final List<String> supportedComponents = [
    "CSU Rootfs",      // CSU系統
    "FAN Module",      // 風扇模組
    "Relay Module",    // 繼電器模組
    "Primary MCU",     // 主控制器
    "Connector 1",     // 連接器1 (CCS1)
    "Connector 2",     // 連接器2 (CCS2)
    "LCM UI",          // 人機界面
    "LED Module",      // LED模組
  ];
}

class Version {
  String value;  // 版本號
  String key;    // 組件鍵值
  String name;   // 顯示名稱
}
```

#### 版本資訊映射
| 組件名稱 | JSON 鍵值 | 顯示名稱 | 說明 |
|----------|-----------|----------|------|
| CSU Rootfs | CSU Rootfs | CSU | 中央系統單元 |
| FAN Module | FAN Module | FAN Module | 散熱風扇模組 |
| Relay Module | Relay Module | Relay Board | 繼電器控制板 |
| Primary MCU | Primary MCU | MCU | 主微控制器 |
| Connector 1 | Connector 1 | CCS 1 | CCS Type 1 連接器 |
| Connector 2 | Connector 2 | CCS 2 | CCS Type 2 連接器 |
| LCM UI | LCM UI | UI | 液晶顯示器界面 |
| LED Module | LED Module | LED | LED指示燈模組 |

---

### 2. Psuserialnumber
**用途**: PSU序號管理  
**資料來源**: Excel/條碼掃描

```dart
class Psuserialnumber {
  final List<SerialNumber> psuSN;  // PSU序號列表
}

class SerialNumber {
  final double spec;   // 規格參考值
  String value;        // 實際序號
  final String key;    // 識別鍵值
  final String name;   // 顯示名稱
}
```

**資料解析規則**:
- 從 `ITEM_PART_SPECS` 欄位篩選包含 "CHARGING MODULE" 的項目
- 從 `ITEM_PART_SN` 欄位提取序號
- 預設規格值: 12

---

### 3. InputOutputCharacteristics
**用途**: 輸入輸出特性測試結果  
**測試項目**: 電壓、電流、功率測量

```dart
class InputOutputCharacteristics {
  final InputOutputCharacteristicsSide leftSideInputOutputCharacteristics;   // 左側測試結果
  final InputOutputCharacteristicsSide rightSideInputOutputCharacteristics;  // 右側測試結果
  final BasicFunctionTestResult basicFunctionTestResult;                     // 基本功能測試結果
}

class InputOutputCharacteristicsSide {
  final List<InputOutputMeasurement> inputVoltage;      // 輸入電壓測量 (3次測量)
  final List<InputOutputMeasurement> inputCurrent;      // 輸入電流測量 (3次測量)
  final InputOutputMeasurement? totalInputPower;        // 總輸入功率
  final InputOutputMeasurement? outputVoltage;          // 輸出電壓
  final InputOutputMeasurement? outputCurrent;          // 輸出電流
  final InputOutputMeasurement? totalOutputPower;       // 總輸出功率
}

class InputOutputMeasurement {
  double spec;           // 規格值
  double value;          // 測量值
  double count;          // 測量次數
  String key;            // 測量項目鍵值
  String name;           // 測量項目名稱
  String description;    // 描述
  Judgement judgement;   // 判定結果 (pass/fail/unknown)
}
```

#### 測量項目與規格對照
| 測量項目 | 測量次數 | 典型規格值 | 判定依據 |
|----------|----------|------------|----------|
| 輸入電壓 (Vin) | 3次/側 | 220V | spec範圍內 |
| 輸入電流 (Iin) | 3次/側 | 230A | spec範圍內 |
| 輸入功率 (Pin) | 1次/側 | 130W | spec範圍內 |
| 輸出電壓 (Vout) | 1次/側 | 950V | spec範圍內 |
| 輸出電流 (Iout) | 1次/側 | 變動 | spec範圍內 |
| 輸出功率 (Pout) | 1次/側 | 變動 | spec範圍內 |

---

### 4. BasicFunctionTestResult
**用途**: 基本功能測試結果  
**測試項目**: 效率、功率因子、諧波失真、軟啟動

```dart
class BasicFunctionTestResult {
  final BasicFunctionMeasurement eff;                      // 效率測試
  final BasicFunctionMeasurement powerFactor;              // 功率因子測試
  final BasicFunctionMeasurement harmonic;                 // 諧波失真測試
  final BasicFunctionMeasurement standbyTotalInputPower;   // 待機功率測試
}

class BasicFunctionMeasurement {
  double spec;           // 規格值
  double value;          // 測量值
  double count;          // 測量次數
  String key;            // 測量項目鍵值
  String name;           // 測量項目名稱
  String description;    // 測量描述
  Judgement judgement;   // 判定結果
}
```

---

### 5. AppearanceStructureInspectionFunctionResult
**用途**: 外觀結構檢查結果  
**檢查項目**: 15個外觀與結構檢查項目

```dart
class AppearanceStructureInspectionFunctionResult {
  final List<TestItem> testItems;  // 檢查項目列表
  
  // 檢查項目清單
  static List<String> keys = [
    "CSU、PSU",           // CSU、PSU檢查
    "Label, Nameplate",   // 標籤、銘牌
    "Screen",             // 螢幕
    "Fan",                // 風扇
    "Cables",             // 線纜
    "Screws",             // 螺絲
    "Door Lock",          // 門鎖
    "Grounding",          // 接地
    "Waterproofing",      // 防水
    "Acrylic Panel",      // 壓克力面板
    "Charging Cable",     // 充電線
    "Cabinet",            // 機櫃
    "Pallet",             // 托盤
    "LED",                // LED指示燈
    "Meter",              // 電表
  ];
}

class TestItem {
  final String name;                           // 檢查項目名稱
  final String description;                    // 檢查描述
  final String result;                         // 檢查結果
  final ValueNotifier<Judgement> _judgementNotifier;  // 判定通知器
}
```

#### 檢查項目詳細說明
| 項目 | 檢查標準 | 判定依據 |
|------|----------|----------|
| CSU、PSU | 必須有防拆標籤 | 標籤完整性 |
| Label, Nameplate | 內容符合圖紙，無模糊、破字、錯位、刮傷 | 標籤品質 |
| Screen | 外觀無刮傷、污漬、膠漬、氣泡 | 螢幕完整性 |
| Fan | 確認風扇格柵和安裝方向 | 安裝正確性 |
| Cables | 確認線纜連接位置、組裝、走線 | 線纜規範性 |
| Screws | 無缺少螺絲，扭力標記驗證 | 螺絲完整性 |
| Door Lock | 門鎖和把手操作正常 | 功能正常性 |
| Grounding | 接地線安裝位置對應接地標籤 | 安裝正確性 |
| Waterproofing | 防水膠施打均勻，範圍符合防水指引 | 防水標準 |
| Acrylic Panel | 壓克力面板無鬆動或刮傷 | 面板完整性 |
| Charging Cable | 長度規格正確，插頭印刷正確 | 規格符合性 |
| Cabinet | 機櫃外觀無掉漆、刮傷、污漬、鏽蝕、焊接缺陷、色差 | 外觀品質 |
| Pallet | 托盤扭力值符合標準，扭力標記檢查 | 扭力標準 |
| LED | 確認LED狀態 (故障/待機/充電) | 功能正常性 |
| Meter | 確認電表累積電量與實際功率值 | 數值正確性 |

---

### 6. PackageListResult
**用途**: 包裝清單檢查結果  
**檢查項目**: 包裝內容物數量核對

```dart
class PackageListResult {
  final List<String> header;                              // 表格標題
  final List<List<String>> rows;                          // 表格行
  final List<PackageListResultMeasurement> datas;         // 檢查數據
  
  // 預設檢查項目
  static final List<PackageListResultMeasurement> defaultDatas = [
    PackageListResultMeasurement(spec: 2, key: 1, translationKey: 'rfid_card'),
    PackageListResultMeasurement(spec: 1, key: 2, translationKey: 'product_certificate_card'),
    PackageListResultMeasurement(spec: 22, key: 3, translationKey: 'bolts_cover'),
    PackageListResultMeasurement(spec: 4, key: 4, translationKey: 'screw_assy_m4_12'),
    PackageListResultMeasurement(spec: 1, key: 5, translationKey: 'user_manual'),
  ];
}

class PackageListResultMeasurement {
  int spec;                          // 規格數量
  final int key;                     // 項目編號
  String translationKey;             // 翻譯鍵值
  final ValueNotifier<bool> isCheck; // 檢查狀態通知器
}
```

#### 包裝清單預設規格
| 項目 | 規格數量 | 翻譯鍵值 | 英文名稱 |
|------|----------|----------|----------|
| RFID卡 | 2 | rfid_card | RFID Card |
| 產品認證卡 | 1 | product_certificate_card | Product Certificate Card |
| 螺栓蓋 | 22 | bolts_cover | Bolts Cover |
| M4螺絲 | 4 | screw_assy_m4_12 | Screw Assy M4*12 |
| 用戶手冊 | 1 | user_manual | User Manual |

---

## 🛠 工具數據模型

### FailCountStore
**用途**: 失敗計數管理工具，統計各項測試的失敗次數  
**Firebase路徑**: `failcounts/{model}/{serialNumber}/{tableName}`

```dart
class FailCountStore {
  static int appearanceStructureInspectionFunction;  // 外觀結構檢查失敗次數
  static int inputOutputCharacteristics;             // 輸入輸出特性失敗次數
  static int basicFunctionTest;                       // 基本功能測試失敗次數
  static int hipotTestSpec;                          // 耐壓測試失敗次數
  
  // 統計方法
  int countInputOutputCharacteristicsFails(InputOutputCharacteristics ioChar);
}
```

#### 支援的表格與統計方式
| 表格名稱 | 說明 | 統計邏輯 |
|----------|------|----------|
| `AppearanceStructureInspectionFunction` | 外觀結構檢查功能 | 統計判定為fail的項目數 |
| `InputOutputCharacteristics` | 輸入輸出特性 | 統計測量值超出規格範圍的項目數 |
| `BasicFunctionTest` | 基本功能測試 | 統計性能指標不達標的項目數 |
| `HipotTestSpec` | 耐壓測試規格 | 統計安全測試失敗的項目數 |

---

## 🎯 枚舉類型定義

### Judgement (測試判定)
**用途**: 定義測試結果的判定狀態

```dart
enum Judgement {
  pass,     // 通過
  fail,     // 失敗
  unknown   // 未知/未測試
}
```

**使用場景**:
- 所有測量結果的判定
- 外觀檢查的判定
- 包裝清單檢查的判定
- 失敗計數的統計依據

---

## 🔄 JSON 映射規則

### 數據類型轉換

#### 數字類型處理
```dart
double parseDouble(dynamic value) {
  return (value is num)
      ? value.toDouble()
      : double.tryParse(value.toString()) ?? double.nan;
}

int? parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
```

#### Firebase Firestore 欄位格式
```json
{
  "fields": {
    "spec": {
      "mapValue": {
        "fields": {
          "EFF": {"doubleValue": 85.5},
          "PF": {"doubleValue": 0.95},
          "THD": {"doubleValue": 5.0},
          "SP": {"doubleValue": 100.0}
        }
      }
    }
  }
}
```

#### Excel 數據解析格式
```json
{
  "SPC_DESC": "Input_Voltage",
  "SPC_VALUE": "220.5",
  "SPC_ITEM": "Left Plug",
  "ITEM_PART_SPECS": "CHARGING MODULE",
  "ITEM_PART_SN": "CM001234567",
  "ITEM_NAME": "CSU、PSU",
  "ITEM_DESC": "Must have tamper-evident stickers.",
  "INSP_RESULT": "OK"
}
```

### 標準化命名規則

#### 欄位縮寫說明
| 縮寫 | 完整名稱 | 中文說明 | 用途範圍 |
|------|----------|----------|----------|
| `Vin` | Voltage Input | 輸入電壓 | 輸入輸出特性 |
| `Iin` | Current Input | 輸入電流 | 輸入輸出特性 |
| `Pin` | Power Input | 輸入功率 | 輸入輸出特性 |
| `Vout` | Voltage Output | 輸出電壓 | 輸入輸出特性 |
| `Iout` | Current Output | 輸出電流 | 輸入輸出特性 |
| `Pout` | Power Output | 輸出功率 | 輸入輸出特性 |
| `LB` | Lower Bound | 下限 | 規格定義 |
| `UB` | Upper Bound | 上限 | 規格定義 |
| `L` | Left | 左側 | 雙側設備 |
| `R` | Right | 右側 | 雙側設備 |
| `EFF` | Efficiency | 效率 | 基本功能測試 |
| `PF` | Power Factor | 功率因子 | 基本功能測試 |
| `THD` | Total Harmonic Distortion | 總諧波失真 | 基本功能測試 |
| `SP` | Soft Start | 軟啟動 | 基本功能測試 |
| `II` | Insulation Impedance | 絕緣阻抗 | 耐壓測試 |
| `LC` | Leakage Current | 漏電流 | 耐壓測試 |
| `QTY` | Quantity | 數量 | 序號與包裝 |
| `SPC` | Specification | 規格 | 測試數據 |
| `INSP` | Inspection | 檢查 | 外觀檢查 |

---

## 📝 使用範例

### 創建規格對象
```dart
// 創建輸入輸出特性規格
final ioSpec = InputOutputCharacteristicsSpec(
  leftVinLowerbound: 100.0,
  leftVinUpperbound: 240.0,
  leftIinLowerbound: 0.5,
  leftIinUpperbound: 2.0,
  leftPinLowerbound: 50.0,
  leftPinUpperbound: 150.0,
  leftVoutLowerbound: 800.0,
  leftVoutUpperbound: 1000.0,
  leftIoutLowerbound: 10.0,
  leftIoutUpperbound: 200.0,
  leftPoutLowerbound: 1000.0,
  leftPoutUpperbound: 150000.0,
  // 右側參數...
  rightVinLowerbound: 100.0,
  rightVinUpperbound: 240.0,
  // ... 其他右側參數
);

// 轉換為JSON
final json = ioSpec.toJson();

// 從JSON創建對象
final newSpec = InputOutputCharacteristicsSpec.fromJson(json);
```

### 測試結果處理
```dart
// 創建測量結果
final measurement = InputOutputMeasurement(
  spec: 220.0,
  value: 218.5,
  count: 1,
  key: "Input_Voltage",
  name: "Vin",
  description: "左側輸入電壓測量",
  judgement: (218.5 >= 100.0 && 218.5 <= 240.0) 
    ? Judgement.pass 
    : Judgement.fail,
);

// 失敗計數統計
if (measurement.judgement == Judgement.fail) {
  FailCountStore.increment('InputOutputCharacteristics');
}
```

### Firebase 操作
```dart
// 保存規格到Firebase
await firebaseService.addOrUpdateSpec(
  model: 'T2449A003A1',
  tableName: 'InputOutputCharacteristics',
  spec: ioSpec.toJson(),
);

// 從Firebase載入規格
final specs = await firebaseService.getAllSpecs(
  model: 'T2449A003A1',
  tableNames: ['InputOutputCharacteristics', 'BasicFunctionTest'],
);

// 保存失敗計數
await firebaseService.addOrUpdateFailCount(
  model: 'T2449A003A1',
  serialNumber: 'PSU001234567',
  tableName: 'InputOutputCharacteristics',
  failCount: FailCountStore.getCount('InputOutputCharacteristics'),
);
```

### Excel 數據解析
```dart
// 從Excel數據創建軟體版本
final softwareVersion = SoftwareVersion.fromJsonList(excelData);

// 從Excel數據創建PSU序號
final psuSerialNumbers = Psuserialnumber.fromJsonList(excelData);

// 從Excel數據創建輸入輸出特性
final ioCharacteristics = InputOutputCharacteristics.fromJsonList(excelData);
```

---

## 🔍 資料驗證

### 必要欄位檢查
1. **規格類別**: 所有數值欄位必須提供，不允許null值
2. **測量結果**: 必須包含spec、value、judgement
3. **外觀檢查**: 必須包含name、description、result

### 數值範圍驗證
| 參數類型 | 驗證規則 | 錯誤處理 |
|----------|----------|----------|
| 電壓 (V) | > 0, < 2000 | 設為double.nan |
| 電流 (A) | > 0, < 1000 | 設為double.nan |
| 功率 (W) | > 0, < 500000 | 設為double.nan |
| 效率 (%) | 0-100 | 限制在0-100範圍 |
| 功率因子 | 0.0-1.0 | 限制在0.0-1.0範圍 |
| 絕緣阻抗 (MΩ) | > 0 | 設為double.nan |
| 漏電流 (mA) | ≥ 0 | 設為0 |

### 判定邏輯驗證
```dart
// 輸入輸出特性判定
bool isWithinSpec(double value, double lowerBound, double upperBound) {
  return value >= lowerBound && value <= upperBound;
}

// 基本功能測試判定
bool isEfficiencyPass(double efficiency) {
  return efficiency >= globalBasicFunctionTestSpec!.eff;
}

// 外觀檢查判定
Judgement parseInspectionResult(String result) {
  switch (result.toUpperCase()) {
    case "OK": return Judgement.pass;
    case "NG": return Judgement.fail;
    default: return Judgement.unknown;
  }
}
```

### 錯誤處理策略
1. **數值解析失敗**: 設為`double.nan`或`null`
2. **JSON格式錯誤**: 拋出解析異常，記錄錯誤日誌
3. **規格缺失**: 使用預設值或提示用戶設定
4. **測量超出範圍**: 標記為失敗，記錄到失敗計數

---

## 🔄 資料流程

### 1. 規格設定流程
```
管理員設定規格 → Firebase儲存 → 全域變數載入 → 測試時使用
```

### 2. 測試數據流程
```
Excel導入 → 數據解析 → 規格比對 → 判定結果 → 失敗計數 → 報告生成
```

### 3. 報告生成流程
```
各項測試結果 → 統一格式化 → PDF生成 → 簽名驗證 → 存檔/列印
```

---

**文檔版本**: v2.0  
**最後更新**: 2024年12月  
**維護者**: Zerova OQC Team  
**更新說明**: 基於Firebase實際結構與代碼分析，新增詳細的報告數據模型、測量結果處理、外觀檢查項目等完整資料結構 