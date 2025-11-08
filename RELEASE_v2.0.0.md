# Zerova OQC Report Generator - Release v2.0.0

## 發布日期
2024-12-19

## 版本資訊
- **版本號**: 2.0.0+1
- **Git Tag**: v2.0.0
- **分支**: versions/1.0

## 主要變更

### 新增功能
- 增強PDF生成器功能和文檔
- 改進OQC報告生成器的整體性能

### 技術改進
- 更新版本配置至2.0.0
- 新增PDF生成器詳細文檔 (`docs/pdf_generator.md`)
- 改善代碼結構和可維護性

## 建置資訊

### Windows Release
- **執行檔**: `build/windows/x64/runner/Release/zerova_oqc_report.exe`
- **依賴DLL檔案**:
  - `flutter_windows.dll`
  - `pdfium.dll`
  - `camera_windows_plugin.dll`
  - `permission_handler_windows_plugin.dll`
  - `printing_plugin.dll`
  - `screen_retriever_plugin.dll`
  - `url_launcher_windows_plugin.dll`
  - `webview_windows_plugin.dll`
  - `WebView2Loader.dll`
  - `window_manager_plugin.dll`

### 資源檔案
- 配置文件和多語言翻譯
- Logo和圖示資源
- Flutter資源包

## 支援的OQC報告表格
1. Basic Information Table (基本資訊表)
2. PSU S/N Table (PSU序號表)
3. Software Version Table (軟體版本表)
4. Appearance & Structure Inspection Table (外觀結構檢查表)
5. Input & Output Characteristics Table (輸入輸出特性表)
6. Basic Function Test Table (基本功能測試表)
7. Protection Function Test Table (保護功能測試表)
8. Package List Table (包裝清單表)
9. Attachment Table (附件表)
10. Signature Table (簽名表)

## 系統需求
- Windows 10 x64 或更新版本
- Visual Studio 2022 Community (開發環境)
- Flutter SDK (開發環境)

## 安裝說明
1. 下載Release目錄中的所有檔案
2. 確保所有DLL檔案與執行檔在同一目錄
3. 直接執行 `zerova_oqc_report.exe`

## 技術棧
- **框架**: Flutter 3.x
- **語言**: Dart
- **平台**: Windows (主要), 支援跨平台擴展
- **依賴**: PDF生成、檔案選擇、列印、攝影頭、權限管理等

## 開發團隊
- 使用者界面：Modern Flutter UI with UX best practices
- PDF生成：Enhanced PDF generation capabilities
- 多語言支援：繁體中文、英文、日文、越南文

---

此版本已成功建置並準備發布。所有核心功能已測試並可正常運作。
