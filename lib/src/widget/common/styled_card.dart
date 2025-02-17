import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF008999); // 綠藍色
  static const blackColor = Color(0xFF000000); // 黑色
  static const grayColor = Color(0xFF808080); // 灰色
  static const darkBlueColor = Color(0xFF002361); // 深藍色
  static const cyanColor = Color(0xFF008999); // 青色
  static const lightBlueColor = Color(0xFFA7D0E6); // 淺藍色
  static const fabColor = Color(0xFFF8F9FD);
}

class StyledCard extends StatelessWidget {
  final String title;
  final Widget? titleAction;
  final Widget content;

  const StyledCard({
    super.key,
    required this.title,
    this.titleAction,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.primaryColor,
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.lightBlueColor,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlueColor,
                    ),
                  ),
                  if (titleAction != null) titleAction!,
                ],
              ),
            ),
            const SizedBox(height: 24),
            content,
          ],
        ),
      ),
    );
  }
}

class StyledDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  final double? dataRowMinHeight;
  final double? dataRowMaxHeight;

  const StyledDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.dataRowMinHeight,
    this.dataRowMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 1024,
        child: DataTable(
          dataRowMinHeight: dataRowMinHeight,
          // 设置数据行的最小高度
          dataRowMaxHeight: dataRowMaxHeight,
          // 设置数据行的最大高度
          border: TableBorder.all(
            color: AppColors.lightBlueColor,
            width: 1,
          ),
          headingRowColor:
              WidgetStateProperty.all(AppColors.primaryColor.withOpacity(0.1)),
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}
