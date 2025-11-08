# API 測試網站部署說明

## 部署步驟

### 1. 安裝依賴

```bash
cd functions
npm install
```

### 2. 部署 Firebase Cloud Functions

```bash
firebase deploy --only functions
```

這會部署 `proxyOqcApi` Cloud Function，用於代理 HTTP API 請求以解決 Mixed Content 問題。

### 3. 部署網站

```bash
firebase deploy --only hosting
```

## 功能說明

### Mixed Content 問題解決

當網站使用 HTTPS 但需要請求 HTTP API 時，會遇到 Mixed Content 錯誤。本系統使用 Firebase Cloud Function 作為代理來解決這個問題：

1. **自動代理**：當檢測到 HTTP API + HTTPS 網站時，自動使用代理
2. **直接請求**：如果 API 是 HTTPS 或網站在 HTTP 環境，直接請求

### 代理 URL

代理 Function 的 URL：
```
https://us-central1-oqcreport-87e5a.cloudfunctions.net/proxyOqcApi
```

### 使用方式

1. 選擇 API Base URL（HTTP 或 HTTPS）
2. 選擇 API Endpoint
3. 輸入 Serial Number
4. 點擊「測試 API」

系統會自動判斷是否需要使用代理。

## 注意事項

1. **內網 API**：越南廠 API (`172.21.1.110`) 是內網 IP，即使使用代理也無法從公網訪問
2. **CORS**：代理會自動處理 CORS 標頭
3. **認證**：Token 由代理處理，不需要在前端傳遞

## 故障排除

如果代理無法工作：
1. 確認 Cloud Function 已成功部署
2. 檢查 Firebase Console 中的 Function 日誌
3. 確認 Function URL 是否正確

