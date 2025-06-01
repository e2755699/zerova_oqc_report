# PSU Serial Number Spec 技術文檔

**檔案路徑**: `lib/src/report/spec/psu_serial_numbers_spec.dart`  
**UI組件**: `lib/src/widget/admin/tabs/psu_serial_num_tab.dart`  
**用途**: PSU序號規格管理  
**版本**: 1.0.0  
**作者**: Zerova OQC Team  

---

## 📋 目錄

1. [概述](#概述)
2. [資料結構](#資料結構)
3. [UI 組件](#ui-組件)
4. [Firebase 整合](#firebase-整合)
5. [使用範例](#使用範例)
6. [預設值設定](#預設值設定)
7. [驗證規則](#驗證規則)

---

## 🎯 概述

`PsuSerialNumSpec` 是用於定義和管理PSU（Power Supply Unit）序號規格的資料模型。它主要控制每個產品型號需要配置的PSU數量，這個數值直接影響：

- PSU序號表格的顯示行數
- 生產批次管理
- 庫存控制
- OQC測試流程

---

## 📊 資料結構

### 核心類別定義

```dart
class PsuSerialNumSpec {
  int? qty;  // PSU數量規格
  
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

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
```

### 全域變數

```dart
// 全域PSU序號規格
PsuSerialNumSpec? globalPsuSerialNumSpec;

// 初始化狀態標記
bool globalPackageListSpecInitialized = false;
```

### JSON 映射

| Dart 屬性 | JSON 鍵值 | 類型 | 說明 | 預設值 |
|-----------|-----------|------|------|--------|
| `qty` | `QTY` | int? | PSU數量規格 | 12 |

---

## 🎨 UI 組件

### PsuSerialNumTab

**檔案路徑**: `lib/src/widget/admin/tabs/psu_serial_num_tab.dart`

#### 組件結構

```dart
class PsuSerialNumTab extends StatefulWidget {
  final PsuSerialNumSpec? spec;
  final Function(PsuSerialNumSpec) onChanged;
  
  // Widget implementation...
}
```

#### 主要功能

1. **數量輸入**：
   - 使用 `LabeledSpecInputField` 組件
   - 自動數字鍵盤
   - 即時驗證和更新

2. **說明資訊**：
   - 預設值說明
   - 功能描述
   - 影響範圍提示

#### UI 結構

```dart
Card(
  child: Column(
    children: [
      Text('PSU序號規格'),  // 標題
      LabeledSpecInputField(
        label: 'PSU數量 (Qty)',
        unit: '個',
        controller: _qtyController,
        isRequired: true,
      ),
      Container(
        // 藍色資訊說明框
        child: Text(
          '• PSU數量: 設定此模型需要的PSU數量\n'
          '• 預設值: 12個\n'
          '• 此設定將影響PSU序號表格的顯示行數',
        ),
      ),
    ],
  ),
)
```

---

## 🔥 Firebase 整合

### 資料庫路徑

```
models/
└── {modelId}/
    └── PsuSerialNumSpec/
        └── spec/
            └── spec: {PsuSerialNumSpec.toJson()}
```

### Firebase 操作範例

#### 保存規格

```dart
final firebaseService = FirebaseService();
final spec = PsuSerialNumSpec(qty: 12);

await firebaseService.addOrUpdateSpec(
  model: 'T2449A003A1',
  tableName: 'PsuSerialNumSpec',
  spec: spec.toJson(),
);
```

#### 讀取規格

```dart
final specs = await firebaseService.getAllSpecs(
  model: 'T2449A003A1',
  tableNames: ['PsuSerialNumSpec'],
);

final psuSpecMap = specs['PsuSerialNumSpec'];
if (psuSpecMap != null && psuSpecMap.isNotEmpty) {
  final psuSpec = PsuSerialNumSpec.fromJson(psuSpecMap);
  print('PSU數量: ${psuSpec.qty}');
}
```

---

## 💻 使用範例

### 1. 在模型規格模板頁面中使用

```dart
class _ModelSpecTemplatePageState extends State<ModelSpecTemplatePage> {
  PsuSerialNumSpec? _psuSerialNumSpec;
  
  void _initializeDefaultSpec() {
    _psuSerialNumSpec = PsuSerialNumSpec(qty: 12);
  }
  
  Widget _buildTabContent() {
    return TabBarView(
      children: [
        // 其他標籤頁...
        PsuSerialNumTab(
          spec: _psuSerialNumSpec,
          onChanged: (newSpec) {
            setState(() {
              _psuSerialNumSpec = newSpec;
            });
          },
        ),
      ],
    );
  }
}
```

### 2. 在PSU序號表格中使用

```dart
class _PsuSerialNumbersTableState extends State<PsuSerialNumbersTable> {
  int get totalQty => globalPsuSerialNumSpec?.qty ?? 12;
  
  @override
  Widget build(BuildContext context) {
    return Table(
      children: List.generate(totalQty, (index) {
        return TableRow(
          children: [
            Text('${index + 1}'),  // 序號
            TextField(...),        // PSU序號輸入
          ],
        );
      }),
    );
  }
}
```

### 3. 全域狀態管理

```dart
// 初始化全域規格
void initializeGlobalSpec() {
  globalPsuSerialNumSpec = PsuSerialNumSpec(qty: 12);
}

// 更新數量並同步UI
void updateQtyAndControllers(int newQty) {
  globalPsuSerialNumSpec = globalPsuSerialNumSpec?.copyWith(qty: newQty);
  
  // 更新相關UI組件
  setState(() {
    // 重新構建依賴數量的組件
  });
}
```

---

## 📋 預設值設定

### 預設值來源

基於產品規格文件 `PSU SN.txt` 的內容：

```
1: _defaultIfEmptyInt(spec?.qty, 12),
```

### 預設值表

| 產品類型 | 預設PSU數量 | 適用範圍 | 備註 |
|----------|-------------|----------|------|
| 標準型號 | 12 | 大多數產品 | 基於歷史數據 |
| 特殊型號 | 可調整 | 特定需求 | 依產品規格 |

### 設定邏輯

```dart
PsuSerialNumSpec _getDefaultSpec() {
  return PsuSerialNumSpec(
    qty: 12,  // 根據 PSU SN.txt 文件設定
  );
}
```

---

## ✅ 驗證規則

### 數值驗證

```dart
class PsuSerialNumValidator {
  static String? validateQty(int? qty) {
    if (qty == null) {
      return '請輸入PSU數量';
    }
    
    if (qty < 1) {
      return 'PSU數量不能小於1';
    }
    
    if (qty > 50) {
      return 'PSU數量不能大於50';
    }
    
    return null; // 驗證通過
  }
}
```

### 業務邏輯驗證

1. **數量範圍**: 1-50個PSU
2. **必填檢查**: 數量不能為空
3. **整數檢查**: 只允許正整數
4. **實際限制**: 考慮硬體和生產限制

---

## 🔗 相關聯的組件

### 直接影響

1. **PSU序號表格** (`PsuSerialNumbersTable`):
   - 表格行數 = PSU數量
   - 序號輸入欄位數量

2. **PDF報告生成**:
   - PSU序號區塊行數
   - 數量標題顯示

### 間接影響

1. **生產管理系統**:
   - 批次計劃
   - 物料需求

2. **品質檢測流程**:
   - 檢測項目數量
   - 測試完整性驗證

---

## 📖 API 參考

### 建構子

```dart
PsuSerialNumSpec({required int? qty})
```

### 靜態方法

```dart
// 從JSON創建實例
static PsuSerialNumSpec fromJson(Map<String, dynamic> json)

// 解析可空整數
static int? _parseNullableInt(dynamic value)
```

### 實例方法

```dart
// 創建副本並修改指定欄位
PsuSerialNumSpec copyWith({int? qty})

// 轉換為JSON格式
Map<String, dynamic> toJson()

// 字串表示
String toString()
```

---

## 🔄 版本記錄

| 版本 | 日期 | 變更內容 |
|------|------|----------|
| 1.0.0 | 2024-12-19 | 初版發布，支援PSU數量規格管理 |

---

**維護者**: Zerova OQC Team  
**最後更新**: 2024-12-19  
**許可證**: MIT License 