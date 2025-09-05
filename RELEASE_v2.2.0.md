# Zerova OQC Report Generator - Release v2.2.0

## 發布日期
2024-12-19

## 版本資訊
- **版本號**: 2.2.0+1
- **Git Tag**: v2.2.0
- **分支**: versions/1.0

## 🚀 主要功能

### 核心功能
1. **OQC報告生成**
   - 10種標準報告表格
   - PDF生成與匯出
   - 多語言支援

2. **版本顯示**
   - 右下角版本資訊
   - 美觀的半透明設計

3. **Release流程**
   - 標準化發布流程
   - 完整的文檔支援
   - 版本管理最佳實踐

## 建置資訊

### Windows Release
- **執行檔**: `build/windows/x64/runner/Release/zerova_oqc_report.exe`
- **建置時間**: 108.2秒
- **建置日期**: 2024-12-19

### 依賴檔案
```
Release/
├── zerova_oqc_report.exe
├── flutter_windows.dll
├── pdfium.dll
├── [插件DLL檔案]
└── data/
    ├── app.so
    └── flutter_assets/
```

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

## 技術棧
- **框架**: Flutter 3.x
- **語言**: Dart
- **平台**: Windows (主要)
- **資料庫**: Firebase Firestore
- **認證**: Firebase Authentication

## 版本對比
| 功能 | v2.1.0 | v2.2.0 |
|------|--------|--------|
| OQC報告生成 | ✅ | ✅ |
| PDF匯出 | ✅ | ✅ |
| 版本顯示 | ✅ | ✅ |
| Release流程 | ✅ | ✅ |
| 多語言支援 | ✅ | ✅ |

## 已知問題
- 無已知重大問題
- 建議在生產環境使用前進行完整測試

## 下一版本預告 (v2.3.0)
- 自動版本檢測
- 效能優化
- UI/UX改進

---

**感謝使用 Zerova OQC Report Generator v2.2.0！**
如有任何問題或建議，請聯絡開發團隊。🎯
