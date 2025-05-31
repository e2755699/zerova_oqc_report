import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';

/// Judgement評判結果相關的顯示邏輯工具類
class JudgementStyles {
  /// 根據評判結果獲取對應的顏色
  static Color getColorByJudgement(Judgement judgement) {
    switch (judgement) {
      case Judgement.pass:
        return Colors.green;
      case Judgement.fail:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// 獲取評判結果的文字樣式
  static TextStyle getTextStyle(Judgement judgement) {
    return TextStyle(
      color: getColorByJudgement(judgement),
      fontWeight: FontWeight.bold,
    );
  }
}

/// 共用的評判下拉選擇組件
class JudgementDropdown extends StatelessWidget {
  /// 當前選中的評判結果
  final Judgement value;
  
  /// 變更時的回調
  final ValueChanged<Judgement?> onChanged;

  const JudgementDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<Judgement>(
        value: value,
        items: Judgement.values.map((j) => DropdownMenuItem(
          value: j,
          child: Text(
            j.name.toUpperCase(),
            style: JudgementStyles.getTextStyle(j),
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

/// 共用的評判顯示文字組件
class JudgementText extends StatelessWidget {
  /// 評判結果
  final Judgement judgement;

  const JudgementText({
    super.key,
    required this.judgement,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        judgement.name.toUpperCase(),
        style: JudgementStyles.getTextStyle(judgement),
        textAlign: TextAlign.center,
      ),
    );
  }
} 