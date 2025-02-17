import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zerova_oqc_report/src/report/model/package_list_result.dart';
import 'package:zerova_oqc_report/src/widget/common/camera_button.dart';
import 'package:zerova_oqc_report/src/widget/common/styled_card.dart';
import 'package:zerova_oqc_report/src/widget/common/image_grid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:zerova_oqc_report/src/widget/common/table_wrapper.dart';

class PackageListTable extends StatelessWidget {
  final String sn;
  final PackageListResult data;

  const PackageListTable(this.data, {super.key, required this.sn});

  List<String> get headers => data.header;

  @override
  Widget build(BuildContext context) {
    return TableWrapper(
      title: 'Packaging Checklist',
      titleAction: CameraButton(
        sn: sn,
        packagingOrAttachment: 0,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text('${entry.key + 1}')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Center(child: Text(entry.value.translationKey.tr())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text(entry.value.spec.toString())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: ValueListenableBuilder(
                          key: GlobalKey(
                              debugLabel: 'checkbox_${entry.value.key}'),
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
