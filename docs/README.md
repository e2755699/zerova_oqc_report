# Zerova OQC Report Documentation

## 目錄

### 1. 系統架構
- [資料結構說明](DataStructure.md)
- [PDF 產生器說明](pdf_generator.md)

### 2. 功能模組
- [PSU 序號規格](PsuSerialNumSpec.md)
- [包裝清單頁面](PackageListTab.md)
- [型號規格範本頁面](ModelSpecTemplatePage.md)

### 3. 整合服務
- [SharePoint 基本說明](sharepoint.md)
- [SharePoint Graph API 整合](SharePointGraphAPI.md)

### 4. 版本歷史
所有版本更新記錄都保存在 `prompt-history/` 目錄下：
- [Release 2.0 打包](prompt-history/release-2.0-packaging.md)
- [Release 2.1 打包](prompt-history/release-2.1-packaging.md)
- [Release 2.2 打包](prompt-history/release-2.2-packaging.md)
- [新增發布流程和版本顯示](prompt-history/add-release-flow-and-version-display.md)
- [檢查 Cursor Rules](prompt-history/check-cursor-rules.md)

## 文件說明

### DataStructure.md
- 系統核心資料結構說明
- OQC 報告相關資料模型
- 資料流程和關係圖

### pdf_generator.md
- PDF 報告生成器的實作說明
- 報告模板設計
- 生成流程和注意事項

### PsuSerialNumSpec.md
- PSU 序號規格定義
- 序號格式驗證規則
- 序號生成邏輯

### PackageListTab.md
- 包裝清單頁面功能說明
- 資料輸入和驗證規則
- UI 元件說明

### ModelSpecTemplatePage.md
- 型號規格範本頁面說明
- 範本管理功能
- 資料匯入匯出功能

### sharepoint.md
- SharePoint 整合基本說明
- 檔案上傳下載機制
- 權限管理

### SharePointGraphAPI.md
- Graph API 整合細節
- API 呼叫範例
- 認證和授權機制

## 開發注意事項

1. 所有程式碼註解必須使用英文
2. 每個新功能或修改都需要在 `prompt-history/` 中記錄
3. 遵循 OQC 報告的 10 個必要表格規範：
   - Basic Information Table
   - PSU S/N Table
   - Software Version Table
   - Appearance & Structure Inspection Table
   - Input & Output Characteristics Table
   - Basic Function Test Table
   - Protection Function Test Table
   - Package List Table
   - Attachment Table
   - Signature Table
