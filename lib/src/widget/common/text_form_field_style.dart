import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

/// 統一的輸入框樣式類
class OqcTextFormStyle {
  /// 獲取標準輸入框樣式
  static InputDecoration getInputDecoration({String? hintText}) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      hintText: hintText,
    );
  }

  /// 獲取只讀輸入框樣式
  static InputDecoration getReadOnlyInputDecoration({String? hintText}) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: Colors.grey[100],
      hintText: hintText,
      enabled: false,
    );
  }
} 