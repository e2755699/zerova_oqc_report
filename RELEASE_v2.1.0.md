# Zerova OQC Report Generator - Release v2.1.0

## 發布日期
2024-12-19

## 版本資訊
- **版本號**: 2.1.0+1
- **Git Tag**: v2.1.0
- **分支**: versions/1.0

## 🚀 主要新增功能

### 📋 完整的Release流程文檔
- 新增詳細的發布Release版本流程章節在README.md
- 包含準備工作、發布步驟、版本命名規範
- 提供完整的檢查清單確保發布品質
- 支援多平台建置指令 (Windows, Android, iOS, Web)

### 🏷️ 版本顯示功能
- 在HomePage右下角添加版本號顯示
- 美觀的半透明容器設計
- 顯示格式：v2.1.0+1
- 登入前後頁面都會顯示

### 📚 文檔完善
- 新增Release流程的詳細說明
- 更新版本更新記錄
- 改善專案管理流程

## 技術改進

### UI/UX 提升
- 版本資訊展示：右下角固定位置顯示版本號
- 視覺設計：使用圓角邊框、灰色配色、適當字體大小
- 響應式佈局：在不同頁面狀態下保持一致性

### 開發流程優化
- 標準化Release流程：從版本更新到GitHub發布的完整步驟
- 版本命名規範：Major.Minor.Patch+Build的詳細說明
- 檢查清單：確保每次發布的完整性和品質

## 建置資訊

### Windows Release
- **執行檔**: `build/windows/x64/runner/Release/zerova_oqc_report.exe`
- **建置時間**: 約95.7秒
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
- 材質設計圖示字體

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
- 最小記憶體：4GB RAM
- 硬碟空間：200MB 可用空間
- 顯示器解析度：1024x768 或更高

## 安裝說明
1. 下載Release目錄中的所有檔案
2. 確保所有DLL檔案與執行檔在同一目錄
3. 直接執行 `zerova_oqc_report.exe`
4. 首次啟動會進行權限確認

## 升級說明
從v2.0.0升級到v2.1.0：
- 直接替換執行檔和相關檔案
- 保留使用者設定和資料
- 無需額外配置步驟

## 已知問題
- 無已知重大問題
- 建議在生產環境使用前進行完整測試

## 技術棧
- **框架**: Flutter 3.x
- **語言**: Dart
- **平台**: Windows (主要), 支援跨平台擴展
- **依賴**: PDF生成、檔案選擇、列印、攝影頭、權限管理等
- **資料庫**: Firebase Firestore
- **認證**: Firebase Authentication

## 版本對比
| 功能 | v2.0.0 | v2.1.0 |
|------|--------|--------|
| PDF生成器 | ✅ | ✅ |
| OQC報告 | ✅ | ✅ |
| 版本顯示 | ❌ | ✅ |
| Release流程文檔 | ❌ | ✅ |
| 多語言支援 | ✅ | ✅ |

## 下一版本預告
v2.2.0 預計功能：
- 自動版本檢測功能
- 效能優化
- 更多報告樣式選擇

---

**感謝使用 Zerova OQC Report Generator v2.1.0！**
如有任何問題或建議，請聯絡開發團隊。🎯
