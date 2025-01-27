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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlueColor,
  );

  static const contentStyle = TextStyle(
    fontSize: 16,
    color: AppColors.blackColor,
  );
} 