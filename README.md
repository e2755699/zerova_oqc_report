# Zerova OQC Report System

一個基於Flutter開發的出廠品質控制(OQC)報告管理系統，專為電源供應器(PSU)產品的品質檢測而設計。

## 📋 項目概述

Zerova OQC Report System 是一個現代化的品質控制報告管理平台，提供完整的產品檢測流程管理，從基本資訊收集到最終檢測報告生成。

## 🚀 主要功能特性

### 📊 OQC報告表格管理
系統包含以下10個核心報告表格：

1. **Basic Information Table** - 基本資訊表
2. **PSU S/N Table** - 電源序號表  
3. **Software Version Table** - 軟體版本表
4. **Appearance & Structure Inspection Table** - 外觀結構檢查表
5. **Input & Output Characteristics Table** - 輸入輸出特性表
6. **Basic Function Test Table** - 基本功能測試表
7. **Protection Function Test Table** - 保護功能測試表
8. **Package List Table** - 配件包表
9. **Attachment Table** - 附件表
10. **Signature Table** - 簽名表

### 🔧 管理員功能
- **模型規格模板管理**: 創建、編輯、刪除產品型號規格模板
- **規格參數設定**: 
  - 輸入輸出特性規格
  - 基本功能測試規格  
  - 耐壓測試規格
- **多語言支持**: 中文/英文界面切換

### 📱 用戶界面特色
- **響應式設計**: 適配不同螢幕尺寸
- **現代化UI**: 採用Material Design設計語言
- **直觀操作**: 標籤頁式管理界面
- **即時驗證**: 輸入資料即時驗證與提示

## 🛠 技術棧

### 前端框架
- **Flutter** - 跨平台應用開發框架
- **Dart** - 程式語言

### 主要套件
- `easy_localization` - 國際化支持
- `http` - HTTP請求處理
- `material_design` - Material Design組件

### 後端服務
- **Firebase Firestore** - NoSQL雲端資料庫
- **Firebase Authentication** - 用戶認證
- **Firebase Storage** - 檔案儲存

### 資料結構
完整的資料結構文檔請參考：📊 **[資料結構文檔](docs/DataStructure.md)**

包含：
- Firebase 資料庫架構
- 所有規格數據模型定義
- JSON 欄位映射規則
- 使用範例和驗證規則

### Firebase 資料路徑
```
default/
├── models/
│   └── {modelId}/
│       ├── InputOutputCharacteristics/
│       ├── BasicFunctionTest/
│       ├── HipotTestSpec/
│       ├── PsuSerialNumSpec/
│       └── PackageListSpec/
├── failcounts/
│   └── {model}/{serialNumber}/{tableName}
└── reports/ (預留)
```

## 📦 安裝與設置

### 環境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 2.17.0
- Android Studio / VS Code
- Firebase 項目配置

### 安裝步驟

1. **克隆項目**
   ```bash
   git clone [repository-url]
   cd zerova_oqc_report
   ```

2. **安裝依賴**
   ```bash
   flutter pub get
   ```

3. **Firebase 配置**
   - 在Firebase Console創建新項目
   - 下載並配置 `google-services.json` (Android) 和 `GoogleService-Info.plist` (iOS)
   - 更新 `firebase_service.dart` 中的項目ID和API密鑰

4. **運行應用**
   ```bash
   flutter run
   ```

## 🔧 使用指南

### 模型規格模板管理

1. **進入管理頁面**
   - 導航到管理員功能
   - 選擇"模型規格模板"

2. **新增模型**
   - 點擊"新增模型"按鈕
   - 輸入模型名稱
   - 配置各項規格參數

3. **編輯現有模型**
   - 從下拉選單選擇模型
   - 在標籤頁中修改對應規格
   - 點擊保存按鈕

4. **刪除模型**
   - 選擇要刪除的模型
   - 點擊刪除按鈕並確認

### 規格配置說明

#### 輸入輸出特性 (Input/Output Characteristics)
- 左側/右側輸入電壓範圍 (Vin)
- 左側/右側輸入電流範圍 (Iin)  
- 左側/右側輸入功率範圍 (Pin)
- 左側/右側輸出電壓範圍 (Vout)
- 左側/右側輸出電流範圍 (Iout)
- 左側/右側輸出功率範圍 (Pout)

#### 基本功能測試 (Basic Function Test)
- 效率 (Efficiency)
- 功率因子 (Power Factor)
- 總諧波失真 (THD)
- 軟啟動時間 (Soft Start)

#### 耐壓測試 (Hipot Test)
- 絕緣阻抗規格
- 漏電流規格

#### PSU序號規格 (PSU Serial Number) 🆕
- PSU數量 (Quantity) - 設定每個產品型號的PSU配置數量
- 預設值：12個
- 影響：PSU序號表格顯示行數、生產批次管理

## 🔄 API 接口

### FirebaseService 主要方法

```dart
// 獲取模型列表
Future<List<String>> getModelList()

// 獲取規格資料
Future<Map<String, Map<String, dynamic>>> getAllSpecs({
  required String model,
  required List<String> tableNames,
})

// 保存規格資料
Future<bool> addOrUpdateSpec({
  required String model,
  required String tableName,
  required Map<String, dynamic> spec,
})

// 獲取失敗計數
Future<Map<String, int>> getAllFailCounts({
  required String model,
  required String serialNumber,
  required List<String> tableNames,
})
```

## 🌍 國際化支持

系統支持多語言切換：
- 繁體中文 (zh-TW)
- 英文 (en-US)

語言文件位置：`assets/translations/`

## 🔒 安全性

- Firebase Authentication 用戶認證
- Firestore 安全規則配置
- API 密鑰保護
- 資料傳輸加密

## 🚧 開發指南

### 項目結構
```
lib/
├── src/
│   ├── report/
│   │   └── spec/           # 資料模型定義
│   ├── repo/
│   │   └── firebase_service.dart  # Firebase服務
│   └── widget/
│       ├── admin/          # 管理員界面
│       └── common/         # 共用組件
└── main.dart
```

### 新增功能建議
1. 建立新的規格類別時，請遵循現有的命名規範
2. 在FirebaseService中新增對應的API方法
3. 更新UI組件以支持新的資料類型
4. 新增對應的國際化文字

## 📝 版本更新記錄

### v1.0.0
- 初始版本發布
- 基本OQC報告功能
- 模型規格模板管理
- Firebase集成

## 🤝 貢獻指南

1. Fork 此項目
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 授權條款

此項目採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案

## 📞 聯絡資訊

如有問題或建議，請聯絡開發團隊：
- 項目負責人: [Your Name]
- Email: [your.email@example.com]
- 項目地址: [repository-url]

---

**Zerova OQC Report System** - 讓品質控制更簡單、更可靠 🎯
