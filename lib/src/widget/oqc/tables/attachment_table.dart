import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:zerova_oqc_report/src/widget/common/camera_button.dart';
import 'package:easy_localization/easy_localization.dart';

/// 附件表格
class AttachmentTable extends StatefulWidget {
  final String sn;

  const AttachmentTable({
    super.key,
    required this.sn,
  });

  @override
  State<AttachmentTable> createState() => _AttachmentTableState();
}

class _AttachmentTableState extends State<AttachmentTable> {
  @override
  Widget build(BuildContext context) {
    return StyledCard(
      title: context.tr('attachment'),
      titleAction: CameraButton(
        sn: widget.sn,
        packagingOrAttachment: 1,
        callBack: () {
          setState(() {});
        },
      ),
      content: ImageGrid(
        imagePath: 'Selected Photos/${widget.sn}/Attachment',
        columns: 4,
        cellHeight: 100,
      ),
    );
  }
}
