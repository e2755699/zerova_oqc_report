# Config.json 設定說明

## 📌 重要提醒

`assets/config.json` 包含敏感資訊（SharePoint credentials），**不應該提交到 git**。

## 🔧 設定步驟

1. 如果 `assets/config.json` 不存在，從範本複製：
   ```powershell
   .\restore-config.ps1
   ```
   
   或手動複製：
   ```powershell
   Copy-Item config.template.json assets/config.json
   ```

2. 編輯 `assets/config.json` 填入正確的憑證：
   - `factory`: 工廠代碼 (tw/vn)
   - `clientId`: Azure AD Client ID
   - `clientSecret`: Azure AD Client Secret
   - `tenantId`: Azure AD Tenant ID
   - `siteId`: SharePoint Site ID
   - `driveId`: SharePoint Drive ID

## ⚠️ 合併後 config.json 消失？

如果合併後 `config.json` 不見了，直接執行：
```powershell
.\restore-config.ps1
```

然後重新填入你的憑證。

## 🔒 安全性

- ✅ `config.json` 已在 `.gitignore` 中
- ✅ 不會被 git 追蹤
- ✅ 本地文件不會被合併影響

## 📄 相關文件

- `config.template.json`: 配置範本（可以提交到 git）
- `assets/config.json`: 實際配置（絕對不要提交）

