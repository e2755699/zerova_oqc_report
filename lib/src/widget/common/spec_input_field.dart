import 'package:flutter/material.dart';

/// 規格輸入欄位的共用組件
/// 用於統一管理所有規格頁面中的數值輸入欄位
class SpecInputField extends StatelessWidget {
  /// 欄位標籤
  final String label;

  /// 單位文字（顯示在輸入框右側）
  final String? unit;

  /// 文字控制器
  final TextEditingController controller;

  /// 欄位寬度（可選）
  final double? width;

  /// 是否為必填欄位
  final bool isRequired;

  /// 提示文字
  final String? hintText;

  /// 是否啟用
  final bool enabled;

  /// 值變更回調
  final ValueChanged<String>? onChanged;

  /// 輸入驗證
  final String? Function(String?)? validator;

  const SpecInputField({
    super.key,
    required this.label,
    required this.controller,
    this.unit,
    this.width,
    this.isRequired = false,
    this.hintText,
    this.enabled = true,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: _buildLabel(),
          hintText: hintText,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixText: unit,
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[100],
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
      ),
    );
  }

  /// 構建標籤文字（包含必填標記）
  String _buildLabel() {
    if (isRequired) {
      return '$label *';
    }
    return label;
  }
}

/// 帶有標籤的規格輸入欄位組件
/// 適用於需要左側標籤的場景
class LabeledSpecInputField extends StatelessWidget {
  /// 左側標籤文字
  final String label;

  /// 標籤寬度
  final double labelWidth;

  /// 單位文字
  final String? unit;

  /// 文字控制器
  final TextEditingController controller;

  /// 是否為必填欄位
  final bool isRequired;

  /// 提示文字
  final String? hintText;

  /// 是否啟用
  final bool enabled;

  /// 值變更回調
  final ValueChanged<String>? onChanged;

  const LabeledSpecInputField({
    super.key,
    required this.label,
    required this.controller,
    this.labelWidth = 150,
    this.unit,
    this.isRequired = false,
    this.hintText,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            _buildLabel(),
            style: TextStyle(
              fontWeight: isRequired ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: SpecInputField(
            label: '', // 不顯示標籤，因為已經在左側顯示了
            controller: controller,
            unit: unit,
            hintText: hintText,
            enabled: enabled,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// 構建標籤文字（包含必填標記）
  String _buildLabel() {
    if (isRequired) {
      return '$label *';
    }
    return label;
  }
}

/// 範圍輸入欄位組件（下限-上限）
/// 適用於需要輸入數值範圍的場景
class RangeSpecInputField extends StatelessWidget {
  /// 欄位標籤
  final String label;

  /// 單位文字
  final String? unit;

  /// 下限控制器
  final TextEditingController lowerController;

  /// 上限控制器
  final TextEditingController upperController;

  /// 是否為必填欄位
  final bool isRequired;

  /// 是否啟用
  final bool enabled;

  /// 下限變更回調
  final ValueChanged<String>? onLowerChanged;

  /// 上限變更回調
  final ValueChanged<String>? onUpperChanged;

  const RangeSpecInputField({
    super.key,
    required this.label,
    required this.lowerController,
    required this.upperController,
    this.unit,
    this.isRequired = false,
    this.enabled = true,
    this.onLowerChanged,
    this.onUpperChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _buildLabel(),
          style: TextStyle(
            fontWeight: isRequired ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SpecInputField(
                label: '下限',
                controller: lowerController,
                unit: unit,
                enabled: enabled,
                onChanged: onLowerChanged,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              '~',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SpecInputField(
                label: '上限',
                controller: upperController,
                unit: unit,
                enabled: enabled,
                onChanged: onUpperChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 構建標籤文字（包含必填標記）
  String _buildLabel() {
    if (isRequired) {
      return '$label *';
    }
    return label;
  }
}

/// 規格輸入欄位的工具類
/// 提供常用的驗證和格式化方法
class SpecInputUtils {
  /// 數值驗證器
  static String? numberValidator(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return '此欄位為必填';
    }

    if (value != null && value.isNotEmpty) {
      final number = double.tryParse(value);
      if (number == null) {
        return '請輸入有效的數值';
      }
      if (number < 0) {
        return '數值不能為負數';
      }
    }

    return null;
  }

  /// 範圍驗證器
  static String? rangeValidator(String? lowerValue, String? upperValue) {
    if (lowerValue != null &&
        upperValue != null &&
        lowerValue.isNotEmpty &&
        upperValue.isNotEmpty) {
      final lower = double.tryParse(lowerValue);
      final upper = double.tryParse(upperValue);

      if (lower != null && upper != null && lower >= upper) {
        return '下限值必須小於上限值';
      }
    }

    return null;
  }

  /// 格式化數值顯示
  static String formatNumber(double value, {int decimalPlaces = 2}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  /// 從文字控制器獲取數值
  static double? getNumberFromController(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  /// 設置控制器的數值
  static void setControllerNumber(
      TextEditingController controller, double? value) {
    if (value != null) {
      controller.text = formatNumber(value);
    } else {
      controller.clear();
    }
  }
}
