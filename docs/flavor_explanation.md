# Flavor 參數說明

## 為什麼需要 `--dart-define`？

### 問題背景

**Flutter Dart 代碼** 需要一個統一的方式來傳遞構建時參數，因為：
- Dart 代碼是跨平台的（Android、iOS、Windows 等）
- 不同平台的 flavor 機制不同
- Flutter 需要一個統一的方式來傳遞構建時參數

### 解決方案

Flutter 提供了 `--dart-define` 來在構建時將參數傳遞給 Dart 代碼：

```bash
flutter build apk --dart-define=FLAVOR=tw
flutter build windows --dart-define=FLAVOR=vn
```

**注意**: 
- 只需要使用 `--dart-define=FLAVOR=tw` 或 `--dart-define=FLAVOR=vn` 即可
- Android 的 `build.gradle` 中仍然定義了 flavor（用於設定 applicationId），但 Flutter 建置時只需要 `--dart-define`
- Windows 平台不支援 `--flavor` 參數，只需要 `--dart-define`

## 簡化方案

雖然需要指定兩次，但我們可以：

### 使用 PowerShell 腳本（推薦）

已建立 `build_tw.ps1` 和 `build_vn.ps1`：

```powershell
# build_tw.ps1
flutter build windows --dart-define=FLAVOR=tw --release
```

```powershell
# build_vn.ps1
flutter build windows --dart-define=FLAVOR=vn --release
```

### 使用 alias（開發時）

在 `.bashrc` 或 `.zshrc` 中：
```bash
alias flutter-build-tw='flutter build windows --dart-define=FLAVOR=tw'
alias flutter-build-vn='flutter build windows --dart-define=FLAVOR=vn'
```

## 總結

- **`--dart-define`**: 給 Flutter/Dart 代碼用的，跨平台統一使用
- 只需要指定 `--dart-define=FLAVOR=tw` 或 `--dart-define=FLAVOR=vn` 即可
- Android 的 `build.gradle` 中定義的 flavor 主要用於設定 applicationId，Flutter 建置時不需要 `--flavor` 參數
- Windows 平台不支援 `--flavor` 參數

