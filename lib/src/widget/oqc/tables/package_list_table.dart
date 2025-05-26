import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/widget/common/camera_button.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';
import 'package:zerova_oqc_report/src/repo/sharepoint_uploader.dart';
import 'package:zerova_oqc_report/src/widget/common/global_state.dart';

class PackageListTable extends StatelessWidget {
  final String sn;
  final PackageListResult data;

  const PackageListTable(this.data, {super.key, required this.sn});

  List<String> get headers => data.header;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: globalEditModeNotifier,
      builder: (context, editMode, _) {
        return ValueListenableBuilder<int>(
          valueListenable: permissions,
          builder: (context, permission, _) {
            final isEditable = editMode == 1 && (permission == 1 || permission == 2);
            final isHeaderEditable = editMode == 1 && permission == 1;
            return TableWrapper(
              title: context.tr('package_list'),
              titleAction: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cloud_download),
                    tooltip: 'Download to SharePoint',
                    onPressed: () {
                      SharePointUploader(uploadOrDownload: 2, sn: sn).startAuthorization(
                        categoryTranslations: {
                          "packageing_photo": "Packageing Photo ",
                        },
                      );
                    },
                  ),
                  CameraButton(
                    sn: sn,
                    packagingOrAttachment: 0,
                  ),
                ],
              ),
              content: Column(
                children: [
                  Table(
                    border: TableBorder.all(color: AppColors.lightBlueColor),
                    children: [
                      TableRow(
                        children: headers
                            .map((header) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text(header)),
                        ))
                            .toList(),
                      ),
                      ...data.datas.asMap().entries.map((entry) {
                        return TableRow(
                          children: [
                            // No.
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text('${entry.key + 1}')),
                            ),
                            // Item
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: isHeaderEditable
                                    ? TextFormField(
                                  initialValue: entry.value.translationKey.tr(),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onChanged: (val) {
                                    entry.value.translationKey = val; // 確保這個屬性是可寫的
                                  },
                                )
                                    : Text(entry.value.translationKey.tr()),
                              ),
                            ),

                            // Q'ty
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: isHeaderEditable
                                    ? SizedBox(
                                  width: 120, // 你可以調整這個寬度
                                  height: 36,
                                  child: TextFormField(
                                    initialValue: entry.value.spec.toString(),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      final parsed = int.tryParse(val);
                                      if (parsed != null) {
                                        entry.value.spec = parsed;
                                      }
                                    },
                                  ),
                                )
                                    : Text(entry.value.spec.toString()),
                              ),
                            ),
                            // Checkbox
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: ValueListenableBuilder(
                                  key: GlobalKey(debugLabel: 'checkbox_${entry.value.key}'),
                                  valueListenable: entry.value.isCheck,
                                  builder: (context, value, _) => Checkbox(
                                    value: value,
                                    onChanged: (isCheck) {
                                      entry.value.toggle();
                                    },
                                    activeColor: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ImageGrid(
                    imagePath: 'Selected Photos\\$sn\\Packaging',
                    columns: 4,
                    cellHeight: 100,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<pw.ImageProvider?> imageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
    return null;
  }
}
