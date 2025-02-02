import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

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
        width: MediaQuery.of(context).size.width * 0.9,
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
  static const headerStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlueColor,
  );

  static const contentStyle = TextStyle(
    fontSize: 16,
    color: AppColors.blackColor,
  );
}

class OqcTableStyle {
  static getDataColumn(
    String text,
  ) {
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.center,
      label: Text(
        text,
        style: TableTextStyle.headerStyle,
      ),
    );
  }

  static getDataCell(String text, {MaterialColor? color,  FontWeight? fontWeight}) {
    return DataCell(Text(
      text,
      style: TableTextStyle.contentStyle.copyWith(color: color, fontWeight: fontWeight)
    ));
  }
}
