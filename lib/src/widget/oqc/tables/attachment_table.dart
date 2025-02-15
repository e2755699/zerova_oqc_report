import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:zerova_oqc_report/src/widget/common/camera_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';

/// 附件表格
class AttachmentTable extends StatelessWidget {
  final String sn;

  const AttachmentTable({
    super.key,
    required this.sn,
  });

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: context.tr('attachment'),
      titleAction: CameraButton(
        sn: sn,
        packagingOrAttachment: 1,
      ),
      content: ImageGrid(
        imagePath: 'Selected Photos\\$sn\\Attachment',
        columns: 4,
        cellHeight: 100,
      ),
    );
  }
}
