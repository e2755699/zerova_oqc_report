import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static TextStyle getLocalizedStyle({bool isHeader = false}) {
    // 根据当前语言选择合适的字体
    TextStyle baseStyle = GoogleFonts.notoSans();

    return baseStyle.copyWith(
      fontSize: isHeader ? 20 : 16,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? AppColors.darkBlueColor : AppColors.blackColor,
    );
  }

  static TextStyle headerStyle() => getLocalizedStyle(isHeader: true);
  static TextStyle contentStyle() => getLocalizedStyle(isHeader: false);
}

class OqcTableStyle {
  static DataColumn getDataColumn(String text) {
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.center,
      label: Text(
        text,
        style: TableTextStyle.headerStyle(),
      ),
    );
  }

  static DataCell getDataCell(String text,
      {MaterialColor? color, FontWeight? fontWeight}) {
    return DataCell(Text(
      text,
      style: TableTextStyle.contentStyle().copyWith(
        color: color,
        fontWeight: fontWeight,
      ),
    ));
  }
}
