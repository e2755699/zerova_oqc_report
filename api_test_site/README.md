# OQC API 測試工具

這是一個用於測試 OQC API 並驗證回應欄位是否符合預期的網頁工具。

## 功能

1. **API 測試**: 可以測試不同工廠的 API (台灣/越南)
2. **欄位驗證**: 使用 Google Gemini AI 來驗證 API 回應的欄位是否符合預期
3. **下載回應**: 可以下載 API 回應的 JSON 檔案
4. **差異顯示**: 如果欄位不符，會顯示詳細的差異資訊

## 部署到 Firebase

### 1. 安裝依賴和工具

```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 安裝 Functions 依賴
cd functions
npm install
cd ..
```

### 2. 登入 Firebase

```bash
firebase login
```

### 3. 部署 Cloud Functions（解決 Mixed Content 問題）

```bash
firebase deploy --only functions
```

### 4. 部署網站

```bash
firebase deploy --only hosting
```

### 完整部署（一次部署所有）

```bash
firebase deploy
```

詳細說明請參考 [DEPLOY.md](./DEPLOY.md)

## 使用方式

1. 選擇 API Base URL (台灣廠或越南廠)
2. 選擇要測試的 API Endpoint (OQC, TEST, KEYPART)
3. 輸入 Serial Number
4. 點擊「測試 API」按鈕
5. 查看驗證結果（系統會自動使用 Gemini AI 驗證欄位）
6. 如果需要，可以下載回應 JSON 檔案

## 注意事項

- 此工具需要在客戶的內網環境中使用，因為 API 只能在內網存取
- **Gemini API Key 已安全地儲存在後端**，不需要在前端輸入
- 如果 Gemini API 驗證失敗，仍會顯示 API 回應內容
- 越南廠 API (172.21.1.110) 是內網 IP，即使使用代理也無法從公網訪問

