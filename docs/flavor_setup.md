# Flavor 設定說明

## 概述

本專案支援兩個 flavor：
- **tw**: 台灣廠
- **vn**: 越南廠

每個 flavor 使用不同的 API 端點和 SharePoint 路徑。

## Flavor 配置

### API 端點

- **台灣廠 (tw)**: `http://api.ztmn.com/zapi`
- **越南廠 (vn)**: `http://172.21.1.110:5000/zapi`

### SharePoint 路徑

- **台灣廠 (tw)**: 使用原始路徑，例如 `Jackalope/外觀參考照片/`
- **越南廠 (vn)**: 在 `Jackalope/` 後面插入 `vn/`，例如 `Jackalope/vn/外觀參考照片/`

**注意**: `Jackalope` 是 SharePoint 的根目錄，越南廠的路徑會在根目錄後插入 `vn/` 前綴。

## Factory 配置

### 在 config.json 中設定（推薦）

Factory 配置現在統一放在 `config.json` 中管理：

```json
{
  "factory": "tw",  // 或 "vn" 表示越南廠
  "clientId": "...",
  ...
}
```

**優先順序**:
1. `config.json` 中的 `factory` 欄位（優先）
2. 環境變數 `--dart-define=FLAVOR=xx`（備用）
3. 預設值 `"tw"`（如果都沒有）

詳細說明請參考 [Factory 配置說明](./config_factory_setup.md)

## 建置應用程式

### 使用 config.json（推薦）

只需要在 `config.json` 中設定 `"factory": "tw"` 或 `"factory": "vn"`，建置時不需要額外參數：

```bash
flutter build windows --release
flutter build apk --release
```

### 使用環境變數（備用）

如果 `config.json` 中沒有 `factory` 欄位，可以使用 `--dart-define`：

```bash
flutter build windows --dart-define=FLAVOR=vn --release
```

### Windows

#### 使用 config.json（推薦）

1. 編輯 `config.json` 設定 `"factory": "tw"` 或 `"factory": "vn"`
2. 建置應用程式：

```bash
flutter build windows --release
```

#### 使用 PowerShell 腳本

**台灣廠:**
```powershell
# 確保 config.json 中 "factory": "tw"
.\build_tw.ps1
```

**越南廠:**
```powershell
# 確保 config.json 中 "factory": "vn"
.\build_vn.ps1
```

#### 使用環境變數（備用）

如果 `config.json` 中沒有 `factory` 欄位：

**台灣廠:**
```bash
flutter build windows --dart-define=FLAVOR=tw --release
```

**越南廠:**
```bash
flutter build windows --dart-define=FLAVOR=vn --release
```

### 執行應用程式

**使用 config.json（推薦）:**
```bash
# 確保 config.json 中設定正確的 factory
flutter run
```

**使用環境變數（備用）:**
```bash
# 台灣廠
flutter run --dart-define=FLAVOR=tw

# 越南廠
flutter run --dart-define=FLAVOR=vn
```

## 程式碼中的使用

### 檢查當前 Flavor

```dart
import 'package:zerova_oqc_report/src/config/flavor_config.dart';

// 檢查是否為台灣廠
if (FlavorConfig.isTaiwan) {
  // 台灣廠特定邏輯
}

// 檢查是否為越南廠
if (FlavorConfig.isVietnam) {
  // 越南廠特定邏輯
}

// 取得當前 flavor
String currentFlavor = FlavorConfig.currentFlavor; // 'tw' 或 'vn'
```

### 取得 API Base URL

```dart
import 'package:zerova_oqc_report/src/config/flavor_config.dart';

String apiUrl = FlavorConfig.apiBaseUrl;
// 台灣廠: 'http://api.ztmn.com/zapi'
// 越南廠: 'http://172.21.1.110:5000/zapi'
```

### 使用 OqcApiClient

`OqcApiClient` 會自動根據 flavor 使用正確的 API URL：

```dart
import 'package:zerova_oqc_report/src/client/oqc_api_client.dart';

// 自動使用當前 flavor 的 API URL
final client = OqcApiClient();

// 或手動指定 URL
final client = OqcApiClient(baseUrl: 'http://custom-url.com/zapi');
```

### SharePoint 路徑

`SharePointUploader` 會自動根據 flavor 在 `Jackalope/` 後插入前綴：

```dart
// 台灣廠: "Jackalope/外觀參考照片/model"
// 越南廠: "Jackalope/vn/外觀參考照片/model"
```

路徑會自動透過 `_buildSharePointPath()` 方法處理，所有 CRUD 操作（上傳、下載、刪除）都會使用正確的路徑。

## 注意事項

1. **配置優先順序**: `config.json` > 環境變數 > 預設值 (`tw`)
2. **大小寫**: Factory 名稱不區分大小寫，`tw`、`TW`、`Tw` 都會被視為台灣廠
3. **SharePoint 配置**: 確保越南廠的 SharePoint 中有對應的 `vn/` 資料夾結構
4. **部署時**: 確保執行檔目錄下的 `config.json` 有正確的 `factory` 設定

## 測試

在開發時，可以使用以下命令切換 flavor 進行測試：

```bash
# 測試台灣廠
flutter run --dart-define=FLAVOR=tw

# 測試越南廠
flutter run --dart-define=FLAVOR=vn
```

**注意**: Android 的 `build.gradle` 中仍然定義了 flavor（用於設定 applicationId），但 Flutter 建置時只需要使用 `--dart-define` 即可。

