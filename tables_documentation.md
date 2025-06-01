# OQC報告表格文件說明

本文檔記錄了OQC報告系統中的各個表格文件及其功能。

## 表格文件路徑

所有表格文件位於 `/lib/src/widget/oqc/tables/` 目錄下。

## 表格文件列表

| 文件名稱 | 行數 | 功能說明 |
|---------|-----|---------|
| appearance_structure_inspection_table.dart | 70 | 外觀與結構檢查表格 |
| attachment_table.dart | 74 | 附件表格 |
| basic_function_test_table.dart | 380 | 基本功能測試表格 |
| hipot_test_table.dart | 709 | 耐壓測試表格 |
| input_output_characteristics_table.dart | 829 | 輸入輸出特性表格 |
| model_name_and_serial_number_table.dart | 39 | 型號和序號表格 |
| package_list_table.dart | 177 | 包裝清單表格 |
| protection_function_test_table.dart | 120 | 保護功能測試表格 |
| psu_serial_numbers_table.dart | 107 | PSU序號表格 |
| signature_table.dart | 113 | 簽名表格 |
| software_version.dart | 123 | 軟件版本表格 |

## 表格樣式設定

表格樣式設定主要通過以下文件實現：

1. `/lib/src/widget/common/styled_card.dart` - 定義表格卡片樣式和DataTable的基本樣式
2. `/lib/src/widget/common/table_wrapper.dart` - 定義表格包裝器、表格文字樣式和評判結果顯示方法
3. `/lib/src/widget/common/text_form_field_style.dart` - 定義統一的輸入框樣式
4. `/lib/src/widget/common/oqc_text_field.dart` - 定義帶有外部padding的輸入框組件
5. `/lib/src/widget/common/judgement_dropdown.dart` - 定義統一的評判下拉選擇、文字顯示組件和顯示邏輯

## 表格樣式修改說明

為了實現表格標題居中和改善整體美觀，做了如下修改：

1. 在`StyledDataTable`類中：
   - 添加了`headingTextStyle`設置標題文字樣式
   - 設置`horizontalMargin`為0，移除水平方向的padding
   - 設置`columnSpacing`為0，移除列之間的間距

2. 在`OqcTableStyle.getDataColumn`方法中：
   - 使用`Expanded`和`Center`包裹文字組件
   - 設置`textAlign`為`TextAlign.center`確保文字居中

3. 在`OqcTableStyle.getDataCell`方法中：
   - 添加了`Padding`包裹內容，設置水平方向padding為12像素，垂直方向為8像素
   - 這確保了文字不會貼近表格邊緣，提高了可讀性
   - 將文字對齊方式設置為居中(TextAlign.center)

4. 在`OqcTableStyle`類中添加了`getJudgementCell`方法：
   - 用於顯示評判結果的DataCell
   - 使用`JudgementStyles.getTextStyle`獲取評判結果的樣式
   - 確保評判結果文字居中顯示

5. 在`protection_function_test_table.dart`中：
   - 將第一欄No.使用固定寬度Container包裝，寬度設為80像素
   - 這確保了No.欄有足夠的空間且不會因內容過少而顯得太窄

6. 創建了全局輸入框樣式類`OqcTextFormStyle`：
   - 提供了標準輸入框樣式和唯讀輸入框樣式
   - 設置了適當的內間距：垂直方向10像素，水平方向12像素
   - 添加了圓角邊框和聚焦時的高亮效果

7. 創建了共用輸入框組件`OqcTextField`：
   - 封裝了Flutter原生的TextFormField組件
   - 在外部添加了4像素的padding，避免輸入框與表格邊框重疊
   - 支持自定義控制器、只讀狀態、文字變化回調、提示文字等屬性
   - 默認將文字對齊方式設置為居中(TextAlign.center)
   - 使用統一的樣式，保持整個應用的一致性
   - 已在以下表格中應用：
     - PSU序號表格 (psu_serial_numbers_table.dart)
     - 軟件版本表格 (software_version.dart)
     - 基本功能測試表格 (basic_function_test_table.dart)
     - 耐壓測試表格 (hipot_test_table.dart)

8. 為基本功能測試表格的顯示文字添加居中設置：
   - 所有文字元素的textAlign屬性設置為TextAlign.center
   - 文字所在的Row設置mainAxisAlignment為MainAxisAlignment.center
   - 保持一致的居中視覺效果

9. 為耐壓測試表格進行了全面升級：
   - 將所有TextField替換為OqcTextField組件
   - 為所有顯示文字添加了textAlign: TextAlign.center
   - 保持測試數據顯示的一致性和專業性
   - 改進了表格顯示的整體視覺效果

10. 創建了共用的評判結果相關組件和邏輯：
    - `JudgementStyles` - 工具類，封裝了評判結果的顏色和文字樣式邏輯
    - `JudgementDropdown` - 統一的評判結果下拉選擇，並居中顯示
    - `JudgementText` - 統一的評判結果文字顯示，並居中顯示
    - 這些組件和工具類確保了評判結果顯示的一致性
    - 已在以下表格中應用：
      - 基本功能測試表格 (basic_function_test_table.dart)
      - 耐壓測試表格 (hipot_test_table.dart)

這些修改共同作用，實現了表格標題和內容的居中顯示，解決了輸入框與表格邊框重疊的問題，使整體視覺效果更加美觀、專業和一致性。