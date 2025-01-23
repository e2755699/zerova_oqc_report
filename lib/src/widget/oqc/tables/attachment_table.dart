import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';

/// 附件表格
class AttachmentTable extends StatelessWidget {
  /// 構造函數
  const AttachmentTable({super.key});

  @override
  Widget build(BuildContext context) {
    return const StyledCard(
      title: 'g. Attachment',
      content: ImageGrid(
        imagePath: 'C:\\Users\\USER\\Pictures\\Attachment',
        rows: 2,
        columns: 4,
        cellHeight: 100,
      ),
    );
  }
}
