import 'package:zerova_oqc_report/src/report/enum/judgement.dart';

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
} 