# 添加Release流程和版本顯示功能

## 使用者請求
1. 幫我在 @README.md 裡面加入發布release版本流程
2. 幫我在 @HomePage 右下角放上version

## 時間
2024-12-19

## 執行內容

### 1. README.md - 添加Release版本流程
- 新增詳細的發布Release版本流程章節
- 包含準備工作、發布步驟、版本命名規範
- 添加完整的檢查清單
- 更新版本更新記錄

主要內容：
- 版本更新流程
- Git標籤管理
- 多平台建置指令
- GitHub Release發布步驟
- 版本命名規範說明

### 2. HomePage - 添加版本顯示
- 在HomePage右下角添加版本號顯示
- 使用半透明容器樣式設計
- 版本號格式：v2.0.0+1
- 位置：固定在右下角16px邊距

技術實現：
- 使用 `Stack` 和 `Positioned` 佈局
- 版本號硬編碼為 v2.0.0+1
- 樣式：灰色背景、圓角邊框、小字體

### 檔案修改
1. **README.md** - 新增Release流程章節
2. **lib/src/widget/home/home_page.dart** - 添加版本顯示功能
3. **pubspec.yaml** - 臨時添加後移除package_info_plus依賴

### 技術細節
- 原本嘗試使用 package_info_plus 動態讀取版本
- 由於依賴兼容性問題，改為硬編碼版本號
- 清理了未使用的imports和linting警告
- 保持代碼整潔和可維護性

### 結果
- 成功添加完整的Release流程文檔
- HomePage右下角顯示版本號
- 代碼無linting錯誤
- 功能完成並可正常使用
