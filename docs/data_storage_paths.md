# 資料存放路徑說明文件

本文檔說明 OQC Report 系統中所有資料的存放位置，包括本地存放路徑和 SharePoint 雲端存放路徑。

## 一、本地存放路徑

### 1.1 基礎路徑

系統會根據不同的作業系統，自動建立基礎資料夾：

- **Windows**: `{USERPROFILE}\Pictures\Zerova`
  - 範例：`C:\Users\使用者名稱\Pictures\Zerova`
  
- **macOS**: `{HOME}/Pictures/Zerova`
  - 範例：`/Users/使用者名稱/Pictures/Zerova`
  
- **Linux 或其他系統**: `{HOME}/Pictures/Zerova`
  - 範例：`/home/使用者名稱/Pictures/Zerova`

> **注意**：如果資料夾不存在，系統會自動建立。

### 1.2 本地資料夾結構

所有資料都存放在上述基礎路徑下，結構如下：

```
Zerova/
├── All Photos/                    # 所有測試照片（上傳到 SharePoint）
│   └── {SN}/                      # 以序號 (Serial Number) 命名
│       ├── Packaging/             # 配件包照片
│       └── Attachment/            # 外觀檢查照片
│
├── OQC Report/                    # OQC 報告檔案
│   └── {SN}/                      # 以序號命名
│       └── *.pdf                  # PDF 報告檔案
│
├── Compare Pictures/              # 外觀參考照片（從 SharePoint 下載）
│   └── {Model}/                   # 以型號 (Model) 命名
│       └── *.jpg, *.jpeg, *.png   # 參考照片檔案
│
├── Compare Package Pictures/      # 配件包參考照片（從 SharePoint 下載）
│   └── {Model}/                   # 以型號命名
│       └── *.jpg, *.jpeg, *.png   # 參考照片檔案
│
└── Selected Photos/               # 選取的照片（用於 PDF 報告）
    └── {SN}/                      # 以序號命名
        ├── Packaging/             # 配件包照片
        └── Attachment/            # 外觀檢查照片
```

### 1.3 詳細路徑說明

#### 1.3.1 配件包照片（上傳）
- **路徑**: `{基礎路徑}/All Photos/{SN}/Packaging/`
- **用途**: 存放所有配件包照片，會自動上傳到 SharePoint
- **檔案格式**: `.jpg`, `.jpeg`, `.png`

#### 1.3.2 外觀檢查照片（上傳）
- **路徑**: `{基礎路徑}/All Photos/{SN}/Attachment/`
- **用途**: 存放所有外觀檢查照片，會自動上傳到 SharePoint
- **檔案格式**: `.jpg`, `.jpeg`, `.png`

#### 1.3.3 OQC 報告（上傳）
- **路徑**: `{基礎路徑}/OQC Report/{SN}/`
- **用途**: 存放生成的 PDF 報告，會自動上傳到 SharePoint
- **檔案格式**: `.pdf`

#### 1.3.4 外觀參考照片（下載）
- **路徑**: `{基礎路徑}/Compare Pictures/{Model}/`
- **用途**: 從 SharePoint 下載的參考照片，用於比對檢查
- **下載來源**: SharePoint `Jackalope/外觀參考照片/{Model}/`
- **檔案格式**: `.jpg`, `.jpeg`, `.png`
- **備註**: 如果找不到指定型號的資料夾，會自動使用 `default` 資料夾

#### 1.3.5 配件包參考照片（下載）
- **路徑**: `{基礎路徑}/Compare Package Pictures/{Model}/`
- **用途**: 從 SharePoint 下載的配件包參考照片，用於比對檢查
- **下載來源**: SharePoint `Jackalope/配件包參考照片/{Model}/`
- **檔案格式**: `.jpg`, `.jpeg, `.png`
- **備註**: 如果找不到指定型號的資料夾，會自動使用 `default` 資料夾

#### 1.3.6 選取的照片（PDF 報告用）
- **配件包照片路徑**: `{基礎路徑}/Selected Photos/{SN}/Packaging/`
- **外觀檢查照片路徑**: `{基礎路徑}/Selected Photos/{SN}/Attachment/`
- **用途**: 用於生成 PDF 報告時載入的照片
- **檔案格式**: `.jpg`, `.jpeg`, `.png`

## 二、SharePoint 雲端存放路徑

### 2.1 基礎路徑

所有上傳到 SharePoint 的資料都存放在以下基礎路徑下：
```
Jackalope/
```

### 2.2 SharePoint 資料夾結構

```
Jackalope/
├── Photos/                        # 測試照片
│   └── {SN}/                      # 以序號命名
│       ├── Packaging/             # 配件包照片
│       └── Attachment/            # 外觀檢查照片
│
├── OQC Report/                   # OQC 報告
│   └── {SN}/                      # 以序號命名
│       └── *.pdf                  # PDF 報告檔案
│
├── 外觀參考照片/                  # 外觀參考照片
│   ├── {Model}/                   # 以型號命名
│   └── default/                   # 預設參考照片（當找不到指定型號時使用）
│
└── 配件包參考照片/                # 配件包參考照片
    ├── {Model}/                   # 以型號命名
    └── default/                   # 預設參考照片（當找不到指定型號時使用）
```

### 2.3 詳細路徑說明

#### 2.3.1 配件包照片（SharePoint）
- **完整路徑**: `Jackalope/All Photos/{SN}/Packaging/`
- **對應本地**: `{基礎路徑}/All Photos/{SN}/Packaging/`
- **上傳方式**: 自動上傳所有檔案

#### 2.3.2 外觀檢查照片（SharePoint）
- **完整路徑**: `Jackalope/All Photos/{SN}/Attachment/`
- **對應本地**: `{基礎路徑}/All Photos/{SN}/Attachment/`
- **上傳方式**: 自動上傳所有檔案

#### 2.3.3 OQC 報告（SharePoint）
- **完整路徑**: `Jackalope/OQC Report/{SN}/`
- **對應本地**: `{基礎路徑}/OQC Report/{SN}/`
- **上傳方式**: 自動上傳 PDF 報告

#### 2.3.4 外觀參考照片（SharePoint）
- **完整路徑**: `Jackalope/外觀參考照片/{Model}/`
- **下載目標**: `{基礎路徑}/Compare Pictures/{Model}/`
- **下載方式**: 手動下載或自動下載
- **備註**: 如果找不到指定型號，會自動使用 `Jackalope/外觀參考照片/default/`

#### 2.3.5 配件包參考照片（SharePoint）
- **完整路徑**: `Jackalope/配件包參考照片/{Model}/`
- **下載目標**: `{基礎路徑}/Compare Package Pictures/{Model}/`
- **下載方式**: 手動下載或自動下載
- **備註**: 如果找不到指定型號，會自動使用 `Jackalope/配件包參考照片/default/`

## 三、路徑對應關係表

| 資料類型 | 本地存放路徑 | SharePoint 路徑 | 操作方向 |
|---------|------------|----------------|---------|
| 配件包照片 | `All Photos/{SN}/Packaging/` | `Jackalope/All Photos/{SN}/Packaging/` | 上傳 ⬆️ |
| 外觀檢查照片 | `All Photos/{SN}/Attachment/` | `Jackalope/All Photos/{SN}/Attachment/` | 上傳 ⬆️ |
| OQC 報告 | `OQC Report/{SN}/` | `Jackalope/OQC Report/{SN}/` | 上傳 ⬆️ |
| 外觀參考照片 | `Compare Pictures/{Model}/` | `Jackalope/外觀參考照片/{Model}/` | 下載 ⬇️ |
| 配件包參考照片 | `Compare Package Pictures/{Model}/` | `Jackalope/配件包參考照片/{Model}/` | 下載 ⬇️ |
| PDF 報告用照片 | `Selected Photos/{SN}/Packaging/` 或 `Attachment/` | 無 | 僅本地使用 |

## 四、變數說明

- **{SN}**: Serial Number（序號），例如：`T2449A003A1`
- **{Model}**: Model Name（型號名稱），例如：`Model-ABC-123`
- **{USERPROFILE}**: Windows 使用者資料夾，例如：`C:\Users\使用者名稱`
- **{HOME}**: macOS/Linux 使用者資料夾，例如：`/Users/使用者名稱` 或 `/home/使用者名稱`

## 五、注意事項

1. **自動建立資料夾**: 如果本地資料夾不存在，系統會自動建立。

2. **參考照片預設值**: 當下載參考照片時，如果找不到指定型號的資料夾，系統會自動使用 `default` 資料夾。

3. **檔案格式限制**: 
   - 照片支援格式：`.jpg`, `.jpeg`, `.png`
   - 報告檔案格式：`.pdf`

4. **路徑大小寫**: 
   - Windows 路徑不區分大小寫
   - macOS/Linux 路徑區分大小寫
   - SharePoint 路徑區分大小寫

5. **下載快取機制**: 參考照片下載後會記錄已下載的型號，避免重複下載相同型號的照片。

6. **本地與雲端同步**: 
   - 上傳操作會將本地資料同步到 SharePoint
   - 下載操作會將 SharePoint 資料同步到本地
   - 下載時會先清空舊的參考照片資料夾

## 六、範例

### 範例 1：Windows 系統完整路徑

假設：
- 使用者名稱：`john`
- 序號：`T2449A003A1`
- 型號：`ABC-123`

**配件包照片本地路徑**：
```
C:\Users\john\Pictures\Zerova\All Photos\T2449A003A1\Packaging\
```

**SharePoint 路徑**：
```
Jackalope/All Photos/T2449A003A1/Packaging/
```

### 範例 2：macOS 系統完整路徑

假設：
- 使用者名稱：`john`
- 序號：`T2449A003A1`
- 型號：`ABC-123`

**外觀參考照片本地路徑**：
```
/Users/john/Pictures/Zerova/Compare Pictures/ABC-123/
```

**SharePoint 路徑**：
```
Jackalope/外觀參考照片/ABC-123/
```

---

**最後更新日期**: 2025-01-28  
**文件版本**: 1.0

