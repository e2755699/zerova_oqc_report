# Factory 配置說明

## 概述

Factory（工廠）配置現在統一放在 `config.json` 中管理，不再需要透過 `--dart-define` 參數傳遞。

## 配置方式

### 1. 在 config.json 中設定

編輯 `assets/config.json` 或 `config.json`（執行檔目錄下的）：

```json
{
  "factory": "tw",
  "clientId": "...",
  "clientSecret": "...",
  ...
}
```

**可用的 factory 值**:
- `"tw"` - 台灣廠
- `"vn"` - 越南廠

### 2. 配置優先順序

1. **config.json** (優先) - 從 `assets/config.json` 或執行檔目錄下的 `config.json` 讀取
2. **環境變數** (備用) - 如果 config.json 中沒有 `factory` 欄位，會嘗試從 `--dart-define=FLAVOR=xx` 讀取
3. **預設值** - 如果都沒有，預設為 `"tw"` (台灣廠)

## 不同工廠的配置

### 台灣廠配置範例

```json
{
  "factory": "tw",
  "clientId": "YOUR_CLIENT_ID",
  "clientSecret": "YOUR_CLIENT_SECRET",
  "tenantId": "YOUR_TENANT_ID",
  "redirectUri": "http://localhost:8000/callback",
  "siteId": "YOUR_SITE_ID",
  "driveId": "YOUR_DRIVE_ID"
}
```

### 越南廠配置範例

```json
{
  "factory": "vn",
  "clientId": "YOUR_CLIENT_ID",
  "clientSecret": "YOUR_CLIENT_SECRET",
  "tenantId": "YOUR_TENANT_ID",
  "redirectUri": "http://localhost:8000/callback",
  "siteId": "YOUR_SITE_ID",
  "driveId": "YOUR_DRIVE_ID"
}
```

## 自動行為

根據 `factory` 設定，系統會自動：

1. **API 端點**:
   - `tw`: `http://api.ztmn.com/zapi`
   - `vn`: `http://172.21.1.110:5000/zapi`

2. **SharePoint 路徑**:
   - `tw`: `Jackalope/外觀參考照片/...`
   - `vn`: `Jackalope/vn/外觀參考照片/...`

## 建置應用程式

現在建置時**不需要**指定 `--dart-define=FLAVOR`，系統會自動從 `config.json` 讀取：

```bash
# 建置 Windows 版本
flutter build windows --release
```

**注意**: 確保執行檔目錄下的 `config.json` 有正確的 `factory` 設定。

## 部署建議

### 台灣廠部署

1. 確保 `config.json` 中 `"factory": "tw"`
2. 建置應用程式
3. 部署時確保 `config.json` 一起打包

### 越南廠部署

1. 確保 `config.json` 中 `"factory": "vn"`
2. 建置應用程式
3. 部署時確保 `config.json` 一起打包

## 向後相容性

如果 `config.json` 中沒有 `factory` 欄位，系統會：
1. 嘗試從環境變數 `--dart-define=FLAVOR=xx` 讀取
2. 如果都沒有，預設為 `"tw"`

這樣可以確保舊的建置方式仍然可以運作。

