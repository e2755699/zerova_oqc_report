# 越南廠設定完成說明

## 完成項目

### 1. ✅ Flavor 配置系統

已實作完整的 flavor 配置系統，支援台灣廠 (tw) 和越南廠 (vn)。

**相關檔案:**
- `lib/src/config/flavor_config.dart` - Flavor 配置管理類別
- `android/app/build.gradle` - Android flavor 設定

**功能:**
- 自動根據 flavor 選擇正確的 API URL
- 自動根據 flavor 設定 SharePoint 路徑前綴
- 提供便利的檢查方法 (`isTaiwan`, `isVietnam`)

### 2. ✅ API 端點配置

**台灣廠:**
- API URL: `http://api.ztmn.com/zapi`

**越南廠:**
- API URL: `http://172.21.1.110:5000/zapi`

**修改檔案:**
- `lib/src/client/oqc_api_client.dart` - 支援動態 baseUrl

### 3. ✅ SharePoint 路徑設計

**設計方案:**
- 台灣廠: 使用原始路徑，例如 `Jackalope/外觀參考照片/`
- 越南廠: 在 `Jackalope/` 後面插入 `vn/`，例如 `Jackalope/vn/外觀參考照片/`

**說明:**
- `Jackalope` 是 SharePoint 的根目錄
- 越南廠的路徑會在 `Jackalope/` 之後插入 `vn/` 前綴
- 所有 CRUD 操作（上傳、下載、刪除）都會自動使用正確的路徑

**優點:**
- 路徑清晰，易於區分
- 保持 `Jackalope` 作為根目錄的一致性
- 只需在越南廠的 SharePoint 中建立 `Jackalope/vn/` 資料夾結構

**修改檔案:**
- `lib/src/repo/sharepoint_uploader.dart` - 所有 SharePoint 路徑都會自動在 `Jackalope/` 後插入 flavor 前綴

**路徑範例:**
```
台灣廠:
- Jackalope/外觀參考照片/{model}/
- Jackalope/配件包參考照片/{model}/
- Jackalope/Photos/{sn}/Attachment/
- Jackalope/Photos/{sn}/Packaging/
- Jackalope/OQC Report/{sn}/

越南廠:
- Jackalope/vn/外觀參考照片/{model}/
- Jackalope/vn/配件包參考照片/{model}/
- Jackalope/vn/Photos/{sn}/Attachment/
- Jackalope/vn/Photos/{sn}/Packaging/
- Jackalope/vn/OQC Report/{sn}/
```

### 4. ✅ API 測試網站

已建立完整的 API 測試網站，使用 Google Gemini AI 進行欄位驗證。

**位置:**
- `api_test_site/index.html` - 測試網站主頁面
- `api_test_site/README.md` - 使用說明

**功能:**
- ✅ 支援測試台灣廠和越南廠的 API
- ✅ 支援測試 OQC、TEST、KEYPART 三個端點
- ✅ 使用 Gemini AI 驗證 API 回應欄位
- ✅ 顯示詳細的差異資訊（欄位名稱、資料型態等）
- ✅ 可下載 API 回應 JSON 檔案
- ✅ 美觀的 UI 設計

**部署:**
- 已設定 Firebase Hosting 配置
- 部署命令: `firebase deploy --only hosting`

**使用方式:**
1. 客戶在內網環境中開啟測試網站
2. 選擇要測試的 API (台灣/越南)
3. 輸入 Serial Number
4. 點擊「測試 API」
5. 查看驗證結果
6. 如有需要，下載回應 JSON

## 建置與部署

### Windows 建置

**使用 config.json（推薦）:**

1. 編輯 `config.json` 設定 `"factory": "tw"` 或 `"factory": "vn"`
2. 建置應用程式：

```bash
flutter build windows --release
```

**使用環境變數（備用）:**

**台灣廠:**
```bash
flutter build windows --dart-define=FLAVOR=tw --release
```

**越南廠:**
```bash
flutter build windows --dart-define=FLAVOR=vn --release
```

### 測試網站部署

```bash
# 安裝 Firebase CLI (如果尚未安裝)
npm install -g firebase-tools

# 登入 Firebase
firebase login

# 部署測試網站
firebase deploy --only hosting
```

## SharePoint 設定

### 越南廠 SharePoint 資料夾結構

請在越南廠的 SharePoint 中建立以下資料夾結構（在 `Jackalope/` 目錄下建立 `vn/` 子目錄）：

```
Jackalope/
└── vn/
    ├── 外觀參考照片/
    │   ├── {model}/
    │   └── default/
    ├── 配件包參考照片/
    │   ├── {model}/
    │   └── default/
    ├── Photos/
    │   └── {sn}/
    │       ├── Attachment/
    │       └── Packaging/
    └── OQC Report/
        └── {sn}/
```

## 注意事項

1. **API 內網限制**: 越南廠的 API (`http://172.21.1.110:5000/zapi`) 只能在內網存取，測試網站也需要在內網環境中使用。

2. **SharePoint 權限**: 確保越南廠的 SharePoint 應用程式有權限存取 `vn/` 資料夾下的所有內容。

3. **Gemini API Key**: 測試網站使用 Gemini API 進行欄位驗證，請確保 API Key 有效。

4. **Flavor 預設值**: 如果沒有指定 `FLAVOR` 環境變數，預設會使用 `tw` (台灣廠)。

## 相關文件

- [Flavor 設定說明](./flavor_setup.md) - 詳細的 flavor 使用說明
- [API 測試網站 README](../api_test_site/README.md) - 測試網站使用說明

## 測試建議

1. **本地測試**: 使用 `flutter run --dart-define=FLAVOR=vn` 測試越南廠配置
2. **API 測試**: 使用測試網站驗證 API 回應是否符合預期
3. **SharePoint 測試**: 確認越南廠的 SharePoint 路徑正確建立和存取

