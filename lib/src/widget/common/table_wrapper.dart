import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:easy_localization/easy_localization.dart';

class TableWrapper extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? titleAction;

  const TableWrapper({
    super.key,
    required this.title,
    required this.content,
    this.titleAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: StyledCard(
          title: title,
          titleAction: titleAction,
          content: content,
        ),
      ),
    );
  }
}

class TableTextStyle {
  static TextStyle getLocalizedStyle(BuildContext context,
      {bool isHeader = false}) {
    // 根據當前語言選擇合適的字體
    String fontFamily;
    switch (context.locale.languageCode) {
      case 'zh':
        fontFamily = 'Noto Sans TC';
        break;
      case 'ja':
        fontFamily = 'Noto Sans JP';
        break;
      case 'vi':
        fontFamily = 'Noto Sans Vietnamese';
        break;
      default:
        fontFamily = 'Roboto';
    }

    return TextStyle(
      fontSize: isHeader ? 20 : 16,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? AppColors.darkBlueColor : AppColors.blackColor,
      fontFamily: fontFamily,
    );
  }

  static TextStyle headerStyle(BuildContext context) =>
      getLocalizedStyle(context, isHeader: true);
  static TextStyle contentStyle(BuildContext context) =>
      getLocalizedStyle(context, isHeader: false);
}

class OqcTableStyle {
  static DataColumn getDataColumn(String text, BuildContext context) {
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.center,
      label: Text(
        text,
        style: TableTextStyle.headerStyle(context),
      ),
    );
  }

  static DataCell getDataCell(String text, BuildContext context,
      {MaterialColor? color, FontWeight? fontWeight}) {
    return DataCell(Text(
      text,
      style: TableTextStyle.contentStyle(context).copyWith(
        color: color,
        fontWeight: fontWeight,
      ),
    ));
  }
}
