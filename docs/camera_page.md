# Camera Page 實作說明

## 功能概述
`camera_page.dart` 主要實現了相機拍攝和照片比對的功能，使用者可以根據參考照片（比對照片）來拍攝或選擇對應的實際照片。

## 核心元件說明

### 1. CompareImageService

#### 功能
管理比對照片和實際照片之間的對應關係，使用 Firebase Firestore 作為儲存後端。

#### 資料結構
```dart
// Firestore Document 結構
{
  'model': String,  // 產品型號
  'sn': String,     // 序號
  'mappings': {     // 照片對應關係
    'compareImagePath1': 'actualImagePath1',
    'compareImagePath2': 'actualImagePath2',
    ...
  },
  'updatedAt': Timestamp  // 最後更新時間
}
```

#### 主要方法
1. **loadImageMappings**
   ```dart
   Future<Map<String, String>> loadImageMappings(String model, String sn)
   ```
   載入特定型號和序號的照片對應關係。

2. **saveImageMappings**
   ```dart
   Future<void> saveImageMappings(
     String model, 
     String sn, 
     Map<String, String> mappings
   )
   ```
   儲存整個對應關係映射。

3. **updateImageMapping**
   ```dart
   Future<void> updateImageMapping(
     String model,
     String sn,
     String compareImagePath,
     String? actualImagePath
   )
   ```
   更新單一照片對應關係。

4. **areAllImagesMapped**
   ```dart
   Future<bool> areAllImagesMapped(
     String model,
     String sn,
     List<String> compareImagePaths
   )
   ```
   檢查是否所有比對照片都有對應的實際照片。

### 2. 照片選擇和更新流程

當使用者選擇新照片時的處理流程：

1. **檢查舊照片**
   - 獲取當前比對照片對應的舊照片路徑
   - 檢查是否有其他比對照片正在使用這張舊照片

2. **刪除舊照片**
   - 如果舊照片不再被其他比對照片使用，則從 Selected Photos 資料夾中刪除

3. **更新對應關係**
   - 在 Firebase 中更新新的對應關係
   - 同時更新本地狀態 (_pickedPhotoMap)

4. **儲存新照片**
   - 將新選擇的照片複製到本地的 Selected Photos 資料夾

### 3. UI 實作

#### 照片顯示
```dart
child: _pickedPhotoMap[_selectedImagePath] != null
    ? Image.file(
        File(_pickedPhotoMap[_selectedImagePath]!),
        fit: BoxFit.contain,
      )
    : Center(child: Text(context.tr('no_photo_selected'))),
```

#### 照片選擇狀態顯示
在下拉選單中顯示每張比對照片的選擇狀態：
```dart
final hasPicked = _pickedPhotoMap[path] != null;
// 如果已選擇，顯示綠色勾選圖示
if (hasPicked)
  const Icon(Icons.check_circle, color: Colors.green, size: 18)
```

## 資料夾結構

### 照片儲存路徑
- **All Photos**: 存放所有拍攝的照片
- **Selected Photos**: 存放最終選擇使用的照片
- **Compare Pictures**: 存放比對用的標準照片

## 注意事項

1. 照片對應關係現在使用 Firebase Firestore 儲存，collection 名稱為 `compare_image_mappings`
2. 每個 model 和 sn 組合會有一個獨立的 document
3. 刪除舊照片時會檢查是否還有其他比對照片在使用，避免誤刪
4. 所有照片操作都會同時更新本地檔案系統和 Firebase
5. 離開頁面時會檢查是否所有比對照片都已經有對應的實際照片

## 未來優化建議

1. 可以考慮為每張比對照片建立預設的對應關係
2. 可以加入照片預處理功能（如壓縮、裁剪等）
3. 可以加入照片比對的自動化檢查功能
4. 可以考慮加入離線支援，在沒有網路連接時使用本地快取
5. 可以加入批次上傳功能，減少網路請求次數