import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zerova_oqc_report/src/widget/common/text_form_field_style.dart';

/// 共用的TextField組件，外部添加padding避免與表格邊框重疊
class OqcTextField extends StatelessWidget {
  /// 控制器
  final TextEditingController? controller;
  
  /// 是否只讀
  final bool readOnly;
  
  /// 文字改變回調
  final ValueChanged<String>? onChanged;
  
  /// 提示文字
  final String? hintText;
  
  /// 輸入格式限制
  final List<TextInputFormatter>? inputFormatters;
  
  /// 鍵盤類型
  final TextInputType? keyboardType;

  /// 外部padding
  final EdgeInsetsGeometry padding;
  
  /// 初始值
  final String? initialValue;
  
  /// 文字對齊方式
  final TextAlign textAlign;

  const OqcTextField({
    super.key,
    this.controller,
    this.readOnly = false,
    this.onChanged,
    this.hintText,
    this.inputFormatters,
    this.keyboardType,
    this.padding = const EdgeInsets.all(4.0),
    this.initialValue,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        initialValue: initialValue,
        textAlign: textAlign,
        decoration: readOnly 
            ? OqcTextFormStyle.getReadOnlyInputDecoration(hintText: hintText)
            : OqcTextFormStyle.getInputDecoration(hintText: hintText),
      ),
    );
  }
} 