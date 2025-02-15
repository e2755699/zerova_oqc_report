import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/report/enum/judgement.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';

mixin TableHelper {
  Judgement getJudgementFromString(String judgement) {
    switch (judgement.toLowerCase()) {
      case 'pass':
        return Judgement.pass;
      case 'fail':
        return Judgement.fail;
      default:
        return Judgement.unknown;
    }
  }

  String updateJudgement(Judgement judgement) {
    return judgement.toString().split('.').last.toUpperCase();
  }

  Widget buildJudgementDropdown(
      String currentJudgement, Function(Judgement?) onChanged) {
    return DropdownButton<Judgement>(
      value: getJudgementFromString(currentJudgement),
      items: Judgement.values.map((Judgement value) {
        return DropdownMenuItem<Judgement>(
          value: value,
          child: Text(
            value.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              fontSize: TableTextStyle.contentStyle.fontSize,
              color: value == Judgement.pass
                  ? Colors.green
                  : value == Judgement.fail
                      ? Colors.red
                      : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
