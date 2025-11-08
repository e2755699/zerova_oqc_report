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

#### PSU序號規格 (PSU Serial Number)
- PSU數量 (Quantity) - 設定每個產品型號的PSU配置數量
- 預設值：12個
- 影響：PSU序號表格顯示行數、生產批次管理

#### 包裝清單規格 (Package List) 🆕
- 動態包裝項目管理 - 可新增、編輯、刪除包裝項目
- 預設項目：PSU主體、電源線、使用手冊、保固書、包裝盒
- 項目屬性：名稱、數量
- 影響：OQC報告包裝清單表格內容

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

## 🚀 發布Release版本流程

### 準備工作
1. **確保代碼品質**
   - 運行測試並確保通過
   - 檢查程式碼linting
   - 驗證所有功能正常運作

2. **版本更新**
   ```bash
   # 更新 pubspec.yaml 中的版本號
   # 格式: major.minor.patch+build
   # 例如: 2.0.0+1
   ```

### 發布步驟

#### 1. 更新版本號
```bash
# 編輯 pubspec.yaml
version: x.y.z+build_number
```

#### 2. 提交變更
```bash
# 添加所有修改
git add .

# 提交版本更新
git commit -m "Release vx.y.z: [描述主要變更]"

# 推送到遠端
git push origin [branch-name]
```

#### 3. 創建Release標籤
```bash
# 創建帶註解的標籤
git tag -a vx.y.z -m "Release version x.y.z - [變更摘要]"

# 推送標籤到遠端
git push origin vx.y.z
```

#### 4. 建置Release版本

**Windows版本:**
```bash
# 清理舊建置（可選）
flutter clean

# 獲取依賴
flutter pub get

# 建置Windows Release
flutter build windows --release
```

#### 4.1 Windows 安裝檔打包 🆕

系統已提供自動化打包腳本，可將 Windows 建置檔打包成完整的安裝檔，包含所有 assets 和 config 檔案。

**使用打包腳本：**
```powershell
# 執行打包腳本
powershell -ExecutionPolicy Bypass -File package_windows.ps1
```

**打包內容：**
- ✅ 主執行檔：`zerova_oqc_report.exe`
- ✅ 所有必要的 DLL 檔案
- ✅ Assets 資源：
  - `config.json`（assets 和根目錄都有）
  - `logo.png`
  - 所有翻譯檔案（zh-TW.json, en-US.json, ja-JP.json, vi-VN.json）
- ✅ README.txt 說明檔

**打包輸出：**
- ZIP 安裝檔：`dist/Zerova_OQC_Report_v{version}_Windows.zip`
- 解壓縮資料夾：`dist/Zerova_OQC_Report_{version}/`

**手動打包步驟：**
1. 建置完成後，檔案位於 `build/windows/x64/runner/Release/`
2. 複製整個 Release 目錄到打包資料夾
3. 將根目錄的 `config.json` 複製到打包資料夾根目錄（作為備份）
4. 確認所有 assets 檔案都在 `data/flutter_assets/assets/` 目錄下
5. 將整個資料夾壓縮成 ZIP 檔

**安裝檔使用：**
1. 解壓縮 ZIP 檔到任意資料夾（例如 `C:\Program Files\Zerova_OQC_Report`）
2. 執行 `zerova_oqc_report.exe` 即可啟動應用程式
3. 配置檔案位置：
   - 主要使用：`data/flutter_assets/assets/config.json`
   - 備用位置：根目錄的 `config.json`

**其他平台:**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (需要 macOS)
flutter build ios --release

# Web
flutter build web --release
```

#### 5. 驗證建置結果
- **Windows**: 
  - 檢查 `build/windows/x64/runner/Release/` 目錄
  - 檢查打包後的 `dist/Zerova_OQC_Report_v{version}/` 目錄
  - 確認所有 assets 和 config 檔案都已包含
- **Android**: 檢查 `build/app/outputs/` 目錄
- **Web**: 檢查 `build/web/` 目錄

#### 6. 建置檔案組織
```
release/
├── windows/
│   ├── zerova_oqc_report.exe
│   ├── [所有相依DLL檔案]
│   └── data/
├── android/
│   └── app-release.apk
└── documentation/
    ├── RELEASE_NOTES.md
    └── INSTALLATION_GUIDE.md
```

#### 7. GitHub Release
1. 前往 GitHub 專案頁面
2. 點擊 "Releases" → "Create a new release"
3. 選擇剛才建立的標籤
4. 填寫Release標題和說明
5. 上傳建置檔案
6. 勾選 "Set as the latest release"
7. 發布Release

### Release檢查清單
- [ ] 版本號已更新
- [ ] 所有測試通過
- [ ] 代碼已提交並推送
- [ ] Git標籤已創建並推送
- [ ] Windows版本建置成功
- [ ] Windows安裝檔已打包（使用 `package_windows.ps1`）
- [ ] 確認所有 assets 和 config 檔案已包含在安裝檔中
- [ ] 所有依賴檔案包含完整
- [ ] Release文檔已準備
- [ ] GitHub Release已發布
- [ ] 部署到生產環境（如適用）

### 版本命名規範
- **Major (主版本)**: 重大功能更新或不兼容變更
- **Minor (次版本)**: 新功能添加，向後兼容
- **Patch (修補版本)**: 錯誤修復和小改進
- **Build (建置號)**: 每次建置遞增

範例: `2.1.3+15`
- 主版本: 2 (重大更新)
- 次版本: 1 (新功能)
- 修補版本: 3 (第3次修復)
- 建置號: 15 (第15次建置)

## 📝 版本更新記錄

### v2.0.0 (2024-12-19)
- 增強PDF生成器功能
- 改進OQC報告生成器性能
- 新增詳細PDF生成器文檔
- 版本管理流程優化

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
