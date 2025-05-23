import 'package:flutter/material.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:zerova_oqc_report/src/widget/common/camera_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:zerova_oqc_report/src/report/spec/input_output_characteristics_spec.dart';
import 'package:zerova_oqc_report/src/report/spec/hipot_test_spec.dart';

/// 附件表格
class AttachmentTable extends StatelessWidget {
  final String sn;

  const AttachmentTable({
    super.key,
    required this.sn,
  });
 /* void someFunction() {
    if (globalInputOutputSpec != null) {
      print(globalInputOutputSpec!.vin);
      print(globalInputOutputSpec!.iin);
      print(globalInputOutputSpec!.pin);
      print(globalInputOutputSpec!.vout);
      print(globalInputOutputSpec!.iout);
      print(globalInputOutputSpec!.pout);
    } else {
      print('資料還沒載入');
    }
  }*/
  void someFunction() {
    if (globalInputOutputSpec != null) {
      print(globalHipotTestSpec!.insulationimpedancespec);
      print(globalHipotTestSpec!.leakagecurrentspec);
    } else {
      print('資料還沒載入');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: context.tr('attachment'),
      titleAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Download to SharePoint',
            onPressed: () {
              //someFunction();
              SharePointUploader(uploadOrDownload: 3, sn: sn).startAuthorization(
                categoryTranslations: {
                  //"packageing_photo": "Packageing Photo ",
                  "appearance_photo": "Appearance Photo ",
                  //"oqc_report": "OQC Report ",
                },
              );
            },
          ),
          CameraButton(
            sn: sn,
            packagingOrAttachment: 1,
          ),
        ],
      ),
      content: ImageGrid(
        imagePath: 'Selected Photos\\$sn\\Attachment',
        columns: 4,
        cellHeight: 100,
      ),
    );
  }
}
