import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zerova_oqc_report/src/utils/window_size_manager.dart';

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
    // 基本字體大小
    var fontSize = 14.0;

    // 根據視窗比例調整字體大小
    fontSize *= WindowSizeManager.getFontSizeMultiplier();

    return GoogleFonts.notoSans().copyWith(
      fontSize: fontSize,
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
    return DataCell(
      Center(
        child: Text(
          text,
          style: TableTextStyle.contentStyle().copyWith(
            color: color,
            fontWeight: fontWeight,
          ),
          textAlign: TextAlign.start,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  static DataRow getDataRow(List<DataCell> cells) {
    return DataRow(
      cells: cells,
    );
  }

  static StyledDataTable getStyledDataTable({
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return StyledDataTable(
      dataRowMinHeight: 48,
      dataRowMaxHeight: double.infinity,
      columns: columns,
      rows: rows,
    );
  }
}
