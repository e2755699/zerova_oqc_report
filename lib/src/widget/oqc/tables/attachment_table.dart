import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';

/// 附件表格
class AttachmentTable extends StatelessWidget {
  /// 構造函數
  const AttachmentTable({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      title: 'g. Attachment',
      content: Table(
        border: TableBorder.all(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(1),  // No.
          1: FlexColumnWidth(3),  // Item
          2: FlexColumnWidth(1),  // Qty
          3: FlexColumnWidth(2),  // Remark
        },
        children: List.generate(8, (index) {
          return TableRow(
            children: [
              _buildCell('${index + 1}'),
              _buildCell(''),  // Item 欄位
              _buildCell(''),  // Qty 欄位
              _buildCell(''),  // Remark 欄位
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  /// 生成 PDF 表格數據
  List<List<String>> toPdfTable() {
    final rows = <List<String>>[];

    // 添加數據行
    for (int i = 0; i < 8; i++) {
      rows.add([
        '${i + 1}',
        '', // Item
        '', // Qty
        '', // Remark
      ]);
    }

    return rows;
  }
}
