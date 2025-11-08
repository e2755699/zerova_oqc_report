# 解決 Build 目錄被鎖定問題

## 🔴 問題現象
```
由於另一個處理序正在使用檔案 'cppwinrt.exe'，所以無法存取該檔案。
Failed to install nuget package Microsoft.Windows.CppWinRT.2.0.210806.1
```

## ✅ 解決方案

### 方法 1：暫時關閉 Windows Defender 即時保護（最快，5分鐘）

1. **按 Win + I** 開啟設定
2. 進入 **隱私權與安全性** → **Windows 安全性**
3. 點擊 **病毒與威脅防護**
4. 在「病毒與威脅防護設定」下，點擊 **管理設定**
5. **暫時關閉「即時保護」**（會自動重新開啟）
6. 立即回到 Cursor 執行：
   ```powershell
   flutter clean
   flutter run -d windows
   ```
7. 等待 app 成功啟動後，可以重新開啟即時保護

### 方法 2：將 build 目錄加入排除清單（永久解決）

1. **以管理員身份執行 PowerShell**：
   - 按 Win + X
   - 選擇「Windows PowerShell (系統管理員)」或「終端機 (系統管理員)」

2. **執行以下命令**：
   ```powershell
   Add-MpPreference -ExclusionPath "C:\WorkSpace\zerova_oqc_report\build"
   ```

3. **確認加入成功**：
   ```powershell
   Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
   ```

4. **清理並重新編譯**：
   ```powershell
   cd C:\WorkSpace\zerova_oqc_report
   flutter clean
   flutter run -d windows
   ```

### 方法 3：手動刪除 + 重啟（100% 有效）

1. **完全關閉 Cursor**
2. **重新啟動電腦**
3. **啟動後立即執行**（趁 Windows Defender 還沒開始掃描）：
   ```powershell
   cd C:\WorkSpace\zerova_oqc_report
   Remove-Item -Path "build" -Recurse -Force
   flutter run -d windows
   ```

## 🎯 建議

**如果你經常編譯 Flutter Windows 應用**，強烈建議使用 **方法 2（加入排除清單）**，一次設定永久解決。

## 📝 為什麼會發生這個問題？

- Windows Defender 會掃描新建立的 `.exe` 文件
- `cppwinrt.exe`、`nuget.exe` 等編譯工具會被即時保護鎖定
- Flutter 需要覆寫這些文件但無法存取

## 🔒 安全性說明

將 `build` 目錄加入排除清單是安全的，因為：
- ✅ 這是你自己的編譯輸出目錄
- ✅ 不會影響其他系統保護
- ✅ Flutter 官方文件也有類似建議
- ✅ 只排除本地開發目錄，不是系統目錄

